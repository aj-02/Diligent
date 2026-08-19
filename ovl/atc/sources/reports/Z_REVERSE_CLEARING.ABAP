----------------------------------------------------------------------------------------------------
Main program     Z_REVERSE_CLEARING                        Level 0    Page 1
Object           Z_REVERSE_CLEARING                        Lines 416
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:36
----------------------------------------------------------------------------------------------------
1       REPORT Z_REVERSE_CLEARING.
2      * This report can be used to reverse big clearing documents
3      * for G/L accounts, vendor or customer accounts if
4      * transaction FBRA fails.
5      * The clearing information is deleted in BSEG and the
6      * index tables are actualized.
7
8           tables: bsis, bsas,
9                   bsik, bsak,
10                  bsid, bsad,
11                  bkpf,
12                  bseg.
13
14          selection-screen begin of block 001 with frame title text-001.
15          parameters: p_bukrs like bseg-bukrs obligatory,
16                      p_accnt like bseg-hkont obligatory,
17                      p_augdt like bseg-augdt obligatory,
18                      p_augbl like bseg-augbl obligatory,
19                      p_umsks like bseg-umsks,
20                      p_umskz like bseg-umskz.
21          selection-screen end of block 001.
22
23          selection-screen begin of block 002 with frame title text-002.
24          parameters: gl_doc radiobutton group 0001,
25                      ap_doc radiobutton group 0001,
26                      ar_doc radiobutton group 0001.
27          selection-screen end of block 002.
28
29
30          data: i_bsas  like bsas occurs 40000 with header line,
31                i_bsak  like bsak occurs 40000 with header line,
32                i_bsad  like bsad occurs 40000 with header line,
33                wa_bsis like bsis,
34                wa_bsik like bsik,
35                wa_bsid like bsid,
36                wa_bseg like bseg.
37
38          data: commit_counter type i,
39                n type i.
40
41          constants threashold type i value 100.
42
43     * define initial variables to initialize clearing information
44          data: init_augcp like bseg-augcp,
45                init_augdt like bseg-augdt,
46                init_augbl like bseg-augbl.
47
48
49
50     *---------------------------------------------------------------------*
51     *       main                                                          *
52     *---------------------------------------------------------------------*
53          if gl_doc = 'X'.  perform gl_reverse.  endif.
54          if ap_doc = 'X'.  perform ap_reverse.  endif.
55          if ar_doc = 'X'.  perform ar_reverse.  endif.
56
57
58
59
60
61     *---------------------------------------------------------------------*
62     *       FORM gl_reverse                                               *
63     *---------------------------------------------------------------------*
64          form gl_reverse.
65     * copy all cleared line items into internal table I_BSAS
66            select * from bsas into table i_bsas where bukrs = p_bukrs
67                                                 and   hkont = p_accnt
68                                                 and   augdt = p_augdt
69                                                 and   augbl = p_augbl.
70
71            commit_counter = 0.
72            loop at i_bsas.
73              add 1 to commit_counter.
74     * reset clearing information in BSEG line item
75              update bseg set augcp = init_augcp
76                              augdt = init_augdt
77                              augbl = init_augbl
78                        where bukrs = i_bsas-bukrs
79                        and   belnr = i_bsas-belnr
80                        and   gjahr = i_bsas-gjahr
81                        and   buzei = i_bsas-buzei.
82              perform check_result_gl using sy-subrc i_bsas 1.
83     * insert a new open item line into BSIS
84              wa_bsis = i_bsas.
85              wa_bsis-augbl = init_augbl.
86              wa_bsis-augdt = init_augdt.
87     *         insert bsis from wa_bsis.
88              perform check_result_gl using sy-subrc i_bsas 2.
89     * delete the cleared item line out of BSAS
90     *         delete bsas from i_bsas.
91              perform check_result_gl using sy-subrc i_bsas 3.
92     * perform a commit beyond a given threashold
93              n = commit_counter mod threashold.
94              if n = 0.
95                CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
96                     EXPORTING
97                          TEXT = commit_counter.
98                call function 'DB_COMMIT'.
99              endif.
100           endloop.
101         endform.                               "G/L reverse
102
103
104    *---------------------------------------------------------------------*
105    *       FORM check_result_gl                                          *
106    *---------------------------------------------------------------------*
107    * describes the reaction for a failed UPDATE, INSERT or DELETE
108    * for G/L clearings
109         form check_result_gl using subrc key like bsas msg type i.
110           if subrc ne 0.
111             write: / 'Data base action failed with', key-bukrs,
112                                                      key-belnr,
113                                                      key-gjahr,
114                                                      key-buzei.
115             case msg.
116               when 1.  message a005(FI) with 'BSEG' key-belnr. "#EC MG_PAR_CNT.
117               when 2.  message a004(FI) with 'BSIS' key-belnr. "#EC MG_PAR_CNT
118               when 3.  message a006(FI) with 'BSAS' key-belnr. "#EC MG_PAR_CNT
119             endcase.
120           endif.
121         endform.
122
123
124    *---------------------------------------------------------------------*
125    *       FORM ap_reverse                                               *
126    *---------------------------------------------------------------------*
127         form ap_reverse.
128    * copy all cleared line items into internal table I_BSAK
129           select * from bsak into table i_bsak where bukrs = p_bukrs
130                                                and   lifnr = p_accnt
131                                                and   augdt = p_augdt
132                                                and   augbl = p_augbl
133                                                and   umsks = p_umsks
134                                                and   umskz = p_umskz.
135           commit_counter = 0.
136           loop at i_bsak.
137             add 1 to commit_counter.
138
139
140    * check, if reconciliation account is single item managed
141    *   first read document line item information
142             select single * from bseg into wa_bseg where
143                                   bukrs = i_bsak-bukrs and
144                                   belnr = i_bsak-belnr and
145                                   gjahr = i_bsak-gjahr and
146                                   buzei = i_bsak-buzei.
147             perform check_result_ap using sy-subrc i_bsak 1.
148             If wa_bseg-xhres = 'X'.
149    *     read BSAS entry regarding to vendor line item
150               select single * from bsas into i_bsas where
151                               bukrs = wa_bseg-bukrs and
152                               hkont = wa_bseg-hkont and
153                               augdt = wa_bseg-augdt and
154                               augbl = wa_bseg-augbl and
155                               zuonr = wa_bseg-hzuon and
156                               gjahr = wa_bseg-gjahr and
157                               belnr = wa_bseg-belnr and
158                               buzei = wa_bseg-buzei.
159               perform check_result_ap using sy-subrc i_bsak 1.
160    *     create a new BSIS entry
161               move i_bsas to wa_bsis.
162               wa_bsis-augbl = init_augbl.
163               wa_bsis-augdt = init_augdt.
164    *           insert bsis from wa_bsis.
165               perform check_result_gl using sy-subrc i_bsas 2.
166    *     delete the BSAS entry
167    *           delete bsas from i_bsas .
168               perform check_result_gl using sy-subrc i_bsas 3.
169             endif.
170
171    * check, if the cleared document was posted net
172    * if so, reset clearing information in SKV line items and
173    * restore BSIS / delete BSAS
174             if ( i_bsak-xnetb = 'X' ) or ( i_bsak-augbl = i_bsak-belnr ).
175               perform reverse_skv_ap using i_bsak.
176             endif.
177
178    * handle vendor line item
179    * reset clearing information in BSEG line item
180             wa_bseg-augcp = init_augcp.
181             wa_bseg-augdt = init_augdt.
182             wa_bseg-augbl = init_augbl.
183             update bseg from wa_bseg.
184             perform check_result_ap using sy-subrc i_bsak 1.
185    * insert a new open item line into BSIK
186             wa_bsik = i_bsak.
187             wa_bsik-augbl = init_augbl.
188             wa_bsik-augdt = init_augdt.
189    *         insert bsik from wa_bsik.
190             perform check_result_ap using sy-subrc i_bsak 2.
191    * delete the cleared item line out of BSAK
192    *         delete bsak from i_bsak.
193             perform check_result_ap using sy-subrc i_bsak 3.
194    * perform a commit beyond a given threashold
195             n = commit_counter mod threashold.
196             if n = 0.
197               CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
198                    EXPORTING
199                         TEXT = commit_counter.
200               call function 'DB_COMMIT'.
201             endif.
202           endloop.
203         endform.                               "AP reverse
204
205
206    *---------------------------------------------------------------------*
207    *       FORM reverse_skv_ap                                           *
208    *---------------------------------------------------------------------*
209    * reset clearing information in SKV document line items and
210    * restore BSIS / delete BSAS
211         form reverse_skv_ap using key like bsak.
212           data: iwa_bsis like bsis,
213                 iwa_bsas like bsas.
214           select * from bseg where bukrs = key-bukrs
215                              and   belnr = key-belnr
216                              and   gjahr = key-gjahr
217                              and   ktosl = 'SKV'.
218    *   read BSAS entry
219             select single * from bsas into iwa_bsas
220                                                where bukrs = bseg-bukrs
221                                                and   hkont = bseg-hkont
222                                                and   augdt = bseg-augdt
223                                                and   augbl = bseg-augbl
224                                                and   zuonr = bseg-zuonr
225                                                and   gjahr = bseg-gjahr
226                                                and   belnr = bseg-belnr
227                                                and   buzei = bseg-buzei.
228             perform check_result_ap using sy-subrc key 1.
229    *   create a new BSIS entry
230             move iwa_bsas to iwa_bsis.
231             iwa_bsis-augbl = init_augbl.
232             iwa_bsis-augdt = init_augdt.
233    *         insert bsis from iwa_bsis.
234             perform check_result_gl using sy-subrc iwa_bsas 2.
235    *   delete the BSAS entry
236    *         delete bsas from iwa_bsas.
237             perform check_result_gl using sy-subrc iwa_bsas 3.
238    *   reset clearing information in BSEG
239             bseg-augcp = init_augcp.
240             bseg-augdt = init_augdt.
241             bseg-augbl = init_augbl.
242             update bseg.
243             perform check_result_ap using sy-subrc key 1.
244           endselect.
245         endform.                               "reverse_SKV_AP
246
247
248
249
250    *---------------------------------------------------------------------*
251    *       FORM check_result_ap                                          *
252    *---------------------------------------------------------------------*
253    * describes the reaction for a failed UPDATE, INSERT or DELETE
254    * for AP clearings
255         form check_result_ap using subrc key like bsak msg type i.
256
257           if subrc ne 0.
258             write: / 'Data base action failed with', key-bukrs,
259                                                      key-belnr,
260                                                      key-gjahr,
261                                                      key-buzei.
262             case msg.
263               when 1.  message a005(FI) with 'BSEG' key-belnr. "#EC MG_PAR_CNT
264               when 2.  message a004(FI) with 'BSIK' key-belnr. "#EC MG_PAR_CNT
265               when 3.  message a006(FI) with 'BSAK' key-belnr. "#EC MG_PAR_CNT
266             endcase.
267           endif.
268         endform.
269
270
271    *---------------------------------------------------------------------*
272    *       FORM ar_reverse                                               *
273    *---------------------------------------------------------------------*
274         form ar_reverse.
275    * copy all cleared line items into internal table I_BSAD
276           select * from bsad into table i_bsad where bukrs = p_bukrs
277                                                and   kunnr = p_accnt
278                                                and   augdt = p_augdt
279                                                and   augbl = p_augbl
280                                                and   umsks = p_umsks
281                                                and   umskz = p_umskz.
282
283           commit_counter = 0.
284           loop at i_bsad.
285             add 1 to commit_counter.
286
287    * check, if reconciliation account is single item managed
288    *   first read document line item information
289             select single * from bseg into wa_bseg where
290                                   bukrs = i_bsad-bukrs and
291                                   belnr = i_bsad-belnr and
292                                   gjahr = i_bsad-gjahr and
293                                   buzei = i_bsad-buzei.
294             perform check_result_ar using sy-subrc i_bsad 1.
295             If wa_bseg-xhres = 'X'.
296    *     read BSAS entry regarding to customer line item
297               select single * from bsas into i_bsas where
298                                 bukrs = wa_bseg-bukrs and
299                                 hkont = wa_bseg-hkont and
300                                 augdt = wa_bseg-augdt and
301                                 augbl = wa_bseg-augbl and
302                                 zuonr = wa_bseg-hzuon and
303                                 gjahr = wa_bseg-gjahr and
304                                 belnr = wa_bseg-belnr and
305                                 buzei = wa_bseg-buzei.
306               perform check_result_ar using sy-subrc i_bsad 1.
307    *     create a new BSIS entry
308               move i_bsas to wa_bsis.
309               wa_bsis-augbl = init_augbl.
310               wa_bsis-augdt = init_augdt.
311    *           insert bsis from wa_bsis.
312
313               perform check_result_gl using sy-subrc i_bsas 2.
314    *     delete the BSAS entry
315    *           delete bsas from i_bsas .
316               perform check_result_gl using sy-subrc i_bsas 3.
317             endif.
318
319    * check, if the cleared document was posted net
320    * if so, reset clearing information in SKV line items and
321    * restore BSIS / delete BSAS
322             if ( i_bsad-xnetb = 'X' ) or ( i_bsad-augbl = i_bsad-belnr ).
323               perform reverse_skv_ar using i_bsad.
324             endif.
325
326    * handle customer line item
327    * reset clearing information in BSEG line item
328             wa_bseg-augcp = init_augcp.
329             wa_bseg-augdt = init_augdt.
330             wa_bseg-augbl = init_augbl.
331             update bseg from wa_bseg.
332             perform check_result_ar using sy-subrc i_bsad 1.
333    * insert a new open item line into bsid
334             wa_bsid = i_bsad.
335             wa_bsid-augbl = init_augbl.
336             wa_bsid-augdt = init_augdt.
337    *         insert bsid from wa_bsid.
338             perform check_result_ar using sy-subrc i_bsad 2.
339    * delete the cleared item line out of bsad
340    *         delete bsad from i_bsad.
341             perform check_result_ar using sy-subrc i_bsad 3.
342    * perform a commit beyond a given threashold
343             n = commit_counter mod threashold.
344             if n = 0.
345               CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
346                    EXPORTING
347                         TEXT = commit_counter.
348               call function 'DB_COMMIT'.
349             endif.
350
351           endloop.
352         endform.                               "AR reverse
353
354
355
356    *---------------------------------------------------------------------*
357    *       FORM reverse_skv_ar                                           *
358    *---------------------------------------------------------------------*
359    * reset clearing information in SKV document line items and
360    * restore BSIS / delete BSAS
361         form reverse_skv_ar using key like bsad.
362           data: iwa_bsis like bsis,
363                 iwa_bsas like bsas.
364           select * from bseg where bukrs = key-bukrs
365                              and   belnr = key-belnr
366                              and   gjahr = key-gjahr
367                              and   ktosl = 'SKV'.
368    *   read BSAS entry
369             select single * from bsas into iwa_bsas
370                                                where bukrs = bseg-bukrs
371                                                and   hkont = bseg-hkont
372                                                and   augdt = bseg-augdt
373                                                and   augbl = bseg-augbl
374                                                and   zuonr = bseg-zuonr
375                                                and   gjahr = bseg-gjahr
376                                                and   belnr = bseg-belnr
377                                                and   buzei = bseg-buzei.
378             perform check_result_ar using sy-subrc key 1.
379    *   create a new BSIS entry
380             move iwa_bsas to iwa_bsis.
381             iwa_bsis-augbl = init_augbl.
382             iwa_bsis-augdt = init_augdt.
383    *         insert bsis from iwa_bsis.
384             perform check_result_gl using sy-subrc iwa_bsas 2.
385    *   delete the BSAS entry
386    *         delete bsas from iwa_bsas.
387             perform check_result_gl using sy-subrc iwa_bsas 3.
388    *   reset clearing information in BSEG
389             bseg-augcp = init_augcp.
390             bseg-augdt = init_augdt.
391             bseg-augbl = init_augbl.
392             update bseg.
393             perform check_result_ar using sy-subrc key 1.
394           endselect.
395         endform.                               "reverse_SKV_AR
396
397
398
399    *---------------------------------------------------------------------*
400    *       FORM check_result_ar                                          *
401    *---------------------------------------------------------------------*
402    * describes the reaction for a failed UPDATE, INSERT or DELETE
403    * for AR clearings
404         form check_result_ar using subrc key like bsad msg type i.
405           if subrc ne 0.
406             write: / 'Data base action failed with', key-bukrs,
407                                                      key-belnr,
408                                                      key-gjahr,
409                                                      key-buzei.
410             case msg.
411               when 1.  message a005(FI) with 'BSEG' key-belnr. "#EC MG_PAR_CNT
412               when 2.  message a004(FI) with 'BSID' key-belnr. "#EC MG_PAR_CNT
413               when 3.  message a006(FI) with 'BSAD' key-belnr. "#EC MG_PAR_CNT
414             endcase.
415           endif.
416         endform.
*--- End of Z_REVERSE_CLEARING - 416 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           Z_REVERSE_CLEARING                        Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:36
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
Object           Z_REVERSE_CLEARING                        Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:36
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
Object           Z_REVERSE_CLEARING                        Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:36
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
Object           Z_REVERSE_CLEARING                        Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:36
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
