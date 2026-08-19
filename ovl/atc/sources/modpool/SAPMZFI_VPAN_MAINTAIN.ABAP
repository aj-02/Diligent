----------------------------------------------------------------------------------------------------
Main program     SAPMZFI_VPAN_MAINTAIN                     Level 0    Page 1
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 27
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Module Pool       SAPMZFI_VPAN_MAINTAIN
3      *&
4      *&---------------------------------------------------------------------*
5      * TITLE: Program SAPMZFI_VPAN_MAINTAIN Maintenance
6      *
7      * FS No: FS-CR30005792
8      *
9      * Author: SRSUDHA  Date : 21.09.2011*
10     * Login ID: CAB_SUDHA
11     *
12     * Description:  Table j_1imovend table Maintenance
13     *
14     * Transaction Code: ZJ1INVPAN
15     ****************************************************************************************************
16     *  Date     Transport      USERID       Description
17     *12.10.2012 RD1K982287     CAB_ALOK     CR 30008047- Remove changeTab from tcode ZJ1INVPAN
18     *08.05.2013 RD1K984875     CAB_ALOK     Include new fields in tcode ZJ1INVPAN - CR 30009141
19     *27.03.2015 RD1K996820  CAB_RAMA(ANAMIKA) Deactivate Create Field in ZJ1INVPAN -CR 30012529
20     *03.06.2015 RD1K997375  CAB_RAMA(ANAMIKA) Deactivate PAN Field in Change in ZJ1INVPAN -CR 30012817
21     ****************************************************************************************************
22
23     INCLUDE SAPMZFI_VPAN_MAINTAINTOP             .    " global Data
24     *&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
25     INCLUDE SAPMZFI_VPAN_MAINTAINO .
26     INCLUDE SAPMZFI_VPAN_MAINTAINI .
27     INCLUDE SAPMZFI_VPAN_MAINTAINF .
*--- End of SAPMZFI_VPAN_MAINTAIN - 27 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINTOP                  Level 1    Page 2
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 91
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Include ZFI_UPDATE_j_1imovendTOP                        Module Pool      ZFI_UPDATE_J_1IEWT_ACKN
3      *&
4      *&---------------------------------------------------------------------*
5
6      PROGRAM  sapmzfi_vpan_maintain.
7
8      TYPE-POOLS: vrm, slis,
9                 esp1       " for messages
10                .
11
12     *TABLES :  j_1imovend, j_1iewt_ackn , lfa1.
13     TABLES : j_1iewt_ackn , lfa1.
14
15     *&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC931'
16
17     TYPES: BEGIN OF t_tc931.
18     "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
19     * TYPES:   LIFNR TYPE j_1imovend-LIFNR,
20     *          J_1IPANNO TYPE j_1imovend-J_1IPANNO,
21     **Begin RD1K984875 CAB_ALOK Include new fields in tcode ZJ1INVPAN - CR 30009141
22     *          name1 type lfa1-name1,
23     *          J_1IEXRN TYPE j_1imovend-J_1IEXRN,
24     *          J_1ICSTNO TYPE j_1imovend-J_1ICSTNO,
25     *          J_1ILSTNO TYPE j_1imovend-J_1ILSTNO,
26     *          J_1ISERN TYPE j_1imovend-J_1ISERN.
27     **          name1 type lfa1-name1.
28     **End RD1K984875 CAB_ALOK Include new fields in tcode ZJ1INVPAN - CR 30009141
29
30
31     TYPES: lifnr     TYPE lfa1-lifnr,
32            j_1ipanno TYPE lfa1-j_1ipanno,
33            name1     TYPE lfa1-name1,
34            j_1iexrn  TYPE lfa1-j_1iexrn,
35            j_1icstno TYPE lfa1-j_1icstno,
36            j_1ilstno TYPE lfa1-j_1ilstno,
37            j_1isern  TYPE lfa1-j_1isern.
38     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
39     TYPES :  flag.
40     TYPES : END OF t_tc931.
41     DATA: ls_vend TYPE z1imovend.
42     *&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC931'
43     DATA: g_tc931_itab     TYPE t_tc931 OCCURS 0,
44           g_tc931_wa       TYPE t_tc931, "work area
45           g_tc931_itab_del TYPE t_tc931 OCCURS 0,
46           g_tc931_wa_del   TYPE t_tc931, "work area for Delete
47           "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
48
49     *      g_ackn_wa        TYPE j_1imovend,
50           g_ackn_wa        TYPE lfa1,
51     *      g_pan_wa         TYPE j_1imovend,
52           g_pan_wa         TYPE lfa1,
53           "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
54           wa_t001          TYPE t001,
55           wa_seccode       TYPE seccode.
56
57     DATA:     g_tc931_copied.           "copy flag
58
59     *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC931' ITSELF
60     CONTROLS: tc931 TYPE TABLEVIEW USING SCREEN 0931.
61
62     *&SPWIZARD: LINES OF TABLECONTROL 'TC931'
63     DATA:    g_tc931_lines  LIKE sy-loopc.
64
65     DATA: g_okcode  TYPE sy-ucomm,
66           g_okcode1 TYPE sy-ucomm,
67           ok_code   LIKE sy-ucomm,
68           ok_code2  LIKE sy-ucomm,
69           g_okcode2 LIKE sy-ucomm.
70     DATA: g_text(20),
71           g_cflag    TYPE c,
72           g_vflag    TYPE c,
73     "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
74
75     *      g_lifnr    LIKE j_1imovend-lifnr,
76     *      g_panno    LIKE j_1imovend-j_1ipanno.
77           g_lifnr    LIKE lfa1-lifnr,
78           g_panno    LIKE lfa1-j_1ipanno.
79
80     *DATA: t_panno TYPE j_1imovend-j_1ipanno .
81     DATA: t_panno TYPE lfa1-j_1ipanno .
82     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
83     FIELD-SYMBOLS <wa_del>.
84     DATA: cols LIKE LINE OF tc931-cols.
85     DATA :l_tabix LIKE sy-tabix.
86     TYPES : BEGIN OF ty_lfa1,
87               lifnr TYPE lfa1-lifnr,
88               name1 TYPE lfa1-name1,
89             END OF ty_lfa1.
90     DATA : ist_lfa1 TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
91     DATA : wa_lfa1 TYPE ty_lfa1.
*--- End of SAPMZFI_VPAN_MAINTAINTOP - 91 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINO                    Level 1    Page 3
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 311
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_UPDATE_j_1imovendO
3      *&---------------------------------------------------------------------*
4
5      *&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
6      *&SPWIZARD: COPY DDIC-TABLE TO ITAB
7      MODULE tc931_init OUTPUT.
8
9        IF  g_tc931_copied  IS INITIAL.
10     *&SPWIZARD: COPY DDIC-TABLE 'j_1imovend'
11     *&SPWIZARD: INTO INTERNAL TABLE 'g_TC931_itab'
12         "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
13
14     *    SELECT * FROM j_1imovend
15     *       INTO CORRESPONDING FIELDS
16     *       OF TABLE g_tc931_itab ORDER BY PRIMARY KEY.
17
18
19         SELECT * FROM lfa1
20            INTO CORRESPONDING FIELDS
21            OF TABLE g_tc931_itab ORDER BY PRIMARY KEY.
22         "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
23         IF NOT  g_tc931_itab IS INITIAL.
24           SELECT lifnr Name1 INTO  TABLE ist_lfa1  FROM lfa1
25                        FOR ALL ENTRIES IN  g_tc931_itab
26                         WHERE lifnr = g_tc931_itab-lifnr.
27           LOOP AT g_tc931_itab INTO g_tc931_wa.
28             READ TABLE ist_lfa1 INTO wa_lfa1 WITH KEY
29                                    lifnr = g_tc931_wa-lifnr.
30             IF  sy-subrc = 0.
31               g_tc931_wa-name1 = wa_lfa1-name1.
32               MODIFY g_tc931_itab  FROM  g_tc931_wa TRANSPORTING
33                         name1 .
34             ENDIF.
35           ENDLOOP.
36         ENDIF.
37         g_tc931_copied = 'X'.
38         REFRESH CONTROL 'TC931' FROM SCREEN '0931'.
39       ENDIF.
40       "break cab_sudha.
41       IF g_vflag = 'X'.
42         CLEAR l_tabix.
43         IF NOT g_lifnr IS INITIAL.
44           READ TABLE g_tc931_itab INTO g_tc931_wa
45              WITH KEY  lifnr = g_lifnr.
46           IF sy-subrc = 0.
47             l_tabix = sy-tabix.
48           ENDIF.
49         ELSEIF NOT  g_panno IS   INITIAL.
50           READ TABLE g_tc931_itab INTO g_tc931_wa
51          WITH KEY  j_1ipanno = g_panno.
52           IF sy-subrc = 0.
53             l_tabix = sy-tabix.
54           ENDIF.
55         ENDIF.
56         tc931-top_line = l_tabix.
57         SET CURSOR 1 1. " l_tabix.
58         CLEAR g_vflag.
59         CLEAR l_tabix.
60       ENDIF.
61
62
63     ENDMODULE.
64
65     *&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
66     *&SPWIZARD: MOVE ITAB TO DYNPRO
67     MODULE tc931_move OUTPUT.
68     *  MOVE-CORRESPONDING g_tc931_wa TO j_1imovend.
69       MOVE-CORRESPONDING g_tc931_wa TO LFA1.
70       lfa1-name1 = g_tc931_wa-name1.
71     ENDMODULE.
72
73     *&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
74     *&SPWIZARD: GET LINES OF TABLECONTROL
75     MODULE tc931_get_lines OUTPUT.
76       g_tc931_lines = sy-loopc.
77     ENDMODULE.
78     *&---------------------------------------------------------------------*
79     *&      Module  STATUS_0931  OUTPUT
80     *&---------------------------------------------------------------------*
81     *       text
82     *----------------------------------------------------------------------*
83     MODULE status_0931 OUTPUT.
84       DATA fcode TYPE TABLE OF sy-ucomm.
85
86       IF sy-uname+0(1) <> 'C'.
87         APPEND 'DELE' TO fcode.
88         SET PF-STATUS 'S931' EXCLUDING fcode.
89
90
91     *begin RD1K982287       CAB_ALOK     Remove changeTab from tcode ZJ1INVPAN - CR 30008047
92     *Begin RD1K984875     CAB_ALOK     Include new fields in tcode ZJ1INVPAN - CR 30009141
93     **'Change' enabled for end user again.
94     *   APPEND 'CHANGE' TO fcode.
95     *   SET PF-STATUS 'S931' EXCLUDING fcode.
96     *end RD1K984875     CAB_ALOK     Include new fields in tcode ZJ1INVPAN - CR 30009141
97     *end RD1K982287       CAB_ALOK     Remove changeTab from tcode ZJ1INVPAN - CR 30008047
98
99
100      ELSE.
101        SET PF-STATUS 'S931'.
102      ENDIF.
103      CASE g_okcode.
104        WHEN 'CREATE' .
105          g_text = 'Create New Entries'.
106          SET TITLEBAR  'T931' WITH g_text .
107
108        WHEN 'CHANGE' .
109          g_text = 'Change Entries'.
110          SET TITLEBAR  'T931' WITH g_text .
111
112        WHEN 'DELE'.
113          g_text = 'Delete the Selected Entries'.
114          SET TITLEBAR  'T931' WITH g_text .
115
116
117      ENDCASE.
118    ENDMODULE.                 " STATUS_0931  OUTPUT
119    *&---------------------------------------------------------------------*
120    *&      Module  SCREEN_ATTRIBUTE_931  OUTPUT
121    *&---------------------------------------------------------------------*
122    *       text
123    *----------------------------------------------------------------------*
124    MODULE screen_attribute_931 OUTPUT.
125
126
127
128      DATA : lines TYPE i .
129      lines = sy-loopc.
130      "break cab_sudha.
131
132      CASE g_okcode1.
133        WHEN 'CREATE' OR 'INSR'.
134          LOOP AT SCREEN.
135            IF g_tc931_wa-flag = 'X'.
136              IF tc931-top_line = 1.
137                IF screen-group1 = 'KEY'.
138                  screen-input = 1.
139    *          screen-required = 1.
140                  MODIFY SCREEN.
141                ENDIF.
142              ENDIF.
143            ELSE.
144              IF screen-group2 = 'DIS'.
145                screen-input = 0.
146                MODIFY SCREEN.
147              ENDIF.
148            ENDIF.
149          ENDLOOP.
150        WHEN 'CHANGE'.
151    *     break cab_sudha.
152    *    LOOP AT tc931-cols INTO cols .
153    *     IF g_tc931_wa-flag = 'X' AND
154    *       g_cflag = 'X'.
155    *
156    *        IF  cols-SCREEN-NAME  = 'J_1IMOVEND-LIFNR'.
157    *               cols-SCREEN-INPUT = 0.
158    *       MODIFY tc931-cols FROM cols INDEX sy-tabix.
159    *       elseif cols-SCREEN-NAME  = 'J_1IMOVEND-J1IPANNO'.
160    *                   cols-SCREEN-INPUT = 1.
161    *       MODIFY tc931-cols FROM cols INDEX sy-tabix.
162    *        ENDIF.
163    *       clear g_cflag.
164    *     else.
165    *       if  cols-screen-group2 = 'DIS'.
166    *           cols-screen-input = 0.
167    *        endif.
168    *           MODIFY tc931-cols FROM cols INDEX sy-tabix.
169    *     endif.
170    *      ENDLOOP.
171
172          LOOP AT SCREEN.
173            IF g_tc931_wa-flag = 'X' AND
174               g_cflag = 'X'.
175              IF screen-group1 = 'KEY'.
176                screen-input = 0.
177                SCreen-active = 1.
178                MODIFY SCREEN.
179              ELSEIF screen-name = 'J_1IMOVEND-J1IPANNO'.
180                screen-input = 1.
181                SCreen-active = 1.
182                MODIFY SCREEN.
183              ENDIF.
184
185            ELSEIF g_tc931_wa-flag <> 'X'."  or g_cflag <> 'X'.
186              IF screen-group2 = 'DIS'.
187                screen-input = 0.
188                MODIFY SCREEN.
189              ENDIF.
190
191            ENDIF.
192          ENDLOOP.
193        WHEN ' ' OR 'ENTER'.
194          LOOP AT SCREEN .
195            IF screen-group2 = 'DIS'.
196              screen-input = 0.
197              MODIFY SCREEN.
198            ENDIF.
199          ENDLOOP.
200          LOOP AT SCREEN .
201            IF screen-group1 = 'KEY'.
202              screen-input = 0.
203              MODIFY SCREEN.
204            ENDIF.
205          ENDLOOP.
206
207
208      ENDCASE.
209
210
211    *Begin RD1K984875 CAB_ALOK Include new fields - CR 30009141
212    ** for non core team users, make following fields display only, if some value is altready there.
213    *            J_1IMOVEND-J_1IPANNO
214    *          J_1IEXRN TYPE j_1imovend-J_1IEXRN,
215    *          J_1ICSTNO TYPE j_1imovend-J_1ICSTNO,
216    *          J_1ILSTNO TYPE j_1imovend-J_1ILSTNO,
217    *          J_1ISERN TYPE j_1imovend-J_1ISERN.
218
219      IF sy-uname+0(1) <> 'C'.
220        CASE g_okcode1.
221          WHEN 'CHANGE'.
222
223            LOOP AT SCREEN.
224
225    *******Start of change by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************
226
227              IF  screen-name = 'J_1IMOVEND-J_1IPANNO'.
228                screen-input = 0.
229              ENDIF.
230              MODIFY SCREEN.
231    *****End of change by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************
232
233
234    ****Start of comment by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************
235
236    *     IF ( screen-name = 'J_1IMOVEND-J_1IPANNO'
237    *           and g_tc931_wa-J_1IPANNO is NOT INITIAL )
238    *       or
239
240
241    ****End of comment by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************
242
243
244    *******Start of comment by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997
245    **          IF ( screen-name = 'J_1IMOVEND-J_1IEXRN')
246    **             and g_tc931_wa-J_1IEXRN is NOT INITIAL )
247    **         or
248    **          ( screen-name = 'J_1IMOVEND-J_1ICSTNO')
249    **             and g_tc931_wa-J_1ICSTNO is NOT INITIAL )
250    **         or
251    **          ( screen-name = 'J_1IMOVEND-J_1ILSTNO')
252    **             and g_tc931_wa-J_1ILSTNO is NOT INITIAL )
253    **         or
254    **          ( screen-name = 'J_1IMOVEND-J_1ISERN').
255    **             and g_tc931_wa-J_1ISERN is NOT INITIAL ).
256    **
257    **            screen-input = 0.
258    *******End of comment by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997
259
260
261    *******Start of change by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997
262              IF ( screen-name = 'J_1IMOVEND-J_1IEXRN')
263            OR
264             ( screen-name = 'J_1IMOVEND-J_1ICSTNO')
265            OR
266             ( screen-name = 'J_1IMOVEND-J_1ILSTNO')
267            OR
268             ( screen-name = 'J_1IMOVEND-J_1ISERN').
269
270                screen-input = 1.
271    *******End of change by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997
272
273              ENDIF.
274              MODIFY SCREEN.
275
276            ENDLOOP.
277
278
279
280        ENDCASE.
281
282      ENDIF.
283    *End RD1K984875 CAB_ALOK Include new fields - CR 30009141
284
285    ENDMODULE.                 " SCREEN_ATTRIBUTE_931  OUTPUT
286    *&---------------------------------------------------------------------*
287    *&      Module  STATUS_0932  OUTPUT
288    *&---------------------------------------------------------------------*
289    *       text
290    *----------------------------------------------------------------------*
291    MODULE status_0932 OUTPUT.
292      g_text = 'Enter Vendor Number'.
293      SET PF-STATUS 'S932'.
294      SET TITLEBAR 'V932' WITH g_text.
295
296    ENDMODULE.                 " STATUS_0932  OUTPUT
297    *&---------------------------------------------------------------------*
298    *&      Module  SCR_STATUS  OUTPUT
299    *&---------------------------------------------------------------------*
300    *       text
301    *----------------------------------------------------------------------*
302    MODULE scr_status OUTPUT.
303      LOOP AT SCREEN .
304        IF screen-group1 = 'KEY'.
305          screen-input = 0.
306          screen-active = 1.
307          MODIFY SCREEN.
308        ENDIF.
309      ENDLOOP.
310
311    ENDMODULE.                 " SCR_STATUS  OUTPUT
*--- End of SAPMZFI_VPAN_MAINTAINO - 311 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINI                    Level 1    Page 4
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 423
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_UPDATE_j_1imovendI
3      *&---------------------------------------------------------------------*
4
5      *&SPWIZARD: INPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
6      *&SPWIZARD: MODIFY TABLE
7      MODULE tc931_modify INPUT.
8
9        MOVE-CORRESPONDING LFA1 TO g_tc931_wa.
10     *  MOVE-CORRESPONDING j_1imovend TO g_tc931_wa.
11       PERFORM  get_vendorname.
12       PERFORM  check_validpanno.
13
14       IF g_okcode = 'CHANGE'.
15         g_tc931_wa-flag = 'X'.
16       ENDIF.
17       MODIFY g_tc931_itab FROM g_tc931_wa
18       INDEX tc931-current_line.
19
20     ENDMODULE.                    "TC931_MODIFY INPUT
21
22     *&SPWIZARD: INPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
23     *&SPWIZARD: PROCESS USER COMMAND
24     MODULE tc931_user_command INPUT.
25       "BREAK CAB_SUDHa.
26       ok_code = sy-ucomm.
27       PERFORM user_ok_tc USING    'TC931'
28                                   'G_TC931_ITAB'
29                                   'FLAG'
30                          CHANGING ok_code.
31       g_okcode = sy-ucomm+6.
32       sy-ucomm = ok_code.
33     ENDMODULE.                    "TC931_USER_COMMAND INPUT
34     *&---------------------------------------------------------------------*
35     *&      Module  EXIT  INPUT
36     *&---------------------------------------------------------------------*
37     *       text
38     *----------------------------------------------------------------------*
39     MODULE exit INPUT.
40       g_okcode = sy-ucomm.
41       CASE g_okcode.
42         WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
43           LEAVE TO SCREEN 0.
44       ENDCASE.
45
46     ENDMODULE.                 " EXIT  INPUT
47     *&---------------------------------------------------------------------*
48     *&     Module  USER_COMMAND_INPUT  INPUT
49     *&---------------------------------------------------------------------*
50     *       text
51     *----------------------------------------------------------------------*
52     MODULE user_command_931 INPUT.
53       g_okcode = sy-ucomm.
54       CASE g_okcode.
55         WHEN  'CREATE'.
56           PERFORM insert_new_row.
57         WHEN 'CHANGE'.
58           g_okcode1 = sy-ucomm.
59     *      PERFORM authority_check USING '02' .
60           READ TABLE g_tc931_itab INTO g_tc931_wa
61           WITH KEY flag = 'X'.
62           IF sy-subrc <> 0.
63             MESSAGE e260(zfi).
64           ELSE.
65             g_cflag = 'X'.
66           ENDIF.
67         WHEN 'DELE' OR 'TC931_DELE'.
68           g_okcode1 = sy-ucomm.
69           PERFORM delete_row.
70
71         WHEN 'SAVE' .
72           PERFORM update_record.
73         WHEN 'POSI'.
74           PERFORM position_record.
75
76     *Begin RD1K984875 CAB_ALOK Include new fields - CR 30009141
77     * sort vendor
78         WHEN 'VASC'. "Vendor Ascending
79           SORT g_tc931_itab BY lifnr ASCENDING.
80
81         WHEN 'VDES'. "Vendor Descending
82           SORT g_tc931_itab BY lifnr DESCENDING.
83
84         WHEN 'EXPORT'.
85           PERFORM download_report.
86
87     *End RD1K984875 CAB_ALOK Include new fields - CR 30009141
88
89       ENDCASE.
90     ENDMODULE.                 " USER_COMMAND_INPUT  INPUT
91     *&---------------------------------------------------------------------*
92     *&      Form  INSERT_NEW_ROW
93     *&---------------------------------------------------------------------*
94     *       text
95     *----------------------------------------------------------------------*
96     *  -->  p1        text
97     *  <--  p2        text
98     *----------------------------------------------------------------------*
99     FORM insert_new_row .
100
101    ********start of change by Anamika on 27.03.2015 for deactivation of create button for vendor RD1K996820
102      IF sy-uname+0(1) <> 'C' .
103        MESSAGE TEXT-001 TYPE 'E'.
104      ENDIF.
105
106    ********End of change by Anamika on 27.03.2015 for deactivation of create button for vendor RD1K996820
107
108      READ TABLE  g_tc931_itab INTO LFA1 INDEX 1.
109    *  READ TABLE  g_tc931_itab INTO j_1imovend INDEX 1.
110      DATA : l_line TYPE i.
111
112      DESCRIBE TABLE  g_tc931_itab LINES l_line.
113
114      l_line = l_line + 1.
115      tc931-lines = l_line.
116      tc931-top_line = 1.
117      INSERT INITIAL LINE INTO g_tc931_itab INDEX 1. "L_LINE.
118
119      IF sy-subrc = 0.
120        CLEAR g_tc931_wa.
121      ENDIF.
122
123      SET CURSOR LINE 1. "L_LINE.
124      g_tc931_wa-flag = 'X'.
125      MODIFY g_tc931_itab FROM g_tc931_wa INDEX 1. "L_LINE.
126      g_okcode1 = 'INSR'.
127    ENDFORM.                    " INSERT_NEW_ROW
128    *&---------------------------------------------------------------------*
129    *&      Form  UPDATE_RECORD
130    *&---------------------------------------------------------------------*
131    *       text
132    *----------------------------------------------------------------------*
133    *  -->  p1        text
134    *  <--  p2        text
135    *----------------------------------------------------------------------*
136    FORM update_record .
137      "break cab_sudha.
138      CASE g_okcode1.
139        WHEN 'INSR'.
140
141          LOOP AT g_tc931_itab INTO g_tc931_wa WHERE flag = 'X'.
142            g_ackn_wa-lifnr = g_tc931_wa-lifnr.
143            g_ackn_wa-j_1ipanno  = g_tc931_wa-j_1ipanno.
144    *Begin RD1K984875 CAB_ALOK Include new fields - CR 30009141
145            g_ackn_wa-j_1iexrn = g_tc931_wa-j_1iexrn.
146            g_ackn_wa-j_1icstno = g_tc931_wa-j_1icstno.
147            g_ackn_wa-j_1ilstno = g_tc931_wa-j_1ilstno.
148            g_ackn_wa-j_1isern = g_tc931_wa-j_1isern.
149    *End RD1K984875 CAB_ALOK Include new fields - CR 30009141
150            IF NOT g_tc931_wa-lifnr IS INITIAL.
151              "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
152
153    *          SELECT SINGLE * FROM j_1imovend INTO G_ackn_WA
154    *          WHERE lifnr  = g_tc931_wa-lifnr.
155              SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF G_ackn_WA
156    WHERE lifnr  = g_tc931_wa-lifnr.
157              "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
158              IF sy-subrc <> 0.
159    *----------duplicate pan
160                "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
161
162    *        SELECT * FROM J_1IMOVEND INTO G_PAN_WA UP TO 1 ROWS
163    * WHERE J_1IPANNO = G_TC931_WA-J_1IPANNO
164    * ORDER BY PRIMARY KEY .
165    * ENDSELECT.
166
167                SELECT * FROM lfa1 INTO CORRESPONDING FIELDS OF g_pan_wa UP TO 1 ROWS
168        WHERE j_1ipanno = g_tc931_wa-j_1ipanno
169        ORDER BY PRIMARY KEY .
170                ENDSELECT.
171                "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
172                IF sy-subrc = 0.
173                  MESSAGE i413(zfi) WITH G_pan_WA-lifnr.
174                ENDIF.
175    *            MODIFY j_1imovend FROM g_ackn_wa.
176                MODIFY lfa1 FROM g_ackn_wa.
177                IF sy-subrc = 0.
178                  MESSAGE s555(zfi).
179                ENDIF.
180                CLEAR : g_tc931_wa-flag .
181                MODIFY g_tc931_itab FROM g_tc931_wa.
182              ELSE.
183                MESSAGE e413(zfi) WITH g_ackn_wa-lifnr.
184              ENDIF.
185            ENDIF.
186          ENDLOOP.
187
188        WHEN 'CHANGE'.
189          CLEAR  g_pan_wa.
190          LOOP AT g_tc931_itab INTO g_tc931_wa WHERE flag = 'X'.
191    *----------duplicate pan
192            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
193
194    *        SELECT * FROM j_1imovend INTO g_pan_wa UP TO 1 ROWS
195    *   WHERE j_1ipanno = g_tc931_wa-j_1ipanno
196    *   ORDER BY PRIMARY KEY .
197    *        ENDSELECT.
198            SELECT * FROM lfa1 INTO CORRESPONDING FIELDS OF g_pan_wa UP TO 1 ROWS
199    WHERE j_1ipanno = g_tc931_wa-j_1ipanno
200    ORDER BY PRIMARY KEY .
201            ENDSELECT.
202            IF sy-subrc = 0.
203              MESSAGE i413(zfi) WITH G_pan_WA-lifnr.
204            ENDIF.
205            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
206            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
207
208    *        SELECT SINGLE * FROM j_1imovend INTO G_ackn_WA
209    *        WHERE lifnr  = g_tc931_wa-lifnr.
210            SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF G_ackn_WA
211    WHERE lifnr  = g_tc931_wa-lifnr.
212            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
213            IF sy-subrc = 0.
214              g_ackn_wa-j_1ipanno  = g_tc931_wa-j_1ipanno.
215    *Begin RD1K984875 CAB_ALOK Include new fields - CR 30009141
216              g_ackn_wa-j_1iexrn = g_tc931_wa-j_1iexrn.
217              g_ackn_wa-j_1icstno = g_tc931_wa-j_1icstno.
218              g_ackn_wa-j_1ilstno = g_tc931_wa-j_1ilstno.
219              g_ackn_wa-j_1isern = g_tc931_wa-j_1isern.
220    *End RD1K984875 CAB_ALOK Include new fields - CR 30009141
221    *          MODIFY j_1imovend FROM g_ackn_wa.
222              MODIFY LFA1 FROM g_ackn_wa.
223              IF sy-subrc = 0.
224                MESSAGE s555(zfi).
225                CLEAR : g_tc931_wa-flag .
226              ENDIF.
227              MODIFY g_tc931_itab FROM g_tc931_wa.
228            ELSE.
229              "not updated
230            ENDIF.
231
232          ENDLOOP.
233          CLEAR g_cflag.
234          "    break cab_sudha.
235        WHEN 'DELE'.
236    *    select single * from j_1imovend where lifnr = g_tc931_wa-lifnr.
237    *      if sy-subrc = 0.
238    *      delete j_1imovend .
239    *      if sy-subrc = 0.
240    *           message e414(zfi) with  'Record deleted'.
241    *      endif.
242    *      endif.
243      ENDCASE.
244    ENDFORM.                    " UPDATE_RECORD
245    *&---------------------------------------------------------------------*
246    *&      Module  TC931_MARK  INPUT
247    *&---------------------------------------------------------------------*
248    *       text
249    *----------------------------------------------------------------------*
250    MODULE tc931_mark INPUT.
251
252      IF tc931-line_sel_mode = 1 AND
253         g_tc931_wa-flag = 'X'.
254        LOOP AT g_tc931_itab INTO g_tc931_wa
255          WHERE flag = 'X'.
256          g_tc931_wa-flag = ''.
257          MODIFY g_tc931_itab
258            FROM g_tc931_wa
259            TRANSPORTING flag.
260        ENDLOOP.
261        g_tc931_wa-flag = 'X'.
262      ENDIF.
263
264      MODIFY g_tc931_itab
265      FROM g_tc931_wa
266      INDEX tc931-current_line
267      TRANSPORTING flag.
268
269    ENDMODULE.                 " TC931_MARK  INPUT
270    *&---------------------------------------------------------------------*
271    *&      Form  AUTHORITY_CHECK
272    *&---------------------------------------------------------------------*
273    *       text
274    *----------------------------------------------------------------------*
275    *      -->P_0080   text
276    *----------------------------------------------------------------------*
277    FORM authority_check USING    p_actvt.
278      AUTHORITY-CHECK OBJECT 'ZFITDSACKN'
279               ID 'ACTVT' FIELD p_actvt.
280      IF sy-subrc NE 0.
281        MESSAGE e018(s#).
282      ENDIF.
283    ENDFORM.                     " AUTHORITY_CHECK
284    *&---------------------------------------------------------------------*
285    *&      Form  CHECK_VALIDPANNO
286    *&---------------------------------------------------------------------*
287    *       text
288    *----------------------------------------------------------------------*
289    *  -->  p1        text
290    *  <--  p2        text
291    *----------------------------------------------------------------------*
292    FORM check_validpanno .
293    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
294
295    *  DATA : l_panno  LIKE j_1imovend-j_1ipanno.
296      DATA : l_panno  LIKE lfa1-j_1ipanno.
297    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
298      DATA : l_len TYPE i .
299
300      CLEAR l_panno.
301      CLEAR l_len.
302      l_panno = g_tc931_wa-j_1ipanno.
303      l_len = strlen( l_panno ).
304      IF l_len <> 10.
305        MESSAGE e415(zfi) .
306      ENDIF.
307      IF l_panno+0(5) CN sy-abcde.
308        MESSAGE  e414(zfi) WITH 'First 5 chars should be Alphabets'.
309      ENDIF.
310      IF  l_panno+5(4) CN '0123456789'.
311        MESSAGE e414(zfi) WITH '6th to 9th Chars should be Numeric'.
312      ENDIF.
313      IF l_panno+9(1) CN sy-abcde.
314        MESSAGE  e414(zfi) WITH 'Last Character should be Alphabets'.
315      ENDIF.
316
317    ENDFORM.                    " CHECK_VALIDPANNO
318    *&---------------------------------------------------------------------*
319    *&      Form  POSITION_RECORD
320    *&---------------------------------------------------------------------*
321    *       text
322    *----------------------------------------------------------------------*
323    *  -->  p1        text
324    *  <--  p2        text
325    *----------------------------------------------------------------------*
326    FORM position_record .
327    *  CLEAR j_1imovend-lifnr.
328      CLEAR LFA1-lifnr.
329    *  CLEAR j_1imovend-j_1ipanno.
330      CLEAR LFA1-j_1ipanno.
331      CALL SCREEN 0932  STARTING AT  50  50
332                        ENDING AT  100 100 .
333
334    ENDFORM.                    " POSITION_RECORD
335    *&---------------------------------------------------------------------*
336    *&      Module  USER_COMMAND_0932  INPUT
337    *&---------------------------------------------------------------------*
338    *       text
339    *----------------------------------------------------------------------*
340    MODULE user_command_0932 INPUT.
341      g_okcode2 = ok_code2.
342      BREAK cab_sudha.
343      CASE g_okcode2.
344        WHEN 'ENTR'.
345          CLEAR g_lifnr.
346          CLEAR g_panno.
347    *      IF NOT j_1imovend-lifnr IS INITIAL.
348          IF NOT LFA1-lifnr IS INITIAL.
349    "Code Remediation changes S4 2025 Conversion begin of change SAP_ABAP and 12.06.2026
350    *        DATA(lv_lifnr) = j_1imovend-lifnr.
351            DATA(lv_lifnr) = LFA1-lifnr.
352    *        g_lifnr = j_1imovend-lifnr.
353            g_lifnr = lv_lifnr.
354            g_vflag = 'X'.
355    *      ELSEIF NOT j_1imovend-j_1ipanno IS INITIAL.
356          ELSEIF NOT LFA1-j_1ipanno IS INITIAL.
357    *        DATA(lv_panno) = j_1imovend-j_1ipanno.
358            DATA(lv_panno) = LFA1-j_1ipanno.
359    *        g_panno = j_1imovend-j_1ipanno.
360            g_panno = lv_panno.
361            g_vflag = 'X'.
362          ENDIF.
363    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
364    *  suppress dialog.
365          LEAVE  TO SCREEN  0.
366        WHEN 'CANC'.
367          "break cab_sudha.
368          LEAVE TO  SCREEN 0.
369      ENDCASE.
370    ENDMODULE.                 " USER_COMMAND_0932  INPUT
371    *&---------------------------------------------------------------------*
372    *&      Module  UPDATE_LOGS  INPUT
373    *&---------------------------------------------------------------------*
374    *       text
375    *----------------------------------------------------------------------*
376    MODULE update_logs INPUT.
377      TABLES : zj1invpanlog.
378      DATA : wa_zj1invpanlog TYPE zj1invpanlog.
379      DATA: l_tstamp TYPE timestamp,
380            l_d      TYPE d,
381            l_t      TYPE t.
382
383    *compare PAN no. with original and if changed, maintain logs in zj1invpanlog table.
384    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
385
386    DATA(ls_1imovend) = lfa1.
387    *  IF  t_panno NE j_1imovend-j_1ipanno .
388      IF  t_panno NE ls_1imovend-j_1ipanno .
389
390        wa_zj1invpanlog-mandt = sy-mandt.
391    *    wa_zj1invpanlog-lifnr = j_1imovend-lifnr.
392        wa_zj1invpanlog-lifnr = ls_1imovend-lifnr.
393        wa_zj1invpanlog-changed_date = sy-datum.
394    *  CALCULATE TIMESTAMP.
395        l_d = sy-datum.
396        l_t = sy-uzeit.
397        CONVERT DATE l_d TIME l_t INTO
398                TIME STAMP l_tstamp TIME ZONE 'UTC   '.
399    *
400        wa_zj1invpanlog-timestamp = l_tstamp.
401        wa_zj1invpanlog-j_1ipanno_old = t_panno .
402    *    wa_zj1invpanlog-j_1ipanno_new = j_1imovend-j_1ipanno.
403        wa_zj1invpanlog-j_1ipanno_new = ls_1imovend-j_1ipanno.
404        wa_zj1invpanlog-changed_by = sy-uname.
405     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
406        INSERT zj1invpanlog FROM wa_zj1invpanlog.
407      ENDIF.
408    ENDMODULE.                 " UPDATE_LOGS  INPUT
409    *&---------------------------------------------------------------------*
410    *&      Module  HOLD_ORIGINAL  INPUT
411    *&---------------------------------------------------------------------*
412    *       text
413    *----------------------------------------------------------------------*
414    MODULE hold_original INPUT.
415    * Store current value of Pan No.
416     "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
417
418    *  DATA(lv_pan) = j_1imovend-j_1ipanno.
419      DATA(lv_pan) = LFA1-J_1ipanno.
420    *  t_panno = j_1imovend-j_1ipanno .
421      t_panno = lv_pan .
422      "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
423    ENDMODULE.                 " HOLD_ORIGINAL  INPUT
*--- End of SAPMZFI_VPAN_MAINTAINI - 423 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINF                    Level 1    Page 5
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 488
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_UPDATE_j_1imovendF
3      *&---------------------------------------------------------------------*
4
5      *----------------------------------------------------------------------*
6      *   INCLUDE TABLECONTROL_FORMS                                         *
7      *----------------------------------------------------------------------*
8
9      *&---------------------------------------------------------------------*
10     *&      Form  USER_OK_TC                                               *
11     *&---------------------------------------------------------------------*
12      FORM user_ok_tc USING    p_tc_name TYPE dynfnam
13                               p_table_name
14                               p_mark_name
15                      CHANGING p_ok      LIKE sy-ucomm.
16
17     *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
18        DATA: l_ok     TYPE sy-ucomm,
19              l_offset TYPE i.
20     *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
21
22     *&SPWIZARD: Table control specific operations                          *
23     *&SPWIZARD: evaluate TC name and operations                            *
24        SEARCH p_ok FOR p_tc_name.
25        IF sy-subrc <> 0.
26          EXIT.
27        ENDIF.
28        l_offset = strlen( p_tc_name ) + 1.
29        l_ok = p_ok+l_offset.
30     *&SPWIZARD: execute general and TC specific operations                 *
31        CASE l_ok.
32     *     WHEN 'INSR'.                      "insert row
33     *       perform insert_new_row.
34     *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
35     *                                         P_TABLE_NAME.
36     *       CLEAR P_OK.
37
38          WHEN 'DELE'.                      "delete row
39            IF sy-uname <> 'CAB_SUDHA'.      "add sudha
40              PERFORM authority_check USING '06' .
41            ENDIF.
42
43     *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
44     *                                         P_TABLE_NAME
45     *                                         P_MARK_NAME.
46
47            CLEAR p_ok.
48
49          WHEN 'P--' OR                     "top of list
50               'P-'  OR                     "previous page
51               'P+'  OR                     "next page
52               'P++'.                       "bottom of list
53            PERFORM compute_scrolling_in_tc USING p_tc_name
54                                                  l_ok.
55            CLEAR p_ok.
56
57          WHEN 'MARK'.                      "mark all filled lines
58            PERFORM fcode_tc_mark_lines USING p_tc_name
59                                              p_table_name
60                                              p_mark_name   .
61            CLEAR p_ok.
62
63          WHEN 'DMRK'.                      "demark all filled lines
64            PERFORM fcode_tc_demark_lines USING p_tc_name
65                                                p_table_name
66                                                p_mark_name .
67            CLEAR p_ok.
68
69     *     WHEN 'SASCEND'   OR
70     *          'SDESCEND'.                  "sort column
71     *       PERFORM FCODE_SORT_TC USING P_TC_NAME
72     *                                   l_ok.
73
74        ENDCASE.
75
76      ENDFORM.                              " USER_OK_TC
77
78     *&---------------------------------------------------------------------*
79     *&      Form  FCODE_INSERT_ROW                                         *
80     *&---------------------------------------------------------------------*
81      FORM fcode_insert_row
82                    USING    p_tc_name           TYPE dynfnam
83                             p_table_name             .
84
85     *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
86        DATA l_lines_name       LIKE feld-name.
87        DATA l_selline          LIKE sy-stepl.
88        DATA l_lastline         TYPE i.
89        DATA l_line             TYPE i.
90        DATA l_table_name       LIKE feld-name.
91        FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
92        FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
93        FIELD-SYMBOLS <lines>              TYPE i.
94     *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
95
96        ASSIGN (p_tc_name) TO <tc>.
97
98     *&SPWIZARD: get the table, which belongs to the tc                     *
99        CONCATENATE p_table_name '[]' INTO l_table_name. "table body
100       ASSIGN (l_table_name) TO <table>.                "not headerline
101
102    *&SPWIZARD: get looplines of TableControl                              *
103       CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
104       ASSIGN (l_lines_name) TO <lines>.
105
106    *&SPWIZARD: get current line                                           *
107       GET CURSOR LINE l_selline.
108       IF sy-subrc <> 0.                   " append line to table
109         l_selline = <tc>-lines + 1.
110    *&SPWIZARD: set top line                                               *
111         IF l_selline > <lines>.
112           <tc>-top_line = l_selline - <lines> + 1 .
113         ELSE.
114           <tc>-top_line = 1.
115         ENDIF.
116       ELSE.                               " insert line into table
117         l_selline = <tc>-top_line + l_selline - 1.
118         l_lastline = <tc>-top_line + <lines> - 1.
119       ENDIF.
120    *&SPWIZARD: set new cursor line                                        *
121       l_line = l_selline - <tc>-top_line + 1.
122
123    *&SPWIZARD: insert initial line                                        *
124       INSERT INITIAL LINE INTO <table> INDEX l_selline.
125       <tc>-lines = <tc>-lines + 1.
126    *&SPWIZARD: set cursor                                                 *
127       SET CURSOR LINE l_line.
128
129     ENDFORM.                              " FCODE_INSERT_ROW
130
131    *&---------------------------------------------------------------------*
132    *&      Form  FCODE_DELETE_ROW                                         *
133    *&---------------------------------------------------------------------*
134     FORM fcode_delete_row
135                   USING    p_tc_name           TYPE dynfnam
136                            p_table_name
137                            p_mark_name   .
138
139    *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
140       DATA l_table_name       LIKE feld-name.
141
142       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
143       FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
144       FIELD-SYMBOLS <wa>.
145
146       FIELD-SYMBOLS <mark_field>.
147    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
148    *   break cab_sudhir.
149       ASSIGN (p_tc_name) TO <tc>.
150
151    *&SPWIZARD: get the table, which belongs to the tc                     *
152       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
153       ASSIGN (l_table_name) TO <table>.                "not headerline
154
155    *&SPWIZARD: delete marked lines                                        *
156       DESCRIBE TABLE <table> LINES <tc>-lines.
157       g_tc931_itab_del[] = <table>.
158       READ TABLE g_tc931_itab_del INTO g_tc931_wa_del WITH KEY flag = 'X'.
159       LOOP AT <table> ASSIGNING <wa>.
160
161    *&SPWIZARD: access to the component 'FLAG' of the table header         *
162         ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
163
164         IF <mark_field> = 'X'.
165
166           DELETE <table> INDEX syst-tabix.
167
168           IF sy-subrc = 0.
169             <tc>-lines = <tc>-lines - 1.
170           ENDIF.
171         ENDIF.
172       ENDLOOP.
173       g_okcode1 = sy-ucomm+6.
174     ENDFORM.                              " FCODE_DELETE_ROW
175
176    *&---------------------------------------------------------------------*
177    *&      Form  COMPUTE_SCROLLING_IN_TC
178    *&---------------------------------------------------------------------*
179    *       text
180    *----------------------------------------------------------------------*
181    *      -->P_TC_NAME  name of tablecontrol
182    *      -->P_OK       ok code
183    *----------------------------------------------------------------------*
184     FORM compute_scrolling_in_tc USING    p_tc_name
185                                           p_ok.
186    *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
187       DATA l_tc_new_top_line     TYPE i.
188       DATA l_tc_name             LIKE feld-name.
189       DATA l_tc_lines_name       LIKE feld-name.
190       DATA l_tc_field_name       LIKE feld-name.
191
192       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
193       FIELD-SYMBOLS <lines>      TYPE i.
194    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
195
196       ASSIGN (p_tc_name) TO <tc>.
197    *&SPWIZARD: get looplines of TableControl                              *
198       CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
199       ASSIGN (l_tc_lines_name) TO <lines>.
200
201
202    *&SPWIZARD: is no line filled?                                         *
203       IF <tc>-lines = 0.
204    *&SPWIZARD: yes, ...                                                   *
205         l_tc_new_top_line = 1.
206       ELSE.
207    *&SPWIZARD: no, ...                                                    *
208         CALL FUNCTION 'SCROLLING_IN_TABLE'
209           EXPORTING
210             entry_act      = <tc>-top_line
211             entry_from     = 1
212             entry_to       = <tc>-lines
213             last_page_full = 'X'
214             loops          = <lines>
215             ok_code        = p_ok
216             overlapping    = 'X'
217           IMPORTING
218             entry_new      = l_tc_new_top_line
219           EXCEPTIONS
220    *        NO_ENTRY_OR_PAGE_ACT  = 01
221    *        NO_ENTRY_TO    = 02
222    *        NO_OK_CODE_OR_PAGE_GO = 03
223             OTHERS         = 0.
224       ENDIF.
225
226    *&SPWIZARD: get actual tc and column                                   *
227       GET CURSOR FIELD l_tc_field_name
228                  AREA  l_tc_name.
229
230       IF syst-subrc = 0.
231         IF l_tc_name = p_tc_name.
232    *&SPWIZARD: et actual column                                           *
233           SET CURSOR FIELD l_tc_field_name LINE 1.
234         ENDIF.
235       ENDIF.
236
237    *&SPWIZARD: set the new top line                                       *
238       <tc>-top_line = l_tc_new_top_line.
239
240
241     ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
242
243    *&---------------------------------------------------------------------*
244    *&      Form  FCODE_TC_MARK_LINES
245    *&---------------------------------------------------------------------*
246    *       marks all TableControl lines
247    *----------------------------------------------------------------------*
248    *      -->P_TC_NAME  name of tablecontrol
249    *----------------------------------------------------------------------*
250     FORM fcode_tc_mark_lines USING p_tc_name
251                                    p_table_name
252                                    p_mark_name.
253    *&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
254       DATA l_table_name       LIKE feld-name.
255
256       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
257       FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
258       FIELD-SYMBOLS <wa>.
259       FIELD-SYMBOLS <mark_field>.
260    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
261
262       ASSIGN (p_tc_name) TO <tc>.
263
264    *&SPWIZARD: get the table, which belongs to the tc                     *
265       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
266       ASSIGN (l_table_name) TO <table>.                "not headerline
267
268    *&SPWIZARD: mark all filled lines                                      *
269       LOOP AT <table> ASSIGNING <wa>.
270
271    *&SPWIZARD: access to the component 'FLAG' of the table header         *
272         ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
273
274         <mark_field> = 'X'.
275       ENDLOOP.
276     ENDFORM.                                          "fcode_tc_mark_lines
277
278    *&---------------------------------------------------------------------*
279    *&      Form  FCODE_TC_DEMARK_LINES
280    *&---------------------------------------------------------------------*
281    *       demarks all TableControl lines
282    *----------------------------------------------------------------------*
283    *      -->P_TC_NAME  name of tablecontrol
284    *----------------------------------------------------------------------*
285     FORM fcode_tc_demark_lines USING p_tc_name
286                                      p_table_name
287                                      p_mark_name .
288    *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
289       DATA l_table_name       LIKE feld-name.
290
291       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
292       FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
293       FIELD-SYMBOLS <wa>.
294       FIELD-SYMBOLS <mark_field>.
295    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
296
297       ASSIGN (p_tc_name) TO <tc>.
298
299    *&SPWIZARD: get the table, which belongs to the tc                     *
300       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
301       ASSIGN (l_table_name) TO <table>.                "not headerline
302
303    *&SPWIZARD: demark all filled lines                                    *
304       LOOP AT <table> ASSIGNING <wa>.
305
306    *&SPWIZARD: access to the component 'FLAG' of the table header         *
307         ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
308
309         <mark_field> = space.
310       ENDLOOP.
311     ENDFORM.                                          "fcode_tc_mark_lines
312    *&---------------------------------------------------------------------*
313    *&      Form  GET_VENDORNAME
314    *&---------------------------------------------------------------------*
315    *       text
316    *----------------------------------------------------------------------*
317    *  -->  p1        text
318    *  <--  p2        text
319    *----------------------------------------------------------------------*
320     FORM get_vendorname .
321       DATA : l_name1 LIKE lfa1-name1.
322       SELECT SINGLE name1  INTO  l_name1   FROM lfa1
323    *     WHERE  lifnr = j_1imovend-lifnr .
324         WHERE  lifnr = LFA1-lifnr .
325       IF sy-subrc = 0.
326         g_tc931_wa-name1 = l_name1.
327       ENDIF.
328     ENDFORM.                    " GET_VENDORNAME
329    *&---------------------------------------------------------------------*
330    *&      Form  DELETE_ROW
331    *&---------------------------------------------------------------------*
332    *       text
333    *----------------------------------------------------------------------*
334    *  -->  p1        text
335    *  <--  p2        text
336    *----------------------------------------------------------------------*
337     FORM delete_row .
338       DATA : l_line TYPE i .
339       BREAK cab_sudha.
340       CLEAR l_line.
341       READ TABLE g_tc931_itab  INTO g_tc931_wa  WITH KEY flag = 'X'.
342       IF sy-subrc <> 0.
343         MESSAGE e414(zfi)  WITH  'Select the line to be deleted'.
344       ENDIF.
345    *
346    *message the line has been deleted  from the data base
347       l_line =  tc931-lines.
348       l_line = l_line - 1.
349       tc931-lines = l_line.
350    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
351
352    *   SELECT SINGLE * FROM j_1imovend WHERE lifnr = g_tc931_wa-lifnr.
353       SELECT SINGLE * FROM lfa1 WHERE lifnr = g_tc931_wa-lifnr.
354    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
355       IF sy-subrc = 0.
356    *     DELETE j_1imovend .
357    *     DELETE LFA1 .
358         IF sy-subrc = 0.
359           MESSAGE e414(zfi) WITH  'Record deleted'.
360         ENDIF.
361       ENDIF.
362
363       DELETE g_tc931_itab  WHERE flag = 'X'.
364       g_okcode1 = sy-ucomm+6.
365     ENDFORM.                    " DELETE_ROW
366    *&---------------------------------------------------------------------*
367    *&      Form  DOWNLOAD_REPORT
368    *&---------------------------------------------------------------------*
369    *       text
370    *----------------------------------------------------------------------*
371    *  -->  p1        text
372    *  <--  p2        text
373    *----------------------------------------------------------------------*
374    *Begin RD1K984875 CAB_ALOK Include new fields - CR 30009141
375     FORM download_report .
376    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
377
378    *TYPES: BEGIN OF T_TC931_rep,
379    *          LIFNR TYPE j_1imovend-LIFNR,
380    *          J_1IPANNO TYPE j_1imovend-J_1IPANNO,
381    *          name1 type lfa1-name1,
382    *          J_1IEXRN TYPE j_1imovend-J_1IEXRN,
383    *          J_1ICSTNO TYPE j_1imovend-J_1ICSTNO,
384    *          J_1ILSTNO TYPE j_1imovend-J_1ILSTNO,
385    *          J_1ISERN TYPE j_1imovend-J_1ISERN,
386    *       END OF T_TC931_rep.
387
388       TYPES: BEGIN OF T_TC931_rep,
389                lifnr     TYPE lfa1-lifnr,
390                j_1ipanno TYPE lfa1-j_1ipanno,
391                name1     TYPE lfa1-name1,
392                j_1iexrn  TYPE lfa1-j_1iexrn,
393                j_1icstno TYPE lfa1-j_1icstno,
394                j_1ilstno TYPE lfa1-j_1ilstno,
395                j_1isern  TYPE lfa1-j_1isern,
396              END OF T_TC931_rep.
397    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
398
399       DATA: ist_status_rep TYPE STANDARD TABLE OF T_TC931_rep,
400             wa_status_rep  TYPE T_TC931_rep.
401       DATA: wa_tc931 TYPE t_tc931.
402
403    ** XXL_SIMPLE_API parameters and tables
404       DATA : es_filename    LIKE gxxlt_f-file, " File name on the workstation
405              es_header      LIKE gxxlt_p-text, " XXL interface: texts for printing a list
406              ls_col_text    TYPE gxxlt_v,
407              lt_col_text    TYPE TABLE OF gxxlt_v, " Headings for DATA columns
408              ls_online_text TYPE gxxlt_o,
409              lt_online_text TYPE TABLE OF gxxlt_o, " Table with online texts
410              ls_print_text  TYPE gxxlt_p,
411              lt_print_text  TYPE TABLE OF gxxlt_p. " Table with print texts
412
413    **Prepare Data for downloading
414
415    *ist_status_rep[] = g_tc931_itab[].
416
417       CLEAR: wa_tc931, wa_status_rep.
418       LOOP AT g_tc931_itab INTO wa_tc931.
419         MOVE-CORRESPONDING wa_tc931 TO wa_status_rep.
420         APPEND wa_status_rep TO ist_status_rep.
421         CLEAR: wa_tc931, wa_status_rep.
422       ENDLOOP.
423
424       es_filename = 'VENDOR.xls'.
425       es_header = 'VendorPanDetails'.
426
427    * Headings for DATA columns
428       ls_col_text-col_no = '1'.
429       ls_col_text-col_name = 'Vendor No.'.
430       APPEND ls_col_text TO lt_col_text.
431
432       ls_col_text-col_no = '2'.
433       ls_col_text-col_name = 'Pan No.'.
434       APPEND ls_col_text TO lt_col_text.
435
436       ls_col_text-col_no = '3'.
437       ls_col_text-col_name = 'Vendor Name'.
438       APPEND ls_col_text TO lt_col_text.
439
440       ls_col_text-col_no = '4'.
441       ls_col_text-col_name = 'Excise Reg.No.'.
442       APPEND ls_col_text TO lt_col_text.
443
444       ls_col_text-col_no = '5'.
445       ls_col_text-col_name = 'CST No.'.
446       APPEND ls_col_text TO lt_col_text.
447
448       ls_col_text-col_no = '6'.
449       ls_col_text-col_name = 'LST No.'.
450       APPEND ls_col_text TO lt_col_text.
451
452       ls_col_text-col_no = '7'.
453       ls_col_text-col_name = 'Ser.Tax Reg.no.'.
454       APPEND ls_col_text TO lt_col_text.
455
456    *  ls_col_text-col_no = '8'.
457    *  ls_col_text-col_name = 'Flag'.
458    *  append ls_col_text to lt_col_text.
459
460       CALL FUNCTION 'XXL_SIMPLE_API'
461         EXPORTING
462           filename          = es_filename " File name on the workstation
463           header            = es_header " Heading for exported list object
464           n_key_cols        = 1 " Number of (hierarchical) key columns
465         TABLES
466           col_text          = lt_col_text
467           data              = ist_status_rep
468           online_text       = lt_online_text
469           print_text        = lt_print_text
470         EXCEPTIONS
471           dim_mismatch_data = 1 " Non-present DATA column is referenced
472           file_open_error   = 2 " File FILENAME cannot be opened
473           file_write_error  = 3 " File FILENAME cannot be written to
474           inv_winsys        = 4 " Wrong window system, DOS windows required
475           inv_xxl           = 5 " Installation at the frontend incorrect
476           OTHERS            = 6.
477       IF sy-subrc <> 0.
478    *    message id sy-msgid type sy-msgty number sy-msgno
479    *    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
480       ENDIF.
481
482
483
484
485
486
487     ENDFORM.                    " DOWNLOAD_REPORT
488    *End RD1K984875 CAB_ALOK Include new fields - CR 30009141
*--- End of SAPMZFI_VPAN_MAINTAINF - 488 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
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
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
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
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
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
Generated incl.  <SYSINI>                                  Level 1    Page 9
Object           SAPMZFI_VPAN_MAINTAIN                     Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:45
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
