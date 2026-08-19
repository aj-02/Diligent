----------------------------------------------------------------------------------------------------
Main program     SAPMZFI_VPAN_MAINTAIN_BAK                 Level 0    Page 1
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
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
15     **************************************************************
16     *  Date     Transport      USERID       Description
17     *12.10.2012 RD1K982287     CAB_ALOK     CR 30008047- Remove changeTab from tcode ZJ1INVPAN
18     ************************************************************************
19
20     INCLUDE SAPMZFI_VPAN_MAINTAINTOP_BAK              .    " global Data
21     *&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
22     INCLUDE SAPMZFI_VPAN_MAINTAINO_BAK .
23     INCLUDE SAPMZFI_VPAN_MAINTAINI_BAK .
24     INCLUDE SAPMZFI_VPAN_MAINTAINF_BAK .
*--- End of SAPMZFI_VPAN_MAINTAIN_BAK - 24 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINTOP_BAK              Level 1    Page 2
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 67
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Include ZFI_UPDATE_j_1imovendTOP                        Module Pool      ZFI_UPDATE_J_1IEWT_ACKN
3      *&
4      *&---------------------------------------------------------------------*
5
6      PROGRAM  sapmzfi_vpan_maintain.
7
8      *TABLES : j_1imovend, j_1iewt_ackn , lfa1.
9      TABLES : j_1iewt_ackn , lfa1.
10     "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
11
12     *&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC931'
13     TYPES: BEGIN OF t_tc931.
14     *TYPES: lifnr     TYPE j_1imovend-lifnr,
15     TYPES: lifnr     TYPE lfa1-lifnr,
16     *          J_1IPANNO TYPE j_1imovend-J_1IPANNO,
17            j_1ipanno TYPE lfa1-j_1ipanno,
18            name1     TYPE lfa1-name1.
19     TYPES :  flag.
20     TYPES : END OF t_tc931.
21
22     *&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC931'
23     DATA: g_tc931_itab     TYPE t_tc931 OCCURS 0,
24           g_tc931_wa       TYPE t_tc931, "work area
25           g_tc931_itab_del TYPE t_tc931 OCCURS 0,
26           g_tc931_wa_del   TYPE t_tc931, "work area for Delete
27     *      g_ackn_wa        TYPE j_1imovend,
28     *      g_pan_wa         TYPE j_1imovend,
29     *      g_ackn_wa        TYPE z1imovend,
30           g_ackn_wa        TYPE LFA1,
31     *      g_pan_wa         TYPE z1imovend,
32           g_pan_wa         TYPE LFA1,
33           wa_t001          TYPE t001,
34           wa_seccode       TYPE seccode.
35
36     DATA:     g_tc931_copied.           "copy flag
37
38     *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC931' ITSELF
39     CONTROLS: tc931 TYPE TABLEVIEW USING SCREEN 0931.
40
41     *&SPWIZARD: LINES OF TABLECONTROL 'TC931'
42     DATA:    g_tc931_lines  LIKE sy-loopc.
43
44     DATA: g_okcode  TYPE sy-ucomm,
45           g_okcode1 TYPE sy-ucomm,
46           ok_code   LIKE sy-ucomm,
47           ok_code2  LIKE sy-ucomm,
48           g_okcode2 LIKE sy-ucomm.
49     DATA: g_text(20),
50           g_cflag    TYPE c,
51           g_vflag    TYPE c,
52     *      g_lifnr    LIKE j_1imovend-lifnr,
53           g_lifnr    LIKE z1imovend-lifnr,
54     *      g_panno    LIKE j_1imovend-j_1ipanno.
55           g_panno    LIKE z1imovend-j_1ipanno.
56     *DATA: t_panno TYPE j_1imovend-j_1ipanno .
57     DATA: t_panno TYPE z1imovend-j_1ipanno .
58     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
59     FIELD-SYMBOLS <wa_del>.
60     DATA: cols LIKE LINE OF tc931-cols.
61     DATA :l_tabix LIKE sy-tabix.
62     TYPES : BEGIN OF ty_lfa1,
63               lifnr TYPE lfa1-lifnr,
64               name1 TYPE lfa1-name1,
65             END OF ty_lfa1.
66     DATA : ist_lfa1 TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
67     DATA : wa_lfa1 TYPE ty_lfa1.
*--- End of SAPMZFI_VPAN_MAINTAINTOP_BAK - 67 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINO_BAK                Level 1    Page 3
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 223
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
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
12     "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
13
14     *    SELECT * FROM j_1imovend
15     *       INTO CORRESPONDING FIELDS
16     *       OF TABLE g_tc931_itab ORDER BY PRIMARY KEY.
17
18         SELECT * FROM lfa1
19      INTO CORRESPONDING FIELDS
20      OF TABLE g_tc931_itab ORDER BY PRIMARY KEY.
21     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
22         IF NOT  g_tc931_itab IS INITIAL.
23           SELECT lifnr Name1 INTO  TABLE ist_lfa1  FROM lfa1
24                        FOR ALL ENTRIES IN  g_tc931_itab
25                         WHERE lifnr = g_tc931_itab-lifnr.
26           LOOP AT g_tc931_itab INTO g_tc931_wa.
27             READ TABLE ist_lfa1 INTO wa_lfa1 WITH KEY
28                                    lifnr = g_tc931_wa-lifnr.
29             IF  sy-subrc = 0.
30               g_tc931_wa-name1 = wa_lfa1-name1.
31               MODIFY g_tc931_itab  FROM  g_tc931_wa TRANSPORTING
32                         name1 .
33             ENDIF.
34           ENDLOOP.
35         ENDIF.
36         g_tc931_copied = 'X'.
37         REFRESH CONTROL 'TC931' FROM SCREEN '0931'.
38       ENDIF.
39       "break cab_sudha.
40       IF g_vflag = 'X'.
41         CLEAR l_tabix.
42         IF NOT g_lifnr IS INITIAL.
43           READ TABLE g_tc931_itab INTO g_tc931_wa
44              WITH KEY  lifnr = g_lifnr.
45           IF sy-subrc = 0.
46             l_tabix = sy-tabix.
47           ENDIF.
48         ELSEIF NOT  g_panno IS   INITIAL.
49           READ TABLE g_tc931_itab INTO g_tc931_wa
50          WITH KEY  j_1ipanno = g_panno.
51           IF sy-subrc = 0.
52             l_tabix = sy-tabix.
53           ENDIF.
54         ENDIF.
55         tc931-top_line = l_tabix.
56         SET CURSOR 1 1. " l_tabix.
57         CLEAR g_vflag.
58         CLEAR l_tabix.
59       ENDIF.
60
61     ENDMODULE.
62
63     *&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
64     *&SPWIZARD: MOVE ITAB TO DYNPRO
65     MODULE tc931_move OUTPUT.
66     *  MOVE-CORRESPONDING g_tc931_wa TO j_1imovend.
67       MOVE-CORRESPONDING g_tc931_wa TO LFA1.
68       lfa1-name1 = g_tc931_wa-name1.
69     ENDMODULE.
70
71     *&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
72     *&SPWIZARD: GET LINES OF TABLECONTROL
73     MODULE tc931_get_lines OUTPUT.
74       g_tc931_lines = sy-loopc.
75     ENDMODULE.
76     *&---------------------------------------------------------------------*
77     *&      Module  STATUS_0931  OUTPUT
78     *&---------------------------------------------------------------------*
79     *       text
80     *----------------------------------------------------------------------*
81     MODULE status_0931 OUTPUT.
82       DATA fcode TYPE TABLE OF sy-ucomm.
83
84       IF sy-uname+0(1) <> 'C'.
85         APPEND 'DELE' TO fcode.
86         SET PF-STATUS 'S931' EXCLUDING fcode.
87
88     *begin RD1K982287       CAB_ALOK     Remove changeTab from tcode ZJ1INVPAN - CR 30008047
89
90         APPEND 'CHANGE' TO fcode.
91         SET PF-STATUS 'S931' EXCLUDING fcode.
92     *end RD1K982287       CAB_ALOK     Remove changeTab from tcode ZJ1INVPAN - CR 30008047
93
94       ELSE.
95         SET PF-STATUS 'S931'.
96       ENDIF.
97       CASE g_okcode.
98         WHEN 'CREATE' .
99           g_text = 'Create New Entries'.
100          SET TITLEBAR  'T931' WITH g_text .
101
102        WHEN 'CHANGE' .
103          g_text = 'Change Entries'.
104          SET TITLEBAR  'T931' WITH g_text .
105
106        WHEN 'DELE'.
107          g_text = 'Delete the Selected Entries'.
108          SET TITLEBAR  'T931' WITH g_text .
109
110
111      ENDCASE.
112    ENDMODULE.                 " STATUS_0931  OUTPUT
113    *&---------------------------------------------------------------------*
114    *&      Module  SCREEN_ATTRIBUTE_931  OUTPUT
115    *&---------------------------------------------------------------------*
116    *       text
117    *----------------------------------------------------------------------*
118    MODULE screen_attribute_931 OUTPUT.
119      DATA : lines TYPE i .
120      lines = sy-loopc.
121      "break cab_sudha.
122
123      CASE g_okcode1.
124        WHEN 'CREATE' OR 'INSR'.
125          LOOP AT SCREEN.
126            IF g_tc931_wa-flag = 'X'.
127              IF tc931-top_line = 1.
128                IF screen-group1 = 'KEY'.
129                  screen-input = 1.
130    *          screen-required = 1.
131                  MODIFY SCREEN.
132                ENDIF.
133              ENDIF.
134            ELSE.
135              IF screen-group2 = 'DIS'.
136                screen-input = 0.
137                MODIFY SCREEN.
138              ENDIF.
139            ENDIF.
140          ENDLOOP.
141        WHEN 'CHANGE'.
142    *     break cab_sudha.
143    *    LOOP AT tc931-cols INTO cols .
144    *     IF g_tc931_wa-flag = 'X' AND
145    *       g_cflag = 'X'.
146    *
147    *        IF  cols-SCREEN-NAME  = 'J_1IMOVEND-LIFNR'.
148    *               cols-SCREEN-INPUT = 0.
149    *       MODIFY tc931-cols FROM cols INDEX sy-tabix.
150    *       elseif cols-SCREEN-NAME  = 'J_1IMOVEND-J1IPANNO'.
151    *                   cols-SCREEN-INPUT = 1.
152    *       MODIFY tc931-cols FROM cols INDEX sy-tabix.
153    *        ENDIF.
154    *       clear g_cflag.
155    *     else.
156    *       if  cols-screen-group2 = 'DIS'.
157    *           cols-screen-input = 0.
158    *        endif.
159    *           MODIFY tc931-cols FROM cols INDEX sy-tabix.
160    *     endif.
161    *      ENDLOOP.
162
163          LOOP AT SCREEN.
164            IF g_tc931_wa-flag = 'X' AND
165               g_cflag = 'X'.
166              IF screen-group1 = 'KEY'.
167                screen-input = 0.
168                SCreen-active = 1.
169                MODIFY SCREEN.
170              ELSEIF screen-name = 'J_1IMOVEND-J1IPANNO'.
171                screen-input = 1.
172                SCreen-active = 1.
173                MODIFY SCREEN.
174              ENDIF.
175
176            ELSEIF g_tc931_wa-flag <> 'X'."  or g_cflag <> 'X'.
177              IF screen-group2 = 'DIS'.
178                screen-input = 0.
179                MODIFY SCREEN.
180              ENDIF.
181
182            ENDIF.
183          ENDLOOP.
184        WHEN ' ' OR 'ENTER'.
185          LOOP AT SCREEN .
186            IF screen-group2 = 'DIS'.
187              screen-input = 0.
188              MODIFY SCREEN.
189            ENDIF.
190          ENDLOOP.
191          LOOP AT SCREEN .
192            IF screen-group1 = 'KEY'.
193              screen-input = 0.
194              MODIFY SCREEN.
195            ENDIF.
196          ENDLOOP.
197      ENDCASE.
198    ENDMODULE.                 " SCREEN_ATTRIBUTE_931  OUTPUT
199    *&---------------------------------------------------------------------*
200    *&      Module  STATUS_0932  OUTPUT
201    *&---------------------------------------------------------------------*
202    *       text
203    *----------------------------------------------------------------------*
204    MODULE status_0932 OUTPUT.
205      g_text = 'Enter Vendor Number'.
206      SET PF-STATUS 'S932'.
207      SET TITLEBAR 'V932' WITH g_text.
208
209    ENDMODULE.                 " STATUS_0932  OUTPUT
210    *&---------------------------------------------------------------------*
211    *&      Module  SCR_STATUS  OUTPUT
212    *&---------------------------------------------------------------------*
213    *       text
214    *----------------------------------------------------------------------*
215    MODULE scr_status OUTPUT.
216      LOOP AT SCREEN .
217        IF screen-group1 = 'KEY'.
218          screen-input = 0.
219          screen-active = 1.
220          MODIFY SCREEN.
221        ENDIF.
222      ENDLOOP.
223    ENDMODULE.                 " SCR_STATUS  OUTPUT
*--- End of SAPMZFI_VPAN_MAINTAINO_BAK - 223 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINI_BAK                Level 1    Page 4
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 374
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_UPDATE_j_1imovendI
3      *&---------------------------------------------------------------------*
4
5      *&SPWIZARD: INPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
6      *&SPWIZARD: MODIFY TABLE
7      MODULE tc931_modify INPUT.
8
9      *  MOVE-CORRESPONDING j_1imovend TO g_tc931_wa.
10       MOVE-CORRESPONDING LFA1 TO g_tc931_wa.
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
75       ENDCASE.
76     ENDMODULE.                 " USER_COMMAND_INPUT  INPUT
77     *&---------------------------------------------------------------------*
78     *&      Form  INSERT_NEW_ROW
79     *&---------------------------------------------------------------------*
80     *       text
81     *----------------------------------------------------------------------*
82     *  -->  p1        text
83     *  <--  p2        text
84     *----------------------------------------------------------------------*
85     FORM insert_new_row .
86
87     *  READ TABLE  g_tc931_itab INTO j_1imovend INDEX 1.
88       READ TABLE  g_tc931_itab INTO LFA1 INDEX 1.
89       DATA : l_line TYPE i.
90
91       DESCRIBE TABLE  g_tc931_itab LINES l_line.
92
93       l_line = l_line + 1.
94       tc931-lines = l_line.
95       tc931-top_line = 1.
96       INSERT INITIAL LINE INTO g_tc931_itab INDEX 1. "L_LINE.
97
98       IF sy-subrc = 0.
99         CLEAR g_tc931_wa.
100      ENDIF.
101
102      SET CURSOR LINE 1. "L_LINE.
103      g_tc931_wa-flag = 'X'.
104      MODIFY g_tc931_itab FROM g_tc931_wa INDEX 1. "L_LINE.
105      g_okcode1 = 'INSR'.
106    ENDFORM.                    " INSERT_NEW_ROW
107    *&---------------------------------------------------------------------*
108    *&      Form  UPDATE_RECORD
109    *&---------------------------------------------------------------------*
110    *       text
111    *----------------------------------------------------------------------*
112    *  -->  p1        text
113    *  <--  p2        text
114    *----------------------------------------------------------------------*
115    FORM update_record .
116      "break cab_sudha.
117      CASE g_okcode1.
118        WHEN 'INSR'.
119
120          LOOP AT g_tc931_itab INTO g_tc931_wa WHERE flag = 'X'.
121            g_ackn_wa-lifnr = g_tc931_wa-lifnr.
122            g_ackn_wa-j_1ipanno  = g_tc931_wa-j_1ipanno.
123            IF NOT g_tc931_wa-lifnr IS INITIAL.
124              "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
125
126    *          SELECT SINGLE * FROM j_1imovend INTO G_ackn_WA
127    *          WHERE lifnr  = g_tc931_wa-lifnr.
128
129              SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF G_ackn_WA
130    WHERE lifnr  = g_tc931_wa-lifnr.
131              "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
132              IF sy-subrc <> 0.
133    *----------duplicate pan
134                "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
135
136    *        SELECT * FROM J_1IMOVEND INTO G_PAN_WA UP TO 1 ROWS
137    * WHERE J_1IPANNO = G_TC931_WA-J_1IPANNO
138    * ORDER BY PRIMARY KEY .
139    * ENDSELECT.
140
141                SELECT * FROM lfa1 INTO CORRESPONDING FIELDS OF g_pan_wa UP TO 1 ROWS
142        WHERE j_1ipanno = g_tc931_wa-j_1ipanno
143        ORDER BY PRIMARY KEY .
144                ENDSELECT.
145                "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
146                IF sy-subrc = 0.
147                  MESSAGE i413(zfi) WITH G_pan_WA-lifnr.
148                ENDIF.
149    *            MODIFY j_1imovend FROM g_ackn_wa.
150    *            MODIFY LFA1 FROM g_ackn_wa.
151                IF sy-subrc = 0.
152                  MESSAGE s555(zfi).
153                ENDIF.
154                CLEAR : g_tc931_wa-flag .
155                MODIFY g_tc931_itab FROM g_tc931_wa.
156              ELSE.
157                MESSAGE e413(zfi) WITH g_ackn_wa-lifnr.
158              ENDIF.
159            ENDIF.
160          ENDLOOP.
161
162        WHEN 'CHANGE'.
163          CLEAR  g_pan_wa.
164          LOOP AT g_tc931_itab INTO g_tc931_wa WHERE flag = 'X'.
165    *----------duplicate pan
166    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
167
168    *        SELECT * FROM j_1imovend INTO g_pan_wa UP TO 1 ROWS
169    *   WHERE j_1ipanno = g_tc931_wa-j_1ipanno
170    *   ORDER BY PRIMARY KEY .
171    *        ENDSELECT.
172            SELECT * FROM lfa1 INTO CORRESPONDING FIELDS OF g_pan_wa UP TO 1 ROWS
173    WHERE j_1ipanno = g_tc931_wa-j_1ipanno
174    ORDER BY PRIMARY KEY .
175            ENDSELECT.
176    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
177            IF sy-subrc = 0.
178              MESSAGE i413(zfi) WITH G_pan_WA-lifnr.
179            ENDIF.
180            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
181
182    *        SELECT SINGLE * FROM j_1imovend INTO G_ackn_WA
183    *        WHERE lifnr  = g_tc931_wa-lifnr.
184            SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF G_ackn_WA
185    WHERE lifnr  = g_tc931_wa-lifnr.
186            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
187            IF sy-subrc = 0.
188              g_ackn_wa-j_1ipanno  = g_tc931_wa-j_1ipanno.
189    *          MODIFY j_1imovend FROM g_ackn_wa.
190    *          MODIFY LFA1 FROM g_ackn_wa.
191              IF sy-subrc = 0.
192                MESSAGE s555(zfi).
193                CLEAR : g_tc931_wa-flag .
194              ENDIF.
195              MODIFY g_tc931_itab FROM g_tc931_wa.
196            ELSE.
197              "not updated
198            ENDIF.
199
200          ENDLOOP.
201          CLEAR g_cflag.
202          "    break cab_sudha.
203        WHEN 'DELE'.
204    *    select single * from j_1imovend where lifnr = g_tc931_wa-lifnr.
205    *      if sy-subrc = 0.
206    *      delete j_1imovend .
207    *      if sy-subrc = 0.
208    *           message e414(zfi) with  'Record deleted'.
209    *      endif.
210    *      endif.
211      ENDCASE.
212    ENDFORM.                    " UPDATE_RECORD
213    *&---------------------------------------------------------------------*
214    *&      Module  TC931_MARK  INPUT
215    *&---------------------------------------------------------------------*
216    *       text
217    *----------------------------------------------------------------------*
218    MODULE tc931_mark INPUT.
219
220      IF tc931-line_sel_mode = 1 AND
221         g_tc931_wa-flag = 'X'.
222        LOOP AT g_tc931_itab INTO g_tc931_wa
223          WHERE flag = 'X'.
224          g_tc931_wa-flag = ''.
225          MODIFY g_tc931_itab
226            FROM g_tc931_wa
227            TRANSPORTING flag.
228        ENDLOOP.
229        g_tc931_wa-flag = 'X'.
230      ENDIF.
231
232      MODIFY g_tc931_itab
233      FROM g_tc931_wa
234      INDEX tc931-current_line
235      TRANSPORTING flag.
236
237    ENDMODULE.                 " TC931_MARK  INPUT
238    *&---------------------------------------------------------------------*
239    *&      Form  AUTHORITY_CHECK
240    *&---------------------------------------------------------------------*
241    *       text
242    *----------------------------------------------------------------------*
243    *      -->P_0080   text
244    *----------------------------------------------------------------------*
245    FORM authority_check USING    p_actvt.
246      AUTHORITY-CHECK OBJECT 'ZFITDSACKN'
247               ID 'ACTVT' FIELD p_actvt.
248      IF sy-subrc NE 0.
249        MESSAGE e018(s#).
250      ENDIF.
251    ENDFORM.                     " AUTHORITY_CHECK
252    *&---------------------------------------------------------------------*
253    *&      Form  CHECK_VALIDPANNO
254    *&---------------------------------------------------------------------*
255    *       text
256    *----------------------------------------------------------------------*
257    *  -->  p1        text
258    *  <--  p2        text
259    *----------------------------------------------------------------------*
260    FORM check_validpanno .
261    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
262
263    *  DATA : l_panno  LIKE j_1imovend-j_1ipanno.
264      DATA : l_panno  LIKE lfa1-j_1ipanno.
265    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
266      DATA : l_len TYPE i .
267
268      CLEAR l_panno.
269      CLEAR l_len.
270      l_panno = g_tc931_wa-j_1ipanno.
271      l_len = strlen( l_panno ).
272      IF l_len <> 10.
273        MESSAGE e415(zfi) .
274      ENDIF.
275      IF l_panno+0(5) CN sy-abcde.
276        MESSAGE  e414(zfi) WITH 'First 5 chars should be Alphabets'.
277      ENDIF.
278      IF  l_panno+5(4) CN '0123456789'.
279        MESSAGE e414(zfi) WITH '6th to 9th Chars should be Numeric'.
280      ENDIF.
281      IF l_panno+9(1) CN sy-abcde.
282        MESSAGE  e414(zfi) WITH 'Last Character should be Alphabets'.
283      ENDIF.
284
285    ENDFORM.                    " CHECK_VALIDPANNO
286    *&---------------------------------------------------------------------*
287    *&      Form  POSITION_RECORD
288    *&---------------------------------------------------------------------*
289    *       text
290    *----------------------------------------------------------------------*
291    *  -->  p1        text
292    *  <--  p2        text
293    *----------------------------------------------------------------------*
294    FORM position_record .
295      CLEAR LFA1-lifnr.
296      CLEAR LFA1-j_1ipanno.
297      CALL SCREEN 0932  STARTING AT  50  50
298                        ENDING AT  100 100 .
299
300    ENDFORM.                    " POSITION_RECORD
301    *&---------------------------------------------------------------------*
302    *&      Module  USER_COMMAND_0932  INPUT
303    *&---------------------------------------------------------------------*
304    *       text
305    *----------------------------------------------------------------------*
306    MODULE user_command_0932 INPUT.
307      g_okcode2 = ok_code2.
308      BREAK cab_sudha.
309      CASE g_okcode2.
310        WHEN 'ENTR'.
311          CLEAR g_lifnr.
312          CLEAR g_panno.
313    *      IF NOT j_1imovend-lifnr IS INITIAL.
314          IF NOT LFA1-lifnr IS INITIAL.
315    *        g_lifnr = j_1imovend-lifnr.
316            g_lifnr = LFA1-lifnr.
317            g_vflag = 'X'.
318    *      ELSEIF NOT j_1imovend-j_1ipanno IS INITIAL.
319          ELSEIF NOT LFA1-j_1ipanno IS INITIAL.
320    *        g_panno = j_1imovend-j_1ipanno.
321            g_panno = LFA1-j_1ipanno.
322            g_vflag = 'X'.
323          ENDIF.
324    *  suppress dialog.
325          LEAVE  TO SCREEN  0.
326        WHEN 'CANC'.
327          "break cab_sudha.
328          LEAVE TO  SCREEN 0.
329      ENDCASE.
330    ENDMODULE.                 " USER_COMMAND_0932  INPUT
331    *&---------------------------------------------------------------------*
332    *&      Module  UPDATE_LOGS  INPUT
333    *&---------------------------------------------------------------------*
334    *       text
335    *----------------------------------------------------------------------*
336    MODULE update_logs INPUT.
337      TABLES : zj1invpanlog.
338      DATA : wa_zj1invpanlog TYPE zj1invpanlog.
339      DATA: l_tstamp TYPE timestamp,
340            l_d      TYPE d,
341            l_t      TYPE t.
342
343    *compare PAN no. with original and if changed, maintain logs in zj1invpanlog table.
344    *  IF  t_panno NE j_1imovend-j_1ipanno .
345      IF  t_panno NE LFA1-j_1ipanno .
346        wa_zj1invpanlog-mandt = sy-mandt.
347    *    wa_zj1invpanlog-lifnr = j_1imovend-lifnr.
348        wa_zj1invpanlog-lifnr = LFA1-lifnr.
349        wa_zj1invpanlog-changed_date = sy-datum.
350    *  CALCULATE TIMESTAMP.
351        l_d = sy-datum.
352        l_t = sy-uzeit.
353        CONVERT DATE l_d TIME l_t INTO
354                TIME STAMP l_tstamp TIME ZONE 'UTC   '.
355    *
356        wa_zj1invpanlog-timestamp = l_tstamp.
357        wa_zj1invpanlog-j_1ipanno_old = t_panno .
358    *    wa_zj1invpanlog-j_1ipanno_new = j_1imovend-j_1ipanno.
359        wa_zj1invpanlog-j_1ipanno_new = LFA1-j_1ipanno.
360        wa_zj1invpanlog-changed_by = sy-uname.
361
362        INSERT zj1invpanlog FROM wa_zj1invpanlog.
363      ENDIF.
364    ENDMODULE.                 " UPDATE_LOGS  INPUT
365    *&---------------------------------------------------------------------*
366    *&      Module  HOLD_ORIGINAL  INPUT
367    *&---------------------------------------------------------------------*
368    *       text
369    *----------------------------------------------------------------------*
370    MODULE hold_original INPUT.
371    * Store current value of Pan No.
372    *  t_panno = j_1imovend-j_1ipanno .
373      t_panno = LFA1-j_1ipanno .
374    ENDMODULE.                 " HOLD_ORIGINAL  INPUT
*--- End of SAPMZFI_VPAN_MAINTAINI_BAK - 374 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZFI_VPAN_MAINTAINF_BAK                Level 1    Page 5
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 367
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
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
322
323       SELECT SINGLE name1  INTO  l_name1   FROM lfa1
324    *     WHERE  lifnr = j_1imovend-lifnr .
325         WHERE  lifnr = LFA1-lifnr .
326
327       IF sy-subrc = 0.
328         g_tc931_wa-name1 = l_name1.
329       ENDIF.
330     ENDFORM.                    " GET_VENDORNAME
331    *&---------------------------------------------------------------------*
332    *&      Form  DELETE_ROW
333    *&---------------------------------------------------------------------*
334    *       text
335    *----------------------------------------------------------------------*
336    *  -->  p1        text
337    *  <--  p2        text
338    *----------------------------------------------------------------------*
339     FORM delete_row .
340       DATA : l_line TYPE i .
341       BREAK cab_sudha.
342       CLEAR l_line.
343       READ TABLE g_tc931_itab  INTO g_tc931_wa  WITH KEY flag = 'X'.
344       IF sy-subrc <> 0.
345         MESSAGE e414(zfi)  WITH  'Select the line to be deleted'.
346       ENDIF.
347    *
348    *message the line has been deleted  from the data base
349       l_line =  tc931-lines.
350       l_line = l_line - 1.
351       tc931-lines = l_line.
352       "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
353
354    *select single * from j_1imovend where lifnr = g_tc931_wa-lifnr.
355       SELECT SINGLE * FROM lfa1 WHERE lifnr = g_tc931_wa-lifnr.
356       "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
357       IF sy-subrc = 0.
358    *     DELETE j_1imovend .
359    *     DELETE LFA1 .
360         IF sy-subrc = 0.
361           MESSAGE e414(zfi) WITH  'Record deleted'.
362         ENDIF.
363       ENDIF.
364
365       DELETE g_tc931_itab  WHERE flag = 'X'.
366       g_okcode1 = sy-ucomm+6.
367     ENDFORM.                    " DELETE_ROW
*--- End of SAPMZFI_VPAN_MAINTAINF_BAK - 367 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCXTAB                                  Level 1    Page 6
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CONTRO>                                  Level 1    Page 7
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
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
Generated incl.  <SYSINI>                                  Level 1    Page 8
Object           SAPMZFI_VPAN_MAINTAIN_BAK                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:51
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
