----------------------------------------------------------------------------------------------------
Main program     ZFI_UPDATE_KIDNO                          Level 0    Page 1
Object           ZFI_UPDATE_KIDNO                          Lines 854
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:42
----------------------------------------------------------------------------------------------------
1      REPORT zfi_update_kidno.
2      *-----  PROGRAM FOR Updating payemnt reference in  the old documents ***
3      ***********************************************************************
4      * Program    :                                                        *
5      *                                                                     *
6      * Author     : S.R.Sudha                     Date : 8.11.2007
7      *
8      * Login Id   : CAB_SUDHA                                              *
9      *                                                                      *
10     * Description: ONE TIME EXERCISE FOR CHANGING PAYEMNT REFERAENCE
11     *             IN   All old  DOCUEMNTs
12     *
13     *Tcode       :ZFIUPDATEPAYREF
14     *                                                                     *
15     ***********************************************************************
16     * CHANGE HISTORY                                                       *
17     *                                                                      *
18     * Date       TransportUSERID     Description
19     * 06.12.2010 RD1K974367 CAB_ALOK CR 30004997, 1.update the payment ref
20     *                                field in customer line item with Pay
21     *                                ref value in vendor line item.
22     *                                2. Erroneous blank line being appended to BSEG.
23     *                                3. Posting key logic applied for BSEG.
24     *                                4. Messages made more elaborate.
25     *16.05.2011 RD1K976379 CAB_ALOK CR 30005636- Update Pay ref in LIV Doc.
26     *17.10.2011 RD1K978209 CAB_ALOK CR 30006282- Change in Posting key logic
27     *07.05.2012 RD1K980333 CAB_ALOK CR 30007193- Program changes ZFI_UDATE_KIDNO
28
29     ***********************************************************************
30     *                                                                     *
31     * Mod Date    Changed by    Description                     Chng ID   *
32     *                                                                     *
33     * 20/03/2014  CAB_SPYADAV   Changes as per CR No 30010505    005      *
34     *                           (Ref Cr No. 30010493)                     *
35     ***********************************************************************
36     *16.07.2014 RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
37     *5.08.2015  RD1K997925      CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30013088
38     *4.8.2021   OCDK905553      Shaifali     Change in ZFI_UDATE_KIDNO
39
40     """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
41     TABLES : bsak ,bsik , bseg.
42
43     DATA : wa_bsik LIKE bsik.
44     DATA : wa_bseg LIKE bseg.
45     DATA : wa_bsak LIKE bsak.
46     *begin RD1K976379 CAB_ALOK CR 30005636
47     DATA: wa_bkpf LIKE bkpf,
48           wa_rbkp LIKE rbkp.
49     *end RD1K976379 CAB_ALOK CR 30005636
50     DATA : wa_log      TYPE zfi_kidno_log,
51            g_timestamp TYPE oifbbp1-ftmstm.
52     PARAMETERS:  p_belnr LIKE bsik-belnr
53     """""""""""""""""""""""""""""""""""""""""
54     "added by lipsy on 3.8.2015 RD1K997925
55     OBLIGATORY
56                  "end of addition by lipsy on 3.8.2015 RD1K997925
57                  """"""""""""""""""""""""""""""""""""""
58                  ,
59                  p_year  LIKE bsik-gjahr
60      """""""""""""""""""""""""""""""""""""""""
61     "added by lipsy on 3.8.2015 RD1K997925
62     OBLIGATORY
63                  "end of addition by lipsy on 3.8.2015 RD1K997925
64                  """""""""""""""""""""""""""""""""""""
65                  ,
66                  p_bukrs LIKE bsik-bukrs
67      "
68      "added by lipsy on 3.8.2015 RD1K997925
69     OBLIGATORY
70                  "end of addition by lipsy on 3.8.2015 RD1K997925
71                  "
72
73                  ,
74                  p_buzei LIKE bsik-buzei OBLIGATORY,
75                  p_kidno LIKE bsik-kidno
76      "
77      "added by lipsy on 3.8.2015 RD1K997925
78     OBLIGATORY
79                  "end of addition by lipsy on 3.8.2015 RD1K997925
80                  "
81                  .
82     """"""""""""""""""""""""""""
83     "ADDED BY LIPSY  on 3.8.2015 RD1K997925
84
85     DATA: wa_zmm_ims_doc TYPE zmm_ims_status,
86           p_cldocno      TYPE zmm_ims_status-mblnr_inv,
87           p_cldocdt      TYPE zmm_ims_status-mblnr_invdt,
88           t_lifnr        TYPE bseg-lifnr.
89
90     "end of addition by lipsy on 3.8.2015 RD1K997925
91     """"""""""""""""""""""""""""""
92
93
94     DATA  :g_ernam TYPE zfi_kidno_log-ernam,
95            g_erdat TYPE zfi_kidno_log-erfdt.
96
97     *Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
98     TYPES  : BEGIN OF ty_trackno,
99                trackno TYPE zmm_ims_payref-trackno,
100             END OF ty_trackno.
101    DATA: ist_trackno TYPE STANDARD TABLE OF ty_trackno.
102    DATA: ist_return_tab LIKE STANDARD TABLE OF ddshretval
103                                            WITH  HEADER LINE.
104
105    AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_kidno .
106      PERFORM lov_kidno.
107
108    *End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
109    *------------------------------------------------------*
110    START-OF-SELECTION.
111    *------------------------------------------------------*
112    *  PERFORM UPD_BSEG.
113    *
114    *    PERFORM UPD_BSIK.
115    *
116    *    PERFORM UPD_BSAK.
117    **begin RD1K976379 CAB_ALOK CR 30005636
118    *    PERFORM UPD_RBKP.
119    ************************************************************************}CR
120    *  DATA : l_waers      TYPE zmm_ims-waers.
121      DATA : l_date      TYPE sy-datum,
122             l_waers_loc TYPE zmm_ims-waers VALUE 'INR'.
123    *      l_wrbtr TYPE bseg-wrbtr.
124      DATA  : wa_exchange_rate TYPE bapi1093_0,
125              wa_return        TYPE bapiret1.
126
127      DATA : BEGIN OF wa_inv_dtl,
128               trackno     TYPE zmm_ims-trackno,
129               invoiceval  TYPE zmm_ims-invoiceval,
130    *Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
131               invoiceval1 TYPE zmm_ims-invoiceval,
132               trackdt     TYPE zmm_ims_status-trackdt,
133    *End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
134             END OF wa_inv_dtl.
135      DATA :  g_invoiceval TYPE zmm_ims-invoiceval.
136      DATA : ist_inv_dtl LIKE TABLE OF wa_inv_dtl.
137      DATA : l_trackno TYPE zmm_ims_payref-trackno.
138
139
140
141
142    *Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
143    *  SELECT SINGLE trackno FROM zmm_ims_payref INTO l_trackno
144    *             WHERE  trackno = p_kidno AND
145    *                    liv_flg = 'X'.
146
147
148
149      IF p_kidno IS NOT INITIAL.
150        SELECT SINGLE * FROM bkpf INTO @DATA(w_bkpf)
151          WHERE bukrs = @p_bukrs
152          AND   belnr = @p_belnr
153          AND   gjahr = @p_year.
154        IF w_bkpf-stblg IS NOT INITIAL.
155          MESSAGE 'You cannot update IMS no. in cancelled Invoices' TYPE 'E'.
156          EXIT.
157        ENDIF.
158
159        SELECT SINGLE * FROM zmm_ims INTO @DATA(w_ims)
160          WHERE trackno = @p_kidno.  "#EC CI_NOORDER
161        IF sy-subrc = 0.
162          IF w_ims-created_on GT '20191206' AND w_ims-status NE 'X' AND w_ims-tracktyp = 'F'.
163            MESSAGE 'Please forward the invoice to finance department' TYPE 'E'.
164            EXIT.
165          ENDIF.
166        ENDIF.
167
168        IF w_bkpf-blart EQ 'KS' AND ( w_ims-tracktyp  = 'F' OR w_ims-tracktyp  = 'M' ).
169          MESSAGE 'Incorrect IMS No.' TYPE 'E'.
170          EXIT.
171        ENDIF.
172
173        IF w_bkpf-blart EQ 'KR' AND ( w_ims-tracktyp  = 'F' OR w_ims-tracktyp  = 'S' ).
174          MESSAGE 'Incorrect IMS No.' TYPE 'E'.
175          EXIT.
176        ENDIF.
177
178        IF ( w_bkpf-blart NE 'KS' AND w_bkpf-blart NE 'KR' AND w_bkpf-blart NE 'KC' ) AND ( w_ims-tracktyp  = 'M' OR w_ims-tracktyp  = 'S' ).
179          MESSAGE 'Incorrect IMS No.' TYPE 'E'.
180          EXIT.
181        ENDIF.
182
183        IF w_bkpf-blart EQ 'KS' or w_bkpf-blart EQ 'KR'.
184    *     SELECT SINGLE ebeln FROM bseg INTO @data(v_ebeln)
185    *       WHERE bukrs = @w_bkpf-bukrs
186    *       and   belnr = @w_bkpf-belnr
187    *       and   gjahr = @w_bkpf-gjahr
188    *       and   ebeln ne ' '.
189         SELECT ebeln FROM bseg UP TO 1 rows INTO @data(v_ebeln)
190           WHERE bukrs = @w_bkpf-bukrs
191           and   belnr = @w_bkpf-belnr
192           and   gjahr = @w_bkpf-gjahr
193           and   ebeln ne ' ' ORDER BY PRIMARY KEY. ENDSELECT.
194           IF v_ebeln ne w_ims-EBELN.
195          MESSAGE 'Purchase order of IMS No. and accounting document should be matched' TYPE 'E'.
196           ENDIF.
197        ENDIF.
198
199
200
201      ENDIF.
202
203
204
205
206
207      SELECT SINGLE trackno FROM zmm_ims_payref INTO l_trackno   " LSC/LC etc
208                 WHERE  trackno = p_kidno AND
209                        ( liv_flg = 'X' OR  pay_flg = 'X' ).
210    *End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
211
212
213
214      IF sy-subrc = 0.
215    *    PERFORM upd_bseg.
216    *
217    *    PERFORM upd_bsik.
218    *
219    *    PERFORM upd_bsak.
220    **begin RD1K976379 CAB_ALOK CR 30005636
221    *    PERFORM upd_rbkp.
222        PERFORM update_tables.
223
224      ELSE.
225    *Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
226        PERFORM validate_vendor.
227    *end RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
228
229    ** IMS currency
230        DATA : l_ims_waers      TYPE zmm_ims-waers.
231        SELECT SINGLE waers FROM zmm_ims INTO l_ims_waers
232                           WHERE trackno = p_kidno.  "#EC CI_NOORDER
233    *Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
234
235    ** IMS Amt, Date
236    *    SELECT trackno invoiceval
237        SELECT trackno invoiceval trackdt   "IMS date
238    *End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
239          FROM zmm_ims_status
240             INTO CORRESPONDING FIELDS OF TABLE ist_inv_dtl
241               WHERE trackno = p_kidno.
242
243        IF sy-subrc = 0.
244
245          READ TABLE ist_inv_dtl INTO wa_inv_dtl INDEX 1.  "#EC CI_NOORDER
246          IF sy-subrc = 0.
247    *        MOVE wa_inv_dtl-trackno    to g_kidno.
248            MOVE wa_inv_dtl-invoiceval TO g_invoiceval.
249          ENDIF.
250
251        ENDIF.
252
253    *Begin RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
254    *****    IF NOT l_waers IS INITIAL AND l_waers <> 'INR'.
255    *****
256    *****      CLEAR : wa_exchange_rate,
257    *****              wa_return.
258    *****
259    *****      l_date = sy-datum.
260    *****
261    *****      CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
262    *****        EXPORTING
263    *****          rate_type  = 'BCS'
264    *****          from_curr  = l_waers
265    *****          to_currncy = l_waers_loc
266    *****          date       = l_date
267    *****        IMPORTING
268    *****          exch_rate  = wa_exchange_rate
269    *****          return     = wa_return.
270    *****
271    ******-005 : Start
272    ******      g_invoiceval = ( g_invoiceval * wa_exchange_rate-exch_rate ) * 105
273    ******                      / 10000000.
274    ******-005 : End
275    *****
276    ******+005 : Start
277    ******Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
278    ******      g_invoiceval = ( g_invoiceval * wa_exchange_rate-exch_rate ) * 105
279    ******                      / 100.
280    ******End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
281    ******+005 : End
282    *****
283    ******Start : CR No. 30005826 - 27.06.2011
284    ****** To make tolerance level of 12% over the tracking number amount to cover the
285    ****** service tax while making payment.
286    *****    ELSE.
287    ******Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
288    ******      g_invoiceval = g_invoiceval * 112 / 100.
289    ******End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
290    *****
291    ******End : CR No. 30005826 - 27.06.2011
292    *****    ENDIF.
293    ******End   : Added as per CR No. 30005327
294    *End RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
295    *Begin RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
296    *    CLEAR l_wrbtr.
297    *    SELECT SINGLE wrbtr FROM bseg
298    *      INTO l_wrbtr
299    *      WHERE belnr = p_belnr
300    *        AND gjahr = p_year
301    *        AND bukrs = p_bukrs
302    *        AND buzei = p_buzei.
303
304    * get LIV date, LIV Currency, DOC type
305        DATA : l_budat TYPE bkpf-budat.
306        DATA : l_bkpf_waers TYPE bkpf-waers.
307        DATA : l_blart TYPE bkpf-blart.
308
309        SELECT SINGLE blart budat waers
310          FROM bkpf
311            INTO (l_blart, l_budat , l_bkpf_waers )
312              WHERE bukrs = p_bukrs
313                AND belnr = p_belnr
314                AND gjahr = p_year      .
315
316    * get Amt Doc curr, Amt Loc Curr, Ac type, Debit/Credit Indicator
317        DATA : l_koart   TYPE bseg-koart,
318               l_shkzg   TYPE bseg-shkzg,
319               l_wrbtr   TYPE bseg-wrbtr,
320               l_dmbtr   TYPE bseg-dmbtr,
321               l_liv_amt TYPE bseg-dmbtr.
322
323        CLEAR: l_koart,l_shkzg, l_dmbtr, l_wrbtr.
324        SELECT SINGLE koart shkzg dmbtr wrbtr
325          FROM bseg
326            INTO (l_koart, l_shkzg, l_dmbtr, l_wrbtr )
327              WHERE bukrs = p_bukrs
328              AND belnr = p_belnr
329              AND gjahr = p_year
330              AND buzei = p_buzei.
331
332        IF l_bkpf_waers =  l_ims_waers. "FI:INR = IMS:INR OR FI:JPY = IMS:JPY
333          IF l_bkpf_waers = 'JPY'. "  JPY: WRBTR 4,740.00 / PSWBT  474,000 / PSWSL JPY
334            l_liv_amt = l_wrbtr * 100.
335          ELSE.
336            l_liv_amt = l_wrbtr.
337          ENDIF.
338        ELSEIF ( l_bkpf_waers <>  l_ims_waers ) AND  l_ims_waers = 'INR' .   " FI:JPY <> IMS:INR
339          l_liv_amt = l_dmbtr.  " DMBTR: loc curr (INR)
340
341        ELSEIF ( l_bkpf_waers <>  l_ims_waers ) AND  l_bkpf_waers = 'INR' .  " FI: INR <> IMS: JPY
342    *      MESSAGE e544(zfi).
343    * get xchg rate using CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL' for IMS curr l_ims_waers on L_BUDAT date
344    * L_LIV_AMT = L_WRBTR. " FI
345    * g_invoiceval  =  g_invoiceval * xchg rate      " IMS value in INR
346
347          CLEAR : wa_exchange_rate,
348                  wa_return.
349
350          DATA: l_rate_type TYPE bapi1093_1-rate_type.
351
352          SELECT SINGLE kurst FROM t003
353            INTO l_rate_type
354                 WHERE blart = l_blart.
355
356          IF l_rate_type IS INITIAL.
357            l_rate_type = 'M'.
358          ENDIF.
359
360          CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
361            EXPORTING
362              rate_type  = l_rate_type
363              from_curr  = l_ims_waers
364              to_currncy = l_bkpf_waers
365              date       = l_budat
366            IMPORTING
367              exch_rate  = wa_exchange_rate
368              return     = wa_return.
369
370          g_invoiceval  =  g_invoiceval * wa_exchange_rate-exch_rate * wa_exchange_rate-to_factor /  wa_exchange_rate-from_factor.
371          l_liv_amt = l_wrbtr.
372
373        ENDIF.
374
375    *End RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
376
377    ** for Parked docs - BKPF and vbsegk
378        IF l_wrbtr IS INITIAL.
379          SELECT SINGLE wrbtr FROM vbsegk
380            INTO l_wrbtr
381              WHERE bukrs = p_bukrs
382                AND belnr = p_belnr
383                AND gjahr = p_year
384                AND buzei = p_buzei.
385        ENDIF.
386
387    **Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
388    ** get LIV date
389    *    DATA : L_BUDAT TYPE BKPF-BUDAT.
390    *    select SINGLE BUDAT
391    *      from bkpf
392    *        into L_BUDAT
393    *          WHERE belnr = p_belnr
394    *            AND gjahr = p_year
395    *            AND bukrs = p_bukrs.
396    **End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
397
398
399    * if line item  is related to vendor debit, don't check LIV-IMS condition.
400        IF l_koart <> 'K' OR  l_shkzg <>  'S'.
401    *Case : IMS No 107291007649787  IMS for Less Amount
402    *       7114000024  2014   MUM  LIV for Graeter value
403    *system doesn't allow to update in this case .....
404    *now, Such case will be allowed when LIV is done Prior to IMS No : L_BUDAT  < wa_inv_dtl-TRACKDT
405    *wa_inv_dtl-TRACKDT : IMS date
406    *L_BUDAT  : LIV date
407          g_invoiceval = g_invoiceval * 128 / 100.
408    *Begin RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
409    *    IF ( L_BUDAT =>  wa_inv_dtl-TRACKDT ) AND ( l_wrbtr > g_invoiceval ).
410          IF ( l_budat =>  wa_inv_dtl-trackdt ) AND ( l_liv_amt > g_invoiceval ).
411    *End RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
412            MESSAGE e372(zfi).
413    *    ELSEIF ( L_BUDAT < wa_inv_dtl-TRACKDT ) AND ( l_wrbtr < g_invoiceval ).
414    *      MESSAGE e527(zfi).
415          ENDIF.
416    *End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
417        ENDIF.
418
419    * BEGIN CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
420        PERFORM update_tables.
421    *      PERFORM upd_bseg.
422    *      PERFORM upd_bsik.
423    *      PERFORM upd_bsak.
424    **begin RD1K976379 CAB_ALOK CR 30005636
425    *      PERFORM upd_rbkp.
426    **end RD1K976379 CAB_ALOK CR 30005636
427    * END CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
428
429
430      ENDIF.
431    *&---------------------------------------------------------------------*
432    *&      Form  UPD_BSEG
433    *&---------------------------------------------------------------------*
434    *       text
435    *----------------------------------------------------------------------*
436    *  -->  p1        text
437    *  <--  p2        text
438    *----------------------------------------------------------------------*
439    FORM upd_bseg.
440      CLEAR wa_log.
441      IF g_ernam IS INITIAL.
442        PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
443      ENDIF.
444
445      SELECT SINGLE *   FROM bseg INTO  wa_bseg WHERE
446                     bukrs  =  p_bukrs
447                     AND gjahr = p_year
448                     AND belnr = p_belnr
449    *begin <RD1K974367> CAB_ALOK CR 30004997
450    *               AND buzei =  p_buzei.
451    * begin RD1K978209 CAB_ALOK CR 30006282
452    *               AND ( BSCHL = '21' or BSCHL = '31' ) .
453                     AND buzei =  p_buzei
454    *begin RD1K980333 CAB_ALOK CR 30007193
455    *               AND ( BSCHL = '21' or BSCHL = '31' or BSCHL = '29' or BSCHL = '39') .
456                      AND ( bschl = '21' OR bschl = '31' OR bschl = '29' OR bschl = '39' OR bschl = '26' OR bschl = '36' ).
457    *end RD1K980333 CAB_ALOK CR 30007193
458    * end RD1K978209 CAB_ALOK CR 30006282
459      IF sy-subrc = 0.
460    *end <RD1K974367> CAB_ALOK CR 30004997
461        wa_log-kidno_bseg = wa_bseg-kidno.
462        wa_bseg-kidno = p_kidno.
463        wa_log-kidno = wa_bseg-kidno.
464    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
465    * S/4: BSEG KIDNO via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
466    *    MODIFY  bseg FROM wa_bseg.
467        DATA: lt_acg TYPE STANDARD TABLE OF accchg, ls_acg TYPE accchg.
468        REFRESH lt_acg. CLEAR ls_acg.
469        ls_acg-fdname = 'KIDNO'. ls_acg-newval = wa_bseg-kidno.
470        APPEND ls_acg TO lt_acg.
471        CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = wa_bseg-bukrs i_belnr = wa_bseg-belnr
472             i_gjahr = wa_bseg-gjahr i_buzei = wa_bseg-buzei TABLES t_acchg = lt_acg EXCEPTIONS OTHERS = 0.
473        COMMIT WORK.
474    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
475        IF sy-subrc = 0.
476          MESSAGE  i303(zfi) WITH 'BSEG'.
477    *{"CR 30008286
478          PERFORM log_header CHANGING wa_log-belnr wa_log-gjahr wa_log-bukrs wa_log-buzei.
479          IF wa_log-kidno <> wa_log-kidno_bseg.
480            wa_log-ernam = g_ernam.
481            wa_log-erfdt = g_erdat.
482            wa_log-timestamp = g_timestamp.
483    *}"CR 30008286
484            MODIFY zfi_kidno_log FROM wa_log .                              "CR 30008286
485          ENDIF.
486        ENDIF.
487    *begin <RD1K974367> CAB_ALOK CR 30004997
488      ENDIF.
489    *end <RD1K974367> CAB_ALOK CR 30004997
490    ENDFORM.                    " UPD_BSEG
491
492    *&---------------------------------------------------------------------*
493    *&      Form  UPD_BSIK
494    *&---------------------------------------------------------------------*
495    *       text
496    *----------------------------------------------------------------------*
497    *  -->  p1        text
498    *  <--  p2        text
499    *----------------------------------------------------------------------*
500    FORM upd_bsik.
501
502      IF g_ernam IS INITIAL.
503        PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
504      ENDIF.
505
506      SELECT SINGLE * FROM bsik INTO wa_bsik WHERE
507                   bukrs  =  p_bukrs
508                   AND gjahr = p_year
509                   AND belnr = p_belnr
510                   AND buzei =  p_buzei.  "#EC CI_NOORDER
511      IF sy-subrc = 0.
512        wa_log-kidno_bsik = wa_bsik-kidno.
513        wa_bsik-kidno = p_kidno.
514    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
515
516    *    MODIFY  bsik FROM wa_bsik.
517    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
518        IF sy-subrc = 0.
519    *begin <RD1K974367> CAB_ALOK CR 30004997
520    *      MESSAGE  i303(zfi)
521    *{"CR 30008286
522          wa_log-kidno_bsik =  wa_bsik-kidno.
523          wa_log-ernam = g_ernam.
524          wa_log-erfdt = g_erdat.
525          wa_log-timestamp = g_timestamp.
526    *}"CR 30008286
527          MESSAGE  i303(zfi) WITH 'BSIK'.
528          IF wa_log-kidno <> wa_log-kidno_bsik.
529            MODIFY zfi_kidno_log FROM wa_log .                                  "CR 30008286
530          ENDIF.
531    *End <RD1K974367> CAB_ALOK CR 30004997
532        ENDIF.
533      ENDIF.
534    ENDFORM.                    " UPD_BSIK
535    *&---------------------------------------------------------------------*
536    *&      Form  UPD_BSAK
537    *&---------------------------------------------------------------------*
538    *       text
539    *----------------------------------------------------------------------*
540    *  -->  p1        text
541    *  <--  p2        text
542    *----------------------------------------------------------------------*
543    FORM upd_bsak.
544
545      IF g_ernam IS INITIAL.
546        PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
547      ENDIF.
548
549      SELECT SINGLE *   FROM bsak INTO  wa_bsak WHERE
550                    bukrs  =  p_bukrs
551                    AND gjahr = p_year
552                    AND belnr = p_belnr
553                    AND buzei =  p_buzei.  "#EC CI_NOORDER
554      IF sy-subrc = 0.
555        wa_log-kidno_bsak = wa_bsak-kidno.
556        wa_bsak-kidno = p_kidno.
557    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
558    *    MODIFY  bsak FROM wa_bsak.
559    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
560        IF sy-subrc = 0.
561    *{"CR 30008286
562          PERFORM log_header CHANGING wa_log-belnr wa_log-gjahr wa_log-bukrs wa_log-buzei.
563          wa_log-kidno =  wa_bsak-kidno.
564          wa_log-ernam = g_ernam.
565          wa_log-erfdt = g_erdat.
566          wa_log-timestamp = g_timestamp.
567    *}"CR 30008286
568    *begin <RD1K974367> CAB_ALOK CR 30004997
569    *      MESSAGE  i303(zfi)
570          MESSAGE  i303(zfi) WITH 'BSAK'.
571          IF wa_log-kidno <> wa_log-kidno_bsak.
572            MODIFY zfi_kidno_log FROM wa_log .                              "CR 30008286
573          ENDIF.
574    *End <RD1K974367> CAB_ALOK CR 30004997
575        ENDIF.
576      ENDIF.
577    ENDFORM.                    " UPD_BSAK
578    *&---------------------------------------------------------------------*
579    *&      Form  UPD_RBKP
580    *&---------------------------------------------------------------------*
581    *       text
582    *----------------------------------------------------------------------*
583    *  -->  p1        text
584    *  <--  p2        text
585    *----------------------------------------------------------------------*
586    *begin RD1K976379 CAB_ALOK CR 30005636
587    FORM upd_rbkp .
588      DATA: rbkp_belnr TYPE re_belnr,
589            rbkp_year  TYPE gjahr.
590      CLEAR:  rbkp_belnr, rbkp_year.
591      IF g_ernam IS INITIAL.
592        PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
593      ENDIF.
594
595    *get LIV doc data corresponding to input screen data
596      SELECT SINGLE * FROM bkpf INTO wa_bkpf
597               WHERE bukrs  =  p_bukrs
598                 AND belnr = p_belnr
599                 AND gjahr = p_year.
600
601      IF wa_bkpf-awkey IS NOT INITIAL.
602        rbkp_belnr  =  wa_bkpf-awkey+0(10).
603        rbkp_year   =  wa_bkpf-awkey+10(4).
604    *find LIV line in RBKP
605        SELECT SINGLE * FROM rbkp INTO wa_rbkp
606               WHERE belnr = rbkp_belnr
607                 AND gjahr = rbkp_year.
608        IF sy-subrc = 0.
609    * update rbkp  with KIDNO
610          PERFORM log_header CHANGING wa_log-belnr wa_log-gjahr wa_log-bukrs wa_log-buzei.
611          wa_log-kidno_rbkp = wa_rbkp-kidno.
612          wa_rbkp-kidno = p_kidno.
613          MODIFY  rbkp FROM wa_rbkp.
614          IF sy-subrc = 0.
615    *{"CR 30008286
616            wa_log-kidno =  wa_rbkp-kidno.
617            wa_log-ernam = g_ernam.
618            wa_log-erfdt = g_erdat.
619            wa_log-timestamp = g_timestamp.
620    *}"CR 30008286
621            MESSAGE  i407(zfi) WITH wa_rbkp-belnr wa_rbkp-gjahr 'RBKP'. "Corresponding LIV doc &, & updated successfully in Table &.
622            IF wa_log-kidno <> wa_log-kidno_rbkp.
623              MODIFY zfi_kidno_log FROM wa_log .                   "CR 30008286
624            ENDIF.
625          ENDIF.
626        ENDIF.
627      ENDIF. " /WA_BKPF-AWKEY
628
629    ENDFORM.                    " UPD_RBKP
630    *end RD1K976379 CAB_ALOK CR 30005636
631    *&---------------------------------------------------------------------*
632    *&      Form  LOG_UPDATE
633    *&---------------------------------------------------------------------*
634    *       text
635    *----------------------------------------------------------------------*
636    *      <--P_WA_LOG_TIMESTAMP  text
637    *----------------------------------------------------------------------*
638    FORM log_update  CHANGING p_ernam TYPE zfi_kidno_log-ernam
639                              p_erdat TYPE zfi_kidno_log-erfdt
640                              p_timestamp TYPE oifbbp1-ftmstm.
641      g_ernam = sy-uname.
642      g_erdat = sy-datum.
643      CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
644        EXPORTING
645          i_datum           = sy-datum
646          i_time            = sy-uzeit
647    *     I_NO_DATE_OK      = ' '
648        IMPORTING
649          e_timestamp       = g_timestamp
650        EXCEPTIONS
651          date_not_received = 1
652          time_not_received = 2
653          OTHERS            = 3.
654      IF sy-subrc <> 0.
655    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
656    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
657      ENDIF.
658
659      p_timestamp = g_timestamp.
660    ENDFORM.                    " LOG_UPDATE
661    *&---------------------------------------------------------------------*
662    *&      Form  LOG_HEADER
663    *&---------------------------------------------------------------------*
664    *       text
665    *----------------------------------------------------------------------*
666    *      <--P_WA_LOG_BELNR  text
667    *      <--P_WA_LOG_GJAHR  text
668    *      <--P_WA_LOG_BUKRS  text
669    *      <--P_WA_LOG_BUZEI  text
670    *----------------------------------------------------------------------*
671    FORM log_header  CHANGING p_wa_log_belnr
672                              p_wa_log_gjahr
673                              p_wa_log_bukrs
674                              p_wa_log_buzei.
675
676      p_wa_log_belnr = p_belnr.
677      p_wa_log_gjahr = p_year.
678      p_wa_log_bukrs = p_bukrs.
679      p_wa_log_buzei = p_buzei.
680
681    ENDFORM.                    " LOG_HEADER
682
683    *&---------------------------------------------------------------------*
684    *&      Form  VALIDATE_VENDOR
685    *&---------------------------------------------------------------------*
686    *       text
687    *----------------------------------------------------------------------*
688    *  -->  p1        text
689    *  <--  p2        text
690    *----------------------------------------------------------------------*
691    *Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
692    FORM validate_vendor .
693    *  when we are updating the IMS no in KIDNO
694    *field  in the FI Doc, system should check the Vendor Code (LIFNR) of FI
695    *doc should match with the tracking No first Six Digit as (Vendor Code )
696    *Both the value should be same .
697    * BUKRS BELNR      GJAHR BUZEI LIFNR
698      ""
699      "commented by lipsy on 3.8.2015
700
701    *  data: t_lifnr TYPE bseg-lifnr.
702
703      "end of comment by lipsy  on 3.8.2015
704
705
706    *  t_lifnr = p_kidno+0(6).   ""Commneted by ss on 4.8.2021
707
708    **BOC by ss on 4.8.2021
709    SELECT SINGLE lifnr from zmm_ims into  t_lifnr where trackno eq P_KIDNO.  "#EC CI_NOORDER
710    **EOC by ss on 4.8.2021
711
712      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
713        EXPORTING
714          input  = t_lifnr
715        IMPORTING
716          output = t_lifnr.
717
718      SELECT SINGLE * FROM bseg
719        WHERE bukrs = p_bukrs
720        AND belnr  = p_belnr
721        AND   gjahr = p_year
722        AND buzei = p_buzei
723        AND lifnr = t_lifnr.
724
725      IF  sy-subrc <> 0.
726        MESSAGE e542(zfi).
727      ENDIF.
728
729    ENDFORM.                    " VALIDATE_VENDOR
730    *end RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
731    *&---------------------------------------------------------------------*
732    *&      Form  LOV_KIDNO
733    *&---------------------------------------------------------------------*
734    *       text
735    *----------------------------------------------------------------------*
736    *  -->  p1        text
737    *  <--  p2        text
738    *----------------------------------------------------------------------*
739    *begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
740    FORM lov_kidno .
741
742      REFRESH: ist_trackno, ist_return_tab.
743      CLEAR: ist_trackno, ist_return_tab.
744      SELECT trackno
745        FROM zmm_ims_payref
746          INTO CORRESPONDING FIELDS OF TABLE ist_trackno
747            WHERE ( liv_flg = 'X' OR pay_flg = 'X' ).  "#EC CI_NOORDER
748
749      SORT ist_trackno BY trackno ASCENDING.
750      DELETE ADJACENT DUPLICATES FROM ist_trackno COMPARING trackno.
751
752      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
753        EXPORTING
754          retfield        = 'TRACKNO'
755          dynpprog        = sy-cprog
756          dynpnr          = sy-dynnr
757          value_org       = 'S'
758        TABLES
759          value_tab       = ist_trackno
760          return_tab      = ist_return_tab
761        EXCEPTIONS
762          parameter_error = 1
763          no_values_found = 2
764          OTHERS          = 3.
765      IF sy-subrc <> 0.
766
767        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
768                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
769
770      ENDIF.
771
772      p_kidno =  ist_return_tab-fieldval.
773
774    ENDFORM.                    " LOV_KIDNO
775    *end RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
776    *&---------------------------------------------------------------------*
777    *&      Form  UPDATE_TABLES
778    *&---------------------------------------------------------------------*
779    *       text
780    *----------------------------------------------------------------------*
781    *  -->  p1        text
782    *  <--  p2        text
783    *----------------------------------------------------------------------*
784    FORM update_tables .
785      PERFORM upd_bseg.
786      PERFORM upd_bsik.
787      PERFORM upd_bsak.
788      PERFORM upd_rbkp.
789      """""""""""""""""""""""""
790      "added by lipsy on 3.8.2015 RD1K997925
791    *  PERFORM upd_ims. " commented by hiren
792      "end of addition by lipsy on 3.8.2015 RD1K997925
793      """""""""""""""""""""""""""""""""
794    ENDFORM.                    " UPDATE_TABLES
795    *&---------------------------------------------------------------------*
796    *&      Form  UPD_IMS
797    *&---------------------------------------------------------------------*
798    *       text
799    *----------------------------------------------------------------------*
800    *  -->  p1        text
801    *  <--  p2        text
802    *----------------------------------------------------------------------*
803    FORM upd_ims .
804      CLEAR:wa_zmm_ims_doc.
805      SELECT SINGLE *
806       FROM  zmm_ims_status
807       INTO wa_zmm_ims_doc
808      WHERE trackno  = p_kidno.  "#EC CI_NOORDER
809
810      IF sy-subrc = 0.
811
812        IF  wa_zmm_ims_doc-mblnr_liv IS INITIAL.
813
814          UPDATE zmm_ims_status SET
815          mblnr_liv = p_belnr
816          mbll_stat = 'G'
817          mblnr_livdt = wa_bkpf-budat
818          WHERE
819         trackno  = p_kidno.
820          IF sy-subrc = 0.
821            MESSAGE 'LIV Updated in IMS table ' TYPE 'I'.
822          ENDIF.
823        ENDIF.
824        IF wa_zmm_ims_doc-mblnr_inv IS INITIAL.
825          CLEAR:p_cldocno,p_cldocdt.
826          SELECT SINGLE augbl augdt FROM bsak
827                               INTO (p_cldocno,p_cldocdt)
828                                       WHERE bukrs = p_bukrs AND
829                                             lifnr = t_lifnr AND
830                                             buzei = p_buzei AND
831                                             kidno = p_kidno AND
832                                             bschl = '31'.  "#EC CI_NOORDER
833
834          IF sy-subrc = 0.
835            IF  p_cldocno IS NOT INITIAL AND p_cldocdt IS NOT INITIAL.
836              UPDATE zmm_ims_status SET
837              mblnr_inv = p_cldocno
838              mbli_stat = 'G'
839              mblnr_invdt = p_cldocdt
840              WHERE
841             trackno  = p_kidno.
842              IF sy-subrc = 0.
843                MESSAGE 'Payment Document Updated in IMS table ' TYPE 'I'.
844              ENDIF.
845            ENDIF.
846
847          ENDIF.
848
849        ENDIF.
850      ENDIF.
851
852
853
854    ENDFORM.                    " UPD_IMS
*--- End of ZFI_UPDATE_KIDNO - 854 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 2
Object           ZFI_UPDATE_KIDNO                          Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:42
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
Generated incl.  <REPINI>                                  Level 1    Page 3
Object           ZFI_UPDATE_KIDNO                          Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:42
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
Generated incl.  <SYSINI>                                  Level 1    Page 4
Object           ZFI_UPDATE_KIDNO                          Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:42
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
Generated incl.  <SYSSEL>                                  Level 1    Page 5
Object           ZFI_UPDATE_KIDNO                          Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:42
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
Generated incl.  DB__SSEL                                  Level 1    Page 6
Object           ZFI_UPDATE_KIDNO                          Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:42
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
