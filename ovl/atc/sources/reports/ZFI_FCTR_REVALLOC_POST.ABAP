----------------------------------------------------------------------------------------------------
Main program     ZFI_FCTR_REVALLOC_POST                    Level 0    Page 1
Object           ZFI_FCTR_REVALLOC_POST                    Lines 285
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_FCTR_REVALLOC_POST
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8      REPORT ZFI_FCTR_REVALLOC_POST.
9
10     INCLUDE ZFI_FCTR_REVALLOC_DD.
11     INCLUDE ZFI_FCTR_REVALLOC_SS.
12     INCLUDE ZFI_FCTR_REVALLOC_FR.
13
14     INITIALIZATION.
15
16     AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PERIOD-HIGH.
17       PERFORM F_MONTH_HELP1.
18
19     AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR-LOW.
20       PERFORM S_KOKR_HELP.
21
22     AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR-HIGH.
23       PERFORM S_KOKR_HELP.
24
25     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR1-LOW.
26     *  PERFORM S_KOKR_HELP.
27     *
28     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR1-HIGH.
29     *  PERFORM S_KOKR_HELP.
30     *
31     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR2-LOW.
32     *  PERFORM S_KOKR_HELP.
33     *
34     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR2-HIGH.
35     *  PERFORM S_KOKR_HELP.
36     *
37     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR3-LOW.
38     *  PERFORM S_KOKR_HELP.
39     *
40     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR3-HIGH.
41     *  PERFORM S_KOKR_HELP.
42
43     AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PSPID-LOW.
44       PERFORM S_PSPID_HELP.
45
46     AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PSPID-HIGH.
47       PERFORM S_PSPID_HELP.
48
49     AT SELECTION-SCREEN.
50
51       IF ( S_PERIOD-LOW EQ '01' AND S_PERIOD-HIGH EQ '03' ) OR ( S_PERIOD-LOW EQ '04' AND S_PERIOD-HIGH EQ '06' )
52         OR ( S_PERIOD-LOW EQ '07' AND S_PERIOD-HIGH EQ '09' ) OR ( S_PERIOD-LOW EQ '10' AND S_PERIOD-HIGH EQ '12' ).
53       ELSE.
54
55         MESSAGE 'Please enter correct Quarter' TYPE 'E'.
56
57       ENDIF.
58
59
60
61       IF P_YEAR IS NOT INITIAL AND  S_PERIOD-HIGH IS NOT INITIAL.
62
63         P_POPER = S_PERIOD-HIGH.
64
65         CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
66           EXPORTING
67             I_GJAHR        = P_YEAR
68     *       I_MONMIT       = 00
69             I_PERIV        = 'V3'
70             I_POPER        = P_POPER
71           IMPORTING
72             E_DATE         = P_BUDAT
73           EXCEPTIONS
74             INPUT_FALSE    = 1
75             T009_NOTFOUND  = 2
76             T009B_NOTFOUND = 3
77             OTHERS         = 4.
78         IF SY-SUBRC <> 0.
79     * Implement suitable error handling here
80         ENDIF.
81
82       ENDIF.
83
84
85
86     ** Added by ss on 9.6.21
87       IF SSCRFIELDS-UCOMM = 'ONLI'.
88
89     *    IF S_PERIOD-HIGH = '03'.
90
91           IF S_SENM-LOW IS INITIAL AND S_KOKR IS INITIAL.
92             MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
93           ELSE.
94             IF S_SENM-LOW IS  NOT INITIAL.  " Check for Cost Center Group
95               SELECT SINGLE SETNAME
96                      FROM SETLEAF INTO @DATA(WA_TAB) WHERE SETNAME EQ @S_SENM-LOW.
97               IF SY-SUBRC NE 0.
98                 MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
99               ENDIF.
100            ELSEIF S_KOKR IS NOT INITIAL.  " check Values for Cost Centre
101              LOOP AT S_KOKR.
102                SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL_RS) WHERE KOSTL EQ @S_KOKR-LOW.
103                IF SY-SUBRC NE 0.
104                  MESSAGE 'Please enter correct Values for Cost Center' TYPE  'E'.
105                ENDIF.
106              ENDLOOP.
107
108            ENDIF.  " (Cost center check )
109          ENDIF. " ( Cost Center values initial or not )
110
111
112          IF S_SECLS-LOW IS INITIAL AND S_KTOP IS INITIAL.
113            MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
114          ELSE.
115            IF S_SECLS-LOW IS  NOT INITIAL. " check for cost Element group
116              SELECT SINGLE SETNAME
117                    FROM SETLEAF INTO @DATA(LV_SETNAME) WHERE SETNAME EQ @S_SECLS-LOW.
118              IF SY-SUBRC NE 0.
119                MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
120              ENDIF.
121            ELSEIF S_KTOP IS NOT INITIAL.   " values for Cost Element
122                LOOP AT S_KTOP.
123                  SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP_EQ) WHERE KSTAR EQ @S_KTOP-LOW.
124                  IF SY-SUBRC NE 0.
125                    MESSAGE 'Please enter correct Values of Cost Element' TYPE 'E'.
126                  ENDIF.
127                ENDLOOP.
128
129            ENDIF. " ( Cost Element check  )
130          ENDIF. " ( Cost Element is not initial )
131
132
133    *    ELSEIF S_PERIOD-HIGH  = '06'.
134    *
135    *      IF S_SENM1-LOW IS INITIAL AND S_KOKR1 IS INITIAL.
136    *        MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
137    *      ELSE.
138    *        IF S_SENM1-LOW IS  NOT INITIAL.  " Check for Cost Center Group
139    *          SELECT SINGLE SETNAME
140    *                FROM SETLEAF INTO @DATA(WA_TAB1) WHERE SETNAME EQ @S_SENM1-LOW.
141    *          IF SY-SUBRC NE 0.
142    *            MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
143    *          ENDIF.
144    *
145    *        ELSEIF S_KOKR1 IS NOT INITIAL.  " check for value for cost center.
146    *          LOOP AT S_KOKR1.
147    *            SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL1_RS) WHERE KOSTL EQ @S_KOKR1-LOW.
148    *            IF SY-SUBRC NE 0.
149    *              MESSAGE 'Please enter correct value for Cost Center' TYPE  'E'.
150    *            ENDIF.
151    *          ENDLOOP.
152    *
153    *        ENDIF.  " ( Check for Cost Center values)
154    *      ENDIF.  " (Check if cost center is initial )
155    *
156    *
157    *      IF S_SECLS1-LOW IS INITIAL AND S_KTOP1 IS INITIAL.  " Check for Cost Element
158    *        MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
159    *      ELSE.
160    *        IF S_SECLS1-LOW IS  NOT INITIAL.  " Check for Cost element group
161    *          SELECT SINGLE SETNAME
162    *                FROM SETLEAF INTO @DATA(LV_SETNAME1) WHERE SETNAME EQ @S_SECLS1-LOW.
163    *          IF SY-SUBRC NE 0.
164    *            MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
165    *          ENDIF.
166    *        ELSEIF S_KTOP1 IS NOT INITIAL.  " Check value for cost element
167    *            LOOP AT S_KTOP1.
168    *              SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP1_EQ) WHERE KSTAR EQ @S_KTOP1-LOW.
169    *              IF SY-SUBRC NE 0.
170    *                MESSAGE 'Please enter correct values of Cost Element' TYPE 'E'.
171    *              ENDIF.
172    *            ENDLOOP.
173    *
174    *          ENDIF.  " ( Check Cost Element)
175    *        ENDIF. " ( Check for cost Element is initial)
176    *
177    *    ELSEIF S_PERIOD-HIGH  = '09'.
178    *
179    *      IF S_SENM2-LOW IS INITIAL AND S_KOKR2 IS INITIAL. " Cost center check
180    *        MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
181    *      ELSE.
182    *        IF S_SENM2-LOW IS  NOT INITIAL.  " Check for Cost Group
183    *          SELECT SINGLE SETNAME
184    *                FROM SETLEAF INTO @DATA(WA_TAB2) WHERE SETNAME EQ @S_SENM2-LOW.
185    *          IF SY-SUBRC NE 0.
186    *            MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
187    *          ENDIF.
188    *        ELSEIF S_KOKR2 IS NOT INITIAL. " Check for cost center values
189    *          LOOP AT S_KOKR2.
190    *            SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL2_RS) WHERE KOSTL EQ @S_KOKR2-LOW.
191    *            IF SY-SUBRC NE 0.
192    *              MESSAGE 'Please enter correct values for Cost Center' TYPE  'E'.
193    *            ENDIF.
194    *          ENDLOOP.
195    *
196    *        ENDIF. " ( Check for Cost center )
197    *      ENDIF. " ( Check for Cost Center is initial )
198    *
199    *      IF S_SECLS2-LOW IS INITIAL AND S_KTOP2 IS INITIAL. " Check for Cost Element is initial
200    *        MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
201    *      ELSE.
202    *        IF S_SECLS2-LOW IS  NOT INITIAL.  " Check for Cost Element group
203    *          SELECT SINGLE SETNAME
204    *                FROM SETLEAF INTO @DATA(LV_SETNAME2) WHERE SETNAME EQ @S_SECLS2-LOW.
205    *          IF SY-SUBRC NE 0.
206    *            MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
207    *          ENDIF.
208    *        ELSEIF S_KTOP2 IS NOT INITIAL.   " Check for Values for Cost Element
209    *            LOOP AT S_KTOP2.
210    *              SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP2_EQ) WHERE KSTAR EQ @S_KTOP2-LOW.
211    *              IF SY-SUBRC NE 0.
212    *                MESSAGE 'Please enter correct values of Cost Element' TYPE 'E'.
213    *              ENDIF.
214    *            ENDLOOP.
215    *          ENDIF.  " Check for Cost Element
216    *      ENDIF.  " ( Check for Cost Element is initial)
217    *
218    *
219    *    ELSEIF S_PERIOD-HIGH  = '012'.
220    *
221    *      IF S_SENM3-LOW IS INITIAL AND S_KOKR3 IS INITIAL.  " Check for cost center is initial)
222    *        MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
223    *      ELSE.
224    *        IF S_SENM3-LOW IS  NOT INITIAL.  " Check for Cost Center Group
225    *          SELECT SINGLE SETNAME
226    *                FROM SETLEAF INTO @DATA(WA_TAB3) WHERE SETNAME EQ @S_SENM3-LOW.
227    *          IF SY-SUBRC NE 0.
228    *            MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
229    *          ENDIF.
230    *
231    *        ELSEIF S_KOKR3 IS NOT INITIAL.  " Check for Values for cost center
232    *          LOOP AT S_KOKR3.
233    *            SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL3_RS) WHERE KOSTL EQ @S_KOKR3-LOW.
234    *            IF SY-SUBRC NE 0.
235    *              MESSAGE 'Please enter correct value for Cost Center' TYPE  'E'.
236    *            ENDIF.
237    *          ENDLOOP.
238    *
239    *        ENDIF.  " (Check Cost Center Values )
240    *      ENDIF. " ( Check for cost center is initial)
241    *
242    *
243    *      IF S_SECLS3-LOW IS INITIAL AND S_KTOP3 IS INITIAL.
244    *        MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
245    *      ELSE.
246    *        IF S_SECLS3-LOW IS  NOT INITIAL.  " check for Cost element group
247    *          SELECT SINGLE SETNAME
248    *                FROM SETLEAF INTO @DATA(LV_SETNAME3) WHERE SETNAME EQ @S_SECLS3-LOW.
249    *          IF SY-SUBRC NE 0.
250    *            MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
251    *          ENDIF.
252    *        ELSEIF S_KTOP3 IS NOT INITIAL.  " Check for Values for Cost element
253    *            LOOP AT S_KTOP3.
254    *              SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP3_EQ) WHERE KSTAR EQ @S_KTOP3-LOW.
255    *              IF SY-SUBRC NE 0.
256    *                MESSAGE 'Please enter correct value of Cost Element' TYPE 'E'.
257    *              ENDIF.
258    *            ENDLOOP.
259    *          ENDIF. "( Check Cost Element values )
260    *      ENDIF. " ( Check for Cost Element initial )
261    *
262    *
263    *    ENDIF.  " ( S_PERIOD-HIGH = '03')
264      ENDIF.  "( SSCRFIELDS-UCOMM = 'ONLI')
265    * EOC on 9.6.21
266
267    START-OF-SELECTION.
268
269
270
271      IF R1 = 'X'.
272        PERFORM GET_DATA.
273      ELSE.
274        PERFORM GET_DATA_CC.
275      ENDIF.
276    *    IF gt_saknr IS INITIAL.
277      IF GT_FINAL[] IS NOT INITIAL.
278        PERFORM ALV_FIELDCAT.
279        PERFORM GET_EVENT.
280        PERFORM SUB_COMMENT_BUILD USING T_LIST_TOP_OF_PAGE.
281        PERFORM ALV_DISPLAY.
282      ELSE.
283        MESSAGE 'No Data Found' TYPE 'E'.
284      ENDIF.
285    *    ENDIF.
*--- End of ZFI_FCTR_REVALLOC_POST - 285 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_FCTR_REVALLOC_DD                      Level 1    Page 2
Object           ZFI_FCTR_REVALLOC_POST                    Lines 342
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_FCTR_REVALLOC_DD
3      *&---------------------------------------------------------------------*
4      TYPE-POOLS truxs.
5
6      TABLES : ccr1z,ska1,bsis,tcurr,t001,bkpf, faglflext,tka02,v_prpmp,prps,setleaf,csks,cska,coep,sscrfields.
7
8      .
9
10     *&---------------------------------------------------------------------*
11     *& ALV Data Declaration
12     *&---------------------------------------------------------------------*
13     DATA: it_fieldcat            TYPE slis_t_fieldcat_alv.
14     DATA: wa_fieldcat            LIKE LINE OF it_fieldcat.
15     DATA: t_list_top_of_page     TYPE slis_t_listheader.
16     DATA: t_list_top_of_page1     TYPE slis_t_listheader.
17     DATA: it_events              TYPE slis_t_event WITH HEADER LINE.
18     DATA: g_save                 TYPE c VALUE 'A'.
19     DATA: gt_sort                TYPE slis_t_sortinfo_alv.
20     DATA: gx_save                TYPE c VALUE 'A'.
21     DATA: gx_variant             TYPE disvariant.
22     DATA: g_variant              TYPE disvariant.
23     DATA: gs_layout              TYPE slis_layout_alv.
24     DATA: t_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
25     DATA: t_i_event              TYPE slis_alv_event.
26
27     TYPES : BEGIN OF ty_ska1,
28               ktopl TYPE ktopl,
29               saknr TYPE saknr,
30               xbilk TYPE xbilk,
31             END OF ty_ska1,
32
33             BEGIN OF ty_tcurr,
34               kurst  TYPE kurst_curr,
35               fcurr  TYPE fcurr_curr,
36               tcurr  TYPE tcurr_curr,
37               gdatu  TYPE gdatu_inv,
38               ukurs  TYPE ukurs_curr,
39               tdate  TYPE sy-datum,
40               ukurs1 TYPE p DECIMALS 4,
41             END OF ty_tcurr,
42
43             BEGIN OF ty_fctr,
44               gl_account TYPE  zhkont,
45               znature    TYPE znature1,
46               zconvrsn   TYPE zconvrsn,
47               fctr_gl    TYPE zfhkont,
48             END OF ty_fctr,
49
50             BEGIN OF ty_final,
51               kstar  TYPE kstar,
52               ASAKNR TYPE ZFI_FCTR_GL-ASAKNR,  " added by ss on 21.9.2021
53               pspnr  TYPE prps-pspnr,
54               objnr  TYPE J_OBJNR,
55               AKSTL  type PRPS-AKSTL,
56               wogbtr TYPE wogxxx,
57               wkgbtr TYPE wkgxxx,
58             END OF ty_final,
59
60             BEGIN OF ty_skb1,
61               bukrs TYPE bukrs,
62               saknr TYPE saknr,
63             END OF ty_skb1,
64
65             BEGIN OF ty_saknr,
66               hkont TYPE hkont,
67             END OF ty_saknr.
68
69     DATA : lv_date    TYPE gdatu_inv,
70            datum      TYPE char10,
71            lv_date_ps TYPE gdatu_inv,
72            datum_ps   TYPE char10.
73
74     DATA : lv_odate TYPE char10.
75     DATA : lv_year TYPE char4.
76     DATA : lv_head TYPE char15.
77     DATA : lv_head_date TYPE char10.
78
79     DATA : gt_saknr TYPE STANDARD TABLE OF ty_saknr,
80            gs_saknr TYPE ty_saknr.
81
82     DATA : gt_ska1 TYPE STANDARD TABLE OF ty_ska1,
83            gs_ska1 TYPE ty_ska1.
84
85     DATA : gt_skb1 TYPE STANDARD TABLE OF ty_skb1,
86            gs_skb1 TYPE ty_skb1.
87
88     DATA : gt_tcurr TYPE STANDARD TABLE OF ty_tcurr,
89            gs_tcurr TYPE ty_tcurr.
90
91     DATA : gt_tcurr_pl TYPE STANDARD TABLE OF ty_tcurr,
92            gs_tcurr_pl TYPE ty_tcurr.
93
94     DATA : gt_fctr TYPE STANDARD TABLE OF ty_fctr,
95            gs_fctr TYPE ty_fctr.
96
97     DATA : gt_fctr1 TYPE STANDARD TABLE OF ty_fctr,
98            gs_fctr1 TYPE ty_fctr.
99
100    DATA : gt_final TYPE STANDARD TABLE OF ty_final,
101           gs_final TYPE ty_final.
102
103    DATA : gt_wbs TYPE STANDARD TABLE OF ty_final,
104           gs_wbs TYPE ty_final.
105
106    DATA : gt_final1 TYPE STANDARD TABLE OF ty_final,
107           gs_final1 TYPE ty_final.
108
109    DATA : gt_final2 TYPE STANDARD TABLE OF ty_final,
110           gs_final2 TYPE ty_final.
111
112    DATA : gt_finaltot TYPE STANDARD TABLE OF ty_final,
113           gs_finaltot TYPE ty_final.
114
115    DATA : var  TYPE char50,
116           len  TYPE i,
117           var1 TYPE char1.
118
119    DATA : v_first LIKE sy-datum,
120           v_last  LIKE sy-datum.
121    DATA : lv_fiscal TYPE char4.
122    DATA : lv_fd TYPE t009b-bdatj.
123
124    TYPES : BEGIN OF ty_month,
125              month TYPE monat,
126              text  TYPE makt-maktx,
127            END OF ty_month.
128
129    DATA : lt_read  TYPE STANDARD TABLE OF dynpread,
130           ls_read  TYPE dynpread,
131           lt_month TYPE TABLE OF ty_month,
132           ls_month TYPE ty_month.
133
134    DATA : gt_faglflext TYPE STANDARD TABLE OF faglflext,
135           gs_faglflext TYPE faglflext.
136
137    DATA : gt_faglflext1 TYPE STANDARD TABLE OF faglflext,
138           gs_faglflext1 TYPE faglflext.
139
140    TYPES : BEGIN OF ty_prps,
141              pspnr TYPE ps_posnr,
142              pbukr TYPE ps_pbukr,
143              pkokr TYPE ps_pkokr,
144              posid TYPE ps_posid,  "ADED DISHA JOSHI  14/09/2018
145              objnr TYPE j_objnr ,  "ADED DISHA JOSHI  14/09/2018
146              akstl TYPE prps-akstl,
147            END OF ty_prps.
148
149    DATA : gt_prps TYPE STANDARD TABLE OF ty_prps,
150           gs_prps TYPE ty_prps.
151
152    TYPES : BEGIN OF ty_tka02,
153              bukrs TYPE bukrs,
154              gsber TYPE gsber,
155              kokrs TYPE setsubcls,
156    *          KOKRS TYPE tka02-KOKRS,
157            END OF ty_tka02,
158
159            BEGIN OF ty_setleaf,
160              setclass TYPE setclass,
161              subclass TYPE setsubcls,
162              setname  TYPE setnamenew,
163              valfrom  TYPE setleaf-valfrom,
164    *          LINEID   TYPE SETLINE,
165            END OF ty_setleaf.
166
167
168    DATA : gt_tka02 TYPE STANDARD TABLE OF ty_tka02,
169           gs_tka02 TYPE ty_tka02.
170
171    DATA : gt_setleaf TYPE STANDARD TABLE OF ty_setleaf,
172           gs_setleaf TYPE ty_setleaf.
173    DATA : gt_setleaf2 TYPE STANDARD TABLE OF ty_setleaf,
174           gs_setleaf2 TYPE ty_setleaf.
175    DATA : gt_setleaf3 TYPE STANDARD TABLE OF ty_setleaf,
176           gs_setleaf3 TYPE ty_setleaf.
177    DATA : gt_setleaf4 TYPE STANDARD TABLE OF ty_setleaf,
178           gs_setleaf4 TYPE ty_setleaf.
179
180
181
182    *****************************Added By Rahul Gupta**************************************
183    DATA : gt_setleaf5 TYPE STANDARD TABLE OF setleaf,
184           gs_setleaf5 TYPE setleaf.
185    DATA : gt_setleaf6 TYPE STANDARD TABLE OF setleaf,
186           gs_setleaf6 TYPE setleaf.
187    DATA : gt_setleaf7 TYPE STANDARD TABLE OF setleaf,
188           gs_setleaf7 TYPE setleaf.
189    DATA : gt_setleaf8 TYPE STANDARD TABLE OF setleaf,
190           gs_setleaf8 TYPE setleaf.
191
192
193    ******************************ADDED By Disha Joshi 14/09/2018**************************************************
194
195    TYPES : BEGIN OF ty_v_prpmp,
196              postu TYPE ps_postu,
197              post1 TYPE ps_post1,
198              poski TYPE ps_poski,
199              pspnr TYPE ps_posnr,
200
201              posid TYPE ps_posid,
202              pspid TYPE ps_pspid,
203            END OF ty_v_prpmp,
204
205    *        BEGIN OF ty_PRPS,
206    *        PSPNR  TYPE PS_POSNR,
207    *        POSID  TYPE PS_POSID,
208    *        END OF ty_PRPS,
209
210            BEGIN OF ty_coep,
211              kokrs  TYPE kokrs,
212              belnr  TYPE co_belnr,
213              buzei  TYPE co_buzei,
214              kstar  TYPE kstar,
215              objnr  TYPE j_objnr,
216              wogbtr TYPE wogxxx,
217              wkgbtr TYPE wkgxxx,
218
219
220            END OF ty_coep.
221
222    TYPES : BEGIN OF ty_coep1,
223              kstar  TYPE kstar,
224              objnr  TYPE j_objnr,
225              wogbtr TYPE wogxxx,
226              wkgbtr TYPE wkgxxx,
227            END OF ty_coep1,
228
229            BEGIN OF ty_csks,
230              kokrs TYPE kokrs,
231              kostl TYPE kostl,
232              objnr TYPE j_objnr,
233            END OF ty_csks,
234
235            BEGIN OF ty_tka02_1,
236              bukrs TYPE bukrs,
237              gsber TYPE gsber,
238    *          KOKRS TYPE SETSUBCLS,
239              kokrs TYPE tka02-kokrs,
240            END OF ty_tka02_1,
241
242            BEGIN OF ty_cska,
243              ktopl TYPE ktopl,
244              kstar TYPE kstar,
245            END OF ty_cska.
246
247    DATA : gt_v_prpmp  TYPE STANDARD TABLE OF ty_v_prpmp,
248           gt_v_prpmp1 TYPE STANDARD TABLE OF ty_v_prpmp,
249           gs_v_prpmp  TYPE                   ty_v_prpmp,
250    *        gt_PRPS    TYPE STANDARD TABLE OF ty_PRPS,
251    *        gs_PRPS    TYPE                   ty_PRPS,
252           gt_coep     TYPE STANDARD TABLE OF ty_coep,
253           gt_coep1    TYPE STANDARD TABLE OF ty_coep1,
254           gs_coep     TYPE                   ty_coep,
255           gs_coep1    TYPE                   ty_coep1,
256           gt_coep2    TYPE STANDARD TABLE OF ty_coep,
257           gt_coepq2   TYPE STANDARD TABLE OF ty_coep,
258           gt_coepq3   TYPE STANDARD TABLE OF ty_coep,
259           gt_coepq4   TYPE STANDARD TABLE OF ty_coep,
260           gt_coep3    TYPE STANDARD TABLE OF ty_coep1,
261           gt_coep3q2  TYPE STANDARD TABLE OF ty_coep1,
262           gt_coep3q3  TYPE STANDARD TABLE OF ty_coep1,
263           gt_coep3q4  TYPE STANDARD TABLE OF ty_coep1,
264           gs_coep2    TYPE                   ty_coep,
265           gs_coepq2   TYPE                   ty_coep,
266           gs_coepq3   TYPE                   ty_coep,
267           gs_coepq4   TYPE                   ty_coep,
268           gs_coep3    TYPE                   ty_coep1,
269           gs_coep3q2  TYPE                   ty_coep1,
270           gs_coep3q3  TYPE                   ty_coep1,
271           gs_coep3q4  TYPE                   ty_coep1,
272           gt_csks     TYPE STANDARD TABLE OF ty_csks,
273           gs_csks     TYPE                   ty_csks,
274           gt_csks2    TYPE STANDARD TABLE OF ty_csks,
275           gs_csks2    TYPE                   ty_csks,
276           gt_csks3    TYPE STANDARD TABLE OF ty_csks,
277           gs_csks3    TYPE                   ty_csks,
278           gt_csks4    TYPE STANDARD TABLE OF ty_csks,
279           gs_csks4    TYPE                   ty_csks,
280           gt_tka02_1  TYPE STANDARD TABLE OF ty_tka02_1,
281           gs_tka02_1  TYPE                   ty_tka02_1,
282           gt_cska     TYPE STANDARD TABLE OF ty_cska,
283           gs_cska     TYPE                   ty_cska.
284
285
286    DATA : lv_hkont TYPE hkont.
287    RANGES: r_pspnr FOR prps-posid,
288            r_perio1 FOR bkpf-monat,
289            r_perio2 FOR bkpf-monat,
290            r_perio3 FOR bkpf-monat,
291            r_perio4 FOR bkpf-monat.
292
293    RANGES: r_gl1 FOR faglflext-racct,
294            r_gl2 FOR faglflext-racct,
295            r_gl3 FOR faglflext-racct,
296            r_gl4 FOR faglflext-racct.
297
298    DATA: n TYPE i,
299          s TYPE i.
300    DATA :  documentheader       TYPE bapiache09." OCCURS 0 WITH HEADER  LINE.
301    DATA :  obj_type             TYPE bapiache09-obj_type.
302    DATA :  obj_key              TYPE bapiache09-obj_key.
303    DATA :  obj_sys              TYPE bapiache09-obj_sys.
304    DATA :  wa_accountgl         TYPE bapiacgl09.
305    DATA :  wa_accountreceivable TYPE bapiacar09.
306    DATA :  wa_accountpayable    TYPE bapiacap09.
307    DATA :  wa_currencyamount    TYPE bapiaccr09.
308    DATA :  return               TYPE bapiret2   OCCURS 0 WITH HEADER LINE.
309    DATA :  accountgl            TYPE bapiacgl09 OCCURS 0 WITH HEADER LINE.
310    DATA :  accountreceivable    TYPE bapiacar09 OCCURS 0 WITH HEADER LINE.
311    DATA :  accountpayable       TYPE bapiacap09 OCCURS 0 WITH HEADER LINE.
312    DATA :  currencyamount       TYPE bapiaccr09 OCCURS 0 WITH HEADER LINE.
313    DATA :  it_accountgl         TYPE STANDARD TABLE OF bapiacgl09.
314    DATA : counter_bapi TYPE posnr_acc.
315    DATA :  it_currencyamount    TYPE STANDARD TABLE OF bapiaccr09.
316
317    TYPES : BEGIN OF ty_display,
318              type       TYPE bapi_mtype,
319              id         TYPE symsgid,
320              number     TYPE symsgno,
321              message    TYPE bapi_msg,
322              log_no     TYPE balognr,
323              log_msg_no TYPE balmnr,
324              message_v1 TYPE symsgv,
325              message_v2 TYPE symsgv,
326              message_v3 TYPE symsgv,
327              message_v4 TYPE symsgv,
328              parameter  TYPE bapi_param,
329              row        TYPE bapi_line,
330              field      TYPE bapi_fld,
331              system     TYPE bapilogsys,
332            END OF ty_display.
333
334    DATA : gt_display  TYPE STANDARD TABLE OF esp1_message_wa_type,
335           gs_display  TYPE esp1_message_wa_type,
336           gt_display1  TYPE STANDARD TABLE OF esp1_message_wa_type,
337           gs_display1  TYPE esp1_message_wa_type,
338           wa_post TYPE ZFI_FCTR_DOC,
339           it_post TYPE TABLE OF ZFI_FCTR_DOC,
340           p_poper TYPE poper,
341           wogbtr_diff TYPE wogxxx,
342           wkgbtr_diff TYPE wkgxxx.
*--- End of ZFI_FCTR_REVALLOC_DD - 342 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_FCTR_REVALLOC_SS                      Level 1    Page 3
Object           ZFI_FCTR_REVALLOC_POST                    Lines 1033
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_FCTR_REVALLOC_SS
3      *&---------------------------------------------------------------------*
4      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
5      PARAMETERS : p_bukrs TYPE faglflext-rbukrs DEFAULT 'OVL'.
6      PARAMETERS : p_year TYPE faglflext-ryear OBLIGATORY.
7      SELECT-OPTIONS : s_gl FOR faglflext-racct OBLIGATORY.
8      SELECT-OPTIONS : s_period FOR bkpf-monat OBLIGATORY NO-EXTENSION .
9      PARAMETERS : p_ledger TYPE faglflext-rldnr DEFAULT '0L'.
10     PARAMETERS : p_budat TYPE datum DEFAULT sy-datum.
11
12     SELECTION-SCREEN END OF BLOCK b1.
13     SELECT-OPTIONS : s_kokrs FOR tka02-kokrs NO INTERVALS NO-EXTENSION DEFAULT 'OVL'.
14     SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
15     *DATA: ch TYPE c LENGTH 25.
16     SELECT-OPTIONS : s_pspid FOR v_prpmp-pspid NO INTERVALS NO-EXTENSION DEFAULT 'OV*'.
17     *                 s_pspnr FOR prps-pspnr.
18     SELECTION-SCREEN END OF BLOCK b2.
19
20     SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
21     *SELECT-OPTIONS : s_senm FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q1,  "commented by ss on 2.6.21
22     SELECT-OPTIONS : s_senm FOR setleaf-setname NO INTERVALS NO-EXTENSION MODIF ID q1,   " added by ss on 2.6.21
23     ******************************Cheged Code Disha Joshi 12/09/2018************************************
24                      s_kokr FOR csks-kostl MODIF ID q1,
25     *                 S_KOS  FOR CSKS-KOSTL,
26     *                 s_secls FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q1,  "commented by ss on 2.6.21
27                       s_secls FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q1,
28                      s_ktop FOR cska-kstar MODIF ID q1.
29     ******************************Change Code Disha Joshi 18/09/2018*************************************
30     *SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
31
32     SELECTION-SCREEN END OF BLOCK b3.
33
34
35     *SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
36     **SELECT-OPTIONS : s_senm1 FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q2, "commented by ss on 2.6.21
37     *SELECT-OPTIONS : s_senm1 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q2,   "added by ss on 2.6.21
38     *******************************Cheged Code Disha Joshi 12/09/2018************************************
39     *                 s_kokr1 FOR csks-kostl MODIF ID q2,
40     **                 S_KOS  FOR CSKS-KOSTL,
41     **                 s_secls1 FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q2,  " commented by ss on 2.6.21
42     *                  s_secls1 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q2,            " added by ss on 2.6.21
43     *                 s_ktop1 FOR cska-kstar MODIF ID q2.
44     *******************************Change Code Disha Joshi 18/09/2018*************************************
45     **SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
46     *
47     *SELECTION-SCREEN END OF BLOCK b4.
48     *
49     *
50     *SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-005.
51     **SELECT-OPTIONS : s_senm2 FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q3,  " commented by ss on 2.6.21
52     *SELECT-OPTIONS : s_senm2 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q3,   " added by ss on 2.6.21
53     *******************************Cheged Code Disha Joshi 12/09/2018************************************
54     *                 s_kokr2 FOR csks-kostl MODIF ID q3,
55     **                 S_KOS  FOR CSKS-KOSTL,
56     **                 s_secls2 FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q3, " commented by ss on 2.6.21
57     *                 s_secls2 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q3,  " added by ss on 2.6.21
58     *                 s_ktop2 FOR cska-kstar MODIF ID q3.
59     *******************************Change Code Disha Joshi 18/09/2018*************************************
60     **SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
61     *
62     *SELECTION-SCREEN END OF BLOCK b5.
63     *
64     *
65     *SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE text-006.
66     **SELECT-OPTIONS : s_senm3 FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q4, " commented by ss on 2.6.21
67     *SELECT-OPTIONS : s_senm3 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q4,  " added on 2.6.21
68     *******************************Cheged Code Disha Joshi 12/09/2018************************************
69     *                 s_kokr3 FOR csks-kostl MODIF ID q4,
70     **                 S_KOS  FOR CSKS-KOSTL,
71     **                 s_secls3 FOR setleaf-setname NO INTERVALS NO-EXTENSION OBLIGATORY MODIF ID q4,  " commented by ss on 2.6.21
72     *                  s_secls3 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q4,   " added on 2.6.21
73     *                 s_ktop3 FOR cska-kstar MODIF ID q4.
74     *******************************Change Code Disha Joshi 18/09/2018*************************************
75     **SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
76     *
77     *SELECTION-SCREEN END OF BLOCK b6.
78
79     SELECTION-SCREEN BEGIN OF BLOCK b7 WITH FRAME TITLE text-007.
80     PARAMETERS : r1 RADIOBUTTON GROUP r3,
81                  r2 RADIOBUTTON GROUP r3.
82
83
84     SELECTION-SCREEN END OF BLOCK b7.
85
86
87     *INITIALIZATION.
88     *  s_kokrs-sign = 'I'.
89     *  s_kokrs-option = 'EQ'.
90     *  s_pspid-sign = 'I'.
91     *  s_pspid-option = 'EQ'.
92     *  s_pspid-low = 'OV*'.
93     *  APPEND s_pspid.
94     *  SELECT *
95     *    FROM tka02
96     *    INTO CORRESPONDING FIELDS OF TABLE gt_tka02
97     *  WHERE BUKRS = S_KOKRS.
98     *     WHERE bukrs = p_bukrs.
99     *  READ TABLE gt_tka02 INTO gs_tka02 INDEX 1.
100    *  IF sy-subrc = 0.
101    *    s_kokrs-low = gs_tka02-kokrs.
102    *    APPEND s_kokrs.
103    *  ENDIF.
104
105    AT SELECTION-SCREEN OUTPUT.
106    *
107    *  CLEAR: s_kokrs, s_pspid.
108    *  REFRESH: s_kokrs, s_pspid.
109
110
111
112
113      n = 1.
114
115        LOOP AT SCREEN.
116    *    IF screen-name = 'S_PERIOD-LOW'.
117    *      screen-input = '0'.
118    *    ENDIF.
119        IF screen-name = 'S_PSPID-LOW'.
120          screen-input = '0'.
121        ENDIF.
122        MODIFY SCREEN.
123        IF screen-group1 = 'GRE'.
124          screen-input = 0.
125          MODIFY SCREEN.
126        ENDIF.
127    *    IF screen-group1 = 'Q4'.
128    **      IF s_period-high < 10.
129    *      if  s_period-low ne '10' and s_period-high ne '12'.
130    *        screen-invisible = 0.
131    *        screen-active = 0.
132    *        MODIFY SCREEN.
133    *        n = 4.
134    *      ENDIF.
135    *    ENDIF.
136    *    IF screen-group1 = 'Q2'.
137    **      IF s_period-high < 4.
138    *        if  s_period-low ne '04' and s_period-high ne '06'.
139    *        screen-invisible = 0.
140    *        screen-active = 0.
141    *        MODIFY SCREEN.
142    *        n = 2.
143    *      ENDIF.
144    *    ENDIF.
145    *    IF screen-group1 = 'Q1'.
146    **      IF s_period-high < 1.
147    *        if  s_period-low ne '01' and s_period-high ne '03'.
148    *        screen-invisible = 0.
149    *        screen-active = 0.
150    *        MODIFY SCREEN.
151    *        n = 1.
152    *      ENDIF.
153    *    ENDIF.
154    *    IF screen-group1 = 'Q3'.
155    **      IF s_period-high < 7.
156    *        if  s_period-low ne '07' and s_period-high ne '09'.
157    *        screen-invisible = '0'.
158    *        screen-active = 0.
159    *        MODIFY SCREEN.
160    *        n = 3.
161    *      ENDIF.
162    *    ENDIF.
163    *
164      ENDLOOP.
165
166        IF  s_period-high <= 3.  "quarter 1
167          n = 1.
168
169        ELSEIF s_period-high <= 6 . "quarter 2
170    **            for quarter 1
171          n = 2.
172
173        ELSEIF  s_period-high <= 9.  "quarter 3
174    **            for quarter 1
175          n = 3.
176
177        ELSE.  "quarter 4
178    **            for quarter 1
179          n = 4.
180
181
182        ENDIF.
183
184    *  LOOP AT SCREEN.
185    **    IF screen-name = 'S_PERIOD-LOW'.
186    **      screen-input = '0'.
187    **    ENDIF.
188    *    IF screen-name = 'S_PSPID-LOW'.
189    *      screen-input = '0'.
190    *    ENDIF.
191    *    MODIFY SCREEN.
192    *    IF screen-group1 = 'GRE'.
193    *      screen-input = 0.
194    *      MODIFY SCREEN.
195    *    ENDIF.
196    *
197    **        IF screen-group1 = 'Q4'.
198    ***      IF s_period-high < 10.
199    **        screen-invisible = 0.
200    **        screen-active = 0.
201    **        MODIFY SCREEN.
202    ***        n = 4.
203    ***      ENDIF.
204    **    ENDIF.
205    **    IF screen-group1 = 'Q2'.
206    ***      IF s_period-high < 4.
207    **        screen-invisible = 0.
208    **        screen-active = 0.
209    **        MODIFY SCREEN.
210    ***        n = 2.
211    ***      ENDIF.
212    **    ENDIF.
213    **    IF screen-group1 = 'Q1'.
214    ***      IF s_period-high < 1.
215    **        screen-invisible = 0.
216    **        screen-active = 0.
217    **        MODIFY SCREEN.
218    ***        n = 1.
219    ***      ENDIF.
220    **    ENDIF.
221    **    IF screen-group1 = 'Q3'.
222    ***      IF s_period-high < 7.
223    **        screen-invisible = '0'.
224    **        screen-active = 0.
225    **        MODIFY SCREEN.
226    ***        n = 3.
227    ***      ENDIF.
228    **    ENDIF.
229    *
230    *    IF screen-group1 = 'Q1'.
231    *
232    **      IF s_period-high < 10.
233    *    if  s_period-low eq '01' and s_period-high eq '03' and s_period-high is NOT INITIAL.
234    *        screen-invisible = 1.
235    *        screen-active = 1.
236    *        MODIFY SCREEN.
237    *        n = 1.
238    *        else.
239    *         screen-invisible = 0.
240    *        screen-active = 0.
241    *        MODIFY SCREEN.
242    *      ENDIF.
243    *    ENDIF.
244    *    IF screen-group1 = 'Q2'.
245    *  if  s_period-low eq '04' and s_period-high eq '06' and s_period-high is NOT INITIAL.
246    **      IF s_period-high < 4.
247    *        screen-invisible = 1.
248    *        screen-active = 1.
249    *        MODIFY SCREEN.
250    *        n = 2.
251    *          else.
252    *         screen-invisible = 0.
253    *        screen-active = 0.
254    *        MODIFY SCREEN.
255    *      ENDIF.
256    *    ENDIF.
257    *    IF screen-group1 = 'Q3'.
258    **      IF s_period-high < 1.
259    *    if  s_period-low eq '07' and s_period-high eq '09' and s_period-high is NOT INITIAL.
260    *        screen-invisible = 1.
261    *        screen-active = 1.
262    *        MODIFY SCREEN.
263    *        n = 1.
264    *        else.
265    **            else.
266    *         screen-invisible = 0.
267    *        screen-active = 0.
268    *        MODIFY SCREEN.
269    *      ENDIF.
270    *    ENDIF.
271    *    IF screen-group1 = 'Q4'.
272    *   if s_period-low eq '10' and s_period-high eq '12' and s_period-high is NOT INITIAL .
273    **      IF s_period-high < 7.
274    *        screen-invisible = 1.
275    *        screen-active = 1.
276    *        MODIFY SCREEN.
277    *        n = 3.
278    *        else.
279    **            else.
280    *         screen-invisible = 0.
281    *        screen-active = 0.
282    *        MODIFY SCREEN.
283    *      ENDIF.
284    *    ENDIF.
285    *
286    *  ENDLOOP.
287
288
289
290    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pspnr-low.
291    *
292    *  SELECT pspnr pbukr pkokr posid
293    *    FROM prps
294    *    INTO CORRESPONDING FIELDS OF TABLE gt_prps
295    *    WHERE pbukr = 'OVL'
296    *      AND pkokr = 'OVL'
297    *      AND posid IN s_pspid
298    *    .
299    *
300    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
301    *    EXPORTING
302    *      retfield        = 'PSPNR'
303    *      dynpprog        = sy-repid
304    *      dynpnr          = sy-dynnr "'1000'
305    *      dynprofield     = 'S_PSPNR-LOW'
306    *      value_org       = 'S'
307    *    TABLES
308    *      value_tab       = gt_prps
309    *    EXCEPTIONS
310    *      parameter_error = 1
311    *      no_values_found = 2
312    *      OTHERS          = 3.
313    *
314    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pspnr-high.
315    *
316    *  SELECT pspnr pbukr pkokr
317    *    FROM prps
318    *    INTO CORRESPONDING FIELDS OF TABLE gt_prps
319    *    WHERE pbukr = 'OVL'
320    *      AND pkokr = 'OVL'
321    *      AND posid IN s_pspid
322    *    .
323    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
324    *    EXPORTING
325    *      retfield        = 'PSPNR'
326    *      dynpprog        = sy-repid
327    *      dynpnr          = sy-dynnr "'1000'
328    *      dynprofield     = 'S_PSPNR-HIGH'
329    *      value_org       = 'S'
330    *    TABLES
331    *      value_tab       = gt_prps
332    *    EXCEPTIONS
333    *      parameter_error = 1
334    *      no_values_found = 2
335    *      OTHERS          = 3.
336
337    ******************************* Code Added By Disha Joshi 12/09/2018*********************
338
339    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm-low.
340
341
342      IF p_bukrs IS INITIAL.
343        REFRESH lt_read[].
344        CONSTANTS: lc_11 TYPE i VALUE 11.
345        ls_read-fieldname = 'P_BUKRS'.
346        APPEND ls_read TO lt_read.
347        CALL FUNCTION 'DYNP_VALUES_READ'
348          EXPORTING
349            dyname               = sy-cprog
350            dynumb               = sy-dynnr
351          TABLES
352            dynpfields           = lt_read
353          EXCEPTIONS
354            invalid_abapworkarea = 1
355            invalid_dynprofield  = 2
356            invalid_dynproname   = 3
357            invalid_dynpronummer = 4
358            invalid_request      = 5
359            no_fielddescription  = 6
360            invalid_parameter    = 7
361            undefind_error       = 8
362            double_conversion    = 9
363            stepl_not_found      = 10
364            OTHERS               = lc_11 ##FM_SUBRC_OK.
365        READ TABLE lt_read INTO ls_read INDEX 1.
366        p_bukrs = to_upper( ls_read-fieldvalue ).
367      ENDIF.
368
369
370      SELECT *
371      FROM tka02
372      INTO CORRESPONDING FIELDS OF TABLE gt_tka02
373    *  WHERE BUKRS = S_KOKRS.
374       WHERE bukrs = p_bukrs.
375
376      IF gt_tka02 IS NOT INITIAL.
377        SELECT setclass subclass setname
378           FROM setleaf
379           INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
380           FOR ALL ENTRIES IN gt_tka02
381           WHERE setclass = '0101'
382           AND   subclass = gt_tka02-kokrs.
383        IF gt_setleaf IS   NOT INITIAL.
384          SORT gt_setleaf BY setclass subclass setname.
385          DELETE ADJACENT DUPLICATES FROM gt_setleaf.
386        ENDIF.
387      ENDIF.
388
389
390
391
392      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
393        EXPORTING
394          retfield        = 'SETNAME'
395          dynpprog        = sy-repid
396          dynpnr          = sy-dynnr "'1000'
397          dynprofield     = 'S_SENM'
398          value_org       = 'S'
399        TABLES
400          value_tab       = gt_setleaf
401        EXCEPTIONS
402          parameter_error = 1
403          no_values_found = 2
404          OTHERS          = 3.
405
406
407
408    *  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
409
410
411
412    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm1-low.
413    *  IF p_bukrs IS INITIAL.
414    *    REFRESH lt_read[].
415    *    CONSTANTS: lc_11 TYPE i VALUE 11.
416    *    ls_read-fieldname = 'P_BUKRS'.
417    *    APPEND ls_read TO lt_read.
418    *    CALL FUNCTION 'DYNP_VALUES_READ'
419    *      EXPORTING
420    *        dyname               = sy-cprog
421    *        dynumb               = sy-dynnr
422    *      TABLES
423    *        dynpfields           = lt_read
424    *      EXCEPTIONS
425    *        invalid_abapworkarea = 1
426    *        invalid_dynprofield  = 2
427    *        invalid_dynproname   = 3
428    *        invalid_dynpronummer = 4
429    *        invalid_request      = 5
430    *        no_fielddescription  = 6
431    *        invalid_parameter    = 7
432    *        undefind_error       = 8
433    *        double_conversion    = 9
434    *        stepl_not_found      = 10
435    *        OTHERS               = lc_11 ##FM_SUBRC_OK.
436    *    READ TABLE lt_read INTO ls_read INDEX 1.
437    *    p_bukrs = to_upper( ls_read-fieldvalue ).
438    *  ENDIF.
439    *  SELECT *
440    *  FROM tka02
441    *  INTO CORRESPONDING FIELDS OF TABLE gt_tka02
442    **  WHERE BUKRS = S_KOKRS.
443    *   WHERE bukrs = p_bukrs.
444    *
445    *  IF gt_tka02 IS NOT INITIAL.
446    *    SELECT setclass subclass setname
447    *       FROM setleaf
448    *       INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
449    *       FOR ALL ENTRIES IN gt_tka02
450    *       WHERE setclass = '0101'
451    *       AND   subclass = gt_tka02-kokrs.
452    *    IF gt_setleaf IS   NOT INITIAL.
453    *      SORT gt_setleaf BY setclass subclass setname.
454    *      DELETE ADJACENT DUPLICATES FROM gt_setleaf.
455    *    ENDIF.
456    *  ENDIF.
457    *
458    *
459    *
460    *
461    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
462    *    EXPORTING
463    *      retfield        = 'SETNAME'
464    *      dynpprog        = sy-repid
465    *      dynpnr          = sy-dynnr "'1000'
466    *      dynprofield     = 'S_SENM1'
467    *      value_org       = 'S'
468    *    TABLES
469    *      value_tab       = gt_setleaf
470    *    EXCEPTIONS
471    *      parameter_error = 1
472    *      no_values_found = 2
473    *      OTHERS          = 3.
474    **  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
475    *
476    *
477    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm2-low.
478    *  REFRESH lt_read[].
479    *  CONSTANTS: lc_11 TYPE i VALUE 11.
480    *  ls_read-fieldname = 'P_BUKRS'.
481    *  APPEND ls_read TO lt_read.
482    *  CALL FUNCTION 'DYNP_VALUES_READ'
483    *    EXPORTING
484    *      dyname               = sy-cprog
485    *      dynumb               = sy-dynnr
486    *    TABLES
487    *      dynpfields           = lt_read
488    *    EXCEPTIONS
489    *      invalid_abapworkarea = 1
490    *      invalid_dynprofield  = 2
491    *      invalid_dynproname   = 3
492    *      invalid_dynpronummer = 4
493    *      invalid_request      = 5
494    *      no_fielddescription  = 6
495    *      invalid_parameter    = 7
496    *      undefind_error       = 8
497    *      double_conversion    = 9
498    *      stepl_not_found      = 10
499    *      OTHERS               = lc_11 ##FM_SUBRC_OK.
500    *  READ TABLE lt_read INTO ls_read INDEX 1.
501    *  p_bukrs = to_upper( ls_read-fieldvalue ).
502    *  SELECT *
503    *  FROM tka02
504    *  INTO CORRESPONDING FIELDS OF TABLE gt_tka02
505    **  WHERE BUKRS = S_KOKRS.
506    *   WHERE bukrs = p_bukrs.
507    *
508    *  IF gt_tka02 IS NOT INITIAL.
509    *    SELECT setclass subclass setname
510    *       FROM setleaf
511    *       INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
512    *       FOR ALL ENTRIES IN gt_tka02
513    *       WHERE setclass = '0101'
514    *       AND   subclass = gt_tka02-kokrs.
515    *    IF gt_setleaf IS   NOT INITIAL.
516    *      SORT gt_setleaf BY setclass subclass setname.
517    *      DELETE ADJACENT DUPLICATES FROM gt_setleaf.
518    *    ENDIF.
519    *  ENDIF.
520    *
521    *
522    *
523    *
524    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
525    *    EXPORTING
526    *      retfield        = 'SETNAME'
527    *      dynpprog        = sy-repid
528    *      dynpnr          = sy-dynnr "'1000'
529    *      dynprofield     = 'S_SENM2'
530    *      value_org       = 'S'
531    *    TABLES
532    *      value_tab       = gt_setleaf
533    *    EXCEPTIONS
534    *      parameter_error = 1
535    *      no_values_found = 2
536    *      OTHERS          = 3.
537    **  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
538    *
539    *
540    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm3-low.
541    *  IF p_bukrs IS INITIAL.
542    *    REFRESH lt_read[].
543    *    CONSTANTS: lc_11 TYPE i VALUE 11.
544    *    ls_read-fieldname = 'P_BUKRS'.
545    *    APPEND ls_read TO lt_read.
546    *    CALL FUNCTION 'DYNP_VALUES_READ'
547    *      EXPORTING
548    *        dyname               = sy-cprog
549    *        dynumb               = sy-dynnr
550    *      TABLES
551    *        dynpfields           = lt_read
552    *      EXCEPTIONS
553    *        invalid_abapworkarea = 1
554    *        invalid_dynprofield  = 2
555    *        invalid_dynproname   = 3
556    *        invalid_dynpronummer = 4
557    *        invalid_request      = 5
558    *        no_fielddescription  = 6
559    *        invalid_parameter    = 7
560    *        undefind_error       = 8
561    *        double_conversion    = 9
562    *        stepl_not_found      = 10
563    *        OTHERS               = lc_11 ##FM_SUBRC_OK.
564    *    READ TABLE lt_read INTO ls_read INDEX 1.
565    *    p_bukrs = to_upper( ls_read-fieldvalue ).
566    *  ENDIF.
567    *  SELECT *
568    *  FROM tka02
569    *  INTO CORRESPONDING FIELDS OF TABLE gt_tka02
570    **  WHERE BUKRS = S_KOKRS.
571    *   WHERE bukrs = p_bukrs.
572    *
573    *  IF gt_tka02 IS NOT INITIAL.
574    *    SELECT setclass subclass setname
575    *       FROM setleaf
576    *       INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
577    *       FOR ALL ENTRIES IN gt_tka02
578    *       WHERE setclass = '0101'
579    *       AND   subclass = gt_tka02-kokrs.
580    *    IF gt_setleaf IS   NOT INITIAL.
581    *      SORT gt_setleaf BY setclass subclass setname.
582    *      DELETE ADJACENT DUPLICATES FROM gt_setleaf.
583    *    ENDIF.
584    *  ENDIF.
585    *
586    *
587    *
588    *
589    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
590    *    EXPORTING
591    *      retfield        = 'SETNAME'
592    *      dynpprog        = sy-repid
593    *      dynpnr          = sy-dynnr "'1000'
594    *      dynprofield     = 'S_SENM3'
595    *      value_org       = 'S'
596    *    TABLES
597    *      value_tab       = gt_setleaf
598    *    EXCEPTIONS
599    *      parameter_error = 1
600    *      no_values_found = 2
601    *      OTHERS          = 3.
602    *  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
603
604
605    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop-low.
606    *
607    *  SELECT *
608    *  FROM TKA02
609    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
610    **  WHERE BUKRS = S_KOKRS.
611    *   WHERE BUKRS = P_BUKRS.
612
613    *  IF GT_TKA02 IS NOT INITIAL.
614
615
616      SELECT ktopl kstar
617         FROM cska
618         INTO TABLE gt_cska
619         WHERE ktopl = 'ONGC'.
620
621
622
623    *    IF GT_SETLEAF IS   NOT INITIAL.
624    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
625    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
626    *    ENDIF.
627    *  ENDIF.
628
629      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
630        EXPORTING
631          retfield        = 'KSTAR'
632          dynpprog        = sy-repid
633          dynpnr          = sy-dynnr "'1000'
634          dynprofield     = 'S_KTOP'
635          value_org       = 'S'
636        TABLES
637          value_tab       = gt_cska
638        EXCEPTIONS
639          parameter_error = 1
640          no_values_found = 2
641          OTHERS          = 3.
642
643
644    *********************  COde added by Rahul Gupta  **********************
645    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop-high.
646    *
647    *  SELECT *
648    *  FROM TKA02
649    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
650    **  WHERE BUKRS = S_KOKRS.
651    *   WHERE BUKRS = P_BUKRS.
652
653    *  IF GT_TKA02 IS NOT INITIAL.
654
655      SELECT ktopl kstar
656         FROM cska
657         INTO TABLE gt_cska
658         WHERE ktopl = 'ONGC'.
659
660
661
662
663    *    IF GT_SETLEAF IS   NOT INITIAL.
664    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
665    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
666    *    ENDIF.
667    *  ENDIF.
668
669      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
670        EXPORTING
671          retfield        = 'KSTAR'
672          dynpprog        = sy-repid
673          dynpnr          = sy-dynnr "'1000'
674          dynprofield     = 'S_KTOP'
675          value_org       = 'S'
676        TABLES
677          value_tab       = gt_cska
678        EXCEPTIONS
679          parameter_error = 1
680          no_values_found = 2
681          OTHERS          = 3.
682
683    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop1-low.
684    **
685    **  SELECT *
686    **  FROM TKA02
687    **  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
688    ***  WHERE BUKRS = S_KOKRS.
689    **   WHERE BUKRS = P_BUKRS.
690    *
691    **  IF GT_TKA02 IS NOT INITIAL.
692    *
693    *  SELECT ktopl kstar
694    *     FROM cska
695    *     INTO TABLE gt_cska
696    *     WHERE ktopl = 'ONGC'.
697    *
698    *
699    *
700    *
701    **    IF GT_SETLEAF IS   NOT INITIAL.
702    **      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
703    **      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
704    **    ENDIF.
705    **  ENDIF.
706    *
707    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
708    *    EXPORTING
709    *      retfield        = 'KSTAR'
710    *      dynpprog        = sy-repid
711    *      dynpnr          = sy-dynnr "'1000'
712    *      dynprofield     = 'S_KTOP'
713    *      value_org       = 'S'
714    *    TABLES
715    *      value_tab       = gt_cska
716    *    EXCEPTIONS
717    *      parameter_error = 1
718    *      no_values_found = 2
719    *      OTHERS          = 3.
720    *
721    *
722    **********************  COde added by Rahul Gupta  **********************
723    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop1-high.
724    **
725    **  SELECT *
726    **  FROM TKA02
727    **  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
728    ***  WHERE BUKRS = S_KOKRS.
729    **   WHERE BUKRS = P_BUKRS.
730    *
731    **  IF GT_TKA02 IS NOT INITIAL.
732    *
733    *
734    *
735    *  SELECT ktopl kstar
736    *     FROM cska
737    *     INTO TABLE gt_cska
738    *     WHERE ktopl = 'ONGC'.
739    *
740    *
741    *
742    *
743    **    IF GT_SETLEAF IS   NOT INITIAL.
744    **      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
745    **      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
746    **    ENDIF.
747    **  ENDIF.
748    *
749    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
750    *    EXPORTING
751    *      retfield        = 'KSTAR'
752    *      dynpprog        = sy-repid
753    *      dynpnr          = sy-dynnr "'1000'
754    *      dynprofield     = 'S_KTOP'
755    *      value_org       = 'S'
756    *    TABLES
757    *      value_tab       = gt_cska
758    *    EXCEPTIONS
759    *      parameter_error = 1
760    *      no_values_found = 2
761    *      OTHERS          = 3.
762    *
763    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop2-low.
764    **
765    **  SELECT *
766    **  FROM TKA02
767    **  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
768    ***  WHERE BUKRS = S_KOKRS.
769    **   WHERE BUKRS = P_BUKRS.
770    *
771    **  IF GT_TKA02 IS NOT INITIAL.
772    *
773    *  SELECT ktopl kstar
774    *     FROM cska
775    *     INTO TABLE gt_cska
776    *     WHERE ktopl = 'ONGC'.
777    *
778    *
779    *
780    *
781    *
782    **    IF GT_SETLEAF IS   NOT INITIAL.
783    **      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
784    **      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
785    **    ENDIF.
786    **  ENDIF.
787    *
788    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
789    *    EXPORTING
790    *      retfield        = 'KSTAR'
791    *      dynpprog        = sy-repid
792    *      dynpnr          = sy-dynnr "'1000'
793    *      dynprofield     = 'S_KTOP'
794    *      value_org       = 'S'
795    *    TABLES
796    *      value_tab       = gt_cska
797    *    EXCEPTIONS
798    *      parameter_error = 1
799    *      no_values_found = 2
800    *      OTHERS          = 3.
801    *
802    *
803    **********************  COde added by Rahul Gupta  **********************
804    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop2-high.
805    **
806    **  SELECT *
807    **  FROM TKA02
808    **  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
809    ***  WHERE BUKRS = S_KOKRS.
810    **   WHERE BUKRS = P_BUKRS.
811    *
812    **  IF GT_TKA02 IS NOT INITIAL.
813    *
814    *  SELECT ktopl kstar
815    *     FROM cska
816    *     INTO TABLE gt_cska
817    *     WHERE ktopl = 'ONGC'.
818    *
819    *
820    **    IF GT_SETLEAF IS   NOT INITIAL.
821    **      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
822    **      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
823    **    ENDIF.
824    **  ENDIF.
825    *
826    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
827    *    EXPORTING
828    *      retfield        = 'KSTAR'
829    *      dynpprog        = sy-repid
830    *      dynpnr          = sy-dynnr "'1000'
831    *      dynprofield     = 'S_KTOP'
832    *      value_org       = 'S'
833    *    TABLES
834    *      value_tab       = gt_cska
835    *    EXCEPTIONS
836    *      parameter_error = 1
837    *      no_values_found = 2
838    *      OTHERS          = 3.
839    *
840    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop3-low.
841    **
842    **  SELECT *
843    **  FROM TKA02
844    **  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
845    ***  WHERE BUKRS = S_KOKRS.
846    **   WHERE BUKRS = P_BUKRS.
847    *
848    **  IF GT_TKA02 IS NOT INITIAL.
849    *  SELECT ktopl kstar
850    *     FROM cska
851    *     INTO TABLE gt_cska
852    *     WHERE ktopl = 'ONGC'.
853    *
854    *
855    *
856    **    IF GT_SETLEAF IS   NOT INITIAL.
857    **      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
858    **      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
859    **    ENDIF.
860    **  ENDIF.
861    *
862    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
863    *    EXPORTING
864    *      retfield        = 'KSTAR'
865    *      dynpprog        = sy-repid
866    *      dynpnr          = sy-dynnr "'1000'
867    *      dynprofield     = 'S_KTOP'
868    *      value_org       = 'S'
869    *    TABLES
870    *      value_tab       = gt_cska
871    *    EXCEPTIONS
872    *      parameter_error = 1
873    *      no_values_found = 2
874    *      OTHERS          = 3.
875    *
876    *
877    **********************  COde added by Rahul Gupta  **********************
878    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop3-high.
879    **
880    **  SELECT *
881    **  FROM TKA02
882    **  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
883    ***  WHERE BUKRS = S_KOKRS.
884    **   WHERE BUKRS = P_BUKRS.
885    *
886    **  IF GT_TKA02 IS NOT INITIAL.
887    *  SELECT ktopl kstar
888    *     FROM cska
889    *     INTO TABLE gt_cska
890    *     WHERE ktopl = 'ONGC'.
891    *
892    *
893    *
894    **    IF GT_SETLEAF IS   NOT INITIAL.
895    **      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
896    **      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
897    **    ENDIF.
898    **  ENDIF.
899    *
900    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
901    *    EXPORTING
902    *      retfield        = 'KSTAR'
903    *      dynpprog        = sy-repid
904    *      dynpnr          = sy-dynnr "'1000'
905    *      dynprofield     = 'S_KTOP'
906    *      value_org       = 'S'
907    *    TABLES
908    *      value_tab       = gt_cska
909    *    EXCEPTIONS
910    *      parameter_error = 1
911    *      no_values_found = 2
912    *      OTHERS          = 3.
913
914    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls-low.
915
916      SELECT setclass subclass setname
917         FROM setleaf
918         INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
919         WHERE setclass = '0102'
920         AND   subclass = 'ONGC'.
921
922      IF gt_setleaf IS   NOT INITIAL.
923        SORT gt_setleaf BY setclass subclass setname.
924        DELETE ADJACENT DUPLICATES FROM gt_setleaf.
925      ENDIF.
926
927
928
929
930      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
931        EXPORTING
932          retfield        = 'SETNAME'
933          dynpprog        = sy-repid
934          dynpnr          = sy-dynnr "'1000'
935          dynprofield     = 'S_SECLS'
936          value_org       = 'S'
937        TABLES
938          value_tab       = gt_setleaf
939        EXCEPTIONS
940          parameter_error = 1
941          no_values_found = 2
942          OTHERS          = 3.
943
944    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls1-low.
945    *
946    *  SELECT setclass subclass setname
947    *     FROM setleaf
948    *     INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
949    *     WHERE setclass = '0102'
950    *     AND   subclass = 'ONGC'.
951    *
952    *  IF gt_setleaf IS   NOT INITIAL.
953    *    SORT gt_setleaf BY setclass subclass setname.
954    *    DELETE ADJACENT DUPLICATES FROM gt_setleaf.
955    *  ENDIF.
956    *
957    *
958    *
959    *
960    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
961    *    EXPORTING
962    *      retfield        = 'SETNAME'
963    *      dynpprog        = sy-repid
964    *      dynpnr          = sy-dynnr "'1000'
965    *      dynprofield     = 'S_SECLS'
966    *      value_org       = 'S'
967    *    TABLES
968    *      value_tab       = gt_setleaf
969    *    EXCEPTIONS
970    *      parameter_error = 1
971    *      no_values_found = 2
972    *      OTHERS          = 3.
973    *
974    *
975    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls2-low.
976    *
977    *  SELECT setclass subclass setname
978    *     FROM setleaf
979    *     INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
980    *     WHERE setclass = '0102'
981    *     AND   subclass = 'ONGC'.
982    *
983    *  IF gt_setleaf IS   NOT INITIAL.
984    *    SORT gt_setleaf BY setclass subclass setname.
985    *    DELETE ADJACENT DUPLICATES FROM gt_setleaf.
986    *  ENDIF.
987    *
988    *
989    *
990    *
991    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
992    *    EXPORTING
993    *      retfield        = 'SETNAME'
994    *      dynpprog        = sy-repid
995    *      dynpnr          = sy-dynnr "'1000'
996    *      dynprofield     = 'S_SECLS'
997    *      value_org       = 'S'
998    *    TABLES
999    *      value_tab       = gt_setleaf
1000   *    EXCEPTIONS
1001   *      parameter_error = 1
1002   *      no_values_found = 2
1003   *      OTHERS          = 3.
1004   *
1005   *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls3-low.
1006   *
1007   *  SELECT setclass subclass setname
1008   *     FROM setleaf
1009   *     INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
1010   *     WHERE setclass = '0102'
1011   *     AND   subclass = 'ONGC'.
1012   *
1013   *  IF gt_setleaf IS   NOT INITIAL.
1014   *    SORT gt_setleaf BY setclass subclass setname.
1015   *    DELETE ADJACENT DUPLICATES FROM gt_setleaf.
1016   *  ENDIF.
1017   *
1018   *
1019   *
1020   *
1021   *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1022   *    EXPORTING
1023   *      retfield        = 'SETNAME'
1024   *      dynpprog        = sy-repid
1025   *      dynpnr          = sy-dynnr "'1000'
1026   *      dynprofield     = 'S_SECLS'
1027   *      value_org       = 'S'
1028   *    TABLES
1029   *      value_tab       = gt_setleaf
1030   *    EXCEPTIONS
1031   *      parameter_error = 1
1032   *      no_values_found = 2
1033   *      OTHERS          = 3.
*--- End of ZFI_FCTR_REVALLOC_SS - 1033 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_FCTR_REVALLOC_FR                      Level 1    Page 4
Object           ZFI_FCTR_REVALLOC_POST                    Lines 2353
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_FCTR_REVALLOC_FR
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
13
14       SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
15        FROM coep
16        INTO CORRESPONDING FIELDS OF TABLE gt_coep
17        WHERE kokrs IN s_kokrs
18        AND perio IN s_period
19        AND ( kstar IN s_gl AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%'  )
20        AND gjahr = p_year
21        AND objnr LIKE 'PR%'
22        AND lednr = '00'
23        AND wrttp NE '60'.
24
25
26       IF gt_coep IS NOT INITIAL.
27         SORT gt_coep BY kstar objnr.
28     **  BREAK-POINT.
29         LOOP AT gt_coep INTO gs_coep.
30
31           MOVE-CORRESPONDING gs_coep TO gs_coep1.
32           COLLECT gs_coep1 INTO gt_coep1.
33           CLEAR gs_coep1.
34         ENDLOOP.
35       ENDIF.
36
37       SELECT pspnr pbukr pkokr posid objnr akstl
38          FROM prps
39          INTO  TABLE gt_prps
40          FOR ALL ENTRIES IN gt_coep1
41          WHERE objnr = gt_coep1-objnr
42          AND pbukr = 'OVL'
43          AND pkokr = 'OVL'.
44
45
46       LOOP AT gt_coep1 INTO gs_coep1.
47         MOVE-CORRESPONDING gs_coep1 TO gs_final.
48         READ TABLE gt_prps INTO gs_prps WITH KEY objnr = gs_coep1-objnr.
49         IF sy-subrc = 0.
50           gs_final-pspnr = gs_prps-pspnr.
51           gs_final-akstl = gs_prps-akstl.
52         ENDIF.
53         gs_final-wogbtr = gs_final-wogbtr * -1.
54         gs_final-wkgbtr = gs_final-wkgbtr * -1.
55         APPEND gs_final TO gt_final.
56         CLEAR gs_final.
57
58       ENDLOOP.
59
60
61       LOOP AT gt_final INTO gs_final WHERE kstar = '0000209999'.
62
63
64     * gs_final-wogbtr = gs_final-wogbtr * -1.
65     * gs_final-wkgbtr = gs_final-wkgbtr * -1.
66
67
68         READ TABLE gt_coep1 INTO gs_coep1 WITH KEY kstar = '0000500120'
69                                                    objnr = gs_final-objnr .
70
71         IF sy-subrc = 0.
72           gs_final-wogbtr = gs_final-wogbtr - gs_coep1-wogbtr.
73           gs_final-wkgbtr = gs_final-wkgbtr - gs_coep1-wkgbtr.
74
75
76         ENDIF.
77
78         READ TABLE gt_coep1 INTO gs_coep1 WITH KEY kstar = '0000502010'
79                                                      objnr = gs_final-objnr .
80         IF sy-subrc = 0.
81           gs_final-wogbtr = gs_final-wogbtr - gs_coep1-wogbtr.
82           gs_final-wkgbtr = gs_final-wkgbtr - gs_coep1-wkgbtr.
83         ENDIF.
84
85         MODIFY gt_final FROM gs_final.
86         CLEAR: gs_final , gs_coep1.
87       ENDLOOP.
88
89       DELETE gt_final WHERE kstar CP '00005*'.
90     *LOOP AT gt_final INTO gs_final.
91     *
92     *wogbtr_diff = wogbtr_diff + gs_final-wogbtr.
93     *wkgbtr_diff = wkgbtr_diff + gs_final-wkgbtr.
94     *ENDLOOP.
95     *
96     *clear gs_final.
97     *gs_final-KSTAR = '0000200886'.
98     *gs_final-AKSTL = 'OVLJVCP001'.
99     *gs_final-wogbtr = wogbtr_diff * -1.
100    *gs_final-wkgbtr = wkgbtr_diff * -1.
101    *
102    *APPEND gs_final to gt_final.
103    *clear gs_final.
104
105
106
107    ***   BOC by ss on 21.9.2021 ***
108      LOOP AT gt_final INTO gs_final.
109        SELECT SINGLE asaknr FROM zfi_fctr_gl
110                             INTO CORRESPONDING FIELDS OF gs_final
111                             WHERE osaknr EQ gs_final-kstar.
112
113        SHIFT gs_final-asaknr LEFT DELETING LEADING '0'.
114        MODIFY gt_final FROM gs_final.
115
116      ENDLOOP.
117    **   EOC by ss on 21.9.2021
118
119
120    ENDFORM.
121
122
123    FORM get_data_cc .
124
125      SELECT *
126     FROM tka02
127     INTO CORRESPONDING FIELDS OF TABLE gt_tka02
128    *  WHERE BUKRS = S_KOKRS.
129      WHERE bukrs = p_bukrs.
130    *********** For Quarter 1
131      IF gt_tka02 IS NOT INITIAL.
132        IF s_senm IS INITIAL.
133
134          SELECT kokrs kostl objnr
135                  FROM csks
136                  INTO TABLE gt_csks
137
138                  WHERE kostl = S_Kokr
139                  AND kokrs = p_bukrs.
140        ELSE.
141          SELECT setclass subclass setname valfrom
142                FROM setleaf
143                INTO TABLE gt_setleaf
144                FOR ALL ENTRIES IN gt_tka02
145                WHERE setname IN s_senm
146                AND   subclass = gt_tka02-kokrs.
147
148        ENDIF.
149
150        IF s_secls IS INITIAL.
151
152          REFRESH r_gl1.
153          LOOP AT s_ktop.
154            r_gl1-sign = s_ktop-sign.
155            r_gl1-option = s_ktop-option.
156            r_gl1-low = s_ktop-low.
157            r_gl1-high = s_ktop-high.
158            APPEND r_gl1.
159            CLEAR: r_gl1, gs_setleaf5.
160          ENDLOOP.
161
162        ELSE.
163          SELECT *
164                FROM setleaf
165                INTO TABLE gt_setleaf5
166                WHERE setname IN s_secls
167                AND   subclass = 'ONGC'.
168
169        ENDIF.
170        IF gt_setleaf IS   NOT INITIAL.
171          SORT gt_setleaf BY valfrom.
172          DELETE ADJACENT DUPLICATES FROM gt_setleaf.
173          SELECT kokrs kostl objnr
174            FROM csks
175            INTO TABLE gt_csks
176            FOR ALL ENTRIES IN gt_setleaf
177            WHERE kostl = gt_setleaf-valfrom+0(10)
178            AND kokrs = p_bukrs.
179        ENDIF.
180      ENDIF.
181      IF gt_setleaf5 IS NOT INITIAL.
182        REFRESH  r_gl1[].
183        LOOP AT gt_setleaf5 INTO gs_setleaf5.
184          r_gl1-sign = gs_setleaf5-valsign.
185          r_gl1-option = gs_setleaf5-valoption.
186          r_gl1-low = gs_setleaf5-valfrom.
187          r_gl1-high = gs_setleaf5-valto.
188          APPEND r_gl1.
189          CLEAR: r_gl1, gs_setleaf5.
190        ENDLOOP.
191      ENDIF.
192
193      IF gt_csks IS NOT INITIAL.
194        SORT gt_csks BY objnr.
195        DELETE ADJACENT DUPLICATES FROM gt_csks COMPARING objnr.
196        SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
197          FROM coep
198          INTO CORRESPONDING FIELDS OF TABLE gt_coep
199          FOR ALL ENTRIES IN gt_csks
200          WHERE objnr = gt_csks-objnr
201          AND kokrs IN s_kokrs
202          AND perio IN s_period
203          AND ( kstar IN s_gl  AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%' AND kstar IN r_gl1 )
204          AND gjahr = p_year
205          AND lednr = '00'
206          AND wrttp NE '60'.
207
208      ENDIF.
209
210      IF gt_coep IS NOT INITIAL.
211        SORT gt_coep BY kstar objnr.
212    **  BREAK-POINT.
213        LOOP AT gt_coep INTO gs_coep.
214
215          MOVE-CORRESPONDING gs_coep TO gs_coep1.
216          COLLECT gs_coep1 INTO gt_coep1.
217          CLEAR gs_coep1.
218        ENDLOOP.
219      ENDIF.
220
221      LOOP AT gt_coep1 INTO gs_coep1.
222        MOVE-CORRESPONDING gs_coep1 TO gs_final.
223        gs_final-akstl = gs_final-objnr+6(10).
224        gs_final-wogbtr = gs_final-wogbtr * -1.
225        gs_final-wkgbtr = gs_final-wkgbtr * -1.
226        APPEND gs_final TO gt_final.
227        CLEAR gs_final.
228
229      ENDLOOP.
230
231      CLEAR gs_final.
232
233      SORT gt_final BY kstar akstl.
234      READ TABLE gt_final INTO gs_final WITH KEY kstar =  '0000209999'.
235      IF sy-subrc NE 0.
236
237        LOOP AT gt_final INTO gs_final WHERE kstar = '0000500120' OR kstar =  '0000502010'.
238
239          gs_final-kstar = '0000209999'.
240    *   gs_final-wogbtr = gs_final-wogbtr - gs_coep1-wogbtr.
241    *   gs_final-wkgbtr = gs_final-wkgbtr - gs_coep1-wkgbtr.
242
243          COLLECT gs_final INTO gt_final.
244
245
246        ENDLOOP.
247      ENDIF.
248
249      DELETE gt_final WHERE kstar CP '00005*'.
250
251
252
253
254    ***   BOC by ss on 21.9.2021 ***
255      LOOP AT gt_final INTO gs_final.
256        SELECT SINGLE asaknr FROM zfi_fctr_gl
257                             INTO CORRESPONDING FIELDS OF gs_final
258                             WHERE osaknr EQ gs_final-kstar.
259
260
261        SHIFT gs_final-asaknr LEFT DELETING LEADING '0'.
262
263
264        MODIFY gt_final FROM gs_final.
265
266      ENDLOOP.
267    **   EOC by ss on 21.9.2021
268
269
270
271
272    ENDFORM.
273
274    *&---------------------------------------------------------------------*
275    *&      Form  ALV_FIELDCAT
276    *&---------------------------------------------------------------------*
277    *       text
278    *----------------------------------------------------------------------*
279    *  -->  p1        text
280    *  <--  p2        text
281    *----------------------------------------------------------------------*
282    FORM alv_fieldcat .
283
284      CLEAR wa_fieldcat.
285      DATA counter TYPE i.
286      counter = counter + 1.
287      wa_fieldcat-col_pos = counter.
288      wa_fieldcat-fieldname = 'KSTAR'.
289      wa_fieldcat-no_zero = 'X'.
290      wa_fieldcat-seltext_m = 'GL'.
291      APPEND wa_fieldcat TO it_fieldcat .
292      CLEAR wa_fieldcat .
293
294
295
296    **  BOC by ss on 21.9.2021
297
298      CLEAR wa_fieldcat.
299      counter = counter + 1.
300      wa_fieldcat-col_pos = counter.
301      wa_fieldcat-fieldname = 'ASAKNR'.
302    *  wa_fieldcat-no_zero = 'X'.
303      wa_fieldcat-seltext_m = 'Adjustment G/L'.
304      APPEND wa_fieldcat TO it_fieldcat .
305      CLEAR wa_fieldcat .
306
307
308    **  EOC by ss on 21.9.2021
309
310
311
312      IF r1 = 'X'.
313
314
315
316        counter = counter + 1.
317        wa_fieldcat-col_pos = counter.
318        wa_fieldcat-fieldname = 'PSPNR'.
319    *  wa_fieldcat-no_zero = 'X'.
320        wa_fieldcat-seltext_m = 'WBS'.
321        APPEND wa_fieldcat TO it_fieldcat .
322        CLEAR wa_fieldcat .
323
324        counter = counter + 1.
325        wa_fieldcat-col_pos = counter.
326        wa_fieldcat-fieldname = 'OBJNR'.
327    *  wa_fieldcat-no_zero = 'X'.
328        wa_fieldcat-seltext_m = 'Object No.'.
329        APPEND wa_fieldcat TO it_fieldcat .
330        CLEAR wa_fieldcat .
331      ENDIF.
332      counter = counter + 1.
333      wa_fieldcat-col_pos = counter.
334      wa_fieldcat-fieldname = 'AKSTL'.
335    *  wa_fieldcat-no_zero = 'X'.
336      wa_fieldcat-seltext_m = 'Cost Center'.
337      APPEND wa_fieldcat TO it_fieldcat .
338      CLEAR wa_fieldcat .
339
340      IF r1 = 'X'.
341        IF n = 1.
342          counter = counter + 1.
343          wa_fieldcat-col_pos   = counter.
344          wa_fieldcat-fieldname = 'WOGBTR'.
345          wa_fieldcat-seltext_m =   'WBS INR Ad. Q1'.
346          APPEND wa_fieldcat TO it_fieldcat .
347          CLEAR wa_fieldcat .
348
349          counter = counter + 1.
350          wa_fieldcat-col_pos   = counter.
351          wa_fieldcat-fieldname = 'WKGBTR'.
352          wa_fieldcat-seltext_m =   'WBS USD Ad. Q1 '.
353          APPEND wa_fieldcat TO it_fieldcat .
354          CLEAR wa_fieldcat .
355
356        ELSEIF n = 2.
357
358          counter = counter + 1.
359          wa_fieldcat-col_pos   = counter.
360          wa_fieldcat-fieldname = 'WOGBTR'.
361          wa_fieldcat-seltext_m =   'WBS INR Ad. Q2'.
362          APPEND wa_fieldcat TO it_fieldcat .
363          CLEAR wa_fieldcat .
364
365          counter = counter + 1.
366          wa_fieldcat-col_pos   = counter.
367          wa_fieldcat-fieldname = 'WKGBTR'.
368          wa_fieldcat-seltext_m =   'WBS USD Ad. Q2'.
369          APPEND wa_fieldcat TO it_fieldcat .
370          CLEAR wa_fieldcat .
371
372        ELSEIF n = 3.
373
374          counter = counter + 1.
375          wa_fieldcat-col_pos   = counter.
376          wa_fieldcat-fieldname = 'WOGBTR'.
377          wa_fieldcat-seltext_m =   'WBS INR Ad. Q3'.
378          APPEND wa_fieldcat TO it_fieldcat .
379          CLEAR wa_fieldcat .
380
381          counter = counter + 1.
382          wa_fieldcat-col_pos   = counter.
383          wa_fieldcat-fieldname = 'WKGBTR'.
384          wa_fieldcat-seltext_m =   'WBS USD Ad. Q3'.
385          APPEND wa_fieldcat TO it_fieldcat .
386          CLEAR wa_fieldcat .
387
388        ELSEIF n = 4.
389
390          counter = counter + 1.
391          wa_fieldcat-col_pos   = counter.
392          wa_fieldcat-fieldname = 'WOGBTR'.
393          wa_fieldcat-seltext_m =   'WBS INR Ad. Q4'.
394          APPEND wa_fieldcat TO it_fieldcat .
395          CLEAR wa_fieldcat .
396
397          counter = counter + 1.
398          wa_fieldcat-col_pos   = counter.
399          wa_fieldcat-fieldname = 'WKGBTR'.
400          wa_fieldcat-seltext_m =   'WBS USD Ad. Q4'.
401          APPEND wa_fieldcat TO it_fieldcat .
402          CLEAR wa_fieldcat .
403
404        ENDIF.
405      ELSE.
406        IF n = 1.
407          counter = counter + 1.
408          wa_fieldcat-col_pos   = counter.
409          wa_fieldcat-fieldname = 'WOGBTR'.
410          wa_fieldcat-seltext_m =   'CC INR Ad. Q1'.
411          APPEND wa_fieldcat TO it_fieldcat .
412          CLEAR wa_fieldcat .
413
414          counter = counter + 1.
415          wa_fieldcat-col_pos   = counter.
416          wa_fieldcat-fieldname = 'WKGBTR'.
417          wa_fieldcat-seltext_m =   'CC USD Ad. Q1 '.
418          APPEND wa_fieldcat TO it_fieldcat .
419          CLEAR wa_fieldcat .
420
421        ELSEIF n = 2.
422
423          counter = counter + 1.
424          wa_fieldcat-col_pos   = counter.
425          wa_fieldcat-fieldname = 'WOGBTR'.
426          wa_fieldcat-seltext_m =   'CC INR Ad. Q2'.
427          APPEND wa_fieldcat TO it_fieldcat .
428          CLEAR wa_fieldcat .
429
430          counter = counter + 1.
431          wa_fieldcat-col_pos   = counter.
432          wa_fieldcat-fieldname = 'WKGBTR'.
433          wa_fieldcat-seltext_m =   'CC USD Ad. Q2'.
434          APPEND wa_fieldcat TO it_fieldcat .
435          CLEAR wa_fieldcat .
436
437        ELSEIF n = 3.
438
439          counter = counter + 1.
440          wa_fieldcat-col_pos   = counter.
441          wa_fieldcat-fieldname = 'WOGBTR'.
442          wa_fieldcat-seltext_m =   'CC INR Ad. Q3'.
443          APPEND wa_fieldcat TO it_fieldcat .
444          CLEAR wa_fieldcat .
445
446          counter = counter + 1.
447          wa_fieldcat-col_pos   = counter.
448          wa_fieldcat-fieldname = 'WKGBTR'.
449          wa_fieldcat-seltext_m =   'CC USD Ad. Q3'.
450          APPEND wa_fieldcat TO it_fieldcat .
451          CLEAR wa_fieldcat .
452
453        ELSEIF n = 4.
454
455          counter = counter + 1.
456          wa_fieldcat-col_pos   = counter.
457          wa_fieldcat-fieldname = 'WOGBTR'.
458          wa_fieldcat-seltext_m =   'CC INR Ad. Q4'.
459          APPEND wa_fieldcat TO it_fieldcat .
460          CLEAR wa_fieldcat .
461
462          counter = counter + 1.
463          wa_fieldcat-col_pos   = counter.
464          wa_fieldcat-fieldname = 'WKGBTR'.
465          wa_fieldcat-seltext_m =   'CC USD Ad. Q4'.
466          APPEND wa_fieldcat TO it_fieldcat .
467          CLEAR wa_fieldcat .
468        ENDIF.
469
470      ENDIF.
471    ENDFORM.
472    *&---------------------------------------------------------------------*
473    *&      Form  ALV_DISPLAY
474    *&---------------------------------------------------------------------*
475    *       text
476    *----------------------------------------------------------------------*
477    *  -->  p1        text
478    *  <--  p2        text
479    *----------------------------------------------------------------------*
480    FORM alv_display .
481      gs_layout-zebra = 'X'.
482      gs_layout-detail_popup = 'X'.
483      gs_layout-detail_initial_lines = 'X'.
484      gs_layout-colwidth_optimize = 'X'.
485      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
486        EXPORTING
487          it_fieldcat              = it_fieldcat
488          it_events                = it_events[]
489          i_callback_program       = sy-repid
490          is_layout                = gs_layout
491          it_sort                  = gt_sort[]
492          i_save                   = g_save
493          is_variant               = gx_variant
494          i_callback_pf_status_set = 'ZSTATUS2'  "uncommented on 28.5.21
495          i_callback_user_command  = 'USER_COMMAND'  "uncommented on 28.5.21
496        TABLES
497          t_outtab                 = gt_final[].
498    ENDFORM.
499    *&---------------------------------------------------------------------*
500    *&      Form  GET_EVENT
501    *&---------------------------------------------------------------------*
502    *       text
503    *----------------------------------------------------------------------*
504    *  -->  p1        text
505    *  <--  p2        text
506    *----------------------------------------------------------------------*
507    FORM get_event .
508      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
509        EXPORTING
510          i_list_type     = 0
511        IMPORTING
512          et_events       = it_events[]
513        EXCEPTIONS
514          list_type_wrong = 1
515          OTHERS          = 2.
516      IF sy-subrc <> 0.
517        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
518        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
519      ENDIF.
520      READ TABLE it_events WITH KEY name = slis_ev_top_of_page
521      INTO it_events.
522      IF sy-subrc = 0.
523        MOVE t_formname_top_of_page TO it_events-form.
524        APPEND it_events.
525      ENDIF.
526    ENDFORM.
527    *&---------------------------------------------------------------------*
528    *&      Form  SUB_COMMENT_BUILD
529    *&---------------------------------------------------------------------*
530    *       text
531    *----------------------------------------------------------------------*
532    *      -->P_T_LIST_TOP_OF_PAGE  text
533    *----------------------------------------------------------------------*
534    FORM sub_comment_build  USING    p_t_list_top_of_page  TYPE slis_t_listheader.
535      DATA: ls_line TYPE slis_listheader.
536      DATA: wrk_name TYPE string.
537      DATA : date TYPE char10.
538      wrk_name = ''.
539      CLEAR ls_line.
540      ls_line-typ = 'H'.
541      ls_line-info = wrk_name.
542      APPEND ls_line TO p_t_list_top_of_page.
543      IF p_budat IS NOT INITIAL.
544        CONCATENATE p_budat+6(2) '.' p_budat+4(2) '.' p_budat+0(4) INTO date.
545        CONCATENATE TEXT-h02 'Date of report : ' date INTO ls_line-info SEPARATED BY space.
546        ls_line-typ = 'S'.
547        APPEND ls_line TO p_t_list_top_of_page.
548      ENDIF.
549    ENDFORM.
550    *&---------------------------------------------------------------------*
551    *&      Form  F_MONTH_HELP1
552    *&---------------------------------------------------------------------*
553    *       text
554    *----------------------------------------------------------------------*
555    *  -->  p1        text
556    *  <--  p2        text
557    *----------------------------------------------------------------------*
558
559    FORM f_month_help1 .
560      REFRESH lt_read[].
561      REFRESH lt_month[].
562      CONSTANTS: lc_11 TYPE i VALUE 11.
563      ls_read-fieldname = 'P_YEAR'.
564      APPEND ls_read TO lt_read.
565      CALL FUNCTION 'DYNP_VALUES_READ'
566        EXPORTING
567          dyname               = sy-cprog
568          dynumb               = sy-dynnr
569        TABLES
570          dynpfields           = lt_read
571        EXCEPTIONS
572          invalid_abapworkarea = 1
573          invalid_dynprofield  = 2
574          invalid_dynproname   = 3
575          invalid_dynpronummer = 4
576          invalid_request      = 5
577          no_fielddescription  = 6
578          invalid_parameter    = 7
579          undefind_error       = 8
580          double_conversion    = 9
581          stepl_not_found      = 10
582          OTHERS               = lc_11 ##FM_SUBRC_OK.
583      READ TABLE lt_read INTO ls_read INDEX 1.
584      ls_month-month = '01'.
585      ls_month-text = 'April' && ls_read-fieldvalue.
586      APPEND ls_month TO lt_month.
587      ls_month-month = '02'.
588      ls_month-text = 'May' && ls_read-fieldvalue.
589      APPEND ls_month TO lt_month.
590      ls_month-month = '03'.
591      ls_month-text = 'June' && ls_read-fieldvalue.
592      APPEND ls_month TO lt_month.
593      ls_month-month = '04'.
594      ls_month-text = 'July' && ls_read-fieldvalue.
595      APPEND ls_month TO lt_month.
596      ls_month-month = '05'.
597      ls_month-text = 'August' && ls_read-fieldvalue.
598      APPEND ls_month TO lt_month.
599      ls_month-month = '06'.
600      ls_month-text = 'September' && ls_read-fieldvalue.
601      APPEND ls_month TO lt_month.
602      ls_month-month = '07'.
603      ls_month-text = 'October' && ls_read-fieldvalue.
604      APPEND ls_month TO lt_month.
605      ls_month-month = '08'.
606      ls_month-text = 'November' && ls_read-fieldvalue.
607      APPEND ls_month TO lt_month.
608      ls_month-month = '09'.
609      ls_month-text = 'December' && ls_read-fieldvalue.
610      APPEND ls_month TO lt_month.
611      ls_month-month = '10'.
612      DATA : year TYPE i.
613      year = ls_read-fieldvalue + 1.
614      ls_month-text = 'January'.
615      APPEND ls_month TO lt_month.
616      ls_month-month = '11'.
617    * ls_read-fieldvalue = ls_read-fieldvalue + 1.
618      ls_month-text = 'February'.
619      APPEND ls_month TO lt_month.
620      ls_month-month = '12'.
621    * ls_read-fieldvalue = ls_read-fieldvalue + 1.
622      ls_month-text = 'March' .
623      APPEND ls_month TO lt_month.
624      ls_month-month = '13'.
625      ls_month-text = 'Special period 1'.
626      APPEND ls_month TO lt_month.
627      ls_month-month = '14'.
628      ls_month-text = 'Special period 2'.
629      APPEND ls_month TO lt_month.
630      ls_month-month = '15'.
631      ls_month-text = 'Special period 3'.
632      APPEND ls_month TO lt_month.
633      ls_month-month = '16'.
634      ls_month-text = 'Special period 4'.
635      APPEND ls_month TO lt_month.
636      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
637        EXPORTING
638          retfield         = 'S_PERIOD'
639          dynpprog         = sy-repid
640          dynpnr           = sy-dynnr
641          dynprofield      = 'S_PERIOD-HIGH'
642          value_org        = 'S'
643          callback_program = sy-repid
644        TABLES
645          value_tab        = lt_month
646        EXCEPTIONS
647          parameter_error  = 1
648          no_values_found  = 2
649          OTHERS           = 3 ##FM_SUBRC_OK.
650
651    ENDFORM.
652
653
654    FORM s_kokr_help .
655
656    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR-LOW.
657
658      SELECT *
659      FROM tka02
660      INTO CORRESPONDING FIELDS OF TABLE gt_tka02_1
661    *  WHERE BUKRS = S_KOKRS.
662      WHERE bukrs = p_bukrs.
663
664      IF gt_tka02_1 IS NOT INITIAL.
665        SELECT kokrs kostl
666           FROM csks
667           INTO TABLE gt_csks
668           FOR ALL ENTRIES IN gt_tka02_1
669        WHERE kokrs = gt_tka02_1-kokrs.
670
671        IF gt_csks IS   NOT INITIAL.
672          SORT gt_csks BY kokrs kostl.
673          DELETE ADJACENT DUPLICATES FROM gt_csks.
674        ENDIF.
675      ENDIF.
676
677      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
678        EXPORTING
679          retfield        = 'KOSTL'
680    *     RETFIELD        = 'KOSTL'
681          dynpprog        = sy-repid
682          dynpnr          = sy-dynnr "'1000'
683          dynprofield     = 'S_KOKR'
684          value_org       = 'S'
685        TABLES
686          value_tab       = gt_csks
687        EXCEPTIONS
688          parameter_error = 1
689          no_values_found = 2
690          OTHERS          = 3.
691
692    ENDFORM.
693    *&---------------------------------------------------------------------*
694    *&      Form  S_PSPID_HELP
695    *&---------------------------------------------------------------------*
696    *       text
697    *----------------------------------------------------------------------*
698    *  -->  p1        text
699    *  <--  p2        text
700    *----------------------------------------------------------------------*
701    FORM s_pspid_help .
702      DATA srch_str(20) TYPE c.
703      srch_str = 'OV%'.
704    *  CONCATENATE srch_str '*' INTO srch_str.
705      SELECT postu post1 poski pspnr posid pspid
706    *  SELECT POSID PSPID
707        FROM v_prpmp
708        INTO TABLE gt_v_prpmp
709      WHERE pspid LIKE srch_str.
710
711
712      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
713        EXPORTING
714          retfield        = 'PSPID'
715    *     RETFIELD        = 'KOSTL'
716          dynpprog        = sy-repid
717          dynpnr          = sy-dynnr "'1000'
718          dynprofield     = 'S_PSPID'
719          value_org       = 'S'
720        TABLES
721          value_tab       = gt_v_prpmp
722        EXCEPTIONS
723          parameter_error = 1
724          no_values_found = 2
725          OTHERS          = 3.
726
727
728    ENDFORM.
729    *&---------------------------------------------------------------------*
730    *&      Form  GET_DATA_CC
731    *&---------------------------------------------------------------------*
732    *       text
733    *----------------------------------------------------------------------*
734    *  -->  p1        text
735    *  <--  p2        text
736    *----------------------------------------------------------------------*
737
738    ****Added on 28.5.21
739
740    FORM  zstatus2 USING rt_extab TYPE slis_t_extab.
741
742      IF r1 = 'X'.
743        SET PF-STATUS 'ZSTATUS2'.
744      ELSE.
745        SET PF-STATUS 'ZSTATUS3'.
746      ENDIF.
747
748    ENDFORM.
749
750    FORM user_command USING ucomm TYPE sy-ucomm
751                            selfield TYPE slis_selfield.
752
753      DATA : msgv(100) TYPE c.
754
755    * BREAK abapuser02.
756      DATA : lc_que TYPE char1024.
757      DATA  : lv_answer  TYPE char1,
758              usdamt(15) TYPE c,
759              inramt(15) TYPE c.
760      CLEAR lv_answer
761      .
762      BREAK abapuser02.
763      CLEAR : wogbtr_diff , wkgbtr_diff.
764
765    *delete gt_final WHERE
766      LOOP AT gt_final INTO gs_final.
767
768        wogbtr_diff = wogbtr_diff + gs_final-wogbtr.
769        wkgbtr_diff = wkgbtr_diff + gs_final-wkgbtr.
770      ENDLOOP.
771
772      IF abs( wogbtr_diff )  GT '1000' OR abs( wkgbtr_diff )  GT '10'.
773        MESSAGE 'Difference too large.Document cannot be posted.' TYPE 'E'.
774      ENDIF.
775      usdamt = wkgbtr_diff.
776      inramt = wogbtr_diff.
777
778      IF wkgbtr_diff IS NOT INITIAL OR wogbtr_diff IS NOT INITIAL.
779        CONCATENATE 'Balance of' inramt 'INR' 'and' usdamt 'USD' 'in document. Do you still want to post?' INTO
780          lc_que SEPARATED BY space.
781
782
783
784
785        CALL FUNCTION 'POPUP_TO_CONFIRM'
786          EXPORTING
787            titlebar              = 'Please Confirm'
788            text_question         = lc_que
789            text_button_1         = 'Yes'
790            text_button_2         = 'No'
791            display_cancel_button = abap_false
792          IMPORTING
793            answer                = lv_answer
794          EXCEPTIONS
795            text_not_found        = 1
796            OTHERS                = 2.
797
798        CHECK lv_answer = 1.
799
800      ENDIF.
801
802      IF  wogbtr_diff IS  INITIAL AND wkgbtr_diff IS  INITIAL.
803
804      ELSE.
805
806
807        CLEAR gs_final.
808        gs_final-kstar = '0000200886'.
809        gs_final-akstl = 'OVLJVCP001'.
810        gs_final-wogbtr = wogbtr_diff * -1.
811        gs_final-wkgbtr = wkgbtr_diff * -1.
812
813        APPEND gs_final TO gt_final.
814
815      ENDIF.
816      CLEAR gs_final.
817
818
819      CASE ucomm.
820
821        WHEN 'POST'.
822          CLEAR wa_post.
823          REFRESH : gt_display[].
824
825          SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
826          WHERE fyear = p_year
827          AND   fperio = s_period-low
828          AND   tperio = s_period-high
829          AND   ind = 'W'
830          AND   rev = ' '.
831
832          IF sy-subrc = 0.
833            MESSAGE 'Document for Quarter Already posted' TYPE 'I'.
834          ENDIF.
835
836          CHECK sy-subrc NE 0.
837          gt_wbs[] = gt_final[].
838          DELETE gt_wbs WHERE  wkgbtr IS INITIAL AND wogbtr IS INITIAL.
839          SELECT * FROM zfi_fctr_gl INTO TABLE @DATA(it_wbsgl).
840
841          REFRESH : gt_display1.
842          LOOP AT gt_wbs INTO gs_wbs.
843            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
844              EXPORTING
845                input  = gs_wbs-kstar
846              IMPORTING
847                output = gs_wbs-kstar.
848
849            READ TABLE it_wbsgl INTO DATA(wa_wbsgl) WITH KEY osaknr = gs_wbs-kstar.
850            IF sy-subrc NE 0.
851    *    wa_accountgl-gl_account = gs_wbs-kstar.
852    *    CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
853              gs_display1-msgid = 'ZFI1'.
854              gs_display1-msgty = 'E'.
855              gs_display1-msgno = '003'.
856              gs_display1-msgv1 = gs_wbs-kstar.
857              APPEND gs_display1 TO gt_display1.
858            ENDIF.
859
860          ENDLOOP.
861          DELETE ADJACENT DUPLICATES FROM gt_display1 COMPARING msgv1.
862          IF gt_display1[] IS INITIAL.
863            LOOP AT gt_wbs INTO gs_wbs.
864
865    *    documentheader-bus_act    = 'RFBU'.
866              documentheader-username   = sy-uname.
867              documentheader-comp_code  = 'OVL'.
868              documentheader-doc_date = p_budat.
869              documentheader-pstng_date = p_budat.
870              documentheader-doc_type   = 'FY'.
871              documentheader-header_txt    = 'WBS ADJUSTMENT'.
872              documentheader-ref_doc_no    = 'WBS ADJUSTMENT'.
873
874              counter_bapi = counter_bapi + 1.
875              wa_accountgl-itemno_acc   = counter_bapi.
876
877              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
878                EXPORTING
879                  input  = gs_wbs-kstar
880                IMPORTING
881                  output = gs_wbs-kstar.
882
883
884              READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
885              IF sy-subrc = 0.
886                wa_accountgl-gl_account = wa_wbsgl-asaknr.
887              ELSE.
888    *      wa_accountgl-gl_account = gs_wbs-kstar.
889                CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
890                MESSAGE msgv TYPE 'E'.
891                EXIT.
892              ENDIF.
893
894              wa_accountgl-item_text = 'WBS ADJUSTMENT'.
895              wa_accountgl-comp_code  = 'OVL'.
896              wa_accountgl-bus_area   = 'JV'.
897              wa_accountgl-costcenter = gs_wbs-akstl.
898
899              APPEND wa_accountgl TO it_accountgl.
900              CLEAR wa_accountgl.
901
902    ***************************************************Changed by hrishi n on 28/10/22
903              IF ( gs_wbs-wkgbtr GE 0 AND gs_wbs-wogbtr GE 0 ) OR ( gs_wbs-wkgbtr LE 0 AND gs_wbs-wogbtr LE 0 ) .
904    *    IF gs_wbs-WKGBTR lt 0.
905                wa_currencyamount-itemno_acc  = counter_bapi.
906                wa_currencyamount-curr_type = '00'.
907    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
908    *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr .
909                wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
910    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
911                wa_currencyamount-currency    = 'USD'.
912                APPEND wa_currencyamount TO it_currencyamount.
913                CLEAR : wa_currencyamount.
914
915    *      counter_bapi = counter_bapi + 1.
916                wa_currencyamount-itemno_acc  = counter_bapi.
917                wa_currencyamount-curr_type = '10'.
918    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
919    *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr .
920                wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
921    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
922                wa_currencyamount-currency = 'INR'.
923                APPEND wa_currencyamount TO it_currencyamount.
924                CLEAR : wa_currencyamount.
925    *      else.
926    *         wa_currencyamount-itemno_acc  = counter_bapi.
927    *      wa_currencyamount-curr_type = '00'.
928    *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
929    *      wa_currencyamount-currency    = 'USD'.
930    *      APPEND wa_currencyamount TO it_currencyamount.
931    *      CLEAR : wa_currencyamount.
932    *
933    **      counter_bapi = counter_bapi + 1.
934    *      wa_currencyamount-itemno_acc  = counter_bapi.
935    *      wa_currencyamount-curr_type = '10'.
936    *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
937    *      wa_currencyamount-currency = 'INR'.
938    *      APPEND wa_currencyamount TO it_currencyamount.
939    *      CLEAR : wa_currencyamount.
940    *
941    *    ENDIF.
942
943              ELSEIF gs_wbs-wkgbtr GT 0 AND gs_wbs-wogbtr LT 0.
944
945                wa_currencyamount-itemno_acc  = counter_bapi.
946                wa_currencyamount-curr_type = '00'.
947    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
948    *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
949                wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
950    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
951                wa_currencyamount-currency    = 'USD'.
952                APPEND wa_currencyamount TO it_currencyamount.
953                CLEAR : wa_currencyamount.
954
955                wa_currencyamount-itemno_acc  = counter_bapi.
956                wa_currencyamount-curr_type = '10'.
957    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
958    *            wa_currencyamount-amt_doccur  = '0.01'.
959                wa_currencyamount-amt_doccur = CONV #( '0.01' ).
960    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
961                wa_currencyamount-currency = 'INR'.
962                APPEND wa_currencyamount TO it_currencyamount.
963                CLEAR : wa_currencyamount.
964
965
966                counter_bapi = counter_bapi + 1.
967                wa_accountgl-itemno_acc   = counter_bapi.
968
969                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
970                  EXPORTING
971                    input  = gs_wbs-kstar
972                  IMPORTING
973                    output = gs_wbs-kstar.
974
975
976                READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
977                IF sy-subrc = 0.
978                  wa_accountgl-gl_account = wa_wbsgl-asaknr.
979                ELSE.
980                  CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
981                  MESSAGE msgv TYPE 'E'.
982                  EXIT.
983                ENDIF.
984
985                wa_accountgl-item_text = 'WBS ADJUSTMENT'.
986                wa_accountgl-comp_code  = 'OVL'.
987                wa_accountgl-bus_area   = 'JV'.
988                wa_accountgl-costcenter = gs_wbs-akstl.
989
990                APPEND wa_accountgl TO it_accountgl.
991                CLEAR wa_accountgl.
992
993
994                wa_currencyamount-itemno_acc  = counter_bapi.
995                wa_currencyamount-curr_type = '00'.
996    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
997    *            wa_currencyamount-amt_doccur  = '0.01-'.
998                wa_currencyamount-amt_doccur = CONV #( '0.01-' ).
999    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1000               wa_currencyamount-currency    = 'USD'.
1001               APPEND wa_currencyamount TO it_currencyamount.
1002               CLEAR : wa_currencyamount.
1003
1004               wa_currencyamount-itemno_acc  = counter_bapi.
1005               wa_currencyamount-curr_type = '10'.
1006   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1007   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1008               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1009   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1010               wa_currencyamount-currency = 'INR'.
1011               APPEND wa_currencyamount TO it_currencyamount.
1012               CLEAR : wa_currencyamount.
1013
1014             ELSEIF gs_wbs-wkgbtr LT 0 AND gs_wbs-wogbtr GT 0.
1015
1016               wa_currencyamount-itemno_acc  = counter_bapi.
1017               wa_currencyamount-curr_type = '00'.
1018   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1019   *            wa_currencyamount-amt_doccur  = '0.01'.
1020               wa_currencyamount-amt_doccur = CONV #( '0.01' ).
1021   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1022               wa_currencyamount-currency    = 'USD'.
1023               APPEND wa_currencyamount TO it_currencyamount.
1024               CLEAR : wa_currencyamount.
1025
1026               wa_currencyamount-itemno_acc  = counter_bapi.
1027               wa_currencyamount-curr_type = '10'.
1028   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1029   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1030               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1031   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1032               wa_currencyamount-currency = 'INR'.
1033               APPEND wa_currencyamount TO it_currencyamount.
1034               CLEAR : wa_currencyamount.
1035
1036
1037               counter_bapi = counter_bapi + 1.
1038               wa_accountgl-itemno_acc   = counter_bapi.
1039
1040               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1041                 EXPORTING
1042                   input  = gs_wbs-kstar
1043                 IMPORTING
1044                   output = gs_wbs-kstar.
1045
1046
1047               READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1048               IF sy-subrc = 0.
1049                 wa_accountgl-gl_account = wa_wbsgl-asaknr.
1050               ELSE.
1051                 CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1052                 MESSAGE msgv TYPE 'E'.
1053                 EXIT.
1054               ENDIF.
1055
1056               wa_accountgl-item_text = 'WBS ADJUSTMENT'.
1057               wa_accountgl-comp_code  = 'OVL'.
1058               wa_accountgl-bus_area   = 'JV'.
1059               wa_accountgl-costcenter = gs_wbs-akstl.
1060
1061               APPEND wa_accountgl TO it_accountgl.
1062               CLEAR wa_accountgl.
1063
1064
1065               wa_currencyamount-itemno_acc  = counter_bapi.
1066               wa_currencyamount-curr_type = '00'.
1067   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1068   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1069               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1070   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1071               wa_currencyamount-currency    = 'USD'.
1072               APPEND wa_currencyamount TO it_currencyamount.
1073               CLEAR : wa_currencyamount.
1074
1075               wa_currencyamount-itemno_acc  = counter_bapi.
1076               wa_currencyamount-curr_type = '10'.
1077   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1078   *            wa_currencyamount-amt_doccur  = '0.01-'.
1079               wa_currencyamount-amt_doccur = CONV #( '0.01-' ).
1080   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1081               wa_currencyamount-currency = 'INR'.
1082               APPEND wa_currencyamount TO it_currencyamount.
1083               CLEAR : wa_currencyamount.
1084
1085             ENDIF.
1086   *******************************************************End of change by hrishi n ***************
1087           ENDLOOP.
1088
1089           " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1090           CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
1091               "#EC CI_USAGE_OK[2628704]
1092     "#EC CI_USAGE_OK[2438131]
1093
1094             " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1095             EXPORTING
1096               documentheader = documentheader
1097             IMPORTING
1098               obj_type       = obj_type
1099               obj_key        = obj_key
1100               obj_sys        = obj_sys
1101             TABLES
1102               accountgl      = it_accountgl[]
1103               currencyamount = it_currencyamount[]
1104   *           accountreceivable = accountreceivable[]
1105   *           accountpayable = accountpayable[]
1106               return         = return[].
1107
1108           READ TABLE return WITH KEY type = 'E'.
1109           IF sy-subrc = 0.
1110             LOOP AT return WHERE type = 'E'.
1111
1112               gs_display-msgid = return-id.
1113               gs_display-msgty = return-type.
1114               gs_display-msgno = return-number.
1115               gs_display-msgv1 = return-message_v1.
1116               gs_display-msgv2 = return-message_v2.
1117               gs_display-msgv3 = return-message_v3.
1118               gs_display-msgv4 = return-message_v4.
1119               APPEND gs_display TO gt_display.
1120               CLEAR : gs_display.
1121
1122
1123             ENDLOOP.
1124
1125           ELSE.
1126             LOOP AT return .
1127
1128               gs_display-msgid = return-id.
1129               gs_display-msgty = return-type.
1130               gs_display-msgno = return-number.
1131               gs_display-msgv1 = return-message_v1.
1132               gs_display-msgv2 = return-message_v2.
1133               gs_display-msgv3 = return-message_v3.
1134               gs_display-msgv4 = return-message_v4.
1135               APPEND gs_display TO gt_display.
1136               CLEAR : gs_display.
1137
1138             ENDLOOP.
1139             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
1140
1141             wa_post-fyear = p_year.
1142             wa_post-fperio = s_period-low.
1143             wa_post-tperio = s_period-high.
1144             wa_post-ind    = 'W'.
1145             wa_post-bukrs  = obj_key+10(3).
1146             wa_post-belnr  = obj_key+0(10).
1147             wa_post-gjahr  = obj_key+14(4).
1148   *              REV
1149             MODIFY zfi_fctr_doc FROM wa_post.
1150
1151
1152
1153           ENDIF.
1154
1155           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1156   *            EXPORTING
1157   *              i_lineno      = l_v_lines
1158             TABLES
1159               i_message_tab = gt_display.
1160
1161           REFRESH: return,
1162                  accountgl,
1163                  currencyamount,
1164                  accountreceivable,
1165                  accountpayable,
1166                  gt_display[].
1167   *         documentheader.
1168
1169           CLEAR:   return,
1170                    accountgl,
1171                    currencyamount,
1172                    accountreceivable,
1173                    accountpayable,
1174                    documentheader,
1175                    obj_type,
1176                    obj_sys,
1177                    counter_bapi,
1178                    obj_key,
1179                    it_accountgl,
1180                    it_currencyamount,
1181                    it_accountgl[],
1182                    it_currencyamount[].
1183   *           gt_display.
1184
1185
1186
1187         ELSE.
1188           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1189   *            EXPORTING
1190   *              i_lineno      = l_v_lines
1191             TABLES
1192               i_message_tab = gt_display1.
1193
1194
1195         ENDIF.
1196
1197
1198   **  Added on  29.5.21
1199       WHEN 'CPOST'.
1200
1201         CLEAR wa_post.
1202         REFRESH : gt_display[].
1203
1204         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
1205           WHERE fyear = p_year
1206           AND   fperio = s_period-low
1207           AND   tperio = s_period-high
1208           AND   ind = 'C'
1209           AND   rev = ' '.
1210
1211         IF sy-subrc = 0.
1212           MESSAGE 'Document for Quarter Already posted' TYPE 'I'.
1213         ENDIF.
1214
1215         CHECK sy-subrc NE 0.
1216
1217         gt_wbs[] = gt_final[].
1218
1219         SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
1220
1221         REFRESH : gt_display1.
1222         LOOP AT gt_wbs INTO gs_wbs.
1223           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1224             EXPORTING
1225               input  = gs_wbs-kstar
1226             IMPORTING
1227               output = gs_wbs-kstar.
1228
1229
1230           READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1231           IF sy-subrc NE 0.
1232   *    wa_accountgl-gl_account = gs_wbs-kstar.
1233             gs_display1-msgid = 'ZFI1'.
1234             gs_display1-msgty = 'E'.
1235             gs_display1-msgno = '003'.
1236             gs_display1-msgv1 = gs_wbs-kstar.
1237             APPEND gs_display1 TO gt_display1.
1238           ENDIF.
1239
1240         ENDLOOP.
1241         DELETE ADJACENT DUPLICATES FROM gt_display1 COMPARING msgv1.
1242         IF gt_display1[] IS INITIAL.
1243
1244           LOOP AT gt_wbs INTO gs_wbs.
1245
1246   *    documentheader-bus_act    = 'RFBU'.
1247             documentheader-username   = sy-uname.
1248             documentheader-comp_code  = 'OVL'.
1249             documentheader-doc_date   = p_budat.
1250             documentheader-pstng_date = p_budat.
1251             documentheader-doc_type   = 'FY'.
1252             documentheader-header_txt    = 'CC ADJUSTMENT'.
1253             documentheader-ref_doc_no    = 'CC ADJUSTMENT'.
1254
1255             counter_bapi = counter_bapi + 1.
1256             wa_accountgl-itemno_acc   = counter_bapi.
1257
1258             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1259               EXPORTING
1260                 input  = gs_wbs-kstar
1261               IMPORTING
1262                 output = gs_wbs-kstar.
1263
1264
1265             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1266             IF sy-subrc = 0.
1267               wa_accountgl-gl_account = wa_wbsgl-asaknr.
1268             ELSE.
1269               CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1270               MESSAGE msgv TYPE 'E'.
1271               EXIT.
1272             ENDIF.
1273
1274             wa_accountgl-item_text = 'CC ADJUSTMENT'.
1275             wa_accountgl-comp_code  = 'OVL'.
1276             wa_accountgl-bus_area   = 'JV'.
1277             wa_accountgl-costcenter = gs_wbs-akstl.
1278
1279             APPEND wa_accountgl TO it_accountgl.
1280             CLEAR wa_accountgl.
1281   **********************************************************Changed by hrishi n on 02/05/22
1282             IF ( gs_wbs-wkgbtr GE 0 AND gs_wbs-wogbtr GE 0 ) OR ( gs_wbs-wkgbtr LE 0 AND gs_wbs-wogbtr LE 0 ) .
1283   *    IF gs_wbs-WKGBTR lt 0.
1284               wa_currencyamount-itemno_acc  = counter_bapi.
1285               wa_currencyamount-curr_type = '00'.
1286   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1287   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1288               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1289   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1290               wa_currencyamount-currency    = 'USD'.
1291               APPEND wa_currencyamount TO it_currencyamount.
1292               CLEAR : wa_currencyamount.
1293
1294   *      counter_bapi = counter_bapi + 1.
1295               wa_currencyamount-itemno_acc  = counter_bapi.
1296               wa_currencyamount-curr_type = '10'.
1297   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1298   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1299               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1300   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1301               wa_currencyamount-currency = 'INR'.
1302               APPEND wa_currencyamount TO it_currencyamount.
1303               CLEAR : wa_currencyamount.
1304   *      else.
1305   *         wa_currencyamount-itemno_acc  = counter_bapi.
1306   *      wa_currencyamount-curr_type = '00'.
1307   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
1308   *      wa_currencyamount-currency    = 'USD'.
1309   *      APPEND wa_currencyamount TO it_currencyamount.
1310   *      CLEAR : wa_currencyamount.
1311   *
1312   **      counter_bapi = counter_bapi + 1.
1313   *      wa_currencyamount-itemno_acc  = counter_bapi.
1314   *      wa_currencyamount-curr_type = '10'.
1315   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
1316   *      wa_currencyamount-currency = 'INR'.
1317   *      APPEND wa_currencyamount TO it_currencyamount.
1318   *      CLEAR : wa_currencyamount.
1319   *
1320   *    ENDIF.
1321
1322             ELSEIF gs_wbs-wkgbtr GT 0 AND gs_wbs-wogbtr LT 0.
1323
1324               wa_currencyamount-itemno_acc  = counter_bapi.
1325               wa_currencyamount-curr_type = '00'.
1326   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1327   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1328               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1329   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1330               wa_currencyamount-currency    = 'USD'.
1331               APPEND wa_currencyamount TO it_currencyamount.
1332               CLEAR : wa_currencyamount.
1333
1334               wa_currencyamount-itemno_acc  = counter_bapi.
1335               wa_currencyamount-curr_type = '10'.
1336   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1337   *            wa_currencyamount-amt_doccur  = '0.01'.
1338               wa_currencyamount-amt_doccur = CONV #( '0.01' ).
1339   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1340               wa_currencyamount-currency = 'INR'.
1341               APPEND wa_currencyamount TO it_currencyamount.
1342               CLEAR : wa_currencyamount.
1343
1344
1345               counter_bapi = counter_bapi + 1.
1346               wa_accountgl-itemno_acc   = counter_bapi.
1347
1348               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1349                 EXPORTING
1350                   input  = gs_wbs-kstar
1351                 IMPORTING
1352                   output = gs_wbs-kstar.
1353
1354
1355               READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1356               IF sy-subrc = 0.
1357                 wa_accountgl-gl_account = wa_wbsgl-asaknr.
1358               ELSE.
1359                 CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1360                 MESSAGE msgv TYPE 'E'.
1361                 EXIT.
1362               ENDIF.
1363
1364               wa_accountgl-item_text = 'CC ADJUSTMENT'.
1365               wa_accountgl-comp_code  = 'OVL'.
1366               wa_accountgl-bus_area   = 'JV'.
1367               wa_accountgl-costcenter = gs_wbs-akstl.
1368
1369               APPEND wa_accountgl TO it_accountgl.
1370               CLEAR wa_accountgl.
1371
1372
1373
1374               wa_currencyamount-itemno_acc  = counter_bapi.
1375               wa_currencyamount-curr_type = '00'.
1376   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1377   *            wa_currencyamount-amt_doccur  = '0.01-'.
1378               wa_currencyamount-amt_doccur = CONV #( '0.01-' ).
1379   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1380               wa_currencyamount-currency    = 'USD'.
1381               APPEND wa_currencyamount TO it_currencyamount.
1382               CLEAR : wa_currencyamount.
1383
1384               wa_currencyamount-itemno_acc  = counter_bapi.
1385               wa_currencyamount-curr_type = '10'.
1386   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1387   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1388               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1389   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1390               wa_currencyamount-currency = 'INR'.
1391               APPEND wa_currencyamount TO it_currencyamount.
1392               CLEAR : wa_currencyamount.
1393
1394             ELSEIF gs_wbs-wkgbtr LT 0 AND gs_wbs-wogbtr GT 0.
1395
1396               wa_currencyamount-itemno_acc  = counter_bapi.
1397               wa_currencyamount-curr_type = '00'.
1398   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1399   *            wa_currencyamount-amt_doccur  = '0.01'.
1400               wa_currencyamount-amt_doccur = CONV #( '0.01' ).
1401   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1402               wa_currencyamount-currency    = 'USD'.
1403               APPEND wa_currencyamount TO it_currencyamount.
1404               CLEAR : wa_currencyamount.
1405
1406               wa_currencyamount-itemno_acc  = counter_bapi.
1407               wa_currencyamount-curr_type = '10'.
1408   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1409   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1410               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1411   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1412               wa_currencyamount-currency = 'INR'.
1413               APPEND wa_currencyamount TO it_currencyamount.
1414               CLEAR : wa_currencyamount.
1415
1416
1417               counter_bapi = counter_bapi + 1.
1418               wa_accountgl-itemno_acc   = counter_bapi.
1419
1420               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1421                 EXPORTING
1422                   input  = gs_wbs-kstar
1423                 IMPORTING
1424                   output = gs_wbs-kstar.
1425
1426
1427               READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1428               IF sy-subrc = 0.
1429                 wa_accountgl-gl_account = wa_wbsgl-asaknr.
1430               ELSE.
1431                 CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1432                 MESSAGE msgv TYPE 'E'.
1433                 EXIT.
1434               ENDIF.
1435
1436               wa_accountgl-item_text = 'CC ADJUSTMENT'.
1437               wa_accountgl-comp_code  = 'OVL'.
1438               wa_accountgl-bus_area   = 'JV'.
1439               wa_accountgl-costcenter = gs_wbs-akstl.
1440
1441               APPEND wa_accountgl TO it_accountgl.
1442               CLEAR wa_accountgl.
1443
1444
1445               wa_currencyamount-itemno_acc  = counter_bapi.
1446               wa_currencyamount-curr_type = '00'.
1447   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1448   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1449               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1450   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1451               wa_currencyamount-currency    = 'USD'.
1452               APPEND wa_currencyamount TO it_currencyamount.
1453               CLEAR : wa_currencyamount.
1454
1455               wa_currencyamount-itemno_acc  = counter_bapi.
1456               wa_currencyamount-curr_type = '10'.
1457   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1458   *            wa_currencyamount-amt_doccur  = '0.01-'.
1459               wa_currencyamount-amt_doccur = CONV #( '0.01-' ).
1460   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1461               wa_currencyamount-currency = 'INR'.
1462               APPEND wa_currencyamount TO it_currencyamount.
1463               CLEAR : wa_currencyamount.
1464
1465             ENDIF.
1466   **********************************************************End of change by hrishi n*************
1467           ENDLOOP.
1468
1469           " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1470           CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
1471               "#EC CI_USAGE_OK[2628704]
1472     "#EC CI_USAGE_OK[2438131]
1473
1474             " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1475             EXPORTING
1476               documentheader = documentheader
1477             IMPORTING
1478               obj_type       = obj_type
1479               obj_key        = obj_key
1480               obj_sys        = obj_sys
1481             TABLES
1482               accountgl      = it_accountgl[]
1483               currencyamount = it_currencyamount[]
1484   *           accountreceivable = accountreceivable[]
1485   *           accountpayable = accountpayable[]
1486               return         = return[].
1487
1488           READ TABLE return WITH KEY type = 'E'.
1489           IF sy-subrc = 0.
1490             LOOP AT return WHERE type = 'E'.
1491
1492               gs_display-msgid = return-id.
1493               gs_display-msgty = return-type.
1494               gs_display-msgno = return-number.
1495               gs_display-msgv1 = return-message_v1.
1496               gs_display-msgv2 = return-message_v2.
1497               gs_display-msgv3 = return-message_v3.
1498               gs_display-msgv4 = return-message_v4.
1499               APPEND gs_display TO gt_display.
1500               CLEAR : gs_display.
1501
1502
1503             ENDLOOP.
1504           ELSE.
1505             LOOP AT return .
1506
1507               gs_display-msgid = return-id.
1508               gs_display-msgty = return-type.
1509               gs_display-msgno = return-number.
1510               gs_display-msgv1 = return-message_v1.
1511               gs_display-msgv2 = return-message_v2.
1512               gs_display-msgv3 = return-message_v3.
1513               gs_display-msgv4 = return-message_v4.
1514               APPEND gs_display TO gt_display.
1515               CLEAR : gs_display.
1516
1517             ENDLOOP.
1518             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
1519
1520             wa_post-fyear = p_year.
1521             wa_post-fperio = s_period-low.
1522             wa_post-tperio = s_period-high.
1523             wa_post-ind    = 'C'.
1524             wa_post-bukrs  = obj_key+10(3).
1525             wa_post-belnr  = obj_key+0(10).
1526             wa_post-gjahr  = obj_key+14(4).
1527   *              REV
1528             MODIFY zfi_fctr_doc FROM wa_post.
1529
1530
1531           ENDIF.
1532
1533           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1534   *            EXPORTING
1535   *              i_lineno      = l_v_lines
1536             TABLES
1537               i_message_tab = gt_display.
1538
1539           REFRESH: return,
1540                  accountgl,
1541                  currencyamount,
1542                  accountreceivable,
1543                  accountpayable,
1544                  gt_display[].
1545   *         documentheader.
1546
1547           CLEAR:   return,
1548                    accountgl,
1549                    currencyamount,
1550                    accountreceivable,
1551                    accountpayable,
1552                    documentheader,
1553                    obj_type,
1554                    obj_sys,
1555                    counter_bapi,
1556                    obj_key,
1557                    it_accountgl,
1558                    it_currencyamount,
1559                    it_accountgl[],
1560                    it_currencyamount[].
1561   *           gt_display.
1562
1563         ELSE.
1564           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1565   *            EXPORTING
1566   *              i_lineno      = l_v_lines
1567             TABLES
1568               i_message_tab = gt_display1.
1569
1570
1571         ENDIF.
1572
1573       WHEN 'REVERSE'.
1574
1575         CLEAR wa_post.
1576         REFRESH : gt_display[] , gt_display1[].
1577
1578   *   TYPES: BEGIN OF TYPE_DOCUMENT,
1579   *         BELNR TYPE BELNR_D,           " Accounting Document Number
1580   *         BLART TYPE BLART,             " Document Type
1581   *         GLVOR TYPE GLVOR,
1582   *         AWTYP TYPE AWTYP,             " Reference Transaction
1583   *         AWKEY TYPE AWKEY,             " Reference Key
1584   *       END OF TYPE_DOCUMENT.
1585
1586         DATA: wa_REVERSAL LIKE bapiacrev,
1587               wa_document TYPE bkpf,
1588               l_t_return  LIKE TABLE OF bapiret2,
1589               l_S_return  TYPE bapiret2.
1590
1591         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
1592         WHERE fyear = p_year
1593         AND   fperio = s_period-low
1594         AND   tperio = s_period-high
1595         AND   ind = 'C'.
1596   *    and   rev = 'X'.
1597
1598   *    CHECK sy-subrc ne 0.
1599         IF wa_post-rev NE 'X'.
1600
1601           gt_wbs[] = gt_final[].
1602
1603           SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
1604
1605           LOOP AT gt_wbs INTO gs_wbs.
1606             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1607               EXPORTING
1608                 input  = gs_wbs-kstar
1609               IMPORTING
1610                 output = gs_wbs-kstar.
1611
1612
1613             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1614             IF sy-subrc NE 0.
1615   *    wa_accountgl-gl_account = gs_wbs-kstar.
1616               gs_display1-msgid = 'ZFI1'.
1617               gs_display1-msgty = 'E'.
1618               gs_display1-msgno = '003'.
1619               gs_display1-msgv1 = gs_wbs-kstar.
1620               APPEND gs_display1 TO gt_display1.
1621             ENDIF.
1622
1623           ENDLOOP.
1624
1625           IF gt_display1[] IS INITIAL .
1626
1627             SELECT SINGLE *
1628           FROM bkpf
1629           INTO wa_document
1630          WHERE bukrs     EQ wa_post-bukrs
1631            AND gjahr     EQ wa_post-gjahr
1632            AND belnr     EQ wa_post-belnr.
1633   *     AND BLART     EQ C_DOC_TYPE_Z
1634   *     AND MONAT     EQ G_S_SELECTION-MONAT
1635   *     AND XREVERSAL EQ SPACE.
1636
1637   *    if  wa_document-XREVERSAL ne space.
1638
1639             MOVE: wa_document-awtyp TO wa_reversal-obj_type,
1640                 wa_document-awkey TO wa_reversal-obj_key,
1641   *          L_LOGICAL_SYS       TO wa_reversal-OBJ_SYS,
1642                 wa_document-awkey TO wa_reversal-obj_key_r,
1643                 wa_document-budat TO wa_reversal-pstng_date,
1644                 wa_document-bukrs TO wa_reversal-comp_code,
1645   *          wa_document-BELNR TO wa_reversal-AC_DOC_NO,
1646                 '01'  TO wa_reversal-reason_rev.
1647
1648             CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
1649               EXPORTING
1650                 reversal = wa_REVERSAL
1651                 bus_act  = wa_document-glvor
1652               IMPORTING
1653                 obj_type = obj_type
1654                 obj_key  = obj_key
1655                 obj_sys  = obj_sys
1656               TABLES
1657                 return   = l_t_return.
1658
1659   *     endif.
1660
1661             READ TABLE l_t_return INTO l_s_return WITH KEY type = 'E'.
1662             IF sy-subrc = 0 AND wa_document-xreversal EQ space.
1663               LOOP AT l_t_return INTO l_s_return WHERE type = 'E'.
1664
1665                 gs_display-msgid = l_s_RETURN-id.
1666                 gs_display-msgty = l_s_RETURN-type.
1667                 gs_display-msgno = l_s_RETURN-number.
1668                 gs_display-msgv1 = l_s_RETURN-message_v1.
1669                 gs_display-msgv2 = l_s_RETURN-message_v2.
1670                 gs_display-msgv3 = l_s_RETURN-message_v3.
1671                 gs_display-msgv4 = l_s_RETURN-message_v4.
1672                 APPEND gs_display TO gt_display.
1673                 CLEAR : gs_display.
1674
1675
1676               ENDLOOP.
1677             ELSE.
1678               LOOP AT l_t_return INTO l_s_return.
1679
1680                 gs_display-msgid = l_s_return-id.
1681                 gs_display-msgty = l_s_return-type.
1682                 gs_display-msgno = l_s_return-number.
1683                 gs_display-msgv1 = l_s_return-message_v1.
1684                 gs_display-msgv2 = l_s_return-message_v2.
1685                 gs_display-msgv3 = l_s_return-message_v3.
1686                 gs_display-msgv4 = l_s_return-message_v4.
1687                 APPEND gs_display TO gt_display.
1688                 CLEAR : gs_display.
1689
1690               ENDLOOP.
1691               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
1692
1693   *              wa_post-FYEAR = p_year.
1694   *              wa_post-FPERIO = s_period-low.
1695   *              wa_post-TPERIO = s_period-high.
1696   *              wa_post-IND    = 'C'.
1697   *              wa_post-BUKRS  = obj_key+10(3).
1698   *              wa_post-BELNR  = obj_key+0(10).
1699   *              wa_post-GJAHR  = obj_key+14(4).
1700   *              REV
1701               UPDATE zfi_fctr_doc  SET rev = 'X'
1702               WHERE bukrs = wa_document-bukrs
1703               AND   belnr = wa_document-belnr
1704               AND   gjahr = wa_document-gjahr.
1705   *           MODIFY ZFI_FCTR_DOC FROM wa_post.
1706
1707
1708
1709               CLEAR: wa_document.
1710               REFRESH : l_t_return.
1711
1712
1713
1714   *if gt_display1[] is INITIAL.
1715
1716
1717               LOOP AT gt_wbs INTO gs_wbs.
1718
1719   *    documentheader-bus_act    = 'RFBU'.
1720                 documentheader-username   = sy-uname.
1721                 documentheader-comp_code  = 'OVL'.
1722                 documentheader-doc_date = p_budat.
1723                 documentheader-pstng_date = p_budat.
1724                 documentheader-doc_type   = 'FY'.
1725                 documentheader-header_txt    = 'CC ADJUSTMENT'.
1726                 documentheader-ref_doc_no    = 'CC ADJUSTMENT'.
1727
1728                 counter_bapi = counter_bapi + 1.
1729                 wa_accountgl-itemno_acc   = counter_bapi.
1730
1731                 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1732                   EXPORTING
1733                     input  = gs_wbs-kstar
1734                   IMPORTING
1735                     output = gs_wbs-kstar.
1736
1737
1738                 READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1739                 IF sy-subrc = 0.
1740                   wa_accountgl-gl_account = wa_wbsgl-asaknr.
1741                 ELSE.
1742                   CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1743                   MESSAGE msgv TYPE 'E'.
1744                   EXIT.
1745                 ENDIF.
1746
1747                 wa_accountgl-item_text = 'CC ADJUSTMENT'.
1748                 wa_accountgl-comp_code  = 'OVL'.
1749                 wa_accountgl-bus_area   = 'JV'.
1750                 wa_accountgl-costcenter = gs_wbs-akstl.
1751
1752                 APPEND wa_accountgl TO it_accountgl.
1753                 CLEAR wa_accountgl.
1754
1755                 IF ( gs_wbs-wkgbtr GE 0 AND gs_wbs-wogbtr GE 0 ) OR ( gs_wbs-wkgbtr LE 0 AND gs_wbs-wogbtr LE 0 ) .
1756   *    IF gs_wbs-WKGBTR lt 0.
1757                   wa_currencyamount-itemno_acc  = counter_bapi.
1758                   wa_currencyamount-curr_type = '00'.
1759   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1760   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1761                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1762   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1763                   wa_currencyamount-currency    = 'USD'.
1764                   APPEND wa_currencyamount TO it_currencyamount.
1765                   CLEAR : wa_currencyamount.
1766
1767   *      counter_bapi = counter_bapi + 1.
1768                   wa_currencyamount-itemno_acc  = counter_bapi.
1769                   wa_currencyamount-curr_type = '10'.
1770   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1771   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr .
1772                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1773   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1774                   wa_currencyamount-currency = 'INR'.
1775                   APPEND wa_currencyamount TO it_currencyamount.
1776                   CLEAR : wa_currencyamount.
1777   *      else.
1778   *         wa_currencyamount-itemno_acc  = counter_bapi.
1779   *      wa_currencyamount-curr_type = '00'.
1780   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
1781   *      wa_currencyamount-currency    = 'USD'.
1782   *      APPEND wa_currencyamount TO it_currencyamount.
1783   *      CLEAR : wa_currencyamount.
1784   *
1785   **      counter_bapi = counter_bapi + 1.
1786   *      wa_currencyamount-itemno_acc  = counter_bapi.
1787   *      wa_currencyamount-curr_type = '10'.
1788   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
1789   *      wa_currencyamount-currency = 'INR'.
1790   *      APPEND wa_currencyamount TO it_currencyamount.
1791   *      CLEAR : wa_currencyamount.
1792   *
1793   *    ENDIF.
1794                 ELSEIF gs_wbs-wkgbtr GT 0 AND gs_wbs-wogbtr LT 0.
1795
1796                   wa_currencyamount-itemno_acc  = counter_bapi.
1797                   wa_currencyamount-curr_type = '00'.
1798   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1799   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1800                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1801   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1802                   wa_currencyamount-currency    = 'USD'.
1803                   APPEND wa_currencyamount TO it_currencyamount.
1804                   CLEAR : wa_currencyamount.
1805
1806                   wa_currencyamount-itemno_acc  = counter_bapi.
1807                   wa_currencyamount-curr_type = '10'.
1808   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1809   *                wa_currencyamount-amt_doccur  = '0.01'.
1810                   wa_currencyamount-amt_doccur = CONV #( '0.01' ).
1811   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1812                   wa_currencyamount-currency = 'INR'.
1813                   APPEND wa_currencyamount TO it_currencyamount.
1814                   CLEAR : wa_currencyamount.
1815
1816                   counter_bapi = counter_bapi + 1.
1817                   wa_accountgl-itemno_acc   = counter_bapi.
1818
1819                   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1820                     EXPORTING
1821                       input  = gs_wbs-kstar
1822                     IMPORTING
1823                       output = gs_wbs-kstar.
1824
1825                   READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1826                   IF sy-subrc = 0.
1827                     wa_accountgl-gl_account = wa_wbsgl-asaknr.
1828                   ELSE.
1829                     CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1830                     MESSAGE msgv TYPE 'E'.
1831                     EXIT.
1832                   ENDIF.
1833
1834                   wa_accountgl-item_text = 'CC ADJUSTMENT'.
1835                   wa_accountgl-comp_code  = 'OVL'.
1836                   wa_accountgl-bus_area   = 'JV'.
1837                   wa_accountgl-costcenter = gs_wbs-akstl.
1838                   APPEND wa_accountgl TO it_accountgl.
1839                   CLEAR wa_accountgl.
1840
1841                   wa_currencyamount-itemno_acc  = counter_bapi.
1842                   wa_currencyamount-curr_type = '00'.
1843   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1844   *                wa_currencyamount-amt_doccur  = '0.01-'.
1845                   wa_currencyamount-amt_doccur = CONV #( '0.01-' ).
1846   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1847                   wa_currencyamount-currency    = 'USD'.
1848                   APPEND wa_currencyamount TO it_currencyamount.
1849                   CLEAR : wa_currencyamount.
1850
1851                   wa_currencyamount-itemno_acc  = counter_bapi.
1852                   wa_currencyamount-curr_type = '10'.
1853   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1854   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1855                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1856   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1857                   wa_currencyamount-currency = 'INR'.
1858                   APPEND wa_currencyamount TO it_currencyamount.
1859                   CLEAR : wa_currencyamount.
1860
1861                 ELSEIF gs_wbs-wkgbtr LT 0 AND gs_wbs-wogbtr GT 0.
1862
1863                   wa_currencyamount-itemno_acc  = counter_bapi.
1864                   wa_currencyamount-curr_type = '00'.
1865   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1866   *                wa_currencyamount-amt_doccur  = '0.01'.
1867                   wa_currencyamount-amt_doccur = CONV #( '0.01' ).
1868   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1869                   wa_currencyamount-currency    = 'USD'.
1870                   APPEND wa_currencyamount TO it_currencyamount.
1871                   CLEAR : wa_currencyamount.
1872
1873                   wa_currencyamount-itemno_acc  = counter_bapi.
1874                   wa_currencyamount-curr_type = '10'.
1875   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1876   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr.
1877                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1878   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1879                   wa_currencyamount-currency = 'INR'.
1880                   APPEND wa_currencyamount TO it_currencyamount.
1881                   CLEAR : wa_currencyamount.
1882
1883                   counter_bapi = counter_bapi + 1.
1884                   wa_accountgl-itemno_acc   = counter_bapi.
1885
1886                   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1887                     EXPORTING
1888                       input  = gs_wbs-kstar
1889                     IMPORTING
1890                       output = gs_wbs-kstar.
1891
1892                   READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
1893                   IF sy-subrc = 0.
1894                     wa_accountgl-gl_account = wa_wbsgl-asaknr.
1895                   ELSE.
1896                     CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
1897                     MESSAGE msgv TYPE 'E'.
1898                     EXIT.
1899                   ENDIF.
1900
1901                   wa_accountgl-item_text = 'CC ADJUSTMENT'.
1902                   wa_accountgl-comp_code  = 'OVL'.
1903                   wa_accountgl-bus_area   = 'JV'.
1904                   wa_accountgl-costcenter = gs_wbs-akstl.
1905                   APPEND wa_accountgl TO it_accountgl.
1906                   CLEAR wa_accountgl.
1907
1908                   wa_currencyamount-itemno_acc  = counter_bapi.
1909                   wa_currencyamount-curr_type = '00'.
1910   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1911   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr.
1912                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1913   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1914                   wa_currencyamount-currency    = 'USD'.
1915                   APPEND wa_currencyamount TO it_currencyamount.
1916                   CLEAR : wa_currencyamount.
1917
1918                   wa_currencyamount-itemno_acc  = counter_bapi.
1919                   wa_currencyamount-curr_type = '10'.
1920   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1921   *                wa_currencyamount-amt_doccur  = '0.01-'.
1922                   wa_currencyamount-amt_doccur = CONV #( '0.01-' ).
1923   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1924                   wa_currencyamount-currency = 'INR'.
1925                   APPEND wa_currencyamount TO it_currencyamount.
1926                   CLEAR : wa_currencyamount.
1927
1928                 ENDIF.
1929               ENDLOOP.
1930
1931               " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1932               CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
1933                   "#EC CI_USAGE_OK[2628704]
1934     "#EC CI_USAGE_OK[2438131]
1935
1936                 " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1937                 EXPORTING
1938                   documentheader = documentheader
1939                 IMPORTING
1940                   obj_type       = obj_type
1941                   obj_key        = obj_key
1942                   obj_sys        = obj_sys
1943                 TABLES
1944                   accountgl      = it_accountgl[]
1945                   currencyamount = it_currencyamount[]
1946   *               accountreceivable = accountreceivable[]
1947   *               accountpayable = accountpayable[]
1948                   return         = return[].
1949
1950               READ TABLE return WITH KEY type = 'E'.
1951               IF sy-subrc = 0.
1952                 LOOP AT return WHERE type = 'E'.
1953
1954                   gs_display-msgid = return-id.
1955                   gs_display-msgty = return-type.
1956                   gs_display-msgno = return-number.
1957                   gs_display-msgv1 = return-message_v1.
1958                   gs_display-msgv2 = return-message_v2.
1959                   gs_display-msgv3 = return-message_v3.
1960                   gs_display-msgv4 = return-message_v4.
1961                   APPEND gs_display TO gt_display.
1962                   CLEAR : gs_display.
1963
1964
1965                 ENDLOOP.
1966               ELSE.
1967                 LOOP AT return .
1968
1969                   gs_display-msgid = return-id.
1970                   gs_display-msgty = return-type.
1971                   gs_display-msgno = return-number.
1972                   gs_display-msgv1 = return-message_v1.
1973                   gs_display-msgv2 = return-message_v2.
1974                   gs_display-msgv3 = return-message_v3.
1975                   gs_display-msgv4 = return-message_v4.
1976                   APPEND gs_display TO gt_display.
1977                   CLEAR : gs_display.
1978
1979                 ENDLOOP.
1980                 CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
1981
1982                 wa_post-fyear = p_year.
1983                 wa_post-fperio = s_period-low.
1984                 wa_post-tperio = s_period-high.
1985                 wa_post-ind    = 'C'.
1986                 wa_post-bukrs  = obj_key+10(3).
1987                 wa_post-belnr  = obj_key+0(10).
1988                 wa_post-gjahr  = obj_key+14(4).
1989   *              REV
1990                 MODIFY zfi_fctr_doc FROM wa_post.
1991
1992
1993               ENDIF.
1994
1995               CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1996   *            EXPORTING
1997   *              i_lineno      = l_v_lines
1998                 TABLES
1999                   i_message_tab = gt_display.
2000
2001               REFRESH: return,
2002                      accountgl,
2003                      currencyamount,
2004                      accountreceivable,
2005                      accountpayable,
2006                      gt_display[].
2007   *         documentheader.
2008
2009               CLEAR:   return,
2010                        accountgl,
2011                        currencyamount,
2012                        accountreceivable,
2013                        accountpayable,
2014                        documentheader,
2015                        obj_type,
2016                        obj_sys,
2017                        counter_bapi,
2018                        obj_key,
2019                        it_accountgl,
2020                        it_currencyamount,
2021                        it_accountgl[],
2022                        it_currencyamount[].
2023
2024             ENDIF.
2025
2026           ELSE.
2027             CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2028   *      EXPORTING
2029   *        i_lineno      = l_v_lines
2030               TABLES
2031                 i_message_tab = gt_display1.
2032
2033           ENDIF.
2034
2035   *     else.
2036   *         CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2037   **            EXPORTING
2038   **              i_lineno      = l_v_lines
2039   *            TABLES
2040   *              i_message_tab = gt_display1.
2041   *
2042         ENDIF.
2043
2044       WHEN 'WREVERSE'.
2045
2046         CLEAR wa_post.
2047         REFRESH : gt_display[] , gt_display1.
2048         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
2049         WHERE fyear = p_year
2050         AND   fperio = s_period-low
2051         AND   tperio = s_period-high
2052         AND   ind = 'W'.
2053
2054         IF wa_post-rev NE 'X'.
2055
2056
2057           gt_wbs[] = gt_final[].
2058           DELETE gt_wbs WHERE  wkgbtr IS INITIAL AND wogbtr IS INITIAL.
2059
2060           SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
2061
2062           LOOP AT gt_wbs INTO gs_wbs.
2063             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2064               EXPORTING
2065                 input  = gs_wbs-kstar
2066               IMPORTING
2067                 output = gs_wbs-kstar.
2068
2069
2070             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
2071             IF sy-subrc NE 0.
2072   *    wa_accountgl-gl_account = gs_wbs-kstar.
2073               gs_display1-msgid = 'ZFI1'.
2074               gs_display1-msgty = 'E'.
2075               gs_display1-msgno = '003'.
2076               gs_display1-msgv1 = gs_wbs-kstar.
2077               APPEND gs_display1 TO gt_display1.
2078             ENDIF.
2079
2080
2081           ENDLOOP.
2082
2083           IF gt_display1[] IS INITIAL.
2084
2085             SELECT SINGLE *
2086             FROM bkpf
2087             INTO wa_document
2088            WHERE bukrs     EQ wa_post-bukrs
2089              AND gjahr     EQ wa_post-gjahr
2090              AND belnr     EQ wa_post-belnr.
2091   *     AND BLART     EQ C_DOC_TYPE_Z
2092   *     AND MONAT     EQ G_S_SELECTION-MONAT
2093   *     AND XREVERSAL EQ SPACE.
2094
2095             MOVE: wa_document-awtyp TO wa_reversal-obj_type,
2096                 wa_document-awkey TO wa_reversal-obj_key,
2097   *          L_LOGICAL_SYS       TO wa_reversal-OBJ_SYS,
2098                 wa_document-awkey TO wa_reversal-obj_key_r,
2099                 wa_document-budat TO wa_reversal-pstng_date,
2100                 wa_document-bukrs TO wa_reversal-comp_code,
2101   *          wa_document-BELNR TO wa_reversal-AC_DOC_NO,
2102                 '01'  TO wa_reversal-reason_rev.
2103
2104             CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
2105               EXPORTING
2106                 reversal = wa_REVERSAL
2107                 bus_act  = wa_document-glvor
2108               IMPORTING
2109                 obj_type = obj_type
2110                 obj_key  = obj_key
2111                 obj_sys  = obj_sys
2112               TABLES
2113                 return   = l_t_return.
2114
2115             READ TABLE l_t_return INTO l_s_return WITH KEY type = 'E'.
2116             IF sy-subrc = 0 AND wa_document-xreversal EQ space.
2117               LOOP AT l_t_return INTO l_s_return WHERE type = 'E'.
2118
2119                 gs_display-msgid = l_s_RETURN-id.
2120                 gs_display-msgty = l_s_RETURN-type.
2121                 gs_display-msgno = l_s_RETURN-number.
2122                 gs_display-msgv1 = l_s_RETURN-message_v1.
2123                 gs_display-msgv2 = l_s_RETURN-message_v2.
2124                 gs_display-msgv3 = l_s_RETURN-message_v3.
2125                 gs_display-msgv4 = l_s_RETURN-message_v4.
2126                 APPEND gs_display TO gt_display.
2127                 CLEAR : gs_display.
2128
2129
2130               ENDLOOP.
2131             ELSE.
2132               LOOP AT l_t_return INTO l_s_return.
2133
2134                 gs_display-msgid = l_s_return-id.
2135                 gs_display-msgty = l_s_return-type.
2136                 gs_display-msgno = l_s_return-number.
2137                 gs_display-msgv1 = l_s_return-message_v1.
2138                 gs_display-msgv2 = l_s_return-message_v2.
2139                 gs_display-msgv3 = l_s_return-message_v3.
2140                 gs_display-msgv4 = l_s_return-message_v4.
2141                 APPEND gs_display TO gt_display.
2142                 CLEAR : gs_display.
2143
2144               ENDLOOP.
2145               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2146
2147   *              wa_post-FYEAR = p_year.
2148   *              wa_post-FPERIO = s_period-low.
2149   *              wa_post-TPERIO = s_period-high.
2150   *              wa_post-IND    = 'C'.
2151   *              wa_post-BUKRS  = obj_key+10(3).
2152   *              wa_post-BELNR  = obj_key+0(10).
2153   *              wa_post-GJAHR  = obj_key+14(4).
2154   *              REV
2155               UPDATE zfi_fctr_doc  SET rev = 'X'
2156               WHERE bukrs = wa_document-bukrs
2157               AND   belnr = wa_document-belnr
2158               AND   gjahr = wa_document-gjahr.
2159   *           MODIFY ZFI_FCTR_DOC FROM wa_post.
2160
2161
2162               SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
2163
2164               LOOP AT gt_wbs INTO gs_wbs.
2165
2166   *    documentheader-bus_act    = 'RFBU'.
2167                 documentheader-username   = sy-uname.
2168                 documentheader-comp_code  = 'OVL'.
2169                 documentheader-doc_date = p_budat.
2170                 documentheader-pstng_date = p_budat.
2171                 documentheader-doc_type   = 'FY'.
2172                 documentheader-header_txt    = 'WBS ADJUSTMENT'.
2173                 documentheader-ref_doc_no    = 'WBS ADJUSTMENT'.
2174
2175                 counter_bapi = counter_bapi + 1.
2176                 wa_accountgl-itemno_acc   = counter_bapi.
2177
2178                 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2179                   EXPORTING
2180                     input  = gs_wbs-kstar
2181                   IMPORTING
2182                     output = gs_wbs-kstar.
2183
2184
2185                 READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-kstar.
2186                 IF sy-subrc = 0.
2187                   wa_accountgl-gl_account = wa_wbsgl-asaknr.
2188                 ELSE.
2189                   CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-kstar INTO msgv SEPARATED BY space.
2190                   MESSAGE msgv TYPE 'E'.
2191                   EXIT.
2192                 ENDIF.
2193
2194                 wa_accountgl-item_text = 'WBS ADJUSTMENT'.
2195                 wa_accountgl-comp_code  = 'OVL'.
2196                 wa_accountgl-bus_area   = 'JV'.
2197                 wa_accountgl-costcenter = gs_wbs-akstl.
2198
2199                 APPEND wa_accountgl TO it_accountgl.
2200                 CLEAR wa_accountgl.
2201
2202   *    IF gs_wbs-WKGBTR lt 0.
2203                 wa_currencyamount-itemno_acc  = counter_bapi.
2204                 wa_currencyamount-curr_type = '00'.
2205   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2206   *              wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr .
2207                 wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
2208   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2209                 wa_currencyamount-currency    = 'USD'.
2210                 APPEND wa_currencyamount TO it_currencyamount.
2211                 CLEAR : wa_currencyamount.
2212
2213   *      counter_bapi = counter_bapi + 1.
2214                 wa_currencyamount-itemno_acc  = counter_bapi.
2215                 wa_currencyamount-curr_type = '10'.
2216   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2217   *              wa_currencyamount-amt_doccur  = gs_wbs-wogbtr .
2218                 wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
2219   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2220                 wa_currencyamount-currency = 'INR'.
2221                 APPEND wa_currencyamount TO it_currencyamount.
2222                 CLEAR : wa_currencyamount.
2223   *      else.
2224   *         wa_currencyamount-itemno_acc  = counter_bapi.
2225   *      wa_currencyamount-curr_type = '00'.
2226   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
2227   *      wa_currencyamount-currency    = 'USD'.
2228   *      APPEND wa_currencyamount TO it_currencyamount.
2229   *      CLEAR : wa_currencyamount.
2230   *
2231   **      counter_bapi = counter_bapi + 1.
2232   *      wa_currencyamount-itemno_acc  = counter_bapi.
2233   *      wa_currencyamount-curr_type = '10'.
2234   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
2235   *      wa_currencyamount-currency = 'INR'.
2236   *      APPEND wa_currencyamount TO it_currencyamount.
2237   *      CLEAR : wa_currencyamount.
2238   *
2239   *    ENDIF.
2240               ENDLOOP.
2241
2242               " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
2243               CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
2244                   "#EC CI_USAGE_OK[2628704]
2245     "#EC CI_USAGE_OK[2438131]
2246
2247                 " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
2248                 EXPORTING
2249                   documentheader = documentheader
2250                 IMPORTING
2251                   obj_type       = obj_type
2252                   obj_key        = obj_key
2253                   obj_sys        = obj_sys
2254                 TABLES
2255                   accountgl      = it_accountgl[]
2256                   currencyamount = it_currencyamount[]
2257   *               accountreceivable = accountreceivable[]
2258   *               accountpayable = accountpayable[]
2259                   return         = return[].
2260
2261               READ TABLE return WITH KEY type = 'E'.
2262               IF sy-subrc = 0.
2263                 LOOP AT return WHERE type = 'E'.
2264
2265                   gs_display-msgid = return-id.
2266                   gs_display-msgty = return-type.
2267                   gs_display-msgno = return-number.
2268                   gs_display-msgv1 = return-message_v1.
2269                   gs_display-msgv2 = return-message_v2.
2270                   gs_display-msgv3 = return-message_v3.
2271                   gs_display-msgv4 = return-message_v4.
2272                   APPEND gs_display TO gt_display.
2273                   CLEAR : gs_display.
2274
2275
2276                 ENDLOOP.
2277               ELSE.
2278                 LOOP AT return .
2279
2280                   gs_display-msgid = return-id.
2281                   gs_display-msgty = return-type.
2282                   gs_display-msgno = return-number.
2283                   gs_display-msgv1 = return-message_v1.
2284                   gs_display-msgv2 = return-message_v2.
2285                   gs_display-msgv3 = return-message_v3.
2286                   gs_display-msgv4 = return-message_v4.
2287                   APPEND gs_display TO gt_display.
2288                   CLEAR : gs_display.
2289
2290                 ENDLOOP.
2291                 CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2292
2293                 wa_post-fyear = p_year.
2294                 wa_post-fperio = s_period-low.
2295                 wa_post-tperio = s_period-high.
2296                 wa_post-ind    = 'W'.
2297                 wa_post-bukrs  = obj_key+10(3).
2298                 wa_post-belnr  = obj_key+0(10).
2299                 wa_post-gjahr  = obj_key+14(4).
2300   *              REV
2301                 MODIFY zfi_fctr_doc FROM wa_post.
2302
2303
2304
2305               ENDIF.
2306
2307               CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2308   *            EXPORTING
2309   *              i_lineno      = l_v_lines
2310                 TABLES
2311                   i_message_tab = gt_display.
2312
2313               REFRESH: return,
2314                      accountgl,
2315                      currencyamount,
2316                      accountreceivable,
2317                      accountpayable,
2318                      gt_display[].
2319   *         documentheader.
2320
2321               CLEAR:   return,
2322                        accountgl,
2323                        currencyamount,
2324                        accountreceivable,
2325                        accountpayable,
2326                        documentheader,
2327                        obj_type,
2328                        obj_sys,
2329                        counter_bapi,
2330                        obj_key,
2331                        it_accountgl,
2332                        it_currencyamount,
2333                        it_accountgl[],
2334                        it_currencyamount[].
2335
2336             ENDIF.
2337
2338           ELSE.
2339
2340             CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2341   *      EXPORTING
2342   *        i_lineno      = l_v_lines
2343               TABLES
2344                 i_message_tab = gt_display1.
2345
2346           ENDIF.
2347
2348
2349         ENDIF.
2350
2351
2352     ENDCASE.
2353   ENDFORM.
*--- End of ZFI_FCTR_REVALLOC_FR - 2353 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZFI_FCTR_REVALLOC_POST                    Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
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
Object           ZFI_FCTR_REVALLOC_POST                    Lines 486
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
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
Object           ZFI_FCTR_REVALLOC_POST                    Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
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
Object           ZFI_FCTR_REVALLOC_POST                    Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
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
Object           ZFI_FCTR_REVALLOC_POST                    Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
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
Object           ZFI_FCTR_REVALLOC_POST                    Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
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
Object           ZFI_FCTR_REVALLOC_POST                    Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:06
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
