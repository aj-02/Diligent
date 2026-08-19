----------------------------------------------------------------------------------------------------
Main program     ZFI_RFSEPA03                              Level 0    Page 1
Object           ZFI_RFSEPA03                              Lines 394
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      * THIS IS NOT A STANDARD PROGRAM.
3      * IT IS ONLY INCLUDED FOR CONVENIENCE IN CASE IT WILL BE NEEDED.
4      * ONLY USE IT AFTER CONSULTING WITH SAP.
5      *----------------------------------------------------------------------*
6      REPORT ZFI_RFSEPA03 MESSAGE-ID FH LINE-SIZE 80.
7
8      INCLUDE FSACHCDF.
9      INCLUDE FSACHCDV.
10
11     TABLES: BSIS,
12             BSEG,
13             T001.
14
15     DATA: BEGIN OF T_BSIS OCCURS 100.
16             INCLUDE STRUCTURE BSIS.
17     DATA: END OF T_BSIS.
18
19     DATA: BEGIN OF T_LISTE OCCURS 300,
20             GJAHR    LIKE BKPF-GJAHR,
21             BELNR    LIKE BKPF-BELNR,
22             SORT     TYPE I,
23             TABLE(4) TYPE C,
24             TYPE     TYPE C,
25             OK       TYPE C,
26           END OF T_LISTE.
27
28     DATA: D_MAX         LIKE SY-TFILL VALUE '100',
29           D_BELNR       LIKE BSEG-BELNR.
30
31     DATA: NUM_BSEG_SELECT LIKE SY-TFILL,
32           NUM_BSEG_UPDATE LIKE SY-TFILL,
33           NUM_BSIS_INSERT LIKE SY-TFILL,
34           NUM_BSIS_SELECT LIKE SY-TFILL,
35           NUM_BSIS_UPDATE LIKE SY-TFILL,
36           NUM_BSAS_INSERT LIKE SY-TFILL,
37           NUM_BSAS_SELECT LIKE SY-TFILL,
38           NUM_BSAS_UPDATE LIKE SY-TFILL.
39
40     CONSTANTS: CHAR_I     TYPE C VALUE 'I',
41                CHAR_S     TYPE C VALUE 'S',
42                CHAR_U     TYPE C VALUE 'U'.
43
44     *-----------------------------------------------------------------------
45
46     *PARAMETER:     P_BUKRS  LIKE BSEG-BUKRS OBLIGATORY.
47                                            "<<<< DELETE NOTE - 62751
48     *PARAMETER:     P_SAKNR  LIKE BSEG-HKONT OBLIGATORY.
49                                            "<<<< DELETE NOTE - 62751
50     *>>>> BEGIN OF INSERTION - NOTE 62751 <<<<
51     PARAMETERS:     P_BUKRS  LIKE BKPF-BUKRS OBLIGATORY.
52     PARAMETERS:     P_SAKNR  LIKE SKA1-SAKNR OBLIGATORY
53                                       MATCHCODE OBJECT SAKO.
54     *>>>> END OF INSERTION - NOTE 62751 <<<<
55
56     SELECT-OPTIONS P_BELNR  FOR  BSEG-BELNR.
57
58     SELECTION-SCREEN SKIP 1.
59     SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.
60     PARAMETERS:    P_LISTE AS CHECKBOX DEFAULT 'X'.    " Protokoll
61     SELECTION-SCREEN END OF BLOCK B01.
62
63     *-----------------------------------------------------------------------
64     INITIALIZATION.
65       CALL FUNCTION 'POPUP_DISPLAY_TEXT'
66            EXPORTING
67                 POPUP_TITLE    = ' '
68                 TEXT_OBJECT    = 'RFSEPA03'.
69
70     *  LEAVE PROGRAM.
71
72     AT SELECTION-SCREEN ON P_SAKNR.
73       PERFORM CHECK_ACCOUNT.               " locked for posting?
74       PERFORM CHECK_ACCOUNT3.              "<<<< INSERT - NOTE 66156
75     * PERFORM ENQUEUE_ACCOUNT.             "<<<< DELETE - NOTE 65191
76
77     *-----------------------------------------------------------------------
78
79     START-OF-SELECTION.
80       PERFORM ENQUEUE_ACCOUNT.             "<<<< INSERT - NOTE 65191
81       PERFORM CHECK_AUTHORITY_SKA1_BUK.
82       PERFORM CHECK_AUTHORITY_SKA1_BES.
83       PERFORM READ_T001 USING P_BUKRS.
84     *--- BSIS --------------------------------------------------------------
85       DO.
86         PERFORM SELECT_ITEMS USING SY-TFILL.
87         IF SY-TFILL EQ 0.
88           EXIT.
89         ENDIF.
90         LOOP AT T_BSIS.
91           PERFORM BSEG_UPDATE.
92           PERFORM BSIS_UPDATE.
93         ENDLOOP.
94         PERFORM WRITE_LIST_PROTOCOL.
95         COMMIT WORK.
96       ENDDO.
97
98       PERFORM WRITE_PROTOCOL.
99     *-----------------------------------------------------------------------
100    END-OF-SELECTION.
101      PERFORM CHANGE_ACCOUNT.
102      PERFORM DEQUEUE_ACCOUNT.
103
104    *-----------------------------------------------------------------------
105    TOP-OF-PAGE.
106      ULINE.
107      WRITE:/   SY-VLINE,
108             2  TEXT-001,
109             25 P_SAKNR INTENSIFIED OFF,
110             80 SY-VLINE.
111      WRITE:/   SY-VLINE,
112             2  TEXT-002,
113             25 P_BUKRS INTENSIFIED OFF,
114             80 SY-VLINE.
115      ULINE.
116      IF P_LISTE = 'X'.
117        WRITE:/          SY-VLINE,
118                  2(10)  TEXT-S01 COLOR COL_HEADING,
119                  12     SY-VLINE,
120                  13(4)  TEXT-S02 COLOR COL_HEADING,
121                  17     SY-VLINE,
122                  18(62) TEXT-S03 COLOR COL_HEADING,
123                  80     SY-VLINE.
124      ENDIF.
125
126    *&---------------------------------------------------------------------*
127    *&      Form  READ_T001
128    *&---------------------------------------------------------------------*
129    FORM READ_T001 USING BUKRS LIKE T001-BUKRS.
130      SELECT SINGLE * FROM T001 WHERE BUKRS = BUKRS.
131      IF SY-SUBRC <> 0.
132        MESSAGE E001 WITH BUKRS.
133      ENDIF.
134    ENDFORM.                               " READ_T001
135
136    *&---------------------------------------------------------------------*
137    *&      Form  SELECT_ITEMS
138    *&---------------------------------------------------------------------*
139    FORM SELECT_ITEMS USING FILL LIKE SY-TFILL.
140      SELECT * FROM BSIS INTO TABLE T_BSIS
141    *                      UP TO D_MAX ROWS
142                        WHERE BUKRS EQ P_BUKRS
143                          AND HKONT EQ P_SAKNR
144                          AND BELNR IN P_BELNR
145                          AND XOPVW EQ 'X'.
146      FILL = SY-DBCNT.
147    *--- PROTOCOL ----------------------------------------------------------
148      LOOP AT T_BSIS.
149        PERFORM SAVE_PROTOCOL USING T_BSIS-BELNR T_BSIS-GJAHR
150                                    1 'BSIS' CHAR_S 1.
151      ENDLOOP.
152
153      SORT T_BSIS BY MANDT BUKRS BELNR GJAHR.
154
155    ENDFORM.                               " SELECT_ITEMS
156
157    *&---------------------------------------------------------------------*
158    *&      Form  BSEG_UPDATE
159    *&---------------------------------------------------------------------*
160    FORM BSEG_UPDATE.
161      SELECT SINGLE * FROM BSEG WHERE BUKRS = T_BSIS-BUKRS
162                                AND   GJAHR = T_BSIS-GJAHR
163                                AND   BELNR = T_BSIS-BELNR
164                                AND   BUZEI = T_BSIS-BUZEI.
165      IF BSEG-KTOSL = 'SKV' OR BSEG-KTOSL = 'WVW' OR BSEG-KTOSL = 'SGA'.
166         MESSAGE A147.
167      ENDIF.
168    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
169    * S/4: XOPVW (open item mgmt) cannot be changed by direct update in S/4HANA - use FINS_SWITCH_TO_OPEN_ITEM (Note 2745769).
170    *  UPDATE BSEG SET XOPVW = SPACE
171    *            WHERE BUKRS EQ T_BSIS-BUKRS
172    *              AND GJAHR EQ T_BSIS-GJAHR
173    *              AND BELNR EQ T_BSIS-BELNR
174    *              AND BUZEI EQ T_BSIS-BUZEI.
175      MESSAGE 'Document not updated. Open item mgmt (XOPVW) change not possible in S/4HANA - use FINS_SWITCH_TO_OPEN_ITEM. Refer SAP Note 2745769' TYPE 'E'.
176    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
177    *--- PROTOCOL ----------------------------------------------------------
178      PERFORM SAVE_PROTOCOL USING T_BSIS-BELNR T_BSIS-GJAHR
179                                  2 'BSEG' CHAR_U SY-DBCNT.
180    ENDFORM.                               " BSEG_UPDATE
181
182    *&---------------------------------------------------------------------*
183    *&      Form  BSIS_UPDATE
184    *&---------------------------------------------------------------------*
185    FORM BSIS_UPDATE.
186      T_BSIS-XOPVW = SPACE.
187    *  UPDATE BSIS FROM T_BSIS.
188    *--- PROTOCOL -------------------------------------------
189      PERFORM SAVE_PROTOCOL USING T_BSIS-BELNR T_BSIS-GJAHR
190                                  1 'BSIS' CHAR_U SY-DBCNT.
191    ENDFORM.                               " BSIS_UPDATE
192
193
194
195    *&---------------------------------------------------------------------*
196    *&      Form  CHANGE_ACCOUNT
197    *&---------------------------------------------------------------------*
198    FORM CHANGE_ACCOUNT.
199
200      SKB1       = *SKB1.
201      SKB1-XOPVW = SPACE.
202
203      OBJECTID    = T001-KTOPL.
204      OBJECTID+4  = SKB1-SAKNR.
205      OBJECTID+14 = SKB1-BUKRS.
206      UPD_SKB1    = 'U'.
207      UTIME       = SY-UZEIT.
208      UDATE       = SY-DATUM.
209      USERNAME    = SY-UNAME.
210      PERFORM CD_CALL_SACH.
211      CALL FUNCTION 'GL_ACCOUNT_IN_COMPANY_UPDATE'
212           EXPORTING
213                I_SKB1 = SKB1.
214      COMMIT WORK.
215
216    ENDFORM.                               " CHANGE_ACCOUNT
217
218    *&---------------------------------------------------------------------*
219    *&      Form  ENQUEUE_ACCOUNT
220    *&---------------------------------------------------------------------*
221    FORM ENQUEUE_ACCOUNT.
222      CALL FUNCTION 'ENQUEUE_EFSKB1'
223           EXPORTING
224                BUKRS          = P_BUKRS
225                SAKNR          = P_SAKNR
226           EXCEPTIONS
227                FOREIGN_LOCK   = 1
228                SYSTEM_FAILURE = 2.
229      CASE SY-SUBRC.
230        WHEN 1.
231          MESSAGE E042 WITH P_SAKNR P_BUKRS.
232        WHEN 2.
233          MESSAGE E038 WITH P_SAKNR P_BUKRS.
234      ENDCASE.
235    ENDFORM.                               " ENQUEUE_ACCOUNT
236
237    *&---------------------------------------------------------------------*
238    *&      Form  DEQUEUE_ACCOUNT
239    *&---------------------------------------------------------------------*
240    FORM DEQUEUE_ACCOUNT.
241      CALL FUNCTION 'DEQUEUE_EFSKB1'
242           EXPORTING
243                BUKRS          = P_BUKRS
244                SAKNR          = P_SAKNR.
245    ENDFORM.                               " DEQUEUE_ACCOUNT
246
247    *---------------------------------------------------------------------*
248    *       FORM WRITE_LIST_PROTOCOL
249    *---------------------------------------------------------------------*
250    *       writes list protocol                                          *
251    *---------------------------------------------------------------------*
252    FORM WRITE_LIST_PROTOCOL.
253
254      DATA: TEXT(62)   TYPE C.
255
256      DATA: SAVE_BELNR LIKE BKPF-BELNR.
257
258      DESCRIBE TABLE T_LISTE LINES SY-TFILL.
259      CHECK P_LISTE = 'X'.
260      CHECK SY-TFILL > 0.
261
262      SORT T_LISTE BY GJAHR BELNR SORT TYPE.
263
264      LOOP AT T_LISTE.
265        CHECK T_LISTE-OK = 1.
266        CASE T_LISTE-TABLE.
267          WHEN 'BSEG'.
268            CASE T_LISTE-TYPE.
269              WHEN CHAR_S.
270                TEXT = TEXT-BE1.
271              WHEN CHAR_U.
272                TEXT = TEXT-BE2.
273            ENDCASE.
274          WHEN 'BSIS'.
275            CASE T_LISTE-TYPE.
276              WHEN CHAR_S.
277                TEXT = TEXT-XX1.
278                REPLACE '&TAB' WITH T_LISTE-TABLE INTO TEXT.
279              WHEN CHAR_U.
280                TEXT = TEXT-XX2.
281                REPLACE '&TAB' WITH T_LISTE-TABLE INTO TEXT.
282              WHEN CHAR_I.
283                TEXT = TEXT-XX3.
284                REPLACE '&TAB' WITH T_LISTE-TABLE INTO TEXT.
285            ENDCASE.
286        ENDCASE.
287
288        AT NEW BELNR.
289          ULINE.
290          WRITE:/       SY-VLINE,
291                  2     T_LISTE-BELNR COLOR COL_KEY,
292                  12    SY-VLINE,
293                  13    T_LISTE-GJAHR COLOR COL_KEY,
294                  17    SY-VLINE.
295        ENDAT.
296
297        IF SAVE_BELNR <> T_LISTE-BELNR.
298          WRITE: 18(62) TEXT COLOR COL_NORMAL INTENSIFIED OFF,
299                    80  SY-VLINE.
300          SAVE_BELNR = T_LISTE-BELNR.
301        ELSE.
302          WRITE:/       SY-VLINE,
303                 12     SY-VLINE,
304                 17     SY-VLINE,
305                 18(62) TEXT COLOR COL_NORMAL INTENSIFIED OFF,
306                 80     SY-VLINE.
307        ENDIF.
308
309      ENDLOOP.
310      ULINE.
311
312    ENDFORM.                               " WRITE_LIST_PROTOCOL
313
314    *---------------------------------------------------------------------*
315    *       FORM WRITE_PROTOCOL                                           *
316    *---------------------------------------------------------------------*
317    *    writes normal protocol                                           *
318    *---------------------------------------------------------------------*
319    FORM WRITE_PROTOCOL.
320
321    *- selected items-----
322      IF NOT ( NUM_BSIS_SELECT = 0  ).
323        WRITE:/        SY-VLINE,
324                2(58)  TEXT-NX1 COLOR COL_KEY INTENSIFIED ON,
325                60(1)  SY-VLINE,
326                61(19) NUM_BSIS_SELECT COLOR COL_NORMAL INTENSIFIED OFF,
327                80     SY-VLINE.
328      ENDIF.
329      IF NOT ( NUM_BSEG_SELECT = 0 ).
330        WRITE:/       SY-VLINE,
331                2(58) TEXT-NB1 COLOR COL_KEY INTENSIFIED ON,
332                60(1)  SY-VLINE,
333                61(19) NUM_BSEG_SELECT COLOR COL_NORMAL INTENSIFIED OFF,
334                80     SY-VLINE.
335      ENDIF.
336    *- changed items-----
337      IF NUM_BSIS_UPDATE > 0.
338        WRITE:/        SY-VLINE,
339                 2(58) TEXT-NX2 COLOR COL_KEY INTENSIFIED ON,
340                60(1)  SY-VLINE,
341                61(19) NUM_BSIS_UPDATE COLOR COL_NORMAL INTENSIFIED OFF,
342                80     SY-VLINE.
343      ENDIF.
344      IF NUM_BSEG_UPDATE > 0.
345        WRITE:/        SY-VLINE,
346                 2(58) TEXT-NB2 COLOR COL_KEY INTENSIFIED ON,
347                60(1)  SY-VLINE,
348                61(19) NUM_BSEG_UPDATE COLOR COL_NORMAL INTENSIFIED OFF,
349                80     SY-VLINE.
350      ENDIF.
351
352      ULINE.
353
354      ADD NUM_BSIS_SELECT TO NUM_BSAS_SELECT.
355      IF NUM_BSAS_SELECT = 0.
356        ULINE.
357        WRITE:/       SY-VLINE,
358                2(78) TEXT-NSB COLOR COL_NEGATIVE,
359                80    SY-VLINE.
360        ULINE.
361      ENDIF.
362
363    ENDFORM.
364
365    INCLUDE FSACHCDC.
366    INCLUDE EPA00F00.
367
368    *>>>> BEGIN OF INSERTION - NOTE 66156
369    *&---------------------------------------------------------------------*
370    *&      Form  CHECK_ACCOUNT3
371    *&---------------------------------------------------------------------*
372    FORM CHECK_ACCOUNT3.
373      TABLES: T030.
374    * Belege schon archiviert?
375      SELECT * FROM BSIS WHERE BUKRS EQ P_BUKRS
376                         AND   HKONT EQ P_SAKNR
377                         AND   XARCH EQ 'X'.
378        MESSAGE E146.
379    *    Es sind schon Belege archiviert worden. Änderung ist nicht möglich
380      ENDSELECT.
381
382    * Keine Bankverrechnungskonten
383      SELECT * FROM T030  WHERE KTOPL = T001-KTOPL
384                            AND  ( KTOSL = 'SKV' OR
385                                   KTOSL = 'WVW' OR
386                                   KTOSL = 'SGA' ).  "#EC CI_NOORDER
387        IF T030-KONTS = P_SAKNR OR T030-KONTH = P_SAKNR.
388          MESSAGE E147.
389    *     Konto kann nicht geändert werden -> Langtext
390        ENDIF.
391      ENDSELECT.
392    ENDFORM.                               " CHECK_ACCOUNT3
393
394    *>>>> END OF INSERTION - NOTE 66156 <<<<
*--- End of ZFI_RFSEPA03 - 394 lines ---

----------------------------------------------------------------------------------------------------
Include          FSACHCDF                                  Level 1    Page 2
Object           ZFI_RFSEPA03                              Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
----------------------------------------------------------------------------------------------------
1      DATA: OBJECTID                TYPE CDHDR-OBJECTID,
2            TCODE                   TYPE CDHDR-TCODE,
3            PLANNED_CHANGE_NUMBER   TYPE CDHDR-PLANCHNGNR,
4            UTIME                   TYPE CDHDR-UTIME,
5            UDATE                   TYPE CDHDR-UDATE,
6            USERNAME                TYPE CDHDR-USERNAME,
7            CDOC_PLANNED_OR_REAL    TYPE CDHDR-CHANGE_IND,
8            CDOC_UPD_OBJECT         TYPE CDHDR-CHANGE_IND VALUE 'U',
9            CDOC_NO_CHANGE_POINTERS TYPE CDHDR-CHANGE_IND.
10
*--- End of FSACHCDF - 10 lines ---

----------------------------------------------------------------------------------------------------
Include          FSACHCDV                                  Level 1    Page 3
Object           ZFI_RFSEPA03                              Lines 54
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
----------------------------------------------------------------------------------------------------
1      * declaration for the long text
2      DATA: BEGIN OF ICDTXT_SACH OCCURS 20.
3              INCLUDE STRUCTURE CDTXT.
4      DATA: END OF ICDTXT_SACH.
5      DATA: UPD_ICDTXT_SACH TYPE C.
6
7      * workaera_old of PSM_D_GLACCTX
8      TABLES: *PSM_D_GLACCTX
9      * workaera_new of PSM_D_GLACCTX
10            , PSM_D_GLACCTX.
11     DATA: UPD_PSM_D_GLACCTX TYPE C.
12
13     * workaera_old of SKA1
14     TABLES: *SKA1
15     * workaera_new of SKA1
16            , SKA1.
17     DATA: UPD_SKA1 TYPE C.
18
19     * workaera_old of SKAD
20     TABLES: *SKAD
21     * workaera_new of SKAD
22            , SKAD.
23     DATA: UPD_SKAD TYPE C.
24
25     * table with the NEW content of: SKAT
26     DATA: BEGIN OF XSKAT OCCURS 20.
27             INCLUDE STRUCTURE FSKAT.
28     DATA: END OF XSKAT.
29
30     * table with the OLD content of: SKAT
31     DATA: BEGIN OF YSKAT OCCURS 20.
32             INCLUDE STRUCTURE FSKAT.
33     DATA: END OF YSKAT.
34
35     DATA: UPD_SKAT TYPE C.
36
37     * workaera_old of SKA_IMST
38     TABLES: *SKA_IMST
39     * workaera_new of SKA_IMST
40            , SKA_IMST.
41     DATA: UPD_SKA_IMST TYPE C.
42
43     * workaera_old of SKB1
44     TABLES: *SKB1
45     * workaera_new of SKB1
46            , SKB1.
47     DATA: UPD_SKB1 TYPE C.
48
49     * workaera_old of SKB_IMST
50     TABLES: *SKB_IMST
51     * workaera_new of SKB_IMST
52            , SKB_IMST.
53     DATA: UPD_SKB_IMST TYPE C.
54
*--- End of FSACHCDV - 54 lines ---

----------------------------------------------------------------------------------------------------
Include          FSACHCDC                                  Level 1    Page 4
Object           ZFI_RFSEPA03                              Lines 91
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
----------------------------------------------------------------------------------------------------
1      FORM CD_CALL_SACH.
2        IF   ( UPD_PSM_D_GLACCTX NE SPACE )
3          OR ( UPD_SKA1 NE SPACE )
4          OR ( UPD_SKAD NE SPACE )
5          OR ( UPD_SKAT NE SPACE )
6          OR ( UPD_SKA_IMST NE SPACE )
7          OR ( UPD_SKB1 NE SPACE )
8          OR ( UPD_SKB_IMST NE SPACE )
9          OR ( UPD_ICDTXT_SACH NE SPACE )
10       .
11         CALL FUNCTION 'SACH_WRITE_DOCUMENT' IN UPDATE TASK
12             EXPORTING
13               OBJECTID                = OBJECTID
14               TCODE                   = TCODE
15               UTIME                   = UTIME
16               UDATE                   = UDATE
17               USERNAME                = USERNAME
18               PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
19               OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
20               PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
21               NO_CHANGE_POINTERS      = CDOC_NO_CHANGE_POINTERS
22     * workarea_old of PSM_D_GLACCTX
23               O_PSM_D_GLACCTX
24                           = *PSM_D_GLACCTX
25     * workarea_new of PSM_D_GLACCTX
26               N_PSM_D_GLACCTX
27                           = PSM_D_GLACCTX
28     * updateflag of PSM_D_GLACCTX
29               UPD_PSM_D_GLACCTX
30                           = UPD_PSM_D_GLACCTX
31     * workarea_old of SKA1
32               O_SKA1
33                           = *SKA1
34     * workarea_new of SKA1
35               N_SKA1
36                           = SKA1
37     * updateflag of SKA1
38               UPD_SKA1
39                           = UPD_SKA1
40     * workarea_old of SKAD
41               O_SKAD
42                           = *SKAD
43     * workarea_new of SKAD
44               N_SKAD
45                           = SKAD
46     * updateflag of SKAD
47               UPD_SKAD
48                           = UPD_SKAD
49     * updateflag of SKAT
50               UPD_SKAT
51                           = UPD_SKAT
52     * workarea_old of SKA_IMST
53               O_SKA_IMST
54                           = *SKA_IMST
55     * workarea_new of SKA_IMST
56               N_SKA_IMST
57                           = SKA_IMST
58     * updateflag of SKA_IMST
59               UPD_SKA_IMST
60                           = UPD_SKA_IMST
61     * workarea_old of SKB1
62               O_SKB1
63                           = *SKB1
64     * workarea_new of SKB1
65               N_SKB1
66                           = SKB1
67     * updateflag of SKB1
68               UPD_SKB1
69                           = UPD_SKB1
70     * workarea_old of SKB_IMST
71               O_SKB_IMST
72                           = *SKB_IMST
73     * workarea_new of SKB_IMST
74               N_SKB_IMST
75                           = SKB_IMST
76     * updateflag of SKB_IMST
77               UPD_SKB_IMST
78                           = UPD_SKB_IMST
79               UPD_ICDTXT_SACH
80                           = UPD_ICDTXT_SACH
81             TABLES
82               ICDTXT_SACH
83                           = ICDTXT_SACH
84               XSKAT
85                           = XSKAT
86               YSKAT
87                           = YSKAT
88         .
89       ENDIF.
90       CLEAR PLANNED_CHANGE_NUMBER.
91     ENDFORM.
*--- End of FSACHCDC - 91 lines ---

----------------------------------------------------------------------------------------------------
Include          EPA00F00                                  Level 1    Page 5
Object           ZFI_RFSEPA03                              Lines 152
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  P30K102051 / NOTE - 65205  RFSEPA02: Prüfung Konto nicht vollständig
3      *  P30K125324 / NOTE - 65877  RFSEPA01: Prüfung Konto zu stark
4      *  ALRK036824 / Erweiterung von CHECK_ACCOUNT für RFSEPA04
5      ************************************************************************
6
7      *-------------------------------------------------------------------
8      ***INCLUDE EPA00F00 .
9      *-------------------------------------------------------------------
10     *&---------------------------------------------------------------------*
11     *&      Form  CHECK_AUTHORITY_SKA1_BUK
12     *&---------------------------------------------------------------------*
13     *       Check Authority for BUKRS                                      *
14     *----------------------------------------------------------------------*
15     FORM CHECK_AUTHORITY_SKA1_BUK.
16
17       AUTHORITY-CHECK OBJECT 'F_SKA1_BUK'
18         ID 'BUKRS' FIELD P_BUKRS
19         ID 'ACTVT' FIELD '02'.
20       IF SY-SUBRC <> 0.
21         MESSAGE E113 WITH P_BUKRS.
22       ENDIF.
23     ENDFORM.                               " CHECK_AUTHORITY_SKA1_BUK
24
25     *&---------------------------------------------------------------------*
26     *&      Form  CHECK_AUTHORITY_SKA1_BES
27     *&---------------------------------------------------------------------*
28     *       Check authority for BEGRU
29     *----------------------------------------------------------------------*
30     FORM CHECK_AUTHORITY_SKA1_BES.
31
32       IF SKB1-BEGRU <> SPACE.
33
34         AUTHORITY-CHECK OBJECT 'F_SKA1_BES'
35           ID 'BRGRU' FIELD SKB1-BEGRU
36           ID 'ACTVT' FIELD '02'.
37
38         IF SY-SUBRC <> 0.
39           MESSAGE E119.
40         ENDIF.
41       ENDIF.
42
43     ENDFORM.                               " CHECK_AUTHORITY_SKA1_BES
44
45     *&---------------------------------------------------------------------*
46     *&      Form  CHECK_ACCOUNT
47     *&---------------------------------------------------------------------*
48     FORM CHECK_ACCOUNT.
49
50       SELECT SINGLE * FROM T001
51              WHERE BUKRS = P_BUKRS.
52
53       SELECT SINGLE * FROM SKA1
54              WHERE KTOPL = T001-KTOPL
55                AND SAKNR = P_SAKNR.
56       IF SY-SUBRC NE 0.
57         MESSAGE E004(FH) WITH P_SAKNR T001-KTOPL.
58     *   Konto & im Kontenplan & nicht vorgesehen
59       ENDIF.
60
61       SELECT SINGLE * FROM SKB1 INTO *SKB1
62              WHERE  BUKRS       = P_BUKRS
63              AND    SAKNR       = P_SAKNR.
64       IF SY-SUBRC NE 0.
65         MESSAGE E005 WITH P_SAKNR P_BUKRS.
66     *   Konto & im Buchungskreis & nicht vorgesehen
67       ENDIF.
68
69     * all other checks are not relevant for RFSEPA04
70       CHECK SY-REPID NE 'RFSEPA04'.
71
72       IF *SKB1-XSPEB EQ SPACE AND SKA1-XSPEB EQ SPACE.
73         MESSAGE E134 WITH P_SAKNR.
74     *   Konto & ist nicht zum Buchen gesperrt. -> Langtext
75       ENDIF.
76       SKB1 = *SKB1.
77
78       CHECK SY-REPID = 'RFSEPA02'.        "<<<< INSERT - NOTE 0065877
79
80     *>>>> BEGIN OF INSERTION - NOTE 65205 <<<<
81     *------------------OP-Verwaltung nicht bei Kursdifferenzschlüssel ----*
82       IF SKB1-KDFSL NE SPACE.
83         MESSAGE E141.
84     *   Konto enthält Kursdifferenzschlüssel. OP-Verwaltung ist nicht vorge
85       ENDIF.
86     *------------------OP-Verwaltung nur bei Bilanzkonten-----------------*
87       IF SKA1-XBILK = SPACE.
88         MESSAGE E017.
89     *   OP-Verwaltung nur für Bestandskonten erlaubt
90       ENDIF.
91     *------------------Mitbuchkonto kann nicht offene Posten sein --------*
92       IF SKB1-MITKZ <> SPACE.
93         MESSAGE E031.
94     *   Offene Postenverwaltung bei Abstimmkonto nicht vorgesehen
95       ENDIF.
96     *------------------OP-Verwaltung muß immer EP-Verwaltung haben -------*
97       IF SKB1-XKRES = SPACE.
98         MESSAGE E106.
99     *   Offene-Posten-Verwaltung nur bei Einzelpostenanzeige vorgesehen
100      ENDIF.
101
102    *>>>> END OF INSERTION - NOTE 65205 <<<<
103    ENDFORM.                               " CHECK_ACCOUNT
104
105    *&---------------------------------------------------------------------*
106    *&      Form  SAVE_PROTOCOL
107    *&---------------------------------------------------------------------*
108    FORM SAVE_PROTOCOL USING BELNR     LIKE BKPF-BELNR
109                             GJAHR     LIKE BKPF-GJAHR
110                             SORT      TYPE N
111                             TABNAME   TYPE C
112                             TYPCHANGE TYPE C
113                             DBCNR     LIKE SY-TFILL.
114      IF P_LISTE = 'X'.
115        T_LISTE-GJAHR = GJAHR.
116        T_LISTE-BELNR = BELNR.
117        T_LISTE-SORT  = SORT.
118        T_LISTE-TABLE = TABNAME.
119        T_LISTE-TYPE  = TYPCHANGE.
120        T_LISTE-OK    = DBCNR.
121        APPEND T_LISTE.
122      ENDIF.
123      IF DBCNR = 1.
124        CASE TABNAME.
125          WHEN 'BSEG'.
126            CASE TYPCHANGE.
127              WHEN 'U'.
128                ADD 1 TO NUM_BSEG_UPDATE.
129              WHEN 'S'.
130                ADD 1 TO NUM_BSEG_SELECT.
131            ENDCASE.
132          WHEN 'BSIS'.
133            CASE TYPCHANGE.
134              WHEN CHAR_I.
135                ADD 1 TO NUM_BSIS_INSERT.
136              WHEN CHAR_U.
137                ADD 1 TO NUM_BSIS_UPDATE.
138              WHEN CHAR_S.
139                ADD 1 TO NUM_BSIS_SELECT.
140            ENDCASE.
141          WHEN 'BSAS'.
142            CASE TYPCHANGE.
143              WHEN CHAR_I.
144                ADD 1 TO NUM_BSAS_INSERT.
145              WHEN CHAR_U.
146                ADD 1 TO NUM_BSAS_UPDATE.
147              WHEN CHAR_S.
148                ADD 1 TO NUM_BSAS_SELECT.
149            ENDCASE.
150        ENDCASE.
151      ENDIF.
152    ENDFORM.                               " SAVE_PROTOCOL
*--- End of EPA00F00 - 152 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 6
Object           ZFI_RFSEPA03                              Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
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
Generated incl.  <SYSINI>                                  Level 1    Page 7
Object           ZFI_RFSEPA03                              Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
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
Generated incl.  <SYSSEL>                                  Level 1    Page 8
Object           ZFI_RFSEPA03                              Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
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
Generated incl.  DB__SSEL                                  Level 1    Page 9
Object           ZFI_RFSEPA03                              Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 10
Object           ZFI_RFSEPA03                              Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:32
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
