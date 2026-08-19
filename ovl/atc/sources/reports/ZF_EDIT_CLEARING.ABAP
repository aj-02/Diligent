----------------------------------------------------------------------------------------------------
Main program     ZF_EDIT_CLEARING                          Level 0    Page 1
Object           ZF_EDIT_CLEARING                          Lines 215
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:58
----------------------------------------------------------------------------------------------------
1
2      REPORT ZF_EDIT_CLEARING  MESSAGE-ID FB LINE-SIZE 132.
3
4      ************************************************************************
5      * This program is not intended to run DIRECTLY. This program is used
6      * to clear entries in FI related tables.
7      * DO NOT EXECUTE THIS PROGRAM.
8      ************************************************************************
9      TABLES: BSIS, BSAS, BSEG, BKPF, T001, BSIK, BSAK, BSID, BSAD.
10     SELECTION-SCREEN BEGIN OF BLOCK 001.
11     PARAMETERS: P_BUKRS LIKE BSEG-BUKRS MEMORY ID BUK,
12                 P_BELNR LIKE BSEG-BELNR MEMORY ID BLN,
13                 P_GJAHR LIKE BSEG-GJAHR MEMORY ID GJR,
14                 P_BUZEI LIKE BSEG-BUZEI OBLIGATORY.
15     SELECTION-SCREEN SKIP.
16     PARAMETERS:  P_AUGBL LIKE BSEG-AUGBL,
17                  P_AUGDT LIKE BSEG-AUGDT.
18     SELECTION-SCREEN SKIP.
19     PARAMETERS: P_ECHTL AS CHECKBOX.
20     SELECTION-SCREEN END OF BLOCK 001.
21     * konsistente Ausgleichsinformation ?
22     IF ( P_AUGBL IS INITIAL AND NOT P_AUGDT IS INITIAL ) OR
23        ( NOT P_AUGBL IS INITIAL AND P_AUGDT IS INITIAL ).
24       MESSAGE E000 WITH 'p_augbl and p_augdt must be both init or both set'.
25     ENDIF.
26
27     * gibts den buchungskreis
28     SELECT SINGLE * FROM  T001 WHERE  BUKRS  = P_BUKRS.
29     IF SY-SUBRC <> 0.
30       MESSAGE E000 WITH 'Companycode' P_BUKRS 'does not exist'.
31     ENDIF.
32
33     * gibts den Kopf zu der zu ändernden bseg-zeile
34     SELECT SINGLE * FROM  BKPF
35            WHERE  BUKRS  = T001-BUKRS
36            AND    BELNR  = P_BELNR
37            AND    GJAHR  = P_GJAHR.
38     IF SY-SUBRC <> 0.
39       MESSAGE E000 WITH P_BUKRS P_BELNR P_GJAHR 'no header'.
40     ENDIF.
41
42     * gibts die zu ändernde Belegzeile
43     SELECT SINGLE * FROM  BSEG
44            WHERE  BUKRS  = BKPF-BUKRS
45            AND    BELNR  = BKPF-BELNR
46            AND    GJAHR  = BKPF-GJAHR
47            AND    BUZEI  = P_BUZEI.
48     IF SY-SUBRC <> 0.
49       MESSAGE E000 WITH P_BELNR P_BUZEI 'no such line'.
50     ENDIF.
51     * Koart 'M' kann nicht ausgeglichen werden
52     IF BSEG-KOART = 'M' AND NOT P_AUGBL IS INITIAL.
53       MESSAGE E000 WITH 'Material accounts cannot be cleared'.
54     ENDIF.
55     * Keine OPVW der Zeile der Anlagenzeile ?
56     IF BSEG-KOART = 'A' AND NOT P_AUGBL IS INITIAL AND NOT BSEG-XHRES = 'X'.
57       MESSAGE E000 WITH 'Line item not OI managed, clearing not possible'.
58     ENDIF.
59
60     * Keine OPVW der Zeile der Sachkontenzeile ?
61     IF BSEG-KOART = 'S' AND NOT P_AUGBL IS INITIAL AND NOT BSEG-XOPVW = 'X'.
62       MESSAGE E000 WITH 'Line item not OI managed, clearing not possible'.
63     ENDIF.
64
65
66
67     *----------------------------------------------------------------------*
68     *       ab hier ist die Belegselektion abgeschlossen                   *
69     *----------------------------------------------------------------------*
70
71     WRITE: / BSEG-BUKRS COLOR COL_KEY,
72              BSEG-BELNR COLOR COL_KEY,
73              BSEG-GJAHR COLOR COL_KEY,
74              BSEG-BUZEI COLOR COL_KEY,
75              BSEG-BSCHL COLOR COL_NORMAL,
76              BSEG-KOART COLOR COL_NORMAL,
77              BSEG-SHKZG COLOR COL_NORMAL,
78              BSEG-DMBTR COLOR COL_NORMAL.  "#EC CI_FLDEXT_OK[2610650]
79     WRITE :/3(13) 'before update' COLOR COL_NORMAL,
80              BSEG-AUGDT COLOR COL_POSITIVE,
81              BSEG-AUGBL COLOR COL_POSITIVE.
82     * -------------------------------------------------------------------- *
83     *          neue Ausgleichsinformation in bseg stellen.                 *
84     * -------------------------------------------------------------------- *
85
86     WRITE :/3(13) 'after update' COLOR COL_NORMAL,
87              P_AUGDT COLOR COL_POSITIVE,
88              P_AUGBL COLOR COL_POSITIVE.
89              SKIP.
90     IF P_ECHTL = 'X'.
91     " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
92     * S/4: BSEG clearing fields may be changed only by SAP standard programs; direct UPDATE not allowed.
93     *      Reset clearing via the standard posting interface (programmatic FBRA). Old code retained:
94       DATA: lv_augbl_old TYPE bseg-augbl.
95       lv_augbl_old = bseg-augbl.
96     *  PERFORM DELETE_OLD_INDEX. "<-- Löschen des Index
97     *  BSEG-AUGDT = P_AUGDT.
98     *  BSEG-AUGCP = P_AUGDT.
99     *  BSEG-AUGBL = P_AUGBL.
100    *  PERFORM MAKE_NEW_INDEX.   "<-- Neu erezugen
101    *  UPDATE BSEG.              "<-- Bseg updaten
102      IF lv_augbl_old IS NOT INITIAL.
103        CALL FUNCTION 'POSTING_INTERFACE_START' EXPORTING i_client = sy-mandt i_function = 'C'
104             i_mode = 'N' i_update = 'S' i_user = sy-uname EXCEPTIONS OTHERS = 0.
105        CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR' EXPORTING i_bukrs = bseg-bukrs
106             i_augbl = lv_augbl_old i_gjahr = bseg-gjahr i_tcode = 'FBRA' EXCEPTIONS OTHERS = 0.
107        CALL FUNCTION 'POSTING_INTERFACE_END' EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
108      ENDIF.
109    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
110    ENDIF.
111    * -------------------------------------------------------------------- *
112    *                     Ende des Hauptprogramms                          *
113    * -------------------------------------------------------------------- *
114
115    * -------------------------------------------------------------------- *
116    *                Neuerzeugen einer Indextabelle                        *
117    * -------------------------------------------------------------------- *
118    DEFINE MAKE_ANY_NEW_INDEX.
119
120      MOVE-CORRESPONDING BKPF TO &1.
121      MOVE-CORRESPONDING BSEG TO &1.
122
123      IF &2 CA 'R'. "<-- Abstimmkonto von DKA.
124       &1-ZUONR = BSEG-HZUON.
125      ENDIF.
126
127      INSERT &1.
128      WRITE:/3 'Insert' COLOR COL_NORMAL,
129               '&1' COLOR COL_NORMAL,
130               'sy-subrc =' COLOR COL_NORMAL NO-GAP,
131               SY-SUBRC COLOR COL_NORMAL NO-GAP.
132    END-OF-DEFINITION.
133    * -------------------------------------------------------------------- *
134    *               Löschen in einer Indextabelle                          *
135    * -------------------------------------------------------------------- *
136
137    DEFINE DELETE_ANY_OLD_INDEX.
138           DELETE FROM  &1
139           WHERE  BUKRS  = BSEG-BUKRS
140           AND    &2  = BSEG-&2
141           AND    GJAHR  = BSEG-GJAHR
142           AND    BELNR  = BSEG-BELNR
143           AND    BUZEI  = BSEG-BUZEI.
144       WRITE :/3 'Delete' COLOR COL_NORMAL,
145                 '&1' COLOR COL_NORMAL,
146                 'sy-subrc =' COLOR COL_NORMAL NO-GAP,
147                  SY-SUBRC COLOR COL_NORMAL,
148                 'sy-dbcnt =' COLOR COL_NORMAL NO-GAP,
149                 SY-DBCNT COLOR COL_NORMAL.
150    END-OF-DEFINITION.
151
152
153    *&---------------------------------------------------------------------*
154    *&      Form  DELETE_OLD_INDEX
155    *&---------------------------------------------------------------------*
156    FORM DELETE_OLD_INDEX.
157    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
158
159    IF ( BSEG-KOART CA 'SM' AND BSEG-XKRES = 'X' ) OR
160       ( BSEG-KOART CA 'DKA' AND BSEG-XHRES = 'X' ).
161    *   DELETE_ANY_OLD_INDEX BSIS HKONT.
162    *   DELETE_ANY_OLD_INDEX BSAS HKONT.
163    ENDIF.
164    IF BSEG-KOART = 'D'.
165    *   DELETE_ANY_OLD_INDEX BSID KUNNR.
166    *   DELETE_ANY_OLD_INDEX BSAD KUNNR.
167    ENDIF.
168    IF BSEG-KOART = 'K'.
169    *   DELETE_ANY_OLD_INDEX BSIK LIFNR.
170    *   DELETE_ANY_OLD_INDEX BSAK LIFNR.
171    ENDIF.
172    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
173    ENDFORM.                    " DELETE_OLD_INDEX
174
175    *&---------------------------------------------------------------------*
176    *&      Form  MAKE_NEW_INDEX
177    *&---------------------------------------------------------------------*
178
179    FORM MAKE_NEW_INDEX.
180    DATA: TABS(4) TYPE C,
181          TABD(4) TYPE C,
182          TABK(4) TYPE C.
183
184    IF   ( BSEG-KOART CA 'DKA' AND BSEG-XHRES = 'X' ).
185       IF BSEG-AUGBL IS INITIAL.
186    *       MAKE_ANY_NEW_INDEX BSIS 'R'. "R = Abstimmkonto
187       ELSE.
188    *       MAKE_ANY_NEW_INDEX BSAS 'R'. "R = Abstimmkonto
189       ENDIF.
190    ENDIF.
191
192    IF ( BSEG-KOART CA 'SM' AND BSEG-XKRES = 'X' ).
193       IF BSEG-AUGBL IS INITIAL.
194    *       MAKE_ANY_NEW_INDEX BSIS 'N'.  "N = Normal
195       ELSE.
196    *       MAKE_ANY_NEW_INDEX BSAS 'N'.  "N = Normal
197       ENDIF.
198    ENDIF.
199    IF BSEG-KOART CA 'D'.
200       IF BSEG-AUGBL IS INITIAL.
201    *      MAKE_ANY_NEW_INDEX BSID 'N'. "N = Normal
202       ELSE.
203    *      MAKE_ANY_NEW_INDEX BSAD 'N'. "N = Normal
204       ENDIF.
205    ENDIF.
206
207    IF BSEG-KOART = 'K'.
208       IF BSEG-AUGBL = SPACE.
209    *      MAKE_ANY_NEW_INDEX BSIK 'N'. "N = Normal
210       ELSE.
211    *      MAKE_ANY_NEW_INDEX BSAK 'N'. "N = Normal
212       ENDIF.
213
214    ENDIF.
215    ENDFORM.                    " MAKE_NEW_INDEX
*--- End of ZF_EDIT_CLEARING - 215 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZF_EDIT_CLEARING                          Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:58
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
Generated incl.  <SYSINI>                                  Level 1    Page 3
Object           ZF_EDIT_CLEARING                          Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:58
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
Generated incl.  <SYSSEL>                                  Level 1    Page 4
Object           ZF_EDIT_CLEARING                          Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:58
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
Generated incl.  DB__SSEL                                  Level 1    Page 5
Object           ZF_EDIT_CLEARING                          Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:58
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
