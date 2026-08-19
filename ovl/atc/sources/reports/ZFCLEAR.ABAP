----------------------------------------------------------------------------------------------------
Main program     ZFCLEAR                                   Level 0    Page 1
Object           ZFCLEAR                                   Lines 295
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:41
----------------------------------------------------------------------------------------------------
1          REPORT zfclear  MESSAGE-ID fb LINE-SIZE 132.
2          TABLES: bsis, bsas, bseg, bkpf, t001, bsik, bsak, bsid, bsad.
3          DATA: expert.
4          SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
5            PARAMETERS: p_bukrs LIKE bseg-bukrs MEMORY ID buk,
6                        p_belnr LIKE bseg-belnr MEMORY ID bln,
7                        p_gjahr LIKE bseg-gjahr MEMORY ID gjr,
8      *                p_buzei LIKE bseg-buzei OBLIGATORY.
9                        p_buzei LIKE bseg-buzei.
10           SELECTION-SCREEN SKIP.
11           PARAMETERS: p_augbl LIKE bseg-augbl,
12                       p_augdt LIKE bseg-augdt.
13           SELECTION-SCREEN SKIP.
14         SELECTION-SCREEN END OF BLOCK 001.
15
16         SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME.
17           PARAMETERS: p_echtl AS CHECKBOX MODIF ID inc.
18         SELECTION-SCREEN END OF BLOCK 002.
19
20         START-OF-SELECTION.
21     *     * konsistente Ausgleichsinformation ?
22           IF ( p_augbl IS INITIAL AND NOT p_augdt IS INITIAL ) OR
23
24
25              ( NOT p_augbl IS INITIAL AND p_augdt IS INITIAL ).
26             MESSAGE e000 WITH 'p_augbl and p_augdt must be both init or both set'.
27           ENDIF.
28
29     *     * gibts den buchungskreis
30           SELECT SINGLE * FROM  t001 WHERE  bukrs  = p_bukrs.
31           IF sy-subrc <> 0.
32             MESSAGE e000 WITH 'Companycode' p_bukrs 'does not exist'.
33           ENDIF.
34
35     *     * gibts den Kopf zu der zu ändernden bseg-zeile
36           SELECT SINGLE * FROM  bkpf
37                  WHERE  bukrs  = t001-bukrs
38                  AND    belnr  = p_belnr
39                  AND    gjahr  = p_gjahr.
40           IF sy-subrc <> 0.
41             MESSAGE e000 WITH p_bukrs p_belnr p_gjahr 'no header'.
42           ENDIF.
43
44     *     * gibts die zu ändernde Belegzeile
45           SELECT SINGLE * FROM  bseg
46                  WHERE  bukrs  = bkpf-bukrs
47                  AND    belnr  = bkpf-belnr
48                  AND    gjahr  = bkpf-gjahr
49                  AND    buzei  = p_buzei.
50           IF sy-subrc <> 0.
51             MESSAGE e000 WITH p_belnr p_buzei 'no such line'.
52           ENDIF.
53     *     * Koart 'M' kann nicht ausgeglichen werden
54           IF bseg-koart = 'M' AND NOT p_augbl IS INITIAL.
55             MESSAGE e000 WITH 'Material accounts cannot be cleared'.
56           ENDIF.
57     *     * Keine OPVW der Zeile der Anlagenzeile ?
58           IF bseg-koart = 'A' AND NOT p_augbl IS INITIAL AND NOT bseg-xhres = 'X'.
59             MESSAGE e000 WITH 'Line item not OI managed, clearing not possible'.
60           ENDIF.
61
62     *     * Keine OPVW der Zeile der Sachkontenzeile ?
63           IF bseg-koart = 'S' AND NOT p_augbl IS INITIAL AND NOT bseg-xopvw = 'X'.
64             MESSAGE e000 WITH 'Line item not OI managed, clearing not possible'.
65           ENDIF.
66
67
68
69
70     **----------------------------------------------------------------------
71     *
72     *     *       ab hier ist die Belegselektion abgeschlossen
73     *     *
74     *
75     **----------------------------------------------------------------------
76     *
77
78           WRITE: / bseg-bukrs COLOR COL_KEY,
79                    bseg-belnr COLOR COL_KEY,
80                    bseg-gjahr COLOR COL_KEY,
81                    bseg-buzei COLOR COL_KEY,
82                    bseg-bschl COLOR COL_NORMAL,
83                    bseg-koart COLOR COL_NORMAL,
84                    bseg-shkzg COLOR COL_NORMAL,
85                    bseg-dmbtr COLOR COL_NORMAL.  "#EC CI_FLDEXT_OK[2610650]
86           WRITE :/3(13) 'before update' COLOR COL_NORMAL,
87                    bseg-augdt COLOR COL_POSITIVE,
88                    bseg-augbl COLOR COL_POSITIVE.
89     *-------------------------------------------------------------------- *
90     *     *          neue Ausgleichsinformation in bseg stellen.
91     *     *
92     *     *
93     *-------------------------------------------------------------------- *
94
95           WRITE :/3(13) 'after update' COLOR COL_NORMAL,
96                    p_augdt COLOR COL_POSITIVE,
97                    p_augbl COLOR COL_POSITIVE.
98           SKIP.
99           IF p_echtl = 'X'.
100    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
101    * S/4: BSEG-AUGBL/AUGDT/AUGCP (clearing fields) may be changed only by SAP standard programs.
102    *      Direct UPDATE bseg is not allowed in S/4HANA - universal journal ACDOCA must stay in sync.
103    *      Reset clearing via the standard posting interface (programmatic FBRA). Old code retained:
104            DATA: lv_augbl_old TYPE bseg-augbl.
105            lv_augbl_old = bseg-augbl.            " current clearing document (capture before reset)
106    *        PERFORM delete_old_index.          "<-- Löschen des Index
107    *        bseg-augdt = p_augdt.
108    *        bseg-augcp = p_augdt.
109    *        bseg-augbl = p_augbl.
110    *        PERFORM make_new_index.            "<-- Neu erezugen
111    *        UPDATE bseg.                       "<-- Bseg updaten
112            IF lv_augbl_old IS NOT INITIAL.
113              CALL FUNCTION 'POSTING_INTERFACE_START'
114                EXPORTING i_client = sy-mandt i_function = 'C' i_mode = 'N'
115                          i_update = 'S' i_user = sy-uname
116                EXCEPTIONS OTHERS = 0.
117              CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR'
118                EXPORTING i_bukrs = bseg-bukrs i_augbl = lv_augbl_old
119                          i_gjahr = bseg-gjahr i_tcode = 'FBRA'
120                EXCEPTIONS OTHERS = 0.
121              CALL FUNCTION 'POSTING_INTERFACE_END'
122                EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
123            ENDIF.
124    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
125          ENDIF.
126    *-------------------------------------------------------------------- *
127    *     *                     Ende des Hauptprogramms
128    *     *
129    *     *
130    *-------------------------------------------------------------------- *
131    *
132    *     *
133    *-------------------------------------------------------------------- *
134    *     *                Neuerzeugen einer Indextabelle
135    *     *
136    *     *
137    *-------------------------------------------------------------------- *
138          DEFINE make_any_new_index.
139
140            MOVE-CORRESPONDING bkpf TO &1.
141            MOVE-CORRESPONDING bseg TO &1.
142
143            IF &2 CA 'R'.                      "<-- Abstimmkonto von DKA.
144              &1-zuonr = bseg-hzuon.
145            ENDIF.
146
147            INSERT &1.
148            WRITE:/3 'Insert' COLOR COL_NORMAL,
149                     '&1' COLOR COL_NORMAL,
150                     'sy-subrc =' COLOR COL_NORMAL NO-GAP,
151                     sy-subrc COLOR COL_NORMAL NO-GAP.
152          END-OF-DEFINITION.
153    *     *
154    *-------------------------------------------------------------------- *
155    *     *               Löschen in einer Indextabelle Hauptbuch
156    *     *
157    *     *
158    *-------------------------------------------------------------------- *
159
160          DEFINE delete_any_old_index_nb.
161            DELETE FROM  &1
162            WHERE  bukrs  = bseg-bukrs
163            AND    &2     = bseg-&2
164            AND    umsks  = bseg-umsks
165            AND    umskz  = bseg-umskz
166            AND    augbl  = bseg-augbl
167            AND    augdt  = bseg-augdt
168            AND    zuonr  = bseg-zuonr
169            AND    gjahr  = bseg-gjahr
170            AND    belnr  = bseg-belnr
171            AND    buzei  = bseg-buzei.
172            WRITE :/3 'Delete' COLOR COL_NORMAL,
173                      '&1' COLOR COL_NORMAL,
174                      'sy-subrc =' COLOR COL_NORMAL NO-GAP,
175
176                      sy-subrc COLOR COL_NORMAL,
177                      'sy-dbcnt =' COLOR COL_NORMAL NO-GAP,
178                      sy-dbcnt COLOR COL_NORMAL.
179          END-OF-DEFINITION.
180
181    *     *
182    *-------------------------------------------------------------------- *
183    *     *               Löschen in einer Indextabelle Nebenbuch
184    *     *
185    *     *
186    *-------------------------------------------------------------------- *
187
188          DEFINE delete_any_old_index_sako.
189            DELETE FROM  &1
190            WHERE  bukrs  = bseg-bukrs
191            AND    hkont  = bseg-hkont
192            AND    augdt  = bseg-augdt
193            AND    augbl  = bseg-augbl
194            AND    zuonr  = bseg-&2
195            AND    gjahr  = bseg-gjahr
196            AND    belnr  = bseg-belnr
197            AND    buzei  = bseg-buzei.
198            WRITE :/3 'Delete' COLOR COL_NORMAL,
199                      '&1' COLOR COL_NORMAL,
200                      'sy-subrc =' COLOR COL_NORMAL NO-GAP,
201                       sy-subrc COLOR COL_NORMAL,
202                      'sy-dbcnt =' COLOR COL_NORMAL NO-GAP,
203                      sy-dbcnt COLOR COL_NORMAL.
204          END-OF-DEFINITION.
205
206    **&---------------------------------------------------------------------
207    *
208    *     *&      Form  DELETE_OLD_INDEX
209    *
210    **&---------------------------------------------------------------------
211    *
212        FORM delete_old_index.
213          IF ( bseg-koart CA 'SM' AND bseg-xkres = 'X' ) OR
214             ( bseg-koart CA 'DKA' AND bseg-xhres = 'X' ).
215            IF Bseg-koart CA 'DKA'.
216    *          delete_any_old_index_sako bsis hzuon.
217    *          delete_any_old_index_sako bsas hzuon.
218            ELSE.
219    *          delete_any_old_index_sako bsis zuonr.
220    *          delete_any_old_index_sako bsas zuonr.
221            ENDIF.
222          ENDIF.
223          IF bseg-koart = 'D'.
224    *        delete_any_old_index_nb bsid kunnr.
225    *        delete_any_old_index_nb bsad kunnr.
226          ENDIF.
227          IF bseg-koart = 'K'.
228    *        delete_any_old_index_nb bsik lifnr.
229    *        delete_any_old_index_nb bsak lifnr.
230          ENDIF.
231        ENDFORM.                               " DELETE_OLD_INDEX
232
233
234    *&---------------------------------------------------------------------*
235    *     *&      Form  MAKE_NEW_INDEX
236
237    *&---------------------------------------------------------------------*
238
239        FORM make_new_index.
240
241
242          DATA: tabs(4) TYPE c,
243                tabd(4) TYPE c,
244                tabk(4) TYPE c.
245
246          IF   ( bseg-koart CA 'DKA' AND bseg-xhres = 'X' ).
247            IF bseg-augbl IS INITIAL.
248    *          make_any_new_index bsis 'R'.     "R = Abstimmkonto
249            ELSE.
250    *          make_any_new_index bsas 'R'.     "R = Abstimmkonto
251            ENDIF.
252          ENDIF.
253
254          IF ( bseg-koart CA 'SM' AND bseg-xkres = 'X' ).
255            IF bseg-augbl IS INITIAL.
256    *          make_any_new_index bsis 'N'.     "N = Normal
257            ELSE.
258    *          make_any_new_index bsas 'N'.     "N = Normal
259            ENDIF.
260          ENDIF.
261          IF bseg-koart CA 'D'.
262            IF bseg-augbl IS INITIAL.
263    *          make_any_new_index bsid 'N'.     "N = Normal
264            ELSE.
265    *          make_any_new_index bsad 'N'.     "N = Normal
266            ENDIF.
267          ENDIF.
268
269          IF bseg-koart = 'K'.
270            IF bseg-augbl = space.
271    *          make_any_new_index bsik 'N'.     "N = Normal
272            ELSE.
273    *          make_any_new_index bsak 'N'.     "N = Normal
274            ENDIF.
275
276          ENDIF.
277        ENDFORM.                               " MAKE_NEW_INDEX
278
279        AT SELECTION-SCREEN.
280          IF sy-ucomm EQ 'XXPM'. expert = 'X'. ENDIF.
281
282        AT SELECTION-SCREEN OUTPUT.
283          CLEAR p_echtl.
284          LOOP AT SCREEN.
285            IF screen-group1 = 'INC'.
286              IF expert = 'X'.
287                screen-invisible = 0.
288              ELSE.
289                screen-invisible = 1.
290              ENDIF.
291              MODIFY SCREEN.
292            ENDIF.
293          ENDLOOP.
294
295    *     *>>>> END OF INSERTION <<<<<<
*--- End of ZFCLEAR - 295 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZFCLEAR                                   Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:41
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
Object           ZFCLEAR                                   Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:41
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
Object           ZFCLEAR                                   Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:41
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
Object           ZFCLEAR                                   Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:41
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
