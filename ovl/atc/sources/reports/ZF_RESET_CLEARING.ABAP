----------------------------------------------------------------------------------------------------
Main program     ZF_RESET_CLEARING                         Level 0    Page 1
Object           ZF_RESET_CLEARING                         Lines 396
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:03
----------------------------------------------------------------------------------------------------
1      REPORT zf_reset_clearing MESSAGE-ID fb LINE-SIZE 132.
2
3      TABLES: bseg, bkpf, t001, bsis, bsas, bsik, bsak, bsid, bsad.
4
5      TYPES: BEGIN OF ty_bseg,
6                bukrs     LIKE bseg-bukrs,
7                belnr     LIKE bseg-belnr,
8                gjahr     LIKE bseg-gjahr,
9                buzei     LIKE bseg-buzei,
10               augbl     LIKE bseg-augbl,
11               augdt     LIKE bseg-augdt,
12               augbl_new LIKE bseg-augbl,
13               augdt_new LIKE bseg-augdt,
14               xarch     LIKE bsis-xarch,
15               del_indx  TYPE char10,
16               ins_indx  TYPE char10,
17            END OF   ty_bseg.
18     DATA i_bseg TYPE ty_bseg OCCURS 0.
19     FIELD-SYMBOLS: <fs_bseg> TYPE ty_bseg.
20
21     TYPES: BEGIN OF ty_indx,
22               indx    TYPE char4,
23            END OF   ty_indx.
24     DATA w_indx TYPE ty_indx.
25     DATA t_del_indx TYPE ty_indx OCCURS 0.
26     DATA t_ins_indx TYPE ty_indx OCCURS 0.
27
28     DATA save_subrc LIKE sy-subrc.
29     DATA index_r TYPE i VALUE 0.
30     DATA index_u TYPE i VALUE 0.
31     DATA index_c TYPE i VALUE 0.
32
33
34     * User Selektion ----------------------------------------------------- *
35
36     PARAMETERS:      x_bukrs LIKE bseg-bukrs  MEMORY ID buk OBLIGATORY.
37     SELECT-OPTIONS:  x_belnr FOR bseg-belnr   MEMORY ID bln.
38     SELECT-OPTIONS:  x_gjahr FOR bseg-gjahr   MEMORY ID gjr.
39     SELECT-OPTIONS:  x_augbl FOR bseg-augbl   MEMORY ID abl.
40     SELECT-OPTIONS:  x_augdt FOR bseg-augdt   MEMORY ID adt.
41     PARAMETERS:      x_konto LIKE bseg-hkont  MEMORY ID kto OBLIGATORY.
42     PARAMETERS:      x_koart LIKE bseg-koart  MEMORY ID krt OBLIGATORY.
43     SELECTION-SCREEN SKIP.
44     PARAMETERS:     update AS CHECKBOX.
45
46     * Initialization ----------------------------------------------------- *
47     INITIALIZATION.
48
49
50     * Start-of-Selection ------------------------------------------------- *
51     START-OF-SELECTION.
52
53
54     * Definition: Datenauswahl ------------------------------------------- *
55       DEFINE select_clearing.
56         select * from &1 into corresponding fields of table i_bseg
57                                        where bukrs  = x_bukrs
58                                          and belnr in x_belnr
59                                          and gjahr in x_gjahr
60                                          and    &2  = x_konto
61                                          and augbl in x_augbl
62                                          and augdt in x_augdt.
63
64         describe table i_bseg lines index_r.
65       END-OF-DEFINITION.
66
67
68     * -------------------------------------------------------------------- *
69     *                    Beginn des Hauptprogramms                         *
70     * -------------------------------------------------------------------- *
71       SELECT SINGLE * FROM  t001 WHERE  bukrs  = x_bukrs.
72       IF sy-subrc <> 0.
73         MESSAGE e000 WITH 'Company code' x_bukrs 'does not exist'.
74       ENDIF.
75
76       IF x_koart = 'D'.
77         select_clearing bsad kunnr.  "#EC CI_FLDEXT_OK
78       ENDIF.
79
80       IF x_koart = 'K'.
81         select_clearing bsak lifnr.  "#EC CI_FLDEXT_OK
82       ENDIF.
83
84       IF x_koart CA 'MSA'.
85         select_clearing bsas hkont.  "#EC CI_FLDEXT_OK
86       ENDIF.
87
88
89       LOOP AT i_bseg ASSIGNING <fs_bseg>.
90     * Beleg archiviert ? ------------------------------------------------- *
91         CHECK <fs_bseg>-xarch = space.
92
93     * Belegzeile selektieren --------------------------------------------- *
94         SELECT SINGLE * FROM  bseg
95                WHERE  bukrs  = <fs_bseg>-bukrs
96                AND    belnr  = <fs_bseg>-belnr
97                AND    gjahr  = <fs_bseg>-gjahr
98                AND    buzei  = <fs_bseg>-buzei.
99
100        save_subrc = sy-subrc.
101
102        IF save_subrc <> 0.
103          WRITE:/ 'No bseg for', <fs_bseg>-bukrs, <fs_bseg>-belnr,
104                                 <fs_bseg>-gjahr, <fs_bseg>-buzei.
105          WRITE:/ 'Index data not changed'.
106        ENDIF.
107
108        CHECK save_subrc = 0.
109
110    * Update durchführen ------------------------------------------------- *
111        IF update = 'X'.
112          DATA save_bkpf LIKE bkpf.
113          DATA lin TYPE i.
114          REFRESH t_del_indx.
115          REFRESH t_ins_indx.
116
117    * Alten Index löschen ------------------------------------------------ *
118          PERFORM delete_old_index CHANGING save_bkpf t_del_indx.
119          DESCRIBE TABLE t_del_indx LINES lin.
120          CASE lin.
121            WHEN 0.
122    *       no index data deleted
123            WHEN 1.
124              READ TABLE t_del_indx INDEX 1 INTO w_indx.
125              WRITE w_indx TO <fs_bseg>-del_indx(5).
126            WHEN 2.
127              READ TABLE t_del_indx INDEX 1 INTO w_indx.
128              WRITE w_indx TO <fs_bseg>-del_indx(5).
129              READ TABLE t_del_indx INDEX 2 INTO w_indx.
130              WRITE w_indx TO <fs_bseg>-del_indx+5(5).
131            WHEN OTHERS.
132              <fs_bseg>-del_indx = '??????????'.
133          ENDCASE.
134
135    * BSEG korrigieren --------------------------------------------------- *
136          CLEAR bseg-augbl.
137          CLEAR bseg-augdt.
138          CLEAR bseg-augcp.
139          CLEAR <fs_bseg>-augbl_new.
140          CLEAR <fs_bseg>-augdt_new.
141
142    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
143    * S/4: BSEG clearing reset via standard posting interface (programmatic FBRA); direct UPDATE not allowed.
144    *      UPDATE bseg SET augdt = <fs_bseg>-augdt_new
145    *                      augbl = <fs_bseg>-augbl_new
146    *                      augcp = '00000000'
147    *                  WHERE  bukrs  = <fs_bseg>-bukrs
148    *                    AND  belnr  = <fs_bseg>-belnr
149    *                    AND  gjahr  = <fs_bseg>-gjahr
150    *                    AND  buzei  = <fs_bseg>-buzei.
151          IF <fs_bseg>-augbl IS NOT INITIAL.
152            CALL FUNCTION 'POSTING_INTERFACE_START' EXPORTING i_client = sy-mandt i_function = 'C'
153                 i_mode = 'N' i_update = 'S' i_user = sy-uname EXCEPTIONS OTHERS = 0.
154            CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR' EXPORTING i_bukrs = <fs_bseg>-bukrs
155                 i_augbl = <fs_bseg>-augbl i_gjahr = <fs_bseg>-gjahr i_tcode = 'FBRA' EXCEPTIONS OTHERS = 0.
156            CALL FUNCTION 'POSTING_INTERFACE_END' EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
157          ENDIF.
158    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
159
160    * Neuen Index erzeugen ----------------------------------------------- *
161          PERFORM make_new_index USING save_bkpf t_ins_indx.
162          DESCRIBE TABLE t_ins_indx LINES lin.
163          CASE lin.
164            WHEN 0.
165    *       no index data created
166            WHEN 1.
167              READ TABLE t_ins_indx INDEX 1 INTO w_indx.
168              WRITE w_indx TO <fs_bseg>-ins_indx(5).
169            WHEN 2.
170              READ TABLE t_ins_indx INDEX 1 INTO w_indx.
171              WRITE w_indx TO <fs_bseg>-ins_indx(5).
172              READ TABLE t_ins_indx INDEX 2 INTO w_indx.
173              WRITE w_indx TO <fs_bseg>-ins_indx+5(5).
174            WHEN OTHERS.
175              <fs_bseg>-ins_indx = '??????????'.
176          ENDCASE.
177
178
179          ADD 1 TO index_u.
180          ADD 1 TO index_c.
181
182          IF index_c >= 1000.
183            COMMIT WORK.
184            index_c = 0.
185          ENDIF.
186
187        ENDIF.
188
189      ENDLOOP.
190
191      IF index_c <> 0.
192        COMMIT WORK.
193      ENDIF.
194
195
196    * OUTPUT ------------------------------------------------------------- *
197      PERFORM write_output.
198
199    * -------------------------------------------------------------------- *
200    *                     Ende des Hauptprogramms                          *
201    * -------------------------------------------------------------------- *
202
203
204
205    * ---------------------------------------------------------------------*
206    * Definition: Setup der internen Tabelle der Indizes 'tab_indx'
207    * ---------------------------------------------------------------------*
208      DEFINE setup_tab_indx.
209        if &2 = 0.
210          &3 = &1.
211        else.
212          &3 = 'error'.
213        endif.
214        &2 = 0.
215      END-OF-DEFINITION.
216
217
218    * ---------------------------------------------------------------------*
219    * Definition: Eintrag in einer Indextabelle löschen
220    * ---------------------------------------------------------------------*
221      DEFINE delete_any_old_index.
222        select * from  &1
223              where  bukrs  = bseg-bukrs
224              and    &2     = bseg-&2
225              and    gjahr  = bseg-gjahr
226              and    belnr  = bseg-belnr
227              and    buzei  = bseg-buzei.
228
229          move-corresponding &1 to &3.
230          delete &1.
231          if sy-subrc <> 0.
232            add sy-subrc to &4.
233          endif.
234        endselect.
235      END-OF-DEFINITION.
236
237    *&---------------------------------------------------------------------*
238    *&      Form  DELETE_OLD_INDEX
239    *&---------------------------------------------------------------------*
240    FORM delete_old_index CHANGING p_bkpf   LIKE bkpf
241                                   tab_indx LIKE t_del_indx[].
242
243      DATA w_indx TYPE ty_indx VALUE space.
244      DATA loc_subrc LIKE sy-subrc VALUE '0'.
245
246      REFRESH tab_indx.
247
248      IF bseg-koart = 'D'.
249    *    delete_any_old_index bsad kunnr p_bkpf loc_subrc.
250        setup_tab_indx 'BSAD' loc_subrc w_indx.
251        APPEND w_indx TO tab_indx.
252      ENDIF.
253
254      IF bseg-koart = 'K'.
255    *    delete_any_old_index bsak lifnr p_bkpf loc_subrc.
256        setup_tab_indx 'BSAK' loc_subrc w_indx.
257        APPEND w_indx TO tab_indx.
258      ENDIF.
259
260      IF ( bseg-koart CA 'SM'  AND bseg-xkres = 'X' ) OR
261           ( bseg-koart CA 'DKA' AND bseg-xhres = 'X' ).
262    *    delete_any_old_index bsas hkont p_bkpf loc_subrc.
263        setup_tab_indx 'BSAS' loc_subrc w_indx.
264        APPEND w_indx TO tab_indx.
265      ENDIF.
266
267    ENDFORM.                    " DELETE_OLD_INDEX
268
269
270    * -------------------------------------------------------------------- *
271    * Definition: Neuer Eintrag in einer Indextabelle
272    * ---------------------------------------------------------------------*
273    DEFINE make_any_new_index.
274      move-corresponding &2 to &1.
275      move-corresponding bseg to &1.
276
277      if &3 = 'R'. "<-- Abstimmkonto von DKA.
278        &1-zuonr = bseg-hzuon.
279      endif.
280      insert &1.
281      if sy-subrc <> 0.
282        add sy-subrc to &4.
283      endif.
284    END-OF-DEFINITION.
285
286    *&---------------------------------------------------------------------*
287    *&      Form  MAKE_NEW_INDEX
288    *&---------------------------------------------------------------------*
289    FORM make_new_index USING p_bkpf   LIKE bkpf
290                              tab_indx LIKE t_ins_indx[].
291    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
292
293      DATA w_indx TYPE ty_indx VALUE space.
294      DATA loc_subrc LIKE sy-subrc VALUE '0'.
295
296      REFRESH tab_indx.
297
298      IF bseg-koart = 'D'.
299        IF bseg-augbl IS INITIAL.
300    *      make_any_new_index bsid p_bkpf 'A' loc_subrc.
301          setup_tab_indx 'BSID' loc_subrc w_indx.
302          APPEND w_indx TO tab_indx.
303          IF bseg-xhres = 'X'.
304    *        make_any_new_index bsis p_bkpf 'R' loc_subrc.
305            setup_tab_indx 'BSIS' loc_subrc w_indx.
306            APPEND w_indx TO tab_indx.
307          ENDIF.
308        ELSE.
309    *      make_any_new_index bsad p_bkpf 'A' loc_subrc.
310          setup_tab_indx 'BSAD' loc_subrc w_indx.
311          APPEND w_indx TO tab_indx.
312          IF bseg-xhres = 'X'.
313    *        make_any_new_index bsas p_bkpf 'R' loc_subrc.
314            setup_tab_indx 'BSAS' loc_subrc w_indx.
315            APPEND w_indx TO tab_indx.
316          ENDIF.
317        ENDIF.
318      ENDIF.
319
320      IF bseg-koart = 'K'.
321        IF bseg-augbl IS INITIAL.
322    *      make_any_new_index bsik p_bkpf 'A' loc_subrc.
323          setup_tab_indx 'BSIK' loc_subrc w_indx.
324          APPEND w_indx TO tab_indx.
325          IF bseg-xhres = 'X'.
326    *        make_any_new_index bsis p_bkpf 'R' loc_subrc.
327            setup_tab_indx 'BSIS' loc_subrc w_indx.
328            APPEND w_indx TO tab_indx.
329          ENDIF.
330        ELSE.
331    *      make_any_new_index bsak p_bkpf 'A' loc_subrc.
332          setup_tab_indx 'BSAK' loc_subrc w_indx.
333          APPEND w_indx TO tab_indx.
334          IF bseg-xhres = 'X'.
335    *        make_any_new_index bsas p_bkpf 'R' loc_subrc.
336            setup_tab_indx 'BSAS' loc_subrc w_indx.
337            APPEND w_indx TO tab_indx.
338          ENDIF.
339        ENDIF.
340      ENDIF.
341
342      IF ( bseg-koart CA 'SM' AND bseg-xkres = 'X' ).
343        IF bseg-augbl IS INITIAL.
344    *      make_any_new_index bsis p_bkpf 'A' loc_subrc.
345          setup_tab_indx 'BSIS' loc_subrc w_indx.
346          APPEND w_indx TO tab_indx.
347        ELSE.
348    *      make_any_new_index bsas p_bkpf 'A' loc_subrc.
349          setup_tab_indx 'BSAS' loc_subrc w_indx.
350          APPEND w_indx TO tab_indx.
351        ENDIF.
352      ENDIF.
353    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
354    ENDFORM.                    " MAKE_NEW_INDEX
355
356
357    *&---------------------------------------------------------------------*
358    *&      Form WRITE_OUTPUT
359    *&---------------------------------------------------------------------*
360    FORM write_output.
361      SKIP.
362
363      FORMAT COLOR COL_HEADING.
364
365      WRITE: /(5) 'BUKRS',  (5) 'GJAHR', (11) 'BELNR',      (5) 'BUZEI',
366              (5) 'KOART', (11) 'ACCNT', (11) 'AUGDT_OLD', (11) 'AUGBL_OLD',
367             (11) 'AUGDT_NEW', (11) 'AUGBL_NEW', (5) 'XARCH',
368             (11) 'OLD_INDEX', (11) 'NEW_INDEX'.
369      SKIP.
370
371      FORMAT COLOR OFF.
372
373      LOOP AT i_bseg ASSIGNING <fs_bseg>.
374        WRITE: /(5) <fs_bseg>-bukrs,
375                (5) <fs_bseg>-gjahr,
376               (11) <fs_bseg>-belnr,
377                (5) <fs_bseg>-buzei,
378                (5) x_koart,
379               (11) x_konto,
380               (11) <fs_bseg>-augdt,
381               (11) <fs_bseg>-augbl,
382               (11) <fs_bseg>-augdt_new,
383               (11) <fs_bseg>-augbl_new,
384                (5) <fs_bseg>-xarch,
385               (11) <fs_bseg>-del_indx,
386               (11) <fs_bseg>-ins_indx.
387      ENDLOOP.
388
389      SKIP.
390      FORMAT COLOR COL_KEY.
391      WRITE : / index_r, 'Document lines found  '.
392      WRITE : / index_u, 'Document lines updated'.
393      FORMAT COLOR COL_NORMAL.
394
395      SKIP.
396    ENDFORM.                    " WRITE_OUTPUT
*--- End of ZF_RESET_CLEARING - 396 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZF_RESET_CLEARING                         Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:03
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
Object           ZF_RESET_CLEARING                         Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:03
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
Object           ZF_RESET_CLEARING                         Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:03
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
Object           ZF_RESET_CLEARING                         Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:03
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
