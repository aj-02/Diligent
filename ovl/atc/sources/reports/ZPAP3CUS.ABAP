----------------------------------------------------------------------------------------------------
Main program     ZPAP3CUS                                  Level 0    Page 1
Object           ZPAP3CUS                                  Lines 145
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:16
----------------------------------------------------------------------------------------------------
1      PROGRAM ZPAP3CUS.
2
3        DATA: VAR_DESIG_TEXT(255),
4              var_payrange(100) .
5      ************************************************************************
6      * VERSION 1.0
7      * PROGRAM                : ZPAP3CUS
8      * TYPE                   : Module Pool
9      * Run Frequency          : Run Internally by SAP
10     * Description            : Customer Exit used for Passing Customer
11     *                        : defined Structures used as Letter Variables
12     *                        : in Letters(RTF Formats & SO10 Objects)
13     * Development Class      : ZDEV
14     * Transaction Code       :
15     * Date Created           : 01.05.2002
16     * Author                 : Rajesh Bothra
17     * Location               : ONGC / SISL -Shramik  Dehradun
18     * Requirement Reference  :                                             *
19     ************************************************************************
20     ***********************************************************************
21     *SHRAMIK Migration Project change
22     *
23     *Program Name in ICE         : ZPAP3CUS
24     *Development Class in ICE    : ZHR_DEV
25     *Author                      : M.Nagarajan
26     *Status                      : Only Development class changed
27     *Hardcoding Analysis         : No Hardcoding changes
28     **********************************************************************
29
30     *                          Table Declaration
31     *
32     ************************************************************************
33     ************************************************************************
34     * Date        Transport     USERID       Description
35     * 11/09/2008  <RD1K960036>  SAB_PUNIT    1) Change in include
36     *                                           ZHR_PB_PAP3CUS
37     ************************************************************************
38     TABLES: T500P, P0001, STXBITMAPS.
39     TABLES: ZTDNAME, ZLTVAR, HRP9410,PB9400, PB9401,PB9404, PB9405, PB0006,
40             PB4002,ZHR_EXM_RECRUIT,T750E, ZHRRPTRB_POSDESG,ZDESIGNATION_REV,
41             MEMOACT,ZHR_EXM_CENTRE, ZBASICPAY, ZHRRST_CATG_COMB,
42             ZHR_EXM_RIT_DESG.
43     CONSTANTS  CON_COMMA(2) TYPE C VALUE ', '.
44
45     ************************************************************************
46     *                           Include
47     *
48     ************************************************************************
49
50     *INCLUDE ZHRRPIRB_PAP3CUS.
51     INCLUDE ZHR_PB_PAP3CUS.
52
53     *----------------------------------------------------------------------
54     *       FORM fill_customer_structure
55     *----------------------------------------------------------------------
56     *       This routine declares the customer structures which
57     *       will be used in WinWord letters.
58     *       Neccessary only if customer uses WinWord
59     *----------------------------------------------------------------------
60     FORM FILL_CUSTOMER_STRUCTURE.
61
62     *  IF SY-TCODE = 'ZPBAT'.
63     *    PERFORM ADD_CUSTOMER_STRUCTURE(ZRPAPRT05) USING 'T500P'.
64     *    PERFORM ADD_CUSTOMER_STRUCTURE(ZRPAPRT05) USING 'ZLTVAR'.
65     *  ELSE.
66     *    PERFORM ADD_CUSTOMER_STRUCTURE(RPAPRT05) USING 'T500P'.
67     *    PERFORM ADD_CUSTOMER_STRUCTURE(RPAPRT05) USING 'ZLTVAR'.
68     *
69     *  ENDIF.
70
71     ENDFORM.
72
73     *----------------------------------------------------------------------
74     *       FORM fill_customer_data
75     *----------------------------------------------------------------------
76     *       This routine fills the customer data for use in applicant
77     *      letters.
78     *----------------------------------------------------------------------
79     FORM FILL_CUSTOMER_DATA.
80
81
82     *********** Photo Selection and Address***********
83       DATA: VAR_PERNR(11),
84             VAR_PERNR1(11),
85             VAR_PERNR2(11) .
86
87       CONCATENATE  'A' P0001-PERNR 'PH' INTO VAR_PERNR.
88       SELECT SINGLE * FROM STXBITMAPS
89                WHERE TDOBJECT = 'GRAPHICS'
90                AND   TDNAME  = VAR_PERNR
91                AND   TDID = 'BMAP'
92                AND   TDBTYPE = 'BCOL'.
93       IF SY-SUBRC = 0.
94         MOVE STXBITMAPS-TDNAME TO ZTDNAME-TDNAMEPH.
95       ENDIF.
96
97       CONCATENATE  'A' P0001-PERNR 'AD' INTO VAR_PERNR1.
98
99       SELECT SINGLE * FROM STXBITMAPS
100               WHERE TDOBJECT = 'GRAPHICS'
101               AND   TDNAME = VAR_PERNR1
102               AND   TDID = 'BMAP'
103               AND   TDBTYPE = 'BCOL'.
104      IF SY-SUBRC = 0.
105        MOVE STXBITMAPS-TDNAME TO ZTDNAME-TDNAMEAD.
106      ENDIF.
107
108      CONCATENATE  'A' P0001-PERNR 'SG' INTO VAR_PERNR2.
109
110      SELECT SINGLE * FROM STXBITMAPS
111               WHERE TDOBJECT = 'GRAPHICS'
112               AND   TDNAME = VAR_PERNR2
113               AND   TDID = 'BMAP'
114               AND   TDBTYPE = 'BCOL'.
115      IF SY-SUBRC = 0.
116        MOVE STXBITMAPS-TDNAME TO ZTDNAME-TDNAMESG.
117      ENDIF.
118
119    *Defining and Passing values to Text Variables used in Letters
120
121      PERFORM FILL_LETTER_VARIABLE USING P0001
122                                      MEMOACT.
123
124    ENDFORM.
125
126    *----------------------------------------------------------------------
127    *       FORM check_customer_exception
128    *----------------------------------------------------------------------
129    *       This routine determines if a MailMergeField
130    *       is mandantory or optional
131    *----------------------------------------------------------------------
132    *
133    * --->  $field_name         technical name of the 'empty' field
134    *
135    * <---  $sw_optional_field  switch to declare that field optional
136    *
137    *----------------------------------------------------------------------
138    FORM CHECK_CUSTOMER_EXCEPTION USING $FIELD_NAME $SW_OPTIONAL_FIELD.
139      DATA YES VALUE '1'.
140
141      IF $FIELD_NAME = 't500p-pfach'.
142        $SW_OPTIONAL_FIELD = YES.
143      ENDIF.
144
145    ENDFORM.
*--- End of ZPAP3CUS - 145 lines ---

----------------------------------------------------------------------------------------------------
Include          ZHR_PB_PAP3CUS                            Level 1    Page 2
Object           ZPAP3CUS                                  Lines 1471
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:16
----------------------------------------------------------------------------------------------------
1      ***INCLUDE ZHRRPIRB_PAP3CUS .
2
3      ************************************************************************
4      * VERSION 1.0
5      * PROGRAM                : ZHRRPIRB_PAP3CUS
6      * TYPE                   : INCLUDE
7      * Run Frequency          :
8      * Description            : Include Program for Customer Exit ZPAP3CUS
9      *                        :
10     * Development Class      : ZDEV
11     * Transaction Code       :
12     * Date Created           : 01.05.2002
13     * Author                 : Rajesh Bothra
14     * Location               : ONGC / SISL -Shramik  Dehradun
15     * Requirement Reference  :                                             *
16     ************************************************************************
17     ************************************************************************
18     * Date        Transport     USERID       Description
19     * 11/09/2008  <RD1K960036>  SAB_PUNIT    1) Replaced obsolete FM
20     *                                           'HELP_VALUES_GET_WITH_TABLE'
21     ************************************************************************
22
23     *&---------------------------------------------------------------------*
24     *&      Form  FILL_LETTER_VARIABLE
25     *&---------------------------------------------------------------------*
26     *       text
27     *----------------------------------------------------------------------*
28     *      -->P_P0001  text
29     *      -->P_MEMOACT  text
30     *----------------------------------------------------------------------*
31     FORM FILL_LETTER_VARIABLE USING  VALUE(P_P0001) STRUCTURE P0001
32                                      VALUE(P_MEMOACT) STRUCTURE MEMOACT.
33
34       TABLES: T526,   HRP1001, HRP1000, T005U, PB0001, ZHR_EXM_VARIABLE,
35               PA0105, PA0002,  PA9930,  T522T, PB4003, PB0016,
36               T547S,  PB9402,  PB4005,  T591S, ZHR_EXM_MASTER, PA0006,
37               PB0002.
38
39       DATA: VAR_COUNT TYPE I,
40             VAR_OBJID LIKE HRP9410-OBJID,
41             VAR_DESIG LIKE ZHRRPTRB_POSDESG-DESIG_CODE,
42             VAR_RP LIKE ZHRRPTRB_POSDESG-R_P_CD,
43             VAR_VERSION LIKE ZHRRPTRB_POSDESG-VERSION,
44             VAR_PERSA LIKE T500P-PERSA ,
45             VAR_CAMPUS_ID LIKE ZHR_EXM_CENTRE-ZCENTRE_ID,
46             VAR_STEXT(41) TYPE C.
47
48     * begin of modification by Anuraag on specs from Rupesh 23.10.2002
49       DATA: BEGIN OF DESIG_ALL_DESIG OCCURS 0,
50             OBJID LIKE PB4003-OBJID,
51             DESIG_CODE LIKE ZDESIGNATION_REV-DESIG_CODE,
52             R_P_CD LIKE ZDESIGNATION_REV-R_P_CD,
53             VERSION LIKE ZDESIGNATION_REV-VERSION,
54             DESIG_TEXT LIKE ZDESIGNATION_REV-DESIG_TEXT,
55             PAYRANGE LIKE ZBASICPAY-PAYRANGE,
56             END OF DESIG_ALL_DESIG .
57     * end of modification by Anuraag on specs from Rupesh  23.10.2002
58       DATA: VAR_YR(2) TYPE N,
59             VAR_MT(2) TYPE N.
60
61       DATA: BEGIN OF IT_EXAM OCCURS 0,
62             SUBTY LIKE T591S-SUBTY,
63             STEXT LIKE T591S-STEXT,
64             END OF IT_EXAM.
65
66       CLEAR: VAR_COUNT,VAR_OBJID,ZLTVAR,VAR_DESIG,VAR_RP,VAR_VERSION,
67              IT_EXAM,VAR_STEXT.
68       REFRESH IT_EXAM.
69
70     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
71     *  SELECT SINGLE * FROM PB9400 WHERE PERNR = P_P0001-PERNR.
72      SELECT * FROM PB9400   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR  ORDER
73     BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
74     " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
75       IF SY-SUBRC = 0.
76     *To Select Recruitment id
77         MOVE PB9400-ZRECRUIT_ID TO ZLTVAR-ZREC.
78         SELECT SINGLE * FROM ZHR_EXM_RECRUIT
79                         WHERE ZRECRUIT_ID = PB9400-ZRECRUIT_ID.
80     *To Select Recruitment Description
81         MOVE  ZHR_EXM_RECRUIT-ZRECRUIT_DESC TO ZLTVAR-ZRECDESC.
82
83         GET PARAMETER ID 'PBR' FIELD VAR_PERSA.
84         SELECT SINGLE * FROM T500P WHERE PERSA = VAR_PERSA.
85         T500P-NAME1  = ZLTVAR-PBR_NAME1.
86         T500P-STRAS  = ZLTVAR-PBR_STRAS.
87         T500P-PSTLZ  = ZLTVAR-PBR_PSTLZ.
88         T500P-ORT01  = ZLTVAR-PBR_ORT01.
89
90         SELECT SINGLE * FROM  T005U WHERE  SPRAS  = SY-LANGU
91                                     AND    LAND1  = T500P-LAND1
92                                     AND    BLAND  = T500P-REGIO.
93         T005U-BEZEI = ZLTVAR-PBR_STATE.
94
95     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
96     *    SELECT SINGLE * FROM PB0001 WHERE PERNR = P_P0001-PERNR
97     *                                AND   BEGDA <= SY-DATUM
98     *                                AND   ENDDA >= SY-DATUM.
99      SELECT * FROM PB0001   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
100    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
101    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
102    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
103
104        SELECT SINGLE * FROM T526 WHERE WERKS = 'APPL'
105                                  AND   SACHX = PB0001-SACHP.
106
107    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
108    *    SELECT SINGLE * FROM PA0105 WHERE USRID = T526-USRID
109    *                                AND   BEGDA <= SY-DATUM
110    *                                AND   ENDDA >= SY-DATUM.
111     SELECT * FROM PA0105   UP TO 1 ROWS WHERE USRID = T526-USRID AND BEGDA
112    <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS SPRPS
113    ENDDA BEGDA SEQNR .   ENDSELECT.
114    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
115
116    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
117    *    SELECT SINGLE * FROM PA0002 WHERE PERNR = PA0105-PERNR
118    *                                AND   BEGDA <= SY-DATUM
119    *                                AND   ENDDA >= SY-DATUM.
120     SELECT * FROM PA0002   UP TO 1 ROWS WHERE PERNR = PA0105-PERNR AND
121    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
122    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
123    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
124
125    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
126    *    SELECT SINGLE * FROM PA9930 WHERE PERNR = PA0105-PERNR
127    *                                AND   BEGDA <= SY-DATUM
128    *                                AND   ENDDA >= SY-DATUM.
129     SELECT * FROM PA9930   UP TO 1 ROWS WHERE PERNR = PA0105-PERNR AND
130    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
131    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
132    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
133
134        SELECT SINGLE * FROM ZDESIGNATION_REV
135        WHERE DESIG_CODE = PA9930-DESIGNO
136        AND R_P_CD = PA9930-R_P_CD
137        AND VERSION = PA9930-VERSION.
138
139        SELECT SINGLE * FROM T522T WHERE SPRSL = 'EN'
140                                   AND   ANRED = PA0002-ANRED.
141
142        CONCATENATE T522T-ATEXT PA0002-VORNA PA0002-NAME2 PA0002-NACHN
143                    INTO ZLTVAR-ADM_NAME SEPARATED BY SPACE.
144
145        ZLTVAR-ADM_DESG = ZDESIGNATION_REV-DESIG_TEXT.
146    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
147    *    SELECT SINGLE * FROM ZHRRPTRB_POSDESG
148    *                    WHERE OBJID = P_MEMOACT-OBJID.
149     SELECT * FROM ZHRRPTRB_POSDESG   UP TO 1 ROWS WHERE OBJID =
150    P_MEMOACT-OBJID  ORDER BY  DESIG_CODE R_P_CD VERSION OBJID .
151    ENDSELECT.
152    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
153
154
155    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
156    *    SELECT SINGLE * FROM PB4002
157    *    WHERE OBJID = P_MEMOACT-OBJID
158    *    AND PERNR = P_P0001-PERNR
159    *    AND APSTV = '5' .
160     SELECT * FROM PB4002   UP TO 1 ROWS WHERE OBJID = P_MEMOACT-OBJID AND
161    PERNR = P_P0001-PERNR AND APSTV = '5'   ORDER BY  PERNR SUBTY OBJPS
162    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
163    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
164
165    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
166    *    SELECT SINGLE * FROM PB0016
167    *    WHERE BEGDA = PB4002-BEGDA
168    *    AND PERNR = P_P0001-PERNR
169    *    AND SPRPS <> 'X' .
170     SELECT * FROM PB0016   UP TO 1 ROWS WHERE BEGDA = PB4002-BEGDA AND
171    PERNR = P_P0001-PERNR AND SPRPS <> 'X'   ORDER BY  PERNR SUBTY OBJPS
172    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
173    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
174        SELECT SINGLE CTTXT INTO ZLTVAR-CTTXT
175        FROM T547S
176        WHERE SPRSL = 'EN'
177        AND   CTTYP = PB0016-CTTYP .
178
179        VAR_YR = ZHR_EXM_RECRUIT-DURA / 12.
180        VAR_MT = ZHR_EXM_RECRUIT-DURA MOD 12.
181
182        IF PB0016-CTTYP  = '02'.
183          ZLTVAR-PAYSCALE_EMOL = 'with Emoluments of '.
184          IF VAR_YR > 1 .
185            IF VAR_MT > 1 .
186              CONCATENATE VAR_YR 'years, ' VAR_MT 'months'
187              INTO ZLTVAR-DUR_SERV SEPARATED BY SPACE.
188            ELSE .
189              CONCATENATE VAR_YR 'years,' VAR_MT 'month'
190              INTO ZLTVAR-DUR_SERV SEPARATED BY SPACE.
191            ENDIF.
192          ELSE.
193            IF VAR_MT > 1 .
194              CONCATENATE VAR_YR 'year, ' VAR_MT 'months'
195              INTO ZLTVAR-DUR_SERV SEPARATED BY SPACE.
196            ELSE .
197              CONCATENATE VAR_YR 'year,' VAR_MT 'month'
198              INTO ZLTVAR-DUR_SERV SEPARATED BY SPACE.
199            ENDIF.
200          ENDIF.
201        ELSE.
202          ZLTVAR-PAYSCALE_EMOL = 'in the Payscale of'.
203          CLEAR ZLTVAR-DUR_SERV .
204        ENDIF.
205
206        CONCATENATE 'You will also be entitled to draw DA and '
207        'other allowances at such rates and subject to such'
208        INTO ZLTVAR-DA_ALLOW_TEXT
209                       SEPARATED BY SPACE.
210
211        CONDENSE ZLTVAR-DA_ALLOW_TEXT.
212
213        CONCATENATE 'conditions as may be laid down in the rules and '
214        'regulations.' INTO ZLTVAR-DA_ALLOW_TEXT1
215                       SEPARATED BY SPACE.
216
217        SELECT SINGLE VAR_TEXT
218        FROM ZHR_EXM_VARIABLE
219        INTO ZLTVAR-ADVT_TEXT
220        WHERE ZRECRUIT_ID = ZLTVAR-ZREC
221        AND VAR_ID = '00086'.
222        IF SY-SUBRC <> 0.
223          CONCATENATE ZLTVAR-ZREC '-' ZHR_EXM_RECRUIT-BEGDA(4)
224          INTO ZLTVAR-ADVT_TEXT .
225        ENDIF .
226
227
228        IF MEMOACT-APACT = '061' .
229    *        Written Exam Non GT's
230
231    *To get the Applicant mailing Address.
232    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
233    *      SELECT SINGLE * FROM PB0006 WHERE PERNR = P_P0001-PERNR
234    *                       AND  SUBTY = '5'.
235     SELECT * FROM PB0006   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
236    SUBTY = '5'  ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .
237    ENDSELECT.
238    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
239          IF SY-SUBRC = 0.
240            MOVE PB0006-NAME2 TO ZLTVAR-NAME2.
241            MOVE PB0006-STRAS TO ZLTVAR-STRAS.
242            MOVE PB0006-LOCAT TO ZLTVAR-LOCAT.
243            MOVE PB0006-PSTLZ TO ZLTVAR-PSTLZ.
244            MOVE PB0006-ORT01 TO ZLTVAR-ORT01.
245            MOVE PB0006-ORT02 TO ZLTVAR-ORT02.
246            MOVE PB0006-TELNR TO ZLTVAR-TELNR.
247            CLEAR ZLTVAR-ADDR_BMP_ID.
248          ENDIF.
249
250    * get all the activities for the date and time
251    * of this activity and pernr.
252    * for all the Object ID's get the corresponding designation.
253          SELECT * FROM PB4003
254          WHERE PERNR = P_P0001-PERNR
255          AND APACT = P_MEMOACT-APACT
256          AND PLDAT = P_MEMOACT-PLDAT
257          AND PLTIM = P_MEMOACT-PLTIM .
258
259    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
260    *        SELECT SINGLE * FROM ZHRRPTRB_POSDESG
261    *        WHERE OBJID = PB4003-OBJID.
262     SELECT * FROM ZHRRPTRB_POSDESG   UP TO 1 ROWS WHERE OBJID =
263    PB4003-OBJID  ORDER BY  DESIG_CODE R_P_CD VERSION OBJID .   ENDSELECT.
264    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
265
266            IF SY-SUBRC = 0 .
267    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
268    *          SELECT SINGLE * FROM PB4002
269    *          WHERE PERNR = P_P0001-PERNR
270    *          AND APSTV <> '4'
271    *          AND BEGDA <= SY-DATUM
272    *          AND ENDDA >= SY-DATUM
273    *          AND ZZDESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
274    *          AND ZZR_P_CD = ZHRRPTRB_POSDESG-R_P_CD
275    *          AND ZZVERSION = ZHRRPTRB_POSDESG-VERSION
276    *          AND ZZRECRUIT_ID = PB9400-ZRECRUIT_ID .
277     SELECT * FROM PB4002   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
278    APSTV <> '4' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM AND
279    ZZDESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE AND ZZR_P_CD =
280    ZHRRPTRB_POSDESG-R_P_CD AND ZZVERSION = ZHRRPTRB_POSDESG-VERSION AND
281    ZZRECRUIT_ID = PB9400-ZRECRUIT_ID   ORDER BY  PERNR SUBTY OBJPS SPRPS
282    ENDDA BEGDA SEQNR .   ENDSELECT.
283    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
284
285              IF SY-SUBRC = 0 .
286                SELECT SINGLE * FROM ZDESIGNATION_REV
287                WHERE DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
288                AND R_P_CD = ZHRRPTRB_POSDESG-R_P_CD
289                AND VERSION = ZHRRPTRB_POSDESG-VERSION .
290
291                IF SY-SUBRC = 0 .
292                  SELECT SINGLE * FROM ZBASICPAY
293                  WHERE GRADE = ZDESIGNATION_REV-GRADE.
294                  IF SY-SUBRC = 0 .
295                    DESIG_ALL_DESIG-OBJID = ZHRRPTRB_POSDESG-OBJID.
296                   DESIG_ALL_DESIG-DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE.
297                    DESIG_ALL_DESIG-R_P_CD = ZHRRPTRB_POSDESG-R_P_CD.
298                    DESIG_ALL_DESIG-VERSION = ZHRRPTRB_POSDESG-VERSION.
299                  DESIG_ALL_DESIG-DESIG_TEXT = ZDESIGNATION_REV-DESIG_TEXT .
300                    DESIG_ALL_DESIG-PAYRANGE = ZBASICPAY-PAYRANGE .
301                    APPEND DESIG_ALL_DESIG.
302                  ENDIF.
303                ENDIF.
304              ENDIF.
305            ENDIF.
306          ENDSELECT.
307
308          SORT DESIG_ALL_DESIG.
309       DELETE ADJACENT DUPLICATES FROM DESIG_ALL_DESIG COMPARING ALL FIELDS.
310
311          LOOP AT DESIG_ALL_DESIG.
312            SELECT A~SUBTY B~STEXT APPENDING TABLE IT_EXAM
313                   FROM ZHR_EXM_MASTER AS A INNER JOIN T591S AS B
314                     ON A~SUBTY = B~SUBTY
315                     WHERE A~ZRECRUIT_ID = ZLTVAR-ZREC
316                        AND A~DESIG_CODE = DESIG_ALL_DESIG-DESIG_CODE
317                            AND A~R_P_CD = DESIG_ALL_DESIG-R_P_CD
318                           AND A~VERSION = DESIG_ALL_DESIG-VERSION
319                           AND A~APPBE   = 'YES'
320                           AND ( A~SUBTY BETWEEN '01' AND '50'
321                              OR A~SUBTY BETWEEN '71' AND '99' )
322                             AND B~SPRSL = 'EN'
323                             AND B~INFTY = '9401'.
324            IF SY-SUBRC NE 0.
325              SELECT A~SUBTY B~STEXT APPENDING TABLE IT_EXAM
326                     FROM ZHR_EXM_MASTER AS A INNER JOIN T591S AS B
327                       ON A~SUBTY = B~SUBTY
328                       WHERE A~ZRECRUIT_ID = ZLTVAR-ZREC
329                           AND A~APPBE   = 'YES'
330                           AND ( A~SUBTY BETWEEN '01' AND '50'
331                              OR A~SUBTY BETWEEN '71' AND '99' )
332                               AND B~SPRSL = 'EN'
333                               AND B~INFTY = '9401'.
334            ENDIF.
335          ENDLOOP.
336          SORT IT_EXAM BY SUBTY.
337          DELETE ADJACENT DUPLICATES FROM IT_EXAM COMPARING ALL FIELDS.
338
339          LOOP AT IT_EXAM.
340            CONCATENATE IT_EXAM-STEXT ',' INTO VAR_STEXT.
341            CONCATENATE  ZLTVAR-STEXT VAR_STEXT INTO ZLTVAR-STEXT.
342            CLEAR:VAR_STEXT.
343          ENDLOOP.
344
345        ELSEIF MEMOACT-APACT = '062' .
346    *        Interview
347
348          CLEAR ZLTVAR-ADDR_BMP_ID .
349          CONCATENATE 'A' P_P0001-PERNR 'AD' INTO ZLTVAR-ADDR_BMP_ID .
350          SELECT SINGLE * FROM STXBITMAPS
351          WHERE TDOBJECT = 'GRAPHICS'
352          AND TDID = 'BMAP'
353          AND TDBTYPE = 'BCOL'
354          AND TDNAME = ZLTVAR-ADDR_BMP_ID.
355          IF SY-SUBRC <> 0.
356    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
357    *        SELECT SINGLE * FROM PB0006
358    *        WHERE SUBTY = '5' AND PERNR = P_P0001-PERNR.
359     SELECT * FROM PB0006   UP TO 1 ROWS WHERE SUBTY = '5' AND PERNR =
360    P_P0001-PERNR  ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .
361    ENDSELECT.
362    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
363            MOVE PB0006-NAME2 TO ZLTVAR-NAME2.
364            MOVE PB0006-STRAS TO ZLTVAR-STRAS.
365            MOVE PB0006-LOCAT TO ZLTVAR-LOCAT.
366            MOVE PB0006-PSTLZ TO ZLTVAR-PSTLZ.
367            MOVE PB0006-ORT01 TO ZLTVAR-ORT01.
368            MOVE PB0006-ORT02 TO ZLTVAR-ORT02.
369            MOVE PB0006-TELNR TO ZLTVAR-TELNR.
370            CLEAR ZLTVAR-ADDR_BMP_ID.
371          ENDIF.
372
373
374          SELECT SINGLE * FROM ZHR_EXM_VARIABLE
375                  WHERE ZRECRUIT_ID = ZLTVAR-ZREC
376                         AND VAR_ID = '00107'.
377          IF SY-SUBRC = 0.
378            SELECT * FROM HRP1001
379            WHERE OBJID = ZHR_EXM_VARIABLE-VAR_TEXT
380            AND   OTYPE = '9R'
381            AND   PLVAR = '01'
382            AND   RSIGN = 'A'
383            AND   RELAT = '911'
384            AND   ISTAT = '1' ORDER BY PRIMARY KEY.
385
386    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
387    *          SELECT SINGLE * FROM HRP9410
388    *          WHERE DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
389    *          AND  R_P_CD = ZHRRPTRB_POSDESG-R_P_CD
390    *          AND VERSION = ZHRRPTRB_POSDESG-VERSION
391    *          AND OBJID = HRP1001-SOBID .
392     SELECT * FROM HRP9410   UP TO 1 ROWS WHERE DESIG_CODE =
393    ZHRRPTRB_POSDESG-DESIG_CODE AND R_P_CD = ZHRRPTRB_POSDESG-R_P_CD AND
394    VERSION = ZHRRPTRB_POSDESG-VERSION AND OBJID = HRP1001-SOBID   ORDER BY
395     PLVAR OTYPE OBJID SUBTY ISTAT BEGDA ENDDA VARYF SEQNR .   ENDSELECT.
396    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
397              IF SY-SUBRC = 0 .
398                MOVE HRP9410-OBJID TO VAR_OBJID.
399                EXIT.
400              ENDIF.
401
402            ENDSELECT.
403
404            SELECT  * FROM HRP9410
405            WHERE PLVAR = '01'
406            AND OTYPE = '9S'
407            AND OBJID = VAR_OBJID
408            AND ISTAT = '1'.
409
410    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
411    *          SELECT SINGLE * FROM PB4002
412    *          WHERE PERNR = P_P0001-PERNR
413    *          AND ZZRECRUIT_ID = PB9400-ZRECRUIT_ID
414    *          AND ZZDESIG_CODE = HRP9410-DESIG_CODE
415    *          AND  ZZR_P_CD = HRP9410-R_P_CD
416    *          AND  ZZVERSION = HRP9410-VERSION
417    *          AND APSTV <> '4'
418    *          AND ENDDA >= SY-DATUM
419    *          AND BEGDA <= SY-DATUM.
420     SELECT * FROM PB4002   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
421    ZZRECRUIT_ID = PB9400-ZRECRUIT_ID AND ZZDESIG_CODE = HRP9410-DESIG_CODE
422    AND ZZR_P_CD = HRP9410-R_P_CD AND ZZVERSION = HRP9410-VERSION AND APSTV
423    <> '4' AND ENDDA >= SY-DATUM AND BEGDA <= SY-DATUM  ORDER BY  PERNR
424    SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
425    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
426              IF SY-SUBRC = 0 .
427                SELECT SINGLE * FROM ZDESIGNATION_REV
428                WHERE DESIG_CODE = PB4002-ZZDESIG_CODE
429                AND R_P_CD = PB4002-ZZR_P_CD
430                AND VERSION = PB4002-ZZVERSION .
431
432                IF SY-SUBRC = 0 .
433                  SELECT SINGLE * FROM ZBASICPAY
434                  WHERE GRADE = ZDESIGNATION_REV-GRADE.
435                  IF SY-SUBRC = 0 .
436                    DESIG_ALL_DESIG-OBJID = PB4002-OBJID.
437                    DESIG_ALL_DESIG-DESIG_CODE = PB4002-ZZDESIG_CODE.
438                    DESIG_ALL_DESIG-R_P_CD = PB4002-ZZR_P_CD.
439                    DESIG_ALL_DESIG-VERSION = PB4002-ZZVERSION.
440                    DESIG_ALL_DESIG-DESIG_TEXT =
441                                    ZDESIGNATION_REV-DESIG_TEXT .
442                    DESIG_ALL_DESIG-PAYRANGE = ZBASICPAY-PAYRANGE .
443                    APPEND DESIG_ALL_DESIG.
444                  ENDIF.
445                ENDIF.
446              ENDIF.
447            ENDSELECT.
448          ENDIF.
449        ELSEIF MEMOACT-APACT = '063' .
450    *        Written Exam GT's
451          SELECT * FROM PB4002
452          WHERE PERNR = P_P0001-PERNR
453          AND APSTV <> '4'
454          AND BEGDA <= SY-DATUM
455          AND ENDDA >= SY-DATUM .
456
457            IF SY-SUBRC = 0 .
458              SELECT SINGLE * FROM ZDESIGNATION_REV
459              WHERE DESIG_CODE = PB4002-ZZDESIG_CODE
460              AND R_P_CD = PB4002-ZZR_P_CD
461              AND VERSION = PB4002-ZZVERSION .
462
463              IF SY-SUBRC = 0 .
464                SELECT SINGLE * FROM ZBASICPAY
465                WHERE GRADE = ZDESIGNATION_REV-GRADE.
466
467                IF SY-SUBRC = 0 .
468                  DESIG_ALL_DESIG-OBJID = PB4002-OBJID.
469                  DESIG_ALL_DESIG-DESIG_CODE = PB4002-ZZDESIG_CODE.
470                  DESIG_ALL_DESIG-R_P_CD = PB4002-ZZR_P_CD.
471                  DESIG_ALL_DESIG-VERSION = PB4002-ZZVERSION.
472                  DESIG_ALL_DESIG-DESIG_TEXT =
473                                       ZDESIGNATION_REV-DESIG_TEXT .
474                  DESIG_ALL_DESIG-PAYRANGE = ZBASICPAY-PAYRANGE .
475                  APPEND DESIG_ALL_DESIG.
476                ENDIF.
477              ENDIF.
478            ENDIF.
479          ENDSELECT.
480
481        ELSE.
482    *        Offer Letter, Cancellation letter etc.
483    *anurag
484          CLEAR ZLTVAR-ADDR_BMP_ID .
485          CONCATENATE 'A' P_P0001-PERNR 'AD' INTO ZLTVAR-ADDR_BMP_ID .
486          SELECT SINGLE * FROM STXBITMAPS
487          WHERE TDOBJECT = 'GRAPHICS'
488          AND TDID = 'BMAP'
489          AND TDBTYPE = 'BCOL'
490          AND TDNAME = ZLTVAR-ADDR_BMP_ID.
491          IF SY-SUBRC <> 0.
492    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
493    *        SELECT SINGLE * FROM PB0006
494    *        WHERE SUBTY = '5' AND PERNR = P_P0001-PERNR.
495     SELECT * FROM PB0006   UP TO 1 ROWS WHERE SUBTY = '5' AND PERNR =
496    P_P0001-PERNR  ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .
497    ENDSELECT.
498    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
499            MOVE PB0006-NAME2 TO ZLTVAR-NAME2.
500            MOVE PB0006-STRAS TO ZLTVAR-STRAS.
501            MOVE PB0006-LOCAT TO ZLTVAR-LOCAT.
502            MOVE PB0006-PSTLZ TO ZLTVAR-PSTLZ.
503            MOVE PB0006-ORT01 TO ZLTVAR-ORT01.
504            MOVE PB0006-ORT02 TO ZLTVAR-ORT02.
505            MOVE PB0006-TELNR TO ZLTVAR-TELNR.
506            CLEAR ZLTVAR-ADDR_BMP_ID.
507          ENDIF.
508
509    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
510    *      SELECT SINGLE * FROM PB4002
511    *      WHERE PERNR = P_P0001-PERNR
512    *      AND APSTV <> '4'
513    *      AND BEGDA <= SY-DATUM
514    *      AND ENDDA >= SY-DATUM
515    *      AND ZZDESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
516    *      AND ZZR_P_CD = ZHRRPTRB_POSDESG-R_P_CD
517    *      AND ZZVERSION = ZHRRPTRB_POSDESG-VERSION
518    *      AND ZZRECRUIT_ID = PB9400-ZRECRUIT_ID .
519     SELECT * FROM PB4002   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
520    APSTV <> '4' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM AND
521    ZZDESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE AND ZZR_P_CD =
522    ZHRRPTRB_POSDESG-R_P_CD AND ZZVERSION = ZHRRPTRB_POSDESG-VERSION AND
523    ZZRECRUIT_ID = PB9400-ZRECRUIT_ID   ORDER BY  PERNR SUBTY OBJPS SPRPS
524    ENDDA BEGDA SEQNR .   ENDSELECT.
525    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
526
527          IF SY-SUBRC = 0 .
528
529            IF MEMOACT-APACT = '021' .     "AND SY-TCODE = 'PB60' .
530    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
531    *          SELECT SINGLE * FROM PB9402
532    *          WHERE PERNR = P_P0001-PERNR
533    *          AND DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
534    *          AND R_P_CD = ZHRRPTRB_POSDESG-R_P_CD
535    *          AND VERSION = ZHRRPTRB_POSDESG-VERSION
536    *          AND ZRECRUIT_ID = PB9400-ZRECRUIT_ID
537    *          AND BEGDA <= SY-DATUM
538    *          AND ENDDA >= SY-DATUM
539    *          AND SPRPS = ' ' .
540     SELECT * FROM PB9402   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
541    DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE AND R_P_CD =
542    ZHRRPTRB_POSDESG-R_P_CD AND VERSION = ZHRRPTRB_POSDESG-VERSION AND
543    ZRECRUIT_ID = PB9400-ZRECRUIT_ID AND BEGDA <= SY-DATUM AND ENDDA >=
544    SY-DATUM AND SPRPS = ' '   ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA
545    BEGDA SEQNR .   ENDSELECT.
546    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
547              IF SY-SUBRC <> 0 .
548                MESSAGE E000(ZMSG) WITH 'Offer Related Data '
549                'either missing or Locked.' .
550              ENDIF.
551            ENDIF.
552
553
554
555            SELECT SINGLE * FROM ZDESIGNATION_REV
556            WHERE DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
557            AND R_P_CD = ZHRRPTRB_POSDESG-R_P_CD
558            AND VERSION = ZHRRPTRB_POSDESG-VERSION .
559
560            IF SY-SUBRC = 0 .
561              SELECT SINGLE * FROM ZBASICPAY
562                  WHERE GRADE = ZDESIGNATION_REV-GRADE.
563              IF SY-SUBRC = 0.
564                DESIG_ALL_DESIG-OBJID = ZHRRPTRB_POSDESG-OBJID.
565                DESIG_ALL_DESIG-DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE.
566                DESIG_ALL_DESIG-R_P_CD = ZHRRPTRB_POSDESG-R_P_CD.
567                DESIG_ALL_DESIG-VERSION = ZHRRPTRB_POSDESG-VERSION.
568                DESIG_ALL_DESIG-PAYRANGE = ZBASICPAY-PAYRANGE .
569                DESIG_ALL_DESIG-DESIG_TEXT =
570                                     ZDESIGNATION_REV-DESIG_TEXT .
571                APPEND DESIG_ALL_DESIG.
572              ENDIF.
573            ENDIF.
574          ENDIF.
575    *Begin of modification by Anurag AJ03122002
576    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
577    *      SELECT SINGLE *
578    *        FROM PB4005
579    *        WHERE PERNR  = P_P0001-PERNR.
580     SELECT * FROM PB4005   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR  ORDER
581    BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
582    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
583          IF SY-SUBRC = 0 .
584            ZLTVAR-DEPT_APP_PA_CPF_NO = PB4005-EMPNR.
585    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
586    *        SELECT SINGLE *
587    *          FROM PA9930
588    *          WHERE PERNR = PB4005-EMPNR
589    *          AND   BEGDA <= SY-DATUM
590    *          AND   ENDDA >= SY-DATUM.
591     SELECT * FROM PA9930   UP TO 1 ROWS WHERE PERNR = PB4005-EMPNR AND
592    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
593    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
594    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
595            IF SY-SUBRC = 0.
596              SELECT SINGLE *
597                FROM ZDESIGNATION_REV
598                WHERE DESIG_CODE = PA9930-DESIGNO
599                AND R_P_CD = PA9930-R_P_CD
600                AND VERSION = PA9930-VERSION .
601              IF SY-SUBRC = 0.
602                ZLTVAR-DEPT_APP_PA_DESG = ZDESIGNATION_REV-DESIG_TEXT.
603              ENDIF.
604            ENDIF.
605          ENDIF.
606    *Personnel Area
607          SELECT SINGLE *
608            FROM T500P
609            WHERE PERSA = P_P0001-WERKS.
610          IF SY-SUBRC = 0.
611            ZLTVAR-DEPT_APP_PER_AREA = T500P-NAME1.
612          ENDIF.
613    *Place of posting
614    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
615    *      SELECT SINGLE *
616    *        FROM PB9402
617    *        WHERE PERNR = P_P0001-PERNR.
618     SELECT * FROM PB9402   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR  ORDER
619    BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
620    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
621          IF SY-SUBRC = 0.
622            SELECT SINGLE *
623            FROM T500P
624            WHERE PERSA = PB9402-WERKS.
625            IF SY-SUBRC = 0.
626              ZLTVAR-DEPT_APP_POST_PLACE = T500P-NAME1.
627            ENDIF.
628    *Get reporting officer name
629    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
630    *        SELECT SINGLE *
631    *          FROM PA0002
632    *          WHERE PERNR = PB9402-REP_PERNR
633    *          AND   BEGDA <= SY-DATUM
634    *          AND   ENDDA >= SY-DATUM.
635     SELECT * FROM PA0002   UP TO 1 ROWS WHERE PERNR = PB9402-REP_PERNR AND
636    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
637    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
638    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
639            IF SY-SUBRC = 0.
640              CONCATENATE PA0002-VORNA PA0002-NAME2 PA0002-NACHN
641                INTO ZLTVAR-DEPT_APP_REP_OFF SEPARATED BY SPACE.
642            ENDIF.
643
644    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
645    *        SELECT SINGLE *
646    *          FROM PA9930
647    *          WHERE PERNR = PB9402-REP_PERNR
648    *          AND   BEGDA <= SY-DATUM
649    *          AND   ENDDA >= SY-DATUM.
650     SELECT * FROM PA9930   UP TO 1 ROWS WHERE PERNR = PB9402-REP_PERNR AND
651    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
652    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
653    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
654            IF SY-SUBRC = 0.
655    *Get reporting officer designation
656              SELECT SINGLE *
657                FROM ZDESIGNATION_REV
658                WHERE DESIG_CODE = PA9930-DESIGNO
659                AND R_P_CD = PA9930-R_P_CD
660                AND VERSION = PA9930-VERSION .
661              IF SY-SUBRC = 0.
662                ZLTVAR-DEPT_APP_REP_O_DESG =
663                      ZDESIGNATION_REV-DESIG_TEXT.
664              ENDIF.
665            ENDIF.
666    *Get the centre details
667            SELECT SINGLE *
668              FROM ZHR_EXM_CENTRE
669              WHERE ZCENTRE_ID = PB9402-ZCENTRE_ID.
670            IF SY-SUBRC = 0.
671              ZLTVAR-DEPT_APP_REP_ADD = ZHR_EXM_CENTRE-ZCENTRE_NAME.
672            ENDIF.
673          ENDIF.
674    *End of modification by Anurag AJ03122002
675
676
677          SELECT SINGLE VAR_TEXT INTO VAR_CAMPUS_ID
678          FROM ZHR_EXM_VARIABLE
679          WHERE ZRECRUIT_ID = ZLTVAR-ZREC
680          AND VAR_ID = '00152' .
681          IF SY-SUBRC = 0 .
682            ZLTVAR-CAMPUS = 'Y'.
683            SELECT SINGLE VAR_DATE INTO ZLTVAR-CAMPUS_DATE
684            FROM ZHR_EXM_VARIABLE
685            WHERE ZRECRUIT_ID = ZLTVAR-ZREC
686            AND VAR_ID = '00153' .
687
688            SELECT SINGLE * FROM ZHR_EXM_CENTRE
689            WHERE ZCENTRE_ID = VAR_CAMPUS_ID.
690            IF SY-SUBRC = 0.
691              MOVE ZHR_EXM_CENTRE-ZCENTRE_NAME TO ZLTVAR-CNTRNAME.
692              MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR1 TO ZLTVAR-CNTRADR1.
693              MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR2 TO ZLTVAR-CNTRADR2.
694              MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR3 TO ZLTVAR-CNTRADR3.
695              MOVE ZHR_EXM_CENTRE-ZCENTRE_STATE TO ZLTVAR-CNTRSTATE.
696              MOVE ZHR_EXM_CENTRE-PSTLZ TO ZLTVAR-CNTRPIN.
697              MOVE ZHR_EXM_CENTRE-ZCENTRE_PHONE_NO TO ZLTVAR-CNTRPHONE.
698            ENDIF.
699          ELSE.
700            ZLTVAR-CAMPUS = 'N'.
701          ENDIF.
702    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
703    *      SELECT SINGLE * FROM PB9402
704    *      WHERE APRIO = PB4002-APRIO
705    *      AND ZRECRUIT_ID = ZLTVAR-ZREC
706    *      AND DESIG_CODE = PB4002-ZZDESIG_CODE
707    *      AND R_P_CD = PB4002-ZZR_P_CD
708    *      AND VERSION = PB4002-ZZVERSION
709    *      AND PERNR = P_P0001-PERNR .
710     SELECT * FROM PB9402   UP TO 1 ROWS WHERE APRIO = PB4002-APRIO AND
711    ZRECRUIT_ID = ZLTVAR-ZREC AND DESIG_CODE = PB4002-ZZDESIG_CODE AND
712    R_P_CD = PB4002-ZZR_P_CD AND VERSION = PB4002-ZZVERSION AND PERNR =
713    P_P0001-PERNR   ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .
714    ENDSELECT.
715    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
716
717
718    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
719    *      SELECT SINGLE * FROM PA0002
720    *      WHERE PERNR = PB9402-REP_PERNR
721    *      AND BEGDA <= SY-DATUM
722    *      AND ENDDA >= SY-DATUM .
723     SELECT * FROM PA0002   UP TO 1 ROWS WHERE PERNR = PB9402-REP_PERNR AND
724    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM   ORDER BY  PERNR SUBTY OBJPS
725    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
726    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
727
728          CONCATENATE PA0002-VORNA PA0002-NAME2 PA0002-NACHN
729          INTO ZLTVAR-REP_OFF_NAME SEPARATED BY SPACE.
730
731    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
732    *      SELECT SINGLE USRID_LONG FROM PA0105
733    *      INTO ZLTVAR-REP_OFF_EMAIL
734    *      WHERE PERNR = PB9402-REP_PERNR
735    *      AND BEGDA <= SY-DATUM
736    *      AND ENDDA >= SY-DATUM
737    *      AND SUBTY = '0010' .
738     SELECT USRID_LONG FROM PA0105   UP TO 1 ROWS INTO ZLTVAR-REP_OFF_EMAIL
739    WHERE PERNR = PB9402-REP_PERNR AND BEGDA <= SY-DATUM AND ENDDA >=
740    SY-DATUM AND SUBTY = '0010'   ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA
741    BEGDA SEQNR .   ENDSELECT.
742    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
743
744    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
745    *      SELECT SINGLE USRID FROM PA0105
746    *      INTO ZLTVAR-REP_OFF_FAX
747    *      WHERE PERNR = PB9402-REP_PERNR
748    *      AND BEGDA <= SY-DATUM
749    *      AND ENDDA >= SY-DATUM
750    *      AND SUBTY = '0005' .
751     SELECT USRID FROM PA0105   UP TO 1 ROWS INTO ZLTVAR-REP_OFF_FAX WHERE
752    PERNR = PB9402-REP_PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
753    AND SUBTY = '0005'   ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA
754    SEQNR .   ENDSELECT.
755    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
756
757    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
758    *      SELECT SINGLE * FROM PA0002
759    *      WHERE PERNR = PB9402-APP_PERNR
760    *      AND BEGDA <= SY-DATUM
761    *      AND ENDDA >= SY-DATUM .
762     SELECT * FROM PA0002   UP TO 1 ROWS WHERE PERNR = PB9402-APP_PERNR AND
763    BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM   ORDER BY  PERNR SUBTY OBJPS
764    SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
765    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
766
767          CONCATENATE PA0002-VORNA PA0002-NAME2 PA0002-NACHN
768          INTO ZLTVAR-TRAIN_OFF_NAME SEPARATED BY SPACE.
769
770    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
771    *      SELECT SINGLE USRID_LONG FROM PA0105
772    *      INTO ZLTVAR-TRAIN_OFF_EMAIL
773    *      WHERE PERNR = PB9402-APP_PERNR
774    *      AND BEGDA <= SY-DATUM
775    *      AND ENDDA >= SY-DATUM
776    *      AND SUBTY = '0010' .
777     SELECT USRID_LONG FROM PA0105   UP TO 1 ROWS INTO
778    ZLTVAR-TRAIN_OFF_EMAIL WHERE PERNR = PB9402-APP_PERNR AND BEGDA <=
779    SY-DATUM AND ENDDA >= SY-DATUM AND SUBTY = '0010'   ORDER BY  PERNR
780    SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
781    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
782
783    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
784    *      SELECT SINGLE USRID FROM PA0105
785    *      INTO ZLTVAR-TRAIN_OFF_FAX
786    *      WHERE PERNR = PB9402-REP_PERNR
787    *      AND BEGDA <= SY-DATUM
788    *      AND ENDDA >= SY-DATUM
789    *      AND SUBTY = '0005' .
790     SELECT USRID FROM PA0105   UP TO 1 ROWS INTO ZLTVAR-TRAIN_OFF_FAX
791    WHERE PERNR = PB9402-REP_PERNR AND BEGDA <= SY-DATUM AND ENDDA >=
792    SY-DATUM AND SUBTY = '0005'   ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA
793    BEGDA SEQNR .   ENDSELECT.
794    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
795
796          ZLTVAR-TRAINING_APPL = PB9402-CHECK_BOX.
797          ZLTVAR-TRAINING_DATE = PB9402-TRAIN_DATE.
798          ZLTVAR-TRAINING_TIME = PB9402-TRAIN_TIME.
799    *BREAK-POINT.
800    *Begin of Modificatio By Anurag Jain                            AJ210203
801
802    *      SELECT SINGLE * FROM ZHR_EXM_CENTRE
803    *      WHERE ZCENTRE_ID = PB9402-ZCENTRE_ID.
804    *      IF SY-SUBRC = 0.
805    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_NAME TO ZLTVAR-CNTRNAMEWR.
806    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR1 TO ZLTVAR-CNTRAD1WR.
807    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR2 TO ZLTVAR-CNTRAD2WR.
808    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR3 TO ZLTVAR-CNTRAD3WR.
809    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_STATE TO ZLTVAR-CNTRSTWR.
810    *        MOVE ZHR_EXM_CENTRE-PSTLZ TO ZLTVAR-CNTRPINWR.
811    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_PHONE_NO TO ZLTVAR-CNTRPHWR.
812    *      ENDIF.
813
814    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
815    *       SELECT SINGLE *
816    *         FROM PA0006
817    *         WHERE PERNR = PB9402-REP_PERNR
818    *         AND   SUBTY = '23'
819    *         AND   BEGDA <= SY-DATUM
820    *         AND   ENDDA >= SY-DATUM.
821     SELECT * FROM PA0006   UP TO 1 ROWS WHERE PERNR = PB9402-REP_PERNR AND
822    SUBTY = '23' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY
823    PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
824    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
825          IF SY-SUBRC = 0.
826            MOVE PA0006-NAME2 TO ZLTVAR-CNTRNAMEWR.
827            MOVE PA0006-STRAS TO ZLTVAR-CNTRAD1WR.
828            MOVE PA0006-LOCAT TO ZLTVAR-CNTRAD2WR.
829            MOVE PA0006-ORT01 TO ZLTVAR-CNTRAD3WR.
830            MOVE PA0006-STATE TO ZLTVAR-CNTRSTWR.
831            MOVE PA0006-PSTLZ TO ZLTVAR-CNTRPINWR.
832            MOVE PA0006-TELNR TO ZLTVAR-CNTRPHWR.
833          ENDIF.
834
835    *End of Modification By Anurag Jain                             AJ210203
836
837        ENDIF.
838        CLEAR VAR_DESIG_TEXT .
839        CLEAR DESIG_ALL_DESIG.
840        LOOP AT DESIG_ALL_DESIG.
841          IF VAR_DESIG_TEXT IS INITIAL.
842            MOVE DESIG_ALL_DESIG-DESIG_TEXT TO VAR_DESIG_TEXT .
843          ELSE.
844            CONCATENATE VAR_DESIG_TEXT DESIG_ALL_DESIG-DESIG_TEXT
845            INTO VAR_DESIG_TEXT SEPARATED BY ', '.
846          ENDIF.
847          VAR_PAYRANGE = DESIG_ALL_DESIG-PAYRANGE.
848        ENDLOOP.
849
850
851        CONDENSE VAR_DESIG_TEXT .
852        ZLTVAR-DESIG_TEXT = VAR_DESIG_TEXT .
853        ZLTVAR-PAYRANGE1 = VAR_PAYRANGE .
854
855
856        IF MEMOACT-APACT = '061' OR
857        MEMOACT-APACT = '062' OR
858        MEMOACT-APACT = '063' .
859    *To get the Centre Details where the Interview will be conducted
860    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
861    *      SELECT SINGLE * FROM PB9401 WHERE PERNR = P_P0001-PERNR
862    *                        AND SUBTY = '51'
863    *                  AND ZRECRUIT_ID = PB9400-ZRECRUIT_ID
864    *                        AND OBJID = VAR_OBJID.
865     SELECT * FROM PB9401   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
866    SUBTY = '51' AND ZRECRUIT_ID = PB9400-ZRECRUIT_ID AND OBJID = VAR_OBJID
867     ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
868    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
869          IF SY-SUBRC = 0.
870            SELECT SINGLE * FROM ZHR_EXM_CENTRE
871                                WHERE ZCENTRE_ID = PB9401-VENUE.
872            IF SY-SUBRC = 0.
873              MOVE ZHR_EXM_CENTRE-ZCENTRE_NAME TO ZLTVAR-CNTRNAME.
874              MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR1 TO ZLTVAR-CNTRADR1.
875              MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR2 TO ZLTVAR-CNTRADR2.
876              MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR3 TO ZLTVAR-CNTRADR3.
877              MOVE ZHR_EXM_CENTRE-ZCENTRE_STATE TO ZLTVAR-CNTRSTATE.
878              MOVE ZHR_EXM_CENTRE-PSTLZ TO ZLTVAR-CNTRPIN.
879              MOVE ZHR_EXM_CENTRE-ZCENTRE_PHONE_NO TO ZLTVAR-CNTRPHONE.
880            ENDIF.
881          ENDIF.
882        ELSE.
883    * begin of modification Rupesh Sethi 25022003
884    *      SELECT SINGLE * FROM ZHR_EXM_CENTRE
885    *      WHERE ZCENTRE_ID = PB9402-CENTER_ID.
886    *      IF SY-SUBRC = 0.
887    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_NAME TO ZLTVAR-CNTRNAME.
888    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR1 TO ZLTVAR-CNTRADR1.
889    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR2 TO ZLTVAR-CNTRADR2.
890    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR3 TO ZLTVAR-CNTRADR3.
891    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_STATE TO ZLTVAR-CNTRSTATE.
892    *        MOVE ZHR_EXM_CENTRE-PSTLZ TO ZLTVAR-CNTRPIN.
893    *        MOVE ZHR_EXM_CENTRE-ZCENTRE_PHONE_NO TO ZLTVAR-CNTRPHONE.
894    *      ENDIF.
895
896
897    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
898    *       SELECT SINGLE *
899    *         FROM PA0006
900    *         WHERE PERNR = PB9402-APP_PERNR
901    *         AND   SUBTY = '23'
902    *         AND   BEGDA <= SY-DATUM
903    *         AND   ENDDA >= SY-DATUM.
904     SELECT * FROM PA0006   UP TO 1 ROWS WHERE PERNR = PB9402-APP_PERNR AND
905    SUBTY = '23' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY
906    PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
907    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
908          IF SY-SUBRC = 0.
909            MOVE PA0006-NAME2 TO ZLTVAR-CNTRNAME.
910            MOVE PA0006-STRAS TO ZLTVAR-CNTRADR1.
911            MOVE PA0006-LOCAT TO ZLTVAR-CNTRADR2.
912            MOVE PA0006-ORT01 TO ZLTVAR-CNTRADR3.
913            MOVE PA0006-STATE TO ZLTVAR-CNTRSTATE.
914            MOVE PA0006-PSTLZ TO ZLTVAR-CNTRPIN.
915            MOVE PA0006-TELNR TO ZLTVAR-CNTRPHONE.
916          ENDIF.
917    * end of modification Rupesh Sethi 25022003
918
919        ENDIF.
920    *To get the Centre Details where the Written Exam will be conducted
921
922    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
923    *    SELECT SINGLE * FROM PB9405
924    *                WHERE PERNR = P_P0001-PERNR
925    *            AND ZRECRUIT_ID = PB9400-ZRECRUIT_ID
926    *             AND DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
927    *                AND  R_P_CD = ZHRRPTRB_POSDESG-R_P_CD
928    *                AND VERSION = ZHRRPTRB_POSDESG-VERSION.
929     SELECT * FROM PB9405   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
930    ZRECRUIT_ID = PB9400-ZRECRUIT_ID AND DESIG_CODE =
931    ZHRRPTRB_POSDESG-DESIG_CODE AND R_P_CD = ZHRRPTRB_POSDESG-R_P_CD AND
932    VERSION = ZHRRPTRB_POSDESG-VERSION  ORDER BY  PERNR SUBTY OBJPS SPRPS
933    ENDDA BEGDA SEQNR .   ENDSELECT.
934    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
935        IF SY-SUBRC = 0.
936          SELECT SINGLE * FROM ZHR_EXM_CENTRE
937                     WHERE ZCENTRE_ID = PB9405-CENTRE_ALLO.
938          IF SY-SUBRC = 0.
939            MOVE ZHR_EXM_CENTRE-ZCENTRE_NAME TO ZLTVAR-CNTRNAMEWR.
940            MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR1 TO ZLTVAR-CNTRAD1WR.
941            MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR2 TO ZLTVAR-CNTRAD2WR.
942            MOVE ZHR_EXM_CENTRE-ZCENTRE_ADDR3 TO ZLTVAR-CNTRAD3WR.
943            MOVE ZHR_EXM_CENTRE-ZCENTRE_STATE TO ZLTVAR-CNTRSTWR.
944            MOVE ZHR_EXM_CENTRE-PSTLZ TO ZLTVAR-CNTRPINWR.
945            MOVE ZHR_EXM_CENTRE-ZCENTRE_PHONE_NO TO ZLTVAR-CNTRPHWR.
946          ENDIF.
947        ENDIF.
948
949    *To get the Applicant Group in which the Applicant falls
950
951        SELECT SINGLE * FROM T750E WHERE LANGU = 'EN'
952                                     AND APGRP = P0001-PERSG.
953        MOVE T750E-GPTXT TO ZLTVAR-GPTXT.
954
955    *To get the Category of Applicant.
956
957    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
958    *    SELECT SINGLE * FROM PB9404 WHERE PERNR = P_P0001-PERNR.
959     SELECT * FROM PB9404   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR  ORDER
960    BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
961    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
962        IF SY-SUBRC = 0.
963          SELECT SINGLE * FROM ZHRRST_CATG_COMB
964                    WHERE ZCAT_APPL_ID = PB9404-ZCAT_APPL_ID.
965          MOVE ZHRRST_CATG_COMB-ZCAT_APPL_DESC TO ZLTVAR-ZCATDS.
966        ENDIF.
967      ENDIF.
968
969
970
971      IF ( MEMOACT-APACT <> '061'
972       AND MEMOACT-APACT <> '062'
973       AND MEMOACT-APACT <> '063' ) .
974
975        SELECT SINGLE * FROM ZHR_EXM_VARIABLE
976                WHERE ZRECRUIT_ID = ZLTVAR-ZREC
977                       AND VAR_ID = '00107'.
978        IF SY-SUBRC = 0.
979          SELECT * FROM HRP1001
980          WHERE OBJID = ZHR_EXM_VARIABLE-VAR_TEXT
981          AND   OTYPE = '9R'
982          AND   PLVAR = '01'
983          AND   RSIGN = 'A'
984          AND   RELAT = '911'
985          AND   ISTAT = '1'.
986
987    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
988    *        SELECT SINGLE * FROM HRP9410
989    *        WHERE DESIG_CODE = ZHRRPTRB_POSDESG-DESIG_CODE
990    *        AND  R_P_CD = ZHRRPTRB_POSDESG-R_P_CD
991    *        AND VERSION = ZHRRPTRB_POSDESG-VERSION
992    *        AND OBJID = HRP1001-SOBID .
993     SELECT * FROM HRP9410   UP TO 1 ROWS WHERE DESIG_CODE =
994    ZHRRPTRB_POSDESG-DESIG_CODE AND R_P_CD = ZHRRPTRB_POSDESG-R_P_CD AND
995    VERSION = ZHRRPTRB_POSDESG-VERSION AND OBJID = HRP1001-SOBID   ORDER BY
996     PLVAR OTYPE OBJID SUBTY ISTAT BEGDA ENDDA VARYF SEQNR .   ENDSELECT.
997    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
998            IF SY-SUBRC = 0 .
999              MOVE HRP9410-OBJID TO VAR_OBJID.
1000             EXIT.
1001           ENDIF.
1002
1003         ENDSELECT.
1004
1005         SELECT * FROM HRP9410
1006         WHERE OBJID = VAR_OBJID
1007         AND ISTAT = '1'
1008         AND PLVAR = '01' .
1009
1010           SELECT * FROM ZHRRPTRB_POSDESG
1011           WHERE DESIG_CODE = HRP9410-DESIG_CODE
1012           AND R_P_CD = HRP9410-R_P_CD
1013           AND VERSION = HRP9410-VERSION .
1014
1015   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
1016   *          SELECT SINGLE * FROM PB4003
1017   *          WHERE PERNR = P_P0001-PERNR
1018   *          AND APACT = '062'
1019   *          AND OBJID = ZHRRPTRB_POSDESG-OBJID .
1020    SELECT * FROM PB4003   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
1021   APACT = '062' AND OBJID = ZHRRPTRB_POSDESG-OBJID   ORDER BY  PERNR
1022   SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
1023   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
1024             IF SY-SUBRC = 0 .
1025               ZLTVAR-ITVW_DATE = PB4003-PLDAT.
1026             ENDIF.
1027
1028           ENDSELECT.
1029         ENDSELECT .
1030       ENDIF.
1031     ENDIF.
1032   *BEGIN OF MODIFICATION BY ANURAG JAIN  AJ280203
1033   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
1034   *  SELECT SINGLE *
1035   *    FROM PB0002
1036   *    WHERE PERNR = P_P0001-PERNR
1037   *    AND   BEGDA <= SY-DATUM
1038   *    AND   ENDDA >= SY-DATUM.
1039    SELECT * FROM PB0002   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
1040   BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM  ORDER BY  PERNR SUBTY OBJPS
1041   SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
1042   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
1043       IF PB0002-GESCH = '1'.
1044         ZLTVAR-HE_SHE = 'he'.
1045         ZLTVAR-HIS_HER = 'his'.
1046         ZLTVAR-HE_SHE_CAPS = 'He'.
1047         ZLTVAR-HIS_HER_CAPS = 'His'.
1048       ELSEIF PB0002-GESCH = '2'.
1049         ZLTVAR-HE_SHE = 'she'.
1050         ZLTVAR-HIS_HER = 'her'.
1051         ZLTVAR-HE_SHE_CAPS = 'She'.
1052         ZLTVAR-HIS_HER_CAPS = 'Her'.
1053       ELSE.
1054         ZLTVAR-HE_SHE = 'he/she'.
1055         ZLTVAR-HIS_HER = 'his/her'.
1056         ZLTVAR-HE_SHE_CAPS = 'He/She'.
1057         ZLTVAR-HIS_HER_CAPS = 'His/Her'.
1058       ENDIF.
1059
1060   *PB4003-APACT = '011'.
1061   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
1062   *    SELECT SINGLE *
1063   *      FROM PB4002
1064   *      WHERE PERNR = P_P0001-PERNR
1065   *      AND   APSTV = '4'.
1066    SELECT * FROM PB4002   UP TO 1 ROWS WHERE PERNR = P_P0001-PERNR AND
1067   APSTV = '4'  ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .
1068   ENDSELECT.
1069   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
1070       IF SY-SUBRC = 0.
1071   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
1072   *      SELECT SINGLE REATX INTO ZLTVAR-REATX
1073   *        FROM T751C
1074   *        WHERE STREA = PB4002-STREA.
1075    SELECT REATX FROM T751C   UP TO 1 ROWS INTO ZLTVAR-REATX WHERE STREA =
1076   PB4002-STREA  ORDER BY  LANGU STREA .   ENDSELECT.
1077   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
1078       ENDIF.
1079   *END OF MODIFICATION BY ANURAG JAIN  AJ280203
1080     IF NOT ZLTVAR-CNTRNAME IS INITIAL .
1081       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1082         MOVE ZLTVAR-CNTRNAME TO ZLTVAR-CNTRADDRESS .
1083       ELSE.
1084         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRNAME
1085                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1086       ENDIF.
1087     ENDIF.
1088     IF NOT ZLTVAR-CNTRADR1 IS INITIAL .
1089       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1090         MOVE ZLTVAR-CNTRADR1 TO ZLTVAR-CNTRADDRESS .
1091       ELSE.
1092         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRADR1
1093                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1094       ENDIF.
1095     ENDIF.
1096     IF NOT ZLTVAR-CNTRADR2 IS INITIAL .
1097       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1098         MOVE ZLTVAR-CNTRADR2 TO ZLTVAR-CNTRADDRESS .
1099       ELSE.
1100         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRADR2
1101                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1102       ENDIF.
1103     ENDIF.
1104     IF NOT ZLTVAR-CNTRADR3 IS INITIAL .
1105       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1106         MOVE ZLTVAR-CNTRADR3 TO ZLTVAR-CNTRADDRESS .
1107       ELSE.
1108         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRADR3
1109                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1110       ENDIF.
1111     ENDIF.
1112     IF NOT ZLTVAR-CNTRSTATE IS INITIAL .
1113       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1114         MOVE ZLTVAR-CNTRSTATE TO ZLTVAR-CNTRADDRESS .
1115       ELSE.
1116         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRSTATE
1117                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1118       ENDIF.
1119     ENDIF.
1120     IF NOT ZLTVAR-CNTRPIN IS INITIAL .
1121       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1122         MOVE ZLTVAR-CNTRPIN TO ZLTVAR-CNTRADDRESS .
1123       ELSE.
1124         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRPIN
1125                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1126       ENDIF.
1127     ENDIF.
1128     IF NOT ZLTVAR-CNTRPHONE IS INITIAL .
1129       IF ZLTVAR-CNTRADDRESS IS INITIAL .
1130         MOVE ZLTVAR-CNTRPHONE TO ZLTVAR-CNTRADDRESS .
1131       ELSE.
1132         CONCATENATE ZLTVAR-CNTRADDRESS 'Phone No.'
1133                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1134         CONCATENATE ZLTVAR-CNTRADDRESS ZLTVAR-CNTRPHONE
1135                     INTO ZLTVAR-CNTRADDRESS SEPARATED BY SPACE .
1136       ENDIF.
1137     ENDIF.
1138
1139
1140     IF NOT ZLTVAR-CNTRNAMEWR IS INITIAL .
1141       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1142         MOVE ZLTVAR-CNTRNAMEWR TO ZLTVAR-CNTRADDRESSWR .
1143       ELSE.
1144         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRNAMEWR
1145                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1146       ENDIF.
1147     ENDIF.
1148     IF NOT ZLTVAR-CNTRAD1WR IS INITIAL .
1149       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1150         MOVE ZLTVAR-CNTRAD1WR TO ZLTVAR-CNTRADDRESSWR .
1151       ELSE.
1152         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRAD1WR
1153                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1154       ENDIF.
1155     ENDIF.
1156     IF NOT ZLTVAR-CNTRAD2WR IS INITIAL .
1157       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1158         MOVE ZLTVAR-CNTRAD2WR TO ZLTVAR-CNTRADDRESSWR .
1159       ELSE.
1160         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRAD2WR
1161                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1162       ENDIF.
1163     ENDIF.
1164     IF NOT ZLTVAR-CNTRAD3WR IS INITIAL .
1165       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1166         MOVE ZLTVAR-CNTRAD3WR TO ZLTVAR-CNTRADDRESSWR .
1167       ELSE.
1168         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRAD3WR
1169                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1170       ENDIF.
1171     ENDIF.
1172     IF NOT ZLTVAR-CNTRSTWR IS INITIAL .
1173       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1174         MOVE ZLTVAR-CNTRSTWR TO ZLTVAR-CNTRADDRESSWR .
1175       ELSE.
1176         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRSTWR
1177                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1178       ENDIF.
1179     ENDIF.
1180     IF NOT ZLTVAR-CNTRPINWR IS INITIAL .
1181       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1182         MOVE ZLTVAR-CNTRPINWR TO ZLTVAR-CNTRADDRESSWR .
1183       ELSE.
1184         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRPINWR
1185                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1186       ENDIF.
1187     ENDIF.
1188     IF NOT ZLTVAR-CNTRPHWR IS INITIAL .
1189       IF ZLTVAR-CNTRADDRESSWR IS INITIAL .
1190         MOVE ZLTVAR-CNTRPHWR TO ZLTVAR-CNTRADDRESSWR .
1191       ELSE.
1192         CONCATENATE ZLTVAR-CNTRADDRESSWR 'Phone No.'
1193                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1194         CONCATENATE ZLTVAR-CNTRADDRESSWR ZLTVAR-CNTRPHWR
1195                     INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY SPACE .
1196       ENDIF.
1197     ENDIF.
1198
1199
1200   *  CONCATENATE ZLTVAR-CNTRNAME ZLTVAR-CNTRADR1 ZLTVAR-CNTRADR2
1201   *            ZLTVAR-CNTRADR3 ZLTVAR-CNTRSTATE ZLTVAR-CNTRPIN
1202   *            INTO ZLTVAR-CNTRADDRESS SEPARATED BY ', ' .
1203   *
1204   *  IF NOT ZLTVAR-CNTRPHONE IS INITIAL.
1205   *    CONCATENATE ZLTVAR-CNTRADDRESS 'Phone No.' ZLTVAR-CNTRPHONE
1206   *            INTO ZLTVAR-CNTRADDRESS SEPARATED BY SPACE .
1207   *  ENDIF.
1208   *
1209   *  CONCATENATE ZLTVAR-CNTRNAMEWR ZLTVAR-CNTRAD1WR ZLTVAR-CNTRAD2WR
1210   *            ZLTVAR-CNTRAD3WR ZLTVAR-CNTRSTWR ZLTVAR-CNTRPINWR
1211   *            INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY ', ' .
1212   *
1213   *  IF NOT ZLTVAR-CNTRPHWR IS INITIAL.
1214   *    CONCATENATE ZLTVAR-CNTRADDRESSWR 'Phone No.' ZLTVAR-CNTRPHWR
1215   *            INTO ZLTVAR-CNTRADDRESSWR SEPARATED BY SPACE .
1216   *  ENDIF.
1217
1218   *Setting Default Value as '-' when the value is null.
1219     IF SY-TCODE = 'ZPBAT_RTF'.
1220       IF ZLTVAR-ZREC  IS INITIAL.
1221         MOVE '-' TO  ZLTVAR-ZREC.
1222       ENDIF.
1223
1224       IF ZLTVAR-ZRECDESC IS INITIAL.
1225         MOVE '-' TO  ZLTVAR-ZRECDESC.
1226       ENDIF.
1227
1228       IF ZLTVAR-DSGTEXT1 IS INITIAL .
1229         MOVE '-' TO  ZLTVAR-DSGTEXT1.
1230       ENDIF.
1231
1232       IF ZLTVAR-DSGTEXT2 IS INITIAL.
1233         MOVE '-' TO  ZLTVAR-DSGTEXT2.
1234       ENDIF.
1235
1236       IF ZLTVAR-DSGTEXT3 IS INITIAL.
1237         MOVE '-' TO  ZLTVAR-DSGTEXT3.
1238       ENDIF.
1239
1240       IF ZLTVAR-DSGTEXT4 IS INITIAL.
1241         MOVE '-' TO  ZLTVAR-DSGTEXT4.
1242       ENDIF.
1243       IF ZLTVAR-DSGTEXT5 IS INITIAL.
1244         MOVE '-' TO  ZLTVAR-DSGTEXT5.
1245       ENDIF.
1246
1247       IF ZLTVAR-PAYRANGE1 IS INITIAL.
1248         MOVE '-' TO  ZLTVAR-PAYRANGE1.
1249       ENDIF.
1250
1251       IF ZLTVAR-PAYRANGE2 IS INITIAL.
1252         MOVE '-' TO  ZLTVAR-PAYRANGE2.
1253       ENDIF.
1254
1255       IF ZLTVAR-PAYRANGE3 IS INITIAL.
1256         MOVE '-' TO  ZLTVAR-PAYRANGE3.
1257       ENDIF.
1258
1259       IF ZLTVAR-PAYRANGE4 IS INITIAL.
1260         MOVE '-' TO  ZLTVAR-PAYRANGE4.
1261       ENDIF.
1262
1263       IF ZLTVAR-PAYRANGE5 IS INITIAL.
1264         MOVE '-' TO  ZLTVAR-PAYRANGE5.
1265       ENDIF.
1266
1267       IF ZLTVAR-CNTRNAME IS INITIAL.
1268         MOVE '-' TO  ZLTVAR-CNTRNAME.
1269       ENDIF.
1270
1271       IF ZLTVAR-CNTRADR1 IS INITIAL.
1272         MOVE '-' TO  ZLTVAR-CNTRADR1.
1273       ENDIF.
1274
1275       IF ZLTVAR-CNTRADR2 IS INITIAL.
1276         MOVE '-' TO  ZLTVAR-CNTRADR2.
1277       ENDIF.
1278
1279       IF ZLTVAR-CNTRADR3 IS INITIAL.
1280         MOVE '-' TO  ZLTVAR-CNTRADR3.
1281       ENDIF.
1282
1283       IF ZLTVAR-CNTRSTATE IS INITIAL.
1284         MOVE '-' TO  ZLTVAR-CNTRSTATE.
1285       ENDIF.
1286
1287       IF ZLTVAR-CNTRPIN IS INITIAL.
1288         MOVE '-' TO  ZLTVAR-CNTRPIN.
1289       ENDIF.
1290
1291       IF ZLTVAR-CNTRPHONE IS INITIAL.
1292         MOVE '-' TO  ZLTVAR-CNTRPHONE.
1293       ENDIF.
1294
1295       IF ZLTVAR-CNTRNAMEWR IS INITIAL.
1296         MOVE '-' TO  ZLTVAR-CNTRNAMEWR.
1297       ENDIF.
1298
1299       IF ZLTVAR-CNTRAD1WR IS INITIAL.
1300         MOVE '-' TO  ZLTVAR-CNTRAD1WR.
1301       ENDIF.
1302
1303       IF ZLTVAR-CNTRAD2WR IS INITIAL.
1304         MOVE '-' TO  ZLTVAR-CNTRAD2WR.
1305       ENDIF.
1306
1307       IF ZLTVAR-CNTRAD3WR IS INITIAL.
1308         MOVE '-' TO  ZLTVAR-CNTRAD3WR.
1309       ENDIF.
1310
1311       IF ZLTVAR-CNTRSTWR IS INITIAL.
1312         MOVE '-' TO  ZLTVAR-CNTRSTWR.
1313       ENDIF.
1314
1315       IF ZLTVAR-CNTRPINWR IS INITIAL.
1316         MOVE '-' TO  ZLTVAR-CNTRPINWR.
1317       ENDIF.
1318
1319       IF ZLTVAR-CNTRPHWR IS INITIAL.
1320         MOVE '-' TO  ZLTVAR-CNTRPHWR.
1321       ENDIF.
1322
1323       IF ZLTVAR-NAME2 IS INITIAL.
1324         MOVE '-' TO  ZLTVAR-NAME2.
1325       ENDIF.
1326
1327       IF ZLTVAR-STRAS IS INITIAL.
1328         MOVE '-' TO  ZLTVAR-STRAS.
1329       ENDIF.
1330
1331       IF ZLTVAR-LOCAT IS INITIAL.
1332         MOVE '-' TO  ZLTVAR-LOCAT.
1333       ENDIF.
1334
1335       IF ZLTVAR-PSTLZ IS INITIAL.
1336         MOVE '-' TO  ZLTVAR-PSTLZ.
1337       ENDIF.
1338
1339       IF ZLTVAR-ORT01 IS INITIAL.
1340         MOVE '-' TO  ZLTVAR-ORT01.
1341       ENDIF.
1342
1343       IF ZLTVAR-ORT02 IS INITIAL.
1344         MOVE '-' TO  ZLTVAR-ORT02.
1345       ENDIF.
1346
1347       IF ZLTVAR-TELNR IS INITIAL.
1348         MOVE '-' TO  ZLTVAR-TELNR.
1349       ENDIF.
1350
1351       IF ZLTVAR-GPTXT IS INITIAL.
1352         MOVE '-' TO  ZLTVAR-GPTXT.
1353       ENDIF.
1354
1355       IF ZLTVAR-ZCATDS IS INITIAL.
1356         MOVE '-' TO  ZLTVAR-ZCATDS.
1357       ENDIF.
1358     ENDIF.
1359   ENDFORM.                               " FILL_LETTER_VARIABLE
1360
1361   **&---------------------------------------------------------------------
1362   *
1363   **&      Form  F4_FOR_RECRUITMENT
1364   **&---------------------------------------------------------------------
1365   *
1366   **       text
1367   **----------------------------------------------------------------------
1368   *
1369   **  -->  P_REC        text
1370   **  <--  p2        text
1371   **----------------------------------------------------------------------
1372
1373   FORM F4_FOR_RECRUITMENT USING P_REC.
1374
1375     DATA: BEGIN OF IHELP_FIELDS OCCURS 0.
1376             INCLUDE STRUCTURE HELP_VALUE.
1377     DATA: END OF IHELP_FIELDS.
1378
1379     DATA: BEGIN OF HELPTAB OCCURS 0,
1380           HELPTAB(100),
1381           END OF HELPTAB.
1382
1383     DATA: VAR_DISPLAY(1) TYPE C.
1384
1385     REFRESH IHELP_FIELDS.
1386     CLEAR IHELP_FIELDS.
1387
1388     MOVE 'ZHR_EXM_RECRUIT' TO IHELP_FIELDS-TABNAME.
1389     MOVE 'ZRECRUIT_ID' TO IHELP_FIELDS-FIELDNAME.
1390     MOVE 'X' TO IHELP_FIELDS-SELECTFLAG.
1391     APPEND IHELP_FIELDS.
1392
1393     MOVE 'ZHR_EXM_RECRUIT' TO IHELP_FIELDS-TABNAME.
1394     MOVE 'ZRECRUIT_DESC' TO IHELP_FIELDS-FIELDNAME.
1395     MOVE '' TO IHELP_FIELDS-SELECTFLAG.
1396     APPEND IHELP_FIELDS.
1397
1398     REFRESH HELPTAB.
1399     CLEAR HELPTAB.
1400
1401     SELECT * FROM ZHR_EXM_RECRUIT.
1402       MOVE  ZHR_EXM_RECRUIT-ZRECRUIT_ID TO HELPTAB.
1403       APPEND HELPTAB.
1404       MOVE  ZHR_EXM_RECRUIT-ZRECRUIT_DESC TO HELPTAB.
1405       APPEND HELPTAB.
1406     ENDSELECT.
1407
1408     LOOP AT SCREEN.
1409       CHECK SCREEN-NAME EQ 'P_REC'.
1410       IF SCREEN-INPUT EQ '1'.
1411         VAR_DISPLAY = SPACE.
1412       ELSE.
1413         VAR_DISPLAY = 'X'.
1414       ENDIF.
1415     ENDLOOP.
1416
1417   * begin of <RD1K960036>
1418   *  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
1419   *       EXPORTING
1420   *            DISPLAY                       = VAR_DISPLAY
1421   *            FIELDNAME                     = 'ZRECRUIT_ID'
1422   *            TABNAME                       = 'ZHR_EXM_RECRUIT'
1423   *            SHOW_ALL_VALUES_AT_FIRST_TIME = 'X'
1424   **            TITLE_IN_VALUES_LIST         =
1425   **            TITLE                        =
1426   *       IMPORTING
1427   *            SELECT_VALUE                  = P_REC
1428   *       TABLES
1429   *            FIELDS                        = IHELP_FIELDS
1430   *            VALUETAB                      = HELPTAB.
1431   **       EXCEPTIONS
1432   **             FIELD_NOT_IN_DDIC         = 01
1433   **             MORE_THEN_ONE_SELECTFIELD = 02
1434   **             NO_SELECTFIELD            = 03.
1435
1436       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1437         EXPORTING
1438   *       DDIC_STRUCTURE         = ' '
1439           RETFIELD               = 'ZRECRUIT_ID'
1440   *       PVALKEY                = ' '
1441           DYNPPROG               = 'ZPAP3CUS'
1442           DYNPNR                 = SY-DYNNR
1443           DYNPROFIELD            = 'P_REC'
1444   *       STEPL                  = 0
1445   *       WINDOW_TITLE           =
1446   *       VALUE                  = ' '
1447           VALUE_ORG              = 'S'
1448   *       MULTIPLE_CHOICE        = ' '
1449           DISPLAY                = VAR_DISPLAY
1450   *       CALLBACK_PROGRAM       = ' '
1451   *       CALLBACK_FORM          = ' '
1452   *       MARK_TAB               =
1453   *     IMPORTING
1454   *       USER_RESET             =
1455         TABLES
1456           VALUE_TAB              = HELPTAB
1457   *       FIELD_TAB              =
1458   *       RETURN_TAB             =
1459   *       DYNPFLD_MAPPING        =
1460        EXCEPTIONS
1461          PARAMETER_ERROR        = 1
1462          NO_VALUES_FOUND        = 2
1463          OTHERS                 = 3
1464                 .
1465       IF SY-SUBRC <> 0.
1466   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1467   *             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1468       ENDIF.
1469
1470   * end of <RD1K960036>
1471   ENDFORM.                               " F4_FOR_RECRUITMENT
*--- End of ZHR_PB_PAP3CUS - 1471 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <SYSINI>                                  Level 1    Page 3
Object           ZPAP3CUS                                  Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:16
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
