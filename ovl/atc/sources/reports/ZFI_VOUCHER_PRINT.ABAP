----------------------------------------------------------------------------------------------------
Main program     ZFI_VOUCHER_PRINT                         Level 0    Page 1
Object           ZFI_VOUCHER_PRINT                         Lines 1718
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:45
----------------------------------------------------------------------------------------------------
1      ***********************************************************************
2      * Program    : ZFI_VOUCHER_PRINT                                      *
3      *                                                                     *
4      *                                                                     *
5      * Title      : For VOUCHER PRINTING LAY OUT FOR the                   *
6      *              PAYMENTS/RECEIPTS/GENERAL DOCUMENT
7      * MIGRATED FROM UFSO. NO LOGIC CHANGE.                                *
8      *                                                                     *
9      * Functional Specification No. : FS-FI-PCS-016                        *
10     *                                                                     *
11     * Author     : MADHUKAR                     Date : 03-June-2003
12     *
13     *                                                                     *
14     * Login Id   : CAB_MADHUKAR
15     *
16     *                                                                     *
17     * Desciption : For VOUCHER PRINTING LAY OUT FOR the                   *
18     *              PAYMENTS/RECEIPTS/GENERAL DOCUMENT
19     * Tran.Code  : ZFIVCH                                                 *
20     *                                                                     *
21     ***********************************************************************
22     * CHANGE HISTORY                                                      *
23     *                                                                     *
24     * Mod Date    Changed by    Description                 Chng ID       *
25     * 8.04.2008   S.R.Sudha     For Payment method          +001          *
26     * 21.04.2008  S.R.Sudha     Paymethod from ven master   +002
27     *
28     ***********************************************************************
29     **---------------------------------------------------------------------*
30     **                   Amendment History                                 *
31     **---------------------------------------------------------------------*
32     ** Name   : MANESH                    *
33     ** Date         : 21/05/09                                             *
34     ** Change ID    : RD1K961183                                    *
35     ** Reason       : ONGC Trust Migration to ECC 6.0                      *
36     **---------------------------------------------------------------------*
37
38
39     REPORT zfi_voucher_print NO STANDARD PAGE HEADING LINE-SIZE 170
40                                                LINE-COUNT 58 MESSAGE-ID zfi.
41
42     * ---------- DATA DECLARATION SECTION --------------- *
43
44
45     TABLES:
46       bseg,                          " Accounting document segment
47       ska1,                   " G/L accounts master(chart of accounts)
48       bkorm,                  " Accounting correspondence requests
49       skat,                   " G/L A/C master record chart of account
50       bkpf,                          " Accounting document header
51       user_addr,
52       lfa1,                          " Vendor master (general section)
53       kna1,                          " General Data in Customer Master
54       payr,                          " Payment transfer medium file
55       rf05v,                         " Work fields for SAPLF040
56       t001,                          " Company Codes
57       anla,                          " Asset master record-segment
58       vbsec,                  " Preliminary posting one-time data doc.
59       usr03,                         " User address data
60       bsec,                   " One-time account data document segment
61       t074t,                         " Special G/L indicator names
62       with_item,
63       lfb1,
64       lfbk,
65       zfi_reconc,
66       t042z.
67     "03.03.2003
68     DATA gv_wrbtr(20).
69     DATA gv_wrbtr_cr(20).
70     DATA : gv_name1 TYPE kna1-name1.
71     DATA : gv_name2 TYPE lfa1-name1.
72     DATA :v_amount_interval TYPE wmto_s-amount.
73     *-------- Selection Screen and Parameters------------------------------*
74     PARAMETERS : tbukrs LIKE bseg-bukrs OBLIGATORY,
75                  gjahr  LIKE bseg-gjahr  OBLIGATORY.
76     SELECT-OPTIONS: belnr FOR bkorm-belnr OBLIGATORY. " Doc.No.
77     SELECT-OPTIONS: cpudatum    FOR  bkpf-cpudt.     "  Document entry date
78     SELECT-OPTIONS: bu_datum    FOR  bkpf-budat.      "Document posting date
79
80
81     *---- Structure to Hold HEADER DATA -----------------------------------*
82     DATA : BEGIN OF header OCCURS 0,
83              belnr  LIKE bkpf-belnr,         " Document Number
84              bukrs  LIKE bkpf-bukrs,         " Company code
85              gjahr  LIKE bkpf-gjahr,         " Fiscal Year
86              usnam  LIKE bkpf-usnam,         " Entered by - header
87              blart  LIKE bkpf-blart,         " Doc. type - header
88              bldat  LIKE bkpf-bldat,         " Doc. Date - Header
89              budat  LIKE bkpf-budat,         " Posting Date
90              cpudt  LIKE bkpf-cpudt,         " CPU Date - Header
91              name1  LIKE lfa1-name1,         " Vendor name
92              name2  LIKE kna1-name1,         " Customer Name
93              bktxt  LIKE bkpf-bktxt,         " Header Text
94              xblnr  LIKE bkpf-xblnr,         " Ref. Doc No
95              bvorg  LIKE bkpf-bvorg,
96              txt20  LIKE skat-txt20,          " Account Desc - Detail
97              waers  LIKE bkpf-waers,          "currency code
98     *       netamt LIKE bseg-wrbtr,
99              netamt LIKE zfi_reconc-glamount,                     "03.03.2003
100           END OF header.
101
102    *---- Structure to Hold ITEM DATA -------------------------------------*
103
104    DATA : BEGIN OF inrec OCCURS 0,
105             belnr  LIKE bkpf-belnr,         " Document Number
106             bukrs  LIKE bkpf-bukrs,         " Company code
107             gjahr  LIKE bkpf-gjahr,         " Fiscal Year
108             hkont  LIKE bseg-hkont,         " Account Code - Body(Acc.Ty S)
109    *        wrbtr LIKE bseg-wrbtr,         " Amount - Body "03.03.2003
110    *        dmbtr LIKE bseg-dmbtr,         " Local Curr    "03.03.2003
111             wrbtr  LIKE zfi_reconc-glamount, " Amount - Body "03.03.2003
112             dmbtr  LIKE zfi_reconc-glamount, " Local Curr    "03.03.2003
113             pswsl  LIKE bseg-pswsl,         " Curr key
114             kostl  LIKE bseg-kostl,         " Cost Centre - Body
115             projk  LIKE bseg-projk,         " WBS Element  " Added by SB 8/12
116    *       projn like bseg-projn,         " WBS ELEMENT  " Comment by SB
117             bldat  LIKE bkpf-bldat,         " Doc. Date - Header
118             budat  LIKE bkpf-budat,         " Posting Date
119             cpudt  LIKE bkpf-cpudt,         " CPU Date - Header
120             txt20  LIKE skat-txt20,         " Account Desc - Detail
121             shkzg  LIKE bseg-shkzg,         " Indicator
122             gsber  LIKE bseg-gsber,
123             chect  LIKE payr-chect,         " Check No
124             laufd  LIKE payr-laufd,        " Check Date(Run date)
125             sgtxt  LIKE bseg-sgtxt,         " Line Item Text
126             saknr  LIKE bseg-saknr,         " Account Number
127             buzei  LIKE bseg-buzei,         " Line Item No.
128             bschl  LIKE bseg-bschl,         " posting Key
129             aufnr  LIKE bseg-aufnr,         " Order No.
130             zuonr  LIKE bseg-zuonr,         " Allocation Number
131             kunnr  LIKE bseg-kunnr,         " Custmr.Account Number(Acc.Ty )
132             lifnr  LIKE bseg-lifnr,         " Vendor Acct. Code(Acc.Ty. K)
133             name1  LIKE lfa1-name1,         " Vendor name
134             name2  LIKE kna1-name1,         " Customer Name
135             qsskz  LIKE bseg-qsskz,         " Tax Type
136             umskz  LIKE bseg-umskz,         " Sp. G/L indicator
137             koart  LIKE bseg-koart,         " Account Type
138             anln1  LIKE bseg-anln1,         " Asset No.
139             matnr  LIKE bseg-matnr,         " Mat.No.
140             posid  LIKE prps-posid,         " WBS Element
141    *-----+001
142             zlsch  LIKE bseg-zlsch,         "payment method
143    *        netamt LIKE bseg-wrbtr,    " DOCUMENT NET BANK A/c AMOUNT 03.03
144             netamt LIKE zfi_reconc-glamount,                    "03.03.2003
145           END OF inrec.
146
147    *---- Internal Table to store Change document structure -----*
148    *---- Used in the function CALL 'PRELIMINARY_POSTING_DOC_READ' ---- *
149    DATA: BEGIN OF yvbkpf OCCURS 20.
150            INCLUDE STRUCTURE fvbkpf.
151    DATA: END OF yvbkpf.
152
153    DATA: BEGIN OF yvbsec OCCURS 20.
154            INCLUDE STRUCTURE fvbsec.
155    DATA: END OF yvbsec.
156
157    DATA: BEGIN OF yvbseg OCCURS 20.
158            INCLUDE STRUCTURE fvbseg.
159    DATA: END OF yvbseg .
160
161    DATA: BEGIN OF yvbset OCCURS 20.
162            INCLUDE STRUCTURE fvbset.
163    DATA: END OF yvbset.
164    *----------------------------------------------------------------------*
165    * Changed by Vinod on 18th March 2001
166    DATA: BEGIN OF it_bkpf OCCURS 0.
167            INCLUDE STRUCTURE bkpf.
168    DATA: END OF it_bkpf.
169
170    DATA: BEGIN OF it_bseg OCCURS 0.
171            INCLUDE STRUCTURE bseg.
172    DATA: END OF it_bseg .
173
174    DATA: BEGIN OF it_bset OCCURS 0.
175            INCLUDE STRUCTURE bset.
176    DATA: END OF it_bset.
177
178    DATA  BEGIN OF it_with_item OCCURS 0.
179            INCLUDE STRUCTURE  with_itemx.
180    DATA  END   OF it_with_item.
181    * End of changes
182    *----------------------------------------------------------------------*
183    * ---- Internal Table to Keep Line items with Sp. G/L Indicator ---*
184    DATA: BEGIN OF intspl OCCURS 10,
185            umskz LIKE bseg-umskz,
186            desc  LIKE t074t-ltext,
187          END   OF intspl.
188
189    * ---- Working Variable Declaration ------ *
190    DATA : txblnr             LIKE bseg-belnr,
191           tbktxt             LIKE bkpf-bktxt,
192           fdate              LIKE bkpf-budat,
193           tdate              LIKE bkpf-budat,
194           tcdate             LIKE bkpf-cpudt,
195           fcdate             LIKE bkpf-cpudt,
196           acgrp              LIKE ska1-ktoks,
197           cpudt(10),
198           blart              LIKE bkpf-blart,
199    *       totamt LIKE bseg-wrbtr,   "03.03.2003
200           totamt             LIKE zfi_reconc-glamount,                     "03.03.2003
201           word               LIKE spell-word,
202           name1(100) ,
203           hkont              LIKE bseg-hkont,
204           totalamt           LIKE totamt,
205           flag(1),
206           namex              LIKE bsec-name1,
207           len(2)             TYPE n,
208           alloc(10),
209           totamtd            LIKE totamt,
210           totamtc            LIKE totamt,
211           payamt             LIKE totamt,
212    *       netamt LIKE bseg-wrbtr,  "03.03.2003
213           netamt             LIKE zfi_reconc-glamount,                     "03.03.2203
214           no_payee(3)        TYPE n,
215           hdr_ln(3)          TYPE n,
216           inrec_no           LIKE hdr_ln,
217           old_name           LIKE name1,
218           throw(1),
219           banktxt(50),
220           payee,
221           sglno              TYPE n,
222           tick,
223    *       net_cr LIKE bseg-wrbtr ,  "03.03.2203
224    *       net_cr_lc LIKE bseg-dmbtr, "03.03.2203
225    *       net_dr_lc LIKE bseg-dmbtr, "03.03.2203
226    *       net_dr LIKE bseg-wrbtr ,   "03.03.2203
227           net_cr             LIKE zfi_reconc-glamount,                     "03.03.2203
228           net_cr_lc          LIKE zfi_reconc-glamount,                  "03.03.2203
229           net_dr_lc          LIKE zfi_reconc-glamount,                  "03.03.2203
230           net_dr             LIKE zfi_reconc-glamount,                     "03.03.2203
231           projk              LIKE bseg-kostl,
232           temp_amount_lc(20) TYPE n,
233           temp_amount_fc(20) TYPE n,
234           l_aztxt            LIKE t042z-text1,                            " +001
235           l_ktokk            LIKE lfa1-ktokk.
236
237
238    DATA : BEGIN OF it_bankkey OCCURS 0,
239             lifnr   LIKE lfa1-lifnr,
240             belnr   LIKE bseg-belnr,
241             bankey  LIKE lfbk-bankl,
242             bankacc LIKE lfbk-bankn,
243           END   OF it_bankkey.
244    *-------------------------------------+001
245    DATA : BEGIN OF ist_zlsch  OCCURS 0,
246             belnr LIKE bseg-belnr,
247             bukrs LIKE bseg-bukrs,
248             zlsch LIKE bseg-zlsch,
249             text1 LIKE t042z-text1,
250           END OF ist_zlsch .
251    DATA : l_zwels LIKE lfb1-zwels.
252    *-------------------------------------+001
253    * start of addition on 22102003 by sab_lax
254
255    RANGES : hkont_bank_range FOR bseg-hkont,
256             hkont_cash_range FOR bseg-hkont.
257
258    DATA : valfrom LIKE setleaf-valfrom,
259           valto   LIKE setleaf-valto.
260
261    * end of addition on 22102003 by sab_lax
262
263    DATA: wrbtr_input  TYPE wmto_s-amount,
264          wrbtr_output TYPE wmto_s-amount,
265          dmbtr_output TYPE wmto_s-amount,
266          dmbtr_input  TYPE wmto_s-amount.  " ADD BY ROHIT ON 16.04.2026
267
268
269    *--- End of data selection --------------------------------------------*
270    *$*$-------------------------------------------------------------------*
271    *$*$ Code Inserted by Vinod on 5th April for changing Print Layout
272    *CALL FUNCTION 'SET_PRINT_PARAMETERS'
273    *     EXPORTING
274    *          layout     = 'X_65_255'
275    *          line_count = 255
276    *          line_size  = 65.
277    *$*$ End of Insertion -------------------------------------------------*
278    *---------------initialization-----------------------------------------*
279    INITIALIZATION.
280      GET PARAMETER ID 'BUK' FIELD tbukrs.
281      GET PARAMETER ID 'GJR' FIELD gjahr.
282
283    START-OF-SELECTION.
284
285    * start of addition on 22102003 by sab_lax required by  rohit
286
287      REFRESH : hkont_bank_range,
288                hkont_cash_range.
289
290    * append the BANK GL accounts
291
292      SELECT  valfrom valto INTO  (valfrom, valto)
293                            FROM  setleaf
294                            WHERE setname  = 'BANK_CLG_ACCOUNTS'.
295
296        hkont_bank_range-sign = 'I'.
297        hkont_bank_range-option = 'BT'.
298        hkont_bank_range-low = valfrom.
299    *    hkont_bank_range-high = valto.
300
301        APPEND hkont_bank_range.
302        CLEAR hkont_bank_range.
303
304      ENDSELECT.
305
306    * append the BANK GL accounts
307
308      SELECT  valfrom valto INTO  (valfrom, valto)
309                            FROM  setleaf
310                            WHERE setname  = 'BANK_MAIN_ACCOUNTS'.
311
312        hkont_bank_range-sign = 'I'.
313        hkont_bank_range-option = 'BT'.
314        hkont_bank_range-low = valfrom.
315        hkont_bank_range-high = valto.
316
317        APPEND hkont_bank_range.
318        CLEAR hkont_bank_range.
319
320      ENDSELECT.
321
322    * append the CASH GL accounts
323
324      SELECT  valfrom valto INTO  (valfrom, valto)
325                            FROM  setleaf
326                            WHERE setname  = 'CASH_ACCOUNTS'.
327
328        hkont_cash_range-sign = 'I'.
329        hkont_cash_range-option = 'BT'.
330        hkont_cash_range-low = valfrom.
331        hkont_cash_range-high = valto.
332
333        APPEND hkont_cash_range.
334        CLEAR hkont_cash_range.
335
336      ENDSELECT.
337
338
339    * end of addition on 22102003
340
341    *-----Select from header data for the docs. ---------------------------*
342      fcdate = cpudatum-low.
343      tcdate = cpudatum-high.
344      fdate =  bu_datum-low.
345      tdate =  bu_datum-high.
346    *----Initialize internal tables  --------------------------------------*
347      CLEAR : inrec, header.
348      SELECT  * FROM bkpf WHERE gjahr = gjahr
349                            AND belnr IN belnr
350                            AND bukrs = tbukrs.
351    *--- Check for posting date and the cpu date of the document in the
352    *                                              --- selection field range
353        PERFORM budat.
354    *------ store the header data in the internal table   -----------------*
355        APPEND header.
356      ENDSELECT.
357
358    *------ Invalid Document Number  --------------------------------------*
359      DESCRIBE TABLE header LINES hdr_ln.
360      IF hdr_ln < 1.
361    *  MESSAGE e162(yfi)  WITH belnr-low belnr-high. "210501
362        MESSAGE i162(zfi)  WITH belnr-low belnr-high. "210501-yaseen
363
364      ENDIF.
365    *------For Document line items  ---------------------------------------*
366
367    *--Select from vbsegs if document is a parked one ---------------------*
368      LOOP AT header.
369        rf05v-belnr = header-belnr.
370        rf05v-bukrs = header-bukrs.
371        rf05v-gjahr = header-gjahr.
372    *---Function for getting line item details of parked docs. ------------*
373        CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
374          EXPORTING
375            belnr                   = rf05v-belnr
376            bukrs                   = rf05v-bukrs
377            gjahr                   = rf05v-gjahr
378          TABLES
379            t_vbkpf                 = yvbkpf
380            t_vbsec                 = yvbsec
381            t_vbseg                 = yvbseg
382            t_vbset                 = yvbset
383          EXCEPTIONS
384            document_line_not_found = 1
385            document_not_found      = 2
386            OTHERS                  = 3.
387
388        IF sy-subrc = 0.
389    *----------------------------------------------------------------------*
390    *   Changed by Vinod on 18th March 2001
391    *   To determine withholding tax amounts and line items for a parked
392    *   document
393          REFRESH it_with_item.
394          CLEAR   it_with_item.
395
396          SELECT * INTO CORRESPONDING FIELDS OF TABLE it_with_item
397                                                FROM  with_item
398                                               WHERE  bukrs  = header-bukrs
399                                               AND    belnr  = header-belnr
400                                               AND    gjahr  = header-gjahr.
401          "  AND    wt_withcd <> space.
402          IF sy-subrc = 0.
403            REFRESH : it_bkpf,
404                      it_bseg,
405                      it_bset.
406            CLEAR   : it_bkpf,
407                      it_bseg,
408                      it_bset.
409
410            CALL FUNCTION 'FI_WT_PUT_X_WITH_ITEM'
411              TABLES
412                t_with_item = it_with_item.
413    *     Copying to internal table for passing to the function module
414    *     FI_WT_FB01_CALCULATE_WT
415            LOOP AT yvbkpf.
416              MOVE-CORRESPONDING yvbkpf TO it_bkpf.
417              APPEND it_bkpf.
418            ENDLOOP.
419            DATA wa LIKE LINE OF yvbkpf.
420            LOOP AT yvbseg.
421              CLEAR wa.
422              READ TABLE yvbkpf INTO wa
423              WITH KEY ausbk = yvbseg-ausbk
424              belnr = yvbseg-belnr
425              bukrs = yvbseg-bukrs
426              gjahr = yvbseg-gjahr.
427              IF wa-waers = 'JPY'.
428                v_amount_interval = yvbseg-wrbtr.
429                CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
430                  EXPORTING
431                    currency        = wa-waers
432                    amount_internal = v_amount_interval
433                  IMPORTING
434                    amount_display  = v_amount_interval
435                  EXCEPTIONS
436                    internal_error  = 1
437                    OTHERS          = 2.
438                yvbseg-wrbtr = v_amount_interval.
439              ENDIF.
440              MOVE-CORRESPONDING yvbseg TO it_bseg.
441              IF it_bseg-skfbt > 0.
442                it_bseg-wrbtr = it_bseg-skfbt.
443              ENDIF.
444              APPEND it_bseg.
445            ENDLOOP.
446            LOOP AT yvbset.
447              MOVE-CORRESPONDING yvbset TO it_bset.
448              APPEND it_bset.
449            ENDLOOP.
450
451            CALL FUNCTION 'FI_WT_FB01_CALCULATE_WT'
452              EXPORTING
453                i_aktyp = 'H'
454                i_dyncl = 'B'
455              TABLES
456                i_bkpf  = it_bkpf
457                i_bseg  = it_bseg
458                i_bset  = it_bset.
459
460    *   Get withitem data from memory .
461            CALL FUNCTION 'FI_WT_GET_X_WITH_ITEM'
462              TABLES
463                t_with_item = it_with_item.
464
465            DELETE it_with_item WHERE wt_qbshh = 0 OR wt_stat = 'X'.
466
467            READ TABLE it_bkpf INDEX 1.
468            PERFORM add_entries_bseg TABLES it_bseg it_with_item
469                                     USING  it_bkpf.
470    *   Copying back to the internal table YVBSEG
471            REFRESH yvbseg.
472            CLEAR   yvbseg.
473
474            LOOP AT it_bseg.
475              MOVE-CORRESPONDING it_bseg TO yvbseg.
476              APPEND yvbseg.
477            ENDLOOP.
478          ENDIF.
479    *   End of changes by Vinod
480    *----------------------------------------------------------------------*
481    *--validations for payment vouchers -----------------------------------*
482          CLEAR: netamt , hkont.
483
484          LOOP AT yvbseg WHERE
485    *                          bukrs = header-bukrs
486                              belnr = header-belnr
487                             AND gjahr = header-gjahr
488                             AND wrbtr <> 0.
489            IF yvbseg-hkont <> ' '.
490              hkont = yvbseg-hkont.
491            ELSE.
492              hkont = yvbseg-saknr.
493            ENDIF.
494    * commented by sab_lax on 22102003 required by rohit
495    *        IF ( hkont BETWEEN '0000091211' AND '0000091299'
496    * end of comment by sab_lax on 22102003 required by rohit
497
498    * added by sab_lax on 22102003 required by rohit
499            IF ( hkont IN hkont_bank_range
500    * end of addtion by sab_lax on 22102003 required by rohit
501               AND  hkont+9(1)  CA '02468' ) OR     " hkont = '0000091201'.
502    *Commented as request from Sanjay Bharti/Rajeev Kumar Dated 21.05.2002
503    *         ( hkont BETWEEN '0000091201' AND '0000091210' ).
504    * commented by sab_lax on 22102003 required by rohit
505    ** Added Request from rajeev Kumar/Sanjay Bharti dated 21.05.2002
506    *            ( hkont BETWEEN '0000091201' AND '0000091205' ).
507    * end of comment by sab_lax on 22102003
508
509    * added by sab_lax on 22102003 required by rohit
510               ( hkont IN hkont_cash_range ).
511    * end of addition by sab_lax on 22102003
512
513    *       above might change for Bombay implementation for > 1 cash accts
514    *------ Calculate net amount for bank clearing or cask accounts -------*
515              IF yvbseg-shkzg = 'H'.
516                netamt = netamt + yvbseg-wrbtr.
517              ELSEIF yvbseg-shkzg = 'S'.
518                netamt = netamt - yvbseg-wrbtr.
519              ENDIF.
520            ENDIF.
521
522            MOVE-CORRESPONDING yvbseg TO inrec.
523            PERFORM other_details1.
524            APPEND inrec.
525          ENDLOOP.
526        ELSEIF sy-subrc <> 0.
527    *--- Validations  for receipt vouchers  -------------------------------*
528          CLEAR: netamt,hkont, throw.
529          SELECT  * FROM bseg WHERE bukrs = header-bukrs
530                             AND belnr = header-belnr
531                             AND gjahr = header-gjahr.
532            IF bseg-hkont <> ' '.
533              hkont = bseg-hkont.
534            ELSE.
535              hkont = bseg-saknr.
536            ENDIF.
537    *----payment method   Sudha
538    *
539
540    * commented by sab_lax on 22102003 required by rohit
541    *        IF ( hkont BETWEEN '0000091211' AND '0000091299'
542    * end of comment by sab_lax on 22102003
543
544    * start of addition by sab_lax on 22102003 required by rohit
545            IF ( hkont IN hkont_bank_range
546    * end of addition by sab_lax on 22102003
547               AND  hkont+9(1)  CA '02468' )  OR   "  hkont = '0000091201'.
548    *         ( hkont BETWEEN '0000091201' AND '0000091210' ).
549    * commented by sab_lax on 22102003 required by rohit
550    *            ( hkont BETWEEN '0000091201' AND '0000091205' ).
551    * end of comment  by sab_lax on 22102003
552
553    * added by sab_lax on 22102003 required by rohit
554               ( hkont IN hkont_cash_range ).
555    * end of addition by sab_lax 22102003
556
557    *        above might change for Bombay implementation for > 1 cash accts
558              PERFORM calculate_net_amount.
559    *        elseif ( hkont between '0000091211' and '0000091299'
560    *         91299 is contra acct - cannot be included as actual bank acct
561
562    * start of comment on 22102003 by sab_lax required by rohit
563    *        ELSEIF ( hkont BETWEEN '0000091211' AND '0000091297'
564    * end of comment on 22102003 by sab_lax
565
566    * start of addition on 22102003 by sab_lax required by rohit
567            ELSEIF ( hkont IN hkont_bank_range
568    * end of addition by sab_lax on 22102003
569                     AND  hkont+9(1) CA '13579' ) .
570    *-------   General docs.  --------------------------------------------*
571              throw = 'X'.
572            ENDIF.
573    *{30007749
574            DATA : l_curr TYPE bkpf-waers.
575            CLEAR l_curr.
576            SELECT SINGLE waers FROM bkpf
577                INTO l_curr
578              WHERE bukrs = bseg-bukrs
579              AND belnr = bseg-belnr
580              AND gjahr = bseg-gjahr  .
581
582    *        if BSEG-pswsl = 'JPY'.
583            IF l_curr = 'JPY'.
584    *}30007749
585              CLEAR v_amount_interval.
586              v_amount_interval = bseg-wrbtr.
587              CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
588                EXPORTING
589                  currency        = l_curr
590                  amount_internal = v_amount_interval
591                IMPORTING
592                  amount_display  = v_amount_interval
593                EXCEPTIONS
594                  internal_error  = 1
595                  OTHERS          = 2.
596              bseg-wrbtr = v_amount_interval.
597            ENDIF.
598
599            MOVE-CORRESPONDING bseg TO inrec.
600    *{30007559
601    *1.BSEG-EMPFB <> '' print name1 from lfa1 for vendor BSEG-EMPFB
602            DATA : l_name1 TYPE lfa1-name1,
603                   l_kunnr TYPE bseg-kunnr.
604            CLEAR l_name1.
605
606            IF bseg-empfb <> ''.
607              SELECT SINGLE name1 FROM lfa1 INTO l_name1
608                WHERE lifnr = bseg-empfb.
609              IF sy-subrc = 0.
610                inrec-name1 = l_name1.
611              ENDIF.
612            ENDIF.
613            IF bseg-kunnr <> ''.
614              DATA : l_ktokd TYPE kna1-ktokd,
615                     l_ccnum TYPE vcnum-ccnum.
616              CLEAR :l_ccnum,l_ktokd.
617              SELECT SINGLE ktokd INTO l_ktokd
618                FROM kna1
619                WHERE kunnr = bseg-kunnr.
620              IF l_ktokd = 'IMPR'.
621                l_kunnr = bseg-kunnr.
622                DATA :ln TYPE n.
623                ln = strlen( bseg-kunnr ).
624    *            if l_kunnr+0(1) = '0'.
625    *              shift l_kunnr left deleting leading '0'.
626    *            endif.
627                DATA : l_valfrom TYPE setleaf-valfrom.
628                CLEAR l_valfrom.
629                SELECT SINGLE valfrom
630                  INTO l_valfrom
631                  FROM setleaf
632                  WHERE setclass = '0000'
633                  AND setname = 'ZFIPREPAIDCARD'.
634
635                IF NOT l_valfrom IS INITIAL.
636                  IF ln = '9'.
637                    CONCATENATE l_valfrom '0' l_kunnr INTO l_ccnum.
638                  ELSE.
639                    CONCATENATE l_valfrom l_kunnr INTO l_ccnum.
640                  ENDIF.
641                ENDIF.
642                SELECT SINGLE ccname FROM vcnum
643                  INTO inrec-name1
644                  WHERE ccins = 'PPC'
645                  AND ccnum = l_ccnum.
646              ENDIF.
647            ENDIF.
648    *)30007559
649            PERFORM other_details1.
650            APPEND inrec.
651            CLEAR inrec.
652          ENDSELECT.
653        ENDIF.
654    *------ Store net amount for Receipt/Payment Docs  --------------------*
655        IF throw <> 'X'.
656          header-netamt = netamt.
657          MODIFY header.
658          CLEAR netamt.
659        ENDIF.
660      ENDLOOP.
661      CLEAR throw.
662    *$*$ Changed by Vinod on 12th April 2001 for Bank Key
663      REFRESH it_bankkey.
664      CLEAR   it_bankkey.
665
666      LOOP AT inrec WHERE koart = 'K'.
667        IF NOT inrec-lifnr IS INITIAL.
668          SELECT SINGLE * FROM lfb1 WHERE lifnr = inrec-lifnr
669                                    AND   bukrs = inrec-bukrs.
670          IF sy-subrc = 0.
671            SELECT SINGLE * FROM lfbk WHERE lifnr = lfb1-lifnr
672                                      AND   banks = 'IN'.
673            IF sy-subrc = 0.
674              it_bankkey-belnr   = inrec-belnr.
675              it_bankkey-lifnr   = lfb1-lifnr.
676              it_bankkey-bankey  = lfbk-bankl.
677              it_bankkey-bankacc = lfbk-bankn.
678              APPEND it_bankkey.
679            ENDIF.
680          ENDIF.
681        ENDIF.
682      ENDLOOP.
683
684
685    *--------------+001
686      LOOP AT inrec WHERE koart = 'K'.
687        IF NOT inrec-lifnr IS INITIAL.
688          SELECT SINGLE ktokk INTO l_ktokk  FROM lfa1
689                               WHERE lifnr = inrec-lifnr.
690          IF sy-subrc = 0.
691            IF l_ktokk = 'SVWI'  OR
692            l_ktokk = 'SVWF'  OR
693            l_ktokk = 'IMMI' OR
694            l_ktokk = 'IMMF' OR
695            l_ktokk = 'OTV ' OR
696            l_ktokk = 'VEMP'.
697    *------------------------------------------+002
698              CLEAR l_zwels.
699              SELECT SINGLE zwels  INTO l_zwels  FROM  lfb1
700                   WHERE  lifnr = inrec-lifnr
701                    AND   bukrs = inrec-bukrs.
702              IF sy-subrc = 0.
703                IF NOT l_zwels IS  INITIAL.
704                  ist_zlsch-belnr = inrec-belnr .
705                  ist_zlsch-bukrs = inrec-bukrs.
706                  ist_zlsch-zlsch = l_zwels.
707                  APPEND ist_zlsch.
708                  CLEAR ist_zlsch.
709                ENDIF.
710              ENDIF.
711
712    *---------------------------------------------------+002
713            ENDIF.
714          ENDIF.
715        ENDIF.
716
717      ENDLOOP.
718      DELETE ADJACENT DUPLICATES FROM ist_zlsch.
719
720      CLEAR l_aztxt.
721      IF NOT ist_zlsch[] IS INITIAL.
722        LOOP AT ist_zlsch.
723          SELECT SINGLE text1 INTO  l_aztxt FROM t042z
724                               WHERE land1 = 'IN' AND
725                        zlsch = ist_zlsch-zlsch.
726          ist_zlsch-text1 = l_aztxt.
727          MODIFY ist_zlsch  TRANSPORTING text1.
728          CLEAR ist_zlsch.
729        ENDLOOP.
730      ENDIF.
731      SORT ist_zlsch .
732      DELETE ADJACENT DUPLICATES FROM ist_zlsch.
733    *--------------End +001
734    *$*$ End of Changes by Vinod
735    *-----FOR WRITING OF VOUCHER IN DESIRED FORMAT ------------------------*
736      PERFORM printcontrol.
737
738    *---------------------------------------------------------------------*
739    *       FORM OTHER_DETAILS                                            *
740    *---------------------------------------------------------------------*
741    *       ........                                                      *
742    *---------------------------------------------------------------------*
743    FORM other_details.
744
745      SELECT SINGLE * FROM lfa1 WHERE lifnr = inrec-lifnr.                 "" Added by Hrishi N on 01/07/2022
746
747      IF  lfa1-ktokk = 'ZONT' .
748
749    *------- For Alternative payee for posted documents  ------------------*
750    *  SELECT SINGLE * FROM bsec WHERE bukrs = inrec-bukrs
751    *                          AND belnr = inrec-belnr
752    *                          AND gjahr = inrec-gjahr
753    *                          AND buzei = inrec-buzei.
754
755    *  IF sy-subrc = 0 .
756    *    CONCATENATE bsec-name1 bsec-name2
757    *                                     '( alternative party )' INTO name1.
758    *    WRITE: 33 '*' ,bsec-name1(28).     "sym_asterisk  as symbol.
759
760        CONCATENATE lfa1-name1 '( alternative party )' INTO name1.
761        WRITE: 33 '*' ,lfa1-name1.     "sym_asterisk  as symbol.
762
763        tick = 'X'.
764    *  ENDIF.
765
766      ELSE.
767
768    *------ For Alternative payee for parked documents  -------------------*
769        SELECT SINGLE * FROM vbsec WHERE ausbk = inrec-bukrs
770                                AND belnr = inrec-belnr
771                                AND gjahr = inrec-gjahr
772                                AND buzei = inrec-buzei.
773        IF sy-subrc = 0 AND NOT vbsec-name1 IS INITIAL.
774          CONCATENATE vbsec-name1 vbsec-name2
775                                        ' ( Alternative Party )' INTO name1.
776          WRITE: 33 '*' ,vbsec-name1(25).  "sym_asterisk  as symbol.
777          tick = 'X'.
778        ELSE.
779    *      SELECT SINGLE * FROM lfa1 WHERE lifnr = inrec-lifnr.   ""commented by Hrishi N on 01/07/2022
780
781    *      IF sy-subrc = 0 AND inrec-koart = 'K'. "Added by Madhukar 17/08/04  ""commented by Hrishi N on 05/07/2022
782          IF inrec-koart = 'K'.                                                ""added by Hrishi N on 01/07/2022
783    *------ for employees  ------------------------------------------------*
784            IF    lfa1-ktokk = 'VEMP'  OR lfa1-ktokk = 'RETD'.
785    *Modified as per sol mgr not No 3307 by madhukar
786
787              MOVE lfa1-name1 TO name1.
788            ELSE.
789    *----- For normal vendors  --------------------------------------------*
790              CONCATENATE lfa1-name1 lfa1-name2 INTO name1 .
791            ENDIF.
792    *(30007559
793            CLEAR gv_name2.
794            IF inrec-name1 <> ''.
795              gv_name2 = inrec-name1.
796              WRITE: 33 gv_name2(27) NO-GAP, '|' NO-GAP.
797            ELSE.
798    *)30007559
799              WRITE: 33 lfa1-name1(27) NO-GAP, '|' NO-GAP.
800            ENDIF.                                              "*30007559
801          ENDIF.
802        ENDIF.
803    *----for  Customers  --------------------------------------------------*
804
805        SELECT SINGLE * FROM kna1 WHERE kunnr = inrec-kunnr.
806        IF sy-subrc = 0.
807          CONCATENATE kna1-name1 '-' kna1-name2 INTO name1.
808    **(30007559
809          CLEAR gv_name1.
810          IF inrec-name1 <> ''.
811            gv_name1 = inrec-name1.
812            CONCATENATE kna1-name1 inrec-name1 INTO gv_name1 SEPARATED BY space.
813            WRITE: 33  gv_name1(27) NO-GAP,'|' NO-GAP.
814          ELSE.
815    **)30007559
816            WRITE: 33  kna1-name1(27) NO-GAP,'|' NO-GAP.
817          ENDIF.
818        ELSE.
819    *---- For GL payments:from allocation field of line item --------------*
820          IF inrec-hkont <> ' '.
821            hkont = inrec-hkont.
822          ELSE.
823            hkont = inrec-saknr.
824          ENDIF.
825          SELECT SINGLE * FROM ska1 WHERE saknr = hkont.
826          IF sy-subrc = 0.
827            acgrp = ska1-ktoks.
828            IF ( acgrp = 'EMP2' OR acgrp = 'EMP4' OR acgrp = 'EMP6' ) AND
829    inrec-zuonr <> ' '.
830              alloc = inrec-zuonr.
831              len = 10 - strlen( alloc ).
832              DO  len TIMES.
833                CONCATENATE '0' alloc INTO alloc.
834              ENDDO.
835
836              SELECT SINGLE * FROM lfa1 WHERE lifnr =  alloc.
837              IF sy-subrc = 0.
838                CONCATENATE lfa1-name1 lfa1-name2 INTO name1 .
839              ENDIF.
840            ENDIF.
841          ENDIF.
842        ENDIF.
843      ENDIF.
844      IF NOT name1 IS INITIAL.
845        payee = 'X'.
846        IF name1 <> old_name.
847    *----- Caluclate the number of payees derived from the above logic ----*
848          no_payee =   no_payee + 1.
849          old_name = name1.
850        ENDIF.
851      ENDIF.
852
853    ENDFORM.                    "other_details
854
855
856    ************************************************************************
857    FORM other_details1.
858    * Deriving Other Details from Table Payr
859    ************************************************************************
860      SELECT SINGLE * FROM payr WHERE
861       vblnr = inrec-belnr AND
862       zbukr = inrec-bukrs AND
863       gjahr = inrec-gjahr.
864      IF sy-subrc = 0.
865        inrec-chect = payr-chect.          "Check No
866        inrec-laufd = payr-laufd.          "Check Date
867      ENDIF.
868    ENDFORM.                    "other_details1
869
870
871
872
873    ************************************************************************
874    FORM budat.
875    ************************************************************************
876      IF fdate EQ '00000000' AND tdate EQ '00000000'. "Posting Date
877        PERFORM cpudate.
878      ELSEIF fdate NE '00000000' AND tdate NE '00000000'.
879        IF bkpf-budat BETWEEN fdate AND tdate.
880          PERFORM cpudate.
881        ENDIF.
882      ELSEIF fdate NE '00000000' AND tdate EQ '00000000'.
883        tdate = sy-datum.
884        IF bkpf-budat BETWEEN fdate AND tdate.
885          PERFORM cpudate.
886        ENDIF.
887      ELSEIF fdate EQ '00000000' AND tdate NE '00000000'.
888        IF bkpf-budat LE tdate.
889          PERFORM cpudate.
890        ENDIF.
891      ENDIF.
892
893    ENDFORM.                    "budat
894    *---------------------------------------------------------------------*
895    *       FORM CPUDATE                                                  *
896    *---------------------------------------------------------------------*
897    FORM cpudate.
898      IF fcdate EQ '00000000' AND tcdate EQ '00000000'. "CPUDate
899        MOVE-CORRESPONDING bkpf TO header.
900      ELSEIF fcdate NE '00000000' AND tcdate NE '00000000'.
901        IF bkpf-budat BETWEEN fcdate AND tcdate.
902          MOVE-CORRESPONDING bkpf TO header.
903        ENDIF.
904      ELSEIF fcdate NE '00000000' AND tcdate EQ '00000000'.
905        tcdate = sy-datum.
906        IF bkpf-budat BETWEEN fcdate AND tcdate.
907          MOVE-CORRESPONDING bkpf TO header.
908        ENDIF.
909      ELSEIF fcdate EQ '00000000' AND tcdate NE '00000000'.
910        IF bkpf-budat LE tcdate.
911          MOVE-CORRESPONDING bkpf TO header.
912
913        ENDIF.
914      ENDIF.
915    ENDFORM.                    "cpudate
916
917    ************************************************************************
918    FORM fm_cop. " add by rohit on 16.04.2026
919
920      " SOC BY ROHIT ON 16.04.2026
921      break abapuser02.
922
923    **  LOOP AT inrec INTO DATA(ls_rec).
924    **
925    **    IF ls_rec-pswsl = 'COP'.
926    **
927    **      wrbtr_input = ls_rec-wrbtr.
928    **      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
929    **        EXPORTING
930    **          currency        = 'COP'
931    **          amount_internal = wrbtr_input
932    **        IMPORTING
933    **          amount_display  = wrbtr_output
934    **        EXCEPTIONS
935    **          internal_error  = 1
936    **          OTHERS          = 2.
937    **      IF sy-subrc <> 0.
938    *** Implement suitable error handling here
939    **      ENDIF.
940    **      ls_rec-wrbtr = wrbtr_output.
941    **
942    **      dmbtr_input  = ls_rec-dmbtr.
943    **      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
944    **        EXPORTING
945    **          currency        = 'COP'
946    **          amount_internal = dmbtr_input
947    **        IMPORTING
948    **          amount_display  = dmbtr_output
949    **        EXCEPTIONS
950    **          internal_error  = 1
951    **          OTHERS          = 2.
952    **      IF sy-subrc <> 0.
953    *** Implement suitable error handling here
954    **      ENDIF.
955    **      ls_rec-dmbtr = dmbtr_output.
956    **      MODIFY : inrec FROM ls_rec.
957    **
958    **      CLEAR ls_rec.
959    **
960    **    ENDIF.
961    **
962    **  ENDLOOP.
963
964
965    *  IF ls_rec-pswsl = 'COP'.
966
967    *    wrbtr_input = ls_rec-wrbtr.
968      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
969        EXPORTING
970          currency        = 'COP'
971          amount_internal = wrbtr_input
972        IMPORTING
973          amount_display  = wrbtr_output
974        EXCEPTIONS
975          internal_error  = 1
976          OTHERS          = 2.
977      IF sy-subrc <> 0.
978    * Implement suitable error handling here
979      ENDIF.
980    *    ls_rec-wrbtr = wrbtr_output.
981
982
983    *  ENDIF.
984
985
986      " EOC BY ROHIT ON 16.04.2026
987
988
989
990
991    ENDFORM.
992
993
994    FORM printcontrol.
995
996
997    *        Printing of the Vouchers
998    ************************************************************************
999      SELECT SINGLE * FROM t001 WHERE bukrs = bkpf-bukrs.
1000
1001     SORT it_bankkey BY lifnr.
1002     DELETE ADJACENT DUPLICATES FROM it_bankkey
1003                                COMPARING lifnr belnr.
1004
1005     LOOP AT header.
1006       REFRESH intspl.
1007   *Added on 03/08/2001 by Madhukar
1008   *    on change of header-belnr.
1009   *    new-page.
1010   *    endon.
1011   *End of addition
1012
1013       READ TABLE inrec WITH KEY bukrs = header-bukrs
1014                            belnr = header-belnr
1015                             gjahr = header-gjahr.
1016       IF sy-subrc = 0.
1017         SKIP 4.
1018         IF tbukrs = 'OVL' .
1019           WRITE: /80 'ONGC VIDESH LIMITED'.
1020         ELSEIF tbukrs = 'OBV'.
1021           WRITE: /80 'ONGC NILE GANGA B.V.'.
1022         ELSE .
1023           WRITE: /80 'OIL  &  NATURAL  GAS  CORPORATION '.
1024         ENDIF .
1025         WRITE:/80 'Project : ', t001-butxt.
1026         WRITE: /125 'Print Date   : ',sy-datum. "header-cpudt.
1027         WRITE sy-uline(190).
1028         WRITE: / 'Doc.No.       : ', header-belnr.
1029         WRITE: 40  'Proj.Code    : ', header-bukrs.
1030         WRITE: 100 'Voucher Type : '.
1031   *------- Voucher Types  -----------------------------------------------*
1032         LOOP AT inrec WHERE  umskz NE space AND
1033                              bukrs = header-bukrs AND
1034                              belnr = header-belnr AND
1035                              gjahr = header-belnr.
1036           CASE inrec-umskz.
1037             WHEN 'F'.
1038               WRITE : 'Advance Payment Request'.
1039             WHEN 'P'.
1040               WRITE : 'Payment Request'.
1041             WHEN 'G'.
1042               WRITE : 'Bank Guarantee'.
1043             WHEN OTHERS.
1044           ENDCASE.
1045         ENDLOOP.
1046         IF sy-subrc NE 0 OR (  inrec-umskz NE 'F' AND inrec-umskz NE 'P'
1047                                AND  inrec-umskz NE 'G' ).
1048           PERFORM doctype.
1049         ENDIF.
1050
1051   *------ Print Header information  -------------------------------------*
1052         WRITE: / 'Doc.Pstg.Dt   : '.
1053         IF header-budat <> '00000000'.
1054           WRITE:  header-budat UNDER header-belnr.
1055         ELSE.
1056           WRITE: ' '.
1057         ENDIF.
1058         WRITE: 40 'Doc.Type     : '.
1059         WRITE: header-blart UNDER header-bukrs.
1060   *Commented and code included to pick user name from User-ID.
1061   *      SELECT SINGLE * FROM USR03 WHERE BNAME = HEADER-USNAM.
1062         SELECT SINGLE * FROM user_addr WHERE bname = header-usnam.
1063         CONCATENATE user_addr-name_first user_addr-name_last INTO
1064                                             namex SEPARATED BY space.
1065   *     CONCATENATE USR03-NAME1 USR03-NAME2 INTO NAMEX SEPARATED BY SPACE.
1066         WRITE: 100 'Entered By   : ', namex.
1067         WRITE:/ 'Ref.Doc.No.   : ', header-xblnr UNDER header-budat.
1068         WRITE: 40 'Doc.Dt.  :', header-bldat UNDER header-blart.
1069         WRITE: 100 'Header Text  : ', header-bktxt UNDER header-usnam.
1070         IF header-bvorg <> space.
1071           WRITE:/ 'Cross Comp Doc:',header-bvorg UNDER header-xblnr.
1072         ENDIF.
1073         WRITE sy-uline(190).
1074
1075   *---------------------+001
1076
1077         IF NOT ist_zlsch[] IS INITIAL.
1078           WRITE:/ 'Payment method :'.
1079           LOOP AT ist_zlsch WHERE belnr = header-belnr.
1080             IF sy-tabix = 1.
1081               WRITE : 17 ist_zlsch-text1 .
1082             ELSE.
1083               WRITE :/17 ist_zlsch-text1 .
1084             ENDIF.
1085           ENDLOOP.
1086         ENDIF.
1087   *------------------------End-+001
1088
1089   *$*$ Changed by Vinod on 12th April 2001
1090
1091   *      LOOP AT it_bankkey.
1092   *        READ TABLE inrec WITH KEY lifnr = it_bankkey-lifnr.
1093   *        IF sy-subrc = 0.
1094   *          NEW-LINE.
1095   *          WRITE :    'Vendor : ',  it_bankkey-lifnr,
1096   *                  30 'Bank Key:' , it_bankkey-bankey,
1097   *                  65 'Bank Account:', it_bankkey-bankacc.
1098   *        ENDIF.
1099   *      ENDLOOP.
1100
1101   *$*$ End of changes by Vinod
1102
1103   *$ Changed by Madhukar on 24th May 2001
1104         LOOP AT it_bankkey WHERE  belnr = header-belnr.
1105           IF sy-subrc = 0.
1106             NEW-LINE.
1107             WRITE :    'Vendor : ',  it_bankkey-lifnr,
1108                     30 'Bank Key:' , it_bankkey-bankey,
1109                     65 'Bank Account:', it_bankkey-bankacc.
1110           ENDIF.
1111         ENDLOOP.
1112
1113   *$*$ End of Changes by Madhukar
1114         SKIP 2.
1115         WRITE sy-uline(190).
1116   *---List Header for  LINE ITEMS  --------------------------------------*
1117         WRITE:/ '|' NO-GAP,  'Ln.' NO-GAP,  '|' NO-GAP,'Pt' NO-GAP,'|' NO-GAP,
1118                                                        'S' NO-GAP,  '|'NO-GAP,
1119                                            'Acct.          ' NO-GAP,'|'NO-GAP,
1120                ' BA  ' NO-GAP,'|' NO-GAP,'A/C Description            ' NO-GAP,
1121                                    '|'NO-GAP,'Amount                ' NO-GAP ,
1122                                                                     '|'NO-GAP,
1123                                           'Amount                ' NO-GAP,'|'
1124                                                                        NO-GAP,
1125                    'Tx' NO-GAP,  '|' NO-GAP, 'Cost       ' NO-GAP, '|' NO-GAP,
1126                              'Budget Item ' NO-GAP, '|' NO-GAP, 'Description'.
1127
1128         WRITE:/ '|' NO-GAP, 'It.'NO-GAP, '|'NO-GAP, 'Ky' NO-GAP,'|' NO-GAP,
1129
1130                             'G|' NO-GAP, 'Head           'NO-GAP,'|'NO-GAP,
1131                                                  '    ' NO-GAP,' |' NO-GAP,
1132                             '                           ' NO-GAP,'|'NO-GAP,
1133                            'Debit                 'NO-GAP,      '|' NO-GAP,
1134                 'Credit                'NO-GAP, '|'NO-GAP, 'Cd' NO-GAP,'|'
1135                                      NO-GAP,
1136                                                  'Center/WBS '
1137          NO-GAP, '|' NO-GAP,'Order       'NO-GAP,'|' NO-GAP, '           '.
1138
1139         WRITE sy-uline(190).
1140   *-----Printing Line item data  ----------------------------------------*
1141         LOOP AT inrec WHERE belnr = header-belnr.
1142           CLEAR hkont.
1143           WRITE :/ '|' NO-GAP,inrec-buzei NO-GAP,'|'NO-GAP,inrec-bschl NO-GAP,
1144                                     '|' NO-GAP,inrec-umskz NO-GAP, '|' NO-GAP.
1145   *---- Account group Logic  --------------------------------------------*
1146           CASE inrec-koart.
1147             WHEN 'D'.
1148   *Business are included on 17-03-2001
1149               WRITE : inrec-kunnr NO-GAP,'     |' NO-GAP,
1150               inrec-gsber NO-GAP,' |' NO-GAP,
1151        '                          ','|' NO-GAP.
1152             WHEN 'K'.
1153   *Business are included on 17-03-2001
1154               WRITE : inrec-lifnr NO-GAP,'     |' NO-GAP,
1155               inrec-gsber NO-GAP,' |' NO-GAP,
1156        '                          ','|' NO-GAP.
1157             WHEN 'S'.
1158               IF inrec-hkont <> ' '.
1159                 hkont = inrec-hkont.
1160               ELSE.
1161                 hkont = inrec-saknr.
1162               ENDIF.
1163               SELECT SINGLE * FROM skat WHERE saknr = hkont AND
1164                ktopl = 'ONGC'.
1165   * changes made by  request to include IUT vch also
1166               IF inrec-bukrs <> header-bukrs.
1167                 WRITE : hkont NO-GAP,'     |'NO-GAP,
1168   *                  INREC-BUKRS NO-GAP,' | ' NO-GAP,
1169                            inrec-gsber NO-GAP,' |'
1170           NO-GAP,
1171              skat-txt20(20) NO-GAP,'         |' NO-GAP.
1172               ELSE.
1173                 IF hkont = '0000120102' OR hkont = '0000120103'.
1174                   SELECT SINGLE * FROM bseg WHERE bukrs = inrec-bukrs
1175                     AND gjahr = inrec-gjahr AND belnr = inrec-belnr
1176                     AND buzei = inrec-buzei AND hkont = hkont.
1177                   IF bseg-zuonr+(4) <> inrec-bukrs.
1178                     WRITE : hkont NO-GAP,'     |' NO-GAP,
1179   *                  BSEG-ZUONR+(4) NO-GAP,' |' NO-GAP,
1180                                inrec-gsber NO-GAP,
1181              ' |' NO-GAP,
1182                  skat-txt20(20) NO-GAP,'       |' NO-GAP.
1183                   ELSE.
1184                     WRITE : hkont NO-GAP,'     |'NO-GAP,
1185   *                  '    ' NO-GAP,' |' NO-GAP,
1186                 inrec-gsber NO-GAP,' |' NO-GAP,
1187                  skat-txt20(20) NO-GAP,'    |' NO-GAP.
1188                   ENDIF.
1189                 ELSE.
1190                   WRITE : hkont NO-GAP,'     |'NO-GAP,
1191   *                  '    ' NO-GAP,' |' NO-GAP,
1192                                 inrec-gsber NO-GAP,' |' NO-GAP,
1193                skat-txt20(20) NO-GAP,'       |' NO-GAP.
1194                 ENDIF.
1195               ENDIF.
1196   ************
1197             WHEN 'A'.
1198               IF inrec-anln1 = '*'.
1199                 IF inrec-hkont <> ' '.
1200                   hkont = inrec-hkont.
1201                 ELSE.
1202                   hkont = inrec-saknr.
1203                 ENDIF.
1204                 SELECT SINGLE * FROM skat WHERE saknr = hkont AND
1205                  ktopl = 'ONGC'.
1206   * changes  for IUT voucher prn
1207                 IF inrec-bukrs <> header-bukrs.
1208                   WRITE : hkont NO-GAP, '  |' NO-GAP,
1209   *INREC-BUKRS NO-GAP,'|' NO-GAP,
1210                      inrec-gsber NO-GAP,' |' NO-GAP,
1211                         skat-txt20(20) NO-GAP,'       |' NO-GAP.
1212                   IF hkont = '0000120102' OR hkont = '0000120103'.
1213                     SELECT SINGLE * FROM bseg WHERE bukrs = inrec-bukrs
1214                       AND gjahr = inrec-gjahr AND belnr = inrec-belnr
1215                       AND buzei = inrec-buzei AND hkont = hkont.
1216                     IF bseg-zuonr+(4) <> inrec-bukrs.
1217                       WRITE : hkont NO-GAP,'  |'NO-GAP,
1218   *                  BSEG-ZUONR+(4) NO-GAP,' |' NO-GAP,
1219                inrec-gsber NO-GAP,' |' NO-GAP,
1220                    skat-txt20(20) NO-GAP,'       |' NO-GAP.
1221                     ELSE.
1222                       WRITE : hkont NO-GAP ,'     |'NO-GAP,
1223   *                  '    ' NO-GAP,' |' NO-GAP,
1224                                     inrec-gsber NO-GAP,' |' NO-GAP,
1225                    skat-txt20(20) NO-GAP,'       |' NO-GAP.
1226                     ENDIF.
1227                   ELSE.
1228                     WRITE : hkont NO-GAP, '  |' NO-GAP,
1229   *      '    ' NO-GAP,'|' NO-GAP,
1230                        inrec-gsber NO-GAP,' |' NO-GAP,
1231                     skat-txt20(20) NO-GAP,'       |' NO-GAP.
1232                   ENDIF.
1233                 ENDIF.
1234   *************************************
1235               ELSE.
1236                 WRITE: inrec-anln1 NO-GAP,'   |' NO-GAP.
1237                 SELECT SINGLE * FROM anla WHERE anln1 = inrec-anln1 AND bukrs = tbukrs.
1238                 WRITE : anla-txt50(30) NO-GAP,'|' NO-GAP.
1239               ENDIF.
1240             WHEN 'M'.
1241               IF inrec-hkont <> ' '.
1242                 hkont = inrec-hkont.
1243               ELSE.
1244                 hkont = inrec-saknr.
1245               ENDIF.
1246               SELECT SINGLE * FROM skat WHERE saknr = hkont AND
1247                ktopl = 'ONGC'.
1248               WRITE: inrec-hkont NO-GAP,'     |' NO-GAP,inrec-gsber NO-GAP
1249                      , ' |' NO-GAP,
1250                                skat-txt20(20), '      |' NO-GAP.
1251   *Modified as per sol mgr not No 3307 by madhukar
1252             WHEN OTHERS.
1253               REJECT.
1254           ENDCASE.
1255   *----- Store the bank line item text in a variable --------------------*
1256
1257   * start of comment on 22102003 by sab_lax required by rohit
1258   *        IF ( hkont BETWEEN '0000091211' AND '0000091299'
1259   * end of comment on 22102003 by sab_lax
1260
1261   * start of addition on 22102003 by sab_lax required by rohit
1262           IF ( hkont IN hkont_bank_range
1263   * end of addition on 22102003 by sab_lax
1264               AND  hkont+9(1)  CA '02468' )  OR  " hkont = '0000091201'.
1265
1266   * commented by sab_lax on 22102003 required by rohit
1267   *           ( hkont BETWEEN '0000091201' AND '0000091210' ).
1268   * end of comment by sab_lax on 22102003
1269
1270   * added by sab_lax on 22102003 required by rohit
1271             ( hkont IN hkont_cash_range ).
1272   * end of addition by sab_lax on 22102003
1273
1274   * above might change for Bombay implementation for > 1 cash accts
1275             banktxt = inrec-sgtxt.
1276           ENDIF.
1277   *--------------------For the Debit and Credit amounts------------------*
1278           IF inrec-shkzg = 'S'.          "debit
1279   *   concatenate inrec-pswsl inrec-dmbtr into temp_amount_lc.
1280             IF header-waers = 'JPY'.
1281               CLEAR gv_wrbtr.
1282               PERFORM convert_to_nondecimal USING inrec-wrbtr CHANGING gv_wrbtr.
1283
1284               IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1285                 wrbtr_input =  gv_wrbtr.
1286                 PERFORM fm_cop.
1287                 gv_wrbtr = wrbtr_output.
1288                 CLEAR : wrbtr_input , wrbtr_output.
1289               ENDIF." EOC BY ROHIT ON 16.04.2026
1290
1291               WRITE : 61 header-waers NO-GAP,65 gv_wrbtr LEFT-JUSTIFIED  NO-GAP
1292                                                                                   ,
1293                                                                     83 '|' NO-GAP .
1294   *            WRITE : 61 header-waers NO-GAP,65 inrec-wrbtr LEFT-JUSTIFIED  NO-GAP
1295   *                                                                                ,
1296   *                                                                  83 '|' NO-GAP .
1297             ELSE.
1298               IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1299                 wrbtr_input =  inrec-wrbtr.
1300                 PERFORM fm_cop.
1301                 inrec-wrbtr = wrbtr_output.
1302                 CLEAR : wrbtr_input , wrbtr_output.
1303               ENDIF." EOC BY ROHIT ON 16.04.2026
1304
1305               WRITE : 61 header-waers NO-GAP,65 inrec-wrbtr LEFT-JUSTIFIED  NO-GAP
1306                                                                                   ,
1307                                                                     83 '|' NO-GAP .
1308             ENDIF.
1309   **************************************************************
1310           ELSEIF inrec-shkzg = 'H'.      "credit
1311             IF header-waers = 'JPY'.
1312               CLEAR gv_wrbtr.
1313               PERFORM convert_to_nondecimal USING inrec-wrbtr CHANGING gv_wrbtr.
1314
1315               IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1316                 wrbtr_input =  gv_wrbtr.
1317                 PERFORM fm_cop.
1318                 gv_wrbtr = wrbtr_output.
1319                 CLEAR : wrbtr_input , wrbtr_output.
1320               ENDIF." EOC BY ROHIT ON 16.04.2026
1321
1322               WRITE : '                     ','|' NO-GAP,84  header-waers NO-GAP
1323                                                                              ,88
1324                                                gv_wrbtr LEFT-JUSTIFIED NO-GAP.
1325   *            WRITE : '                     ','|' NO-GAP,84  header-waers NO-GAP
1326   *                                                                           ,88
1327   *                                             inrec-wrbtr LEFT-JUSTIFIED NO-GAP.
1328             ELSE.
1329
1330               IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1331                 wrbtr_input =   inrec-wrbtr.
1332                 PERFORM fm_cop.
1333                 inrec-wrbtr = wrbtr_output.
1334                 CLEAR : wrbtr_input , wrbtr_output.
1335               ENDIF." EOC BY ROHIT ON 16.04.2026
1336
1337               WRITE : '                     ','|' NO-GAP,84  header-waers NO-GAP
1338                                                                              ,88
1339                                                inrec-wrbtr LEFT-JUSTIFIED NO-GAP.
1340             ENDIF.
1341           ENDIF.
1342   *--------------------Tax Code------------------------------------------*
1343           WRITE :106 '|' NO-GAP, inrec-qsskz NO-GAP,109 '|'.
1344           "121 '|',134 '|'.
1345   * --------------------Cost Center/WBS ELEMENT -------------------------*
1346   * ---- Inrec-projn has been changed to inrec-projk by SB on 8/12-------*
1347           IF NOT ( inrec-projk IS INITIAL ).
1348             WRITE : 110 inrec-projk NO-GAP,121 '|' NO-GAP,134 '|' NO-GAP.
1349           ELSE.
1350             WRITE : 110 inrec-kostl NO-GAP, 121 '|' NO-GAP,134 '|' NO-GAP.
1351           ENDIF.
1352   *--------------------Budget Item---------------------------------------*
1353           WRITE: 122 inrec-aufnr NO-GAP,'|' NO-GAP,134 '|' NO-GAP.
1354           WRITE:  inrec-sgtxt(35).
1355           totamt = header-netamt.
1356   *-------------------- Net debit/credit amount -------------------------*
1357           PERFORM dr_cr_total.
1358           PERFORM  other_details.
1359           PERFORM spl_ind.
1360   *donot print next line for same curr key from header
1361   *      if header-waers <> 'INR'.
1362           SELECT SINGLE * FROM t001 WHERE bukrs = header-bukrs.
1363           IF header-waers <> t001-waers.
1364             IF inrec-shkzg = 'S'.        "debit
1365   *   concatenate inrec-pswsl inrec-dmbtr into temp_amount_lc.
1366
1367               IF  t001-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1368                 wrbtr_input =   inrec-dmbtr.
1369                 PERFORM fm_cop.
1370                 inrec-dmbtr = wrbtr_output.
1371                 CLEAR : wrbtr_input , wrbtr_output.
1372               ENDIF." EOC BY ROHIT ON 16.04.2026
1373
1374               WRITE :/'|',5 '|',8 '|',10 '|',26 '|',32 '|',60 '|',61
1375    t001-waers NO-GAP,65 inrec-dmbtr LEFT-JUSTIFIED ,83 '|' ,106 '|',109
1376   '|'
1377   , 121 '|',134 '|'.
1378             ELSEIF inrec-shkzg = 'H'.    "credit
1379   *   concatenate inrec-pswsl inrec-dmbtr into temp_amount_fc.
1380               IF  t001-waers = 'JPY'.
1381                 CLEAR gv_wrbtr.
1382                 PERFORM convert_to_nondecimal USING inrec-dmbtr CHANGING gv_wrbtr.
1383
1384                 IF  t001-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1385                   wrbtr_input =    gv_wrbtr.
1386                   PERFORM fm_cop.
1387                   gv_wrbtr = wrbtr_output.
1388                   CLEAR : wrbtr_input , wrbtr_output.
1389                 ENDIF." EOC BY ROHIT ON 16.04.2026
1390
1391                 WRITE : /'|',5 '|',8 '|',10 '|',26 '|',32 '|',60 '|', 83 '|',
1392                                       84 t001-waers NO-GAP,88
1393              gv_wrbtr LEFT-JUSTIFIED NO-GAP ,106 '|',109 '|', 121 '|',134
1394              '|'.
1395               ELSE.
1396
1397                 IF  t001-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
1398                   wrbtr_input =     inrec-dmbtr.
1399                   PERFORM fm_cop.
1400                   inrec-dmbtr = wrbtr_output.
1401                   CLEAR : wrbtr_input , wrbtr_output.
1402                 ENDIF." EOC BY ROHIT ON 16.04.2026
1403
1404                 WRITE : /'|',5 '|',8 '|',10 '|',26 '|',32 '|',60 '|', 83 '|',
1405                                       84 t001-waers NO-GAP,88
1406              inrec-dmbtr LEFT-JUSTIFIED NO-GAP ,106 '|',109 '|', 121 '|',134
1407              '|'.
1408               ENDIF.
1409             ENDIF.
1410           ENDIF.
1411   *donot print next line for same curr key
1412         ENDLOOP.
1413   *--------------------Total Amount in words ----------------------------*
1414         PERFORM convert USING totamt.
1415
1416         WRITE sy-uline(190).
1417         net_dr = - net_dr .
1418         net_dr_lc = - net_dr_lc.
1419
1420         IF header-waers = 'JPY'.
1421           CLEAR :gv_wrbtr,gv_wrbtr_cr.
1422           PERFORM convert_to_nondecimal USING net_dr CHANGING gv_wrbtr.
1423           PERFORM convert_to_nondecimal USING net_cr CHANGING gv_wrbtr_cr.
1424           WRITE: / 'Total' ,64 header-waers NO-GAP,68 gv_wrbtr LEFT-JUSTIFIED
1425         NO-GAP,85 header-waers NO-GAP, 89
1426         gv_wrbtr_cr LEFT-JUSTIFIED NO-GAP.
1427         ELSE.
1428           WRITE: / 'Total' ,64 header-waers NO-GAP,68 net_dr LEFT-JUSTIFIED
1429         NO-GAP,85 header-waers NO-GAP, 89
1430         net_cr LEFT-JUSTIFIED NO-GAP.
1431         ENDIF.
1432   *      if header-waers <> 'INR'.
1433         IF header-waers <> t001-waers.
1434           IF t001-waers = 'JPY'.
1435             CLEAR :gv_wrbtr,gv_wrbtr_cr.
1436             PERFORM convert_to_nondecimal USING net_dr_lc CHANGING gv_wrbtr.
1437             PERFORM convert_to_nondecimal USING net_cr_lc CHANGING gv_wrbtr_cr.
1438             WRITE: / 'Total' ,64 t001-waers,68 gv_wrbtr LEFT-JUSTIFIED
1439       NO-GAP,85 t001-waers, 89
1440       gv_wrbtr_cr LEFT-JUSTIFIED NO-GAP.
1441           ELSE.
1442             WRITE: / 'Total' ,64 t001-waers,68 net_dr_lc LEFT-JUSTIFIED
1443       NO-GAP,85 t001-waers, 89
1444       net_cr_lc LEFT-JUSTIFIED NO-GAP.
1445           ENDIF.
1446         ENDIF.
1447         WRITE sy-uline(190).
1448   *--------------------Name of Receipient--------------------------------*
1449         IF totamt < 0.
1450   *-------------------- FOR RECEIPT VOUCHERS ----------------------------*
1451           WRITE:/ 'Received from :: Ms./Mr./Mrs.:'.
1452           IF   no_payee = 1.
1453             WRITE : name1.
1454           ELSEIF no_payee > 1.
1455             WRITE: '   Please refer the description '.
1456           ELSEIF no_payee IS INITIAL.
1457             WRITE : banktxt.             " PRINT BANK ITEM TEXT
1458           ENDIF.
1459
1460           WRITE sy-uline(190).
1461           totalamt = abs( totamt ).
1462           WRITE : / 'Total Amt. received : Rs.',totalamt.
1463           WRITE :/ 'Amount in words', word.
1464           SKIP 1.
1465         ELSEIF totamt > 0.
1466   *--------------------FOR PAYMENT VOUCHERS -----------------------------*
1467           WRITE:/ 'Pay to:: Ms./Mr./Mrs.:'.
1468           IF   no_payee = 1.
1469   **(30007559
1470             IF NOT gv_name1 IS INITIAL.
1471               WRITE : gv_name1.
1472             ELSE.
1473   **}30007559
1474               WRITE : name1.
1475             ENDIF. "**(30007559 if part added
1476           ELSEIF no_payee > 1.
1477             WRITE: '   Please refer the description '.
1478           ELSEIF no_payee IS INITIAL.
1479             WRITE : banktxt.             " PRINT BANK ITEM TEXT
1480           ENDIF.
1481           WRITE sy-uline(190).
1482           totalamt = abs( totamt ).
1483
1484           WRITE : / 'Total Amt. to be Paid :', header-waers, totalamt.
1485   *currency ' '.
1486           WRITE :/ 'Amount in words', word.
1487           SKIP 1.
1488         ENDIF.
1489
1490         IF tick = 'X'.
1491           WRITE: / '*    Alternative Party '.
1492         ENDIF.
1493         SKIP 1.
1494         WRITE :/ 'Prepared By    : '.
1495   *--------------------Memo No for receipts & payments only--------------*
1496         IF NOT totamt IS INITIAL.
1497           WRITE: 45 'Memorandum No.     : '.
1498         ENDIF.
1499         SKIP 1.
1500         WRITE :/ 'Checked By     : ' .
1501   *--------------------Payment received----------------------------------*
1502         IF totamt > 0.
1503           WRITE : 45 'Payment Received.'.
1504         ENDIF.
1505   *--------------------Cashier for receipts & payments only -------------*
1506         IF NOT totamt IS INITIAL.
1507           WRITE : 100 'Cashier  : '.
1508         ENDIF.
1509         SKIP 1.
1510         WRITE :/ 'Authorised By  : '.
1511   *     payment received
1512         IF totamt > 0.
1513           WRITE : 45 'Signature of Payee : '.
1514         ENDIF.
1515   *     Officer is for receipts & payments
1516         IF NOT totamt IS INITIAL.
1517           WRITE : 100 'Officer  : '.
1518         ENDIF.
1519         SKIP 1.
1520         DESCRIBE TABLE intspl LINES sglno.
1521         IF NOT sglno IS INITIAL.
1522           WRITE :/ 'Legend for Spl GL indicators:'.
1523           WRITE sy-uline(190).
1524           LOOP AT intspl.
1525             WRITE :/ intspl-umskz,':',20 intspl-desc.
1526           ENDLOOP.
1527         ENDIF.
1528
1529         NEW-PAGE.
1530         CLEAR : totamt, word,inrec,hkont,no_payee,name1,old_name, tick,
1531                 net_cr, net_dr,payee,banktxt,net_cr_lc,net_dr_lc.
1532
1533       ENDIF.
1534     ENDLOOP.
1535
1536   ENDFORM.                    "printcontrol
1537
1538   ************************************************************************
1539   FORM doctype.
1540   *    Function for checking Document Type
1541   ************************************************************************
1542     MOVE header-blart TO blart.
1543     SET LOCALE LANGUAGE sy-langu.
1544     TRANSLATE blart TO UPPER CASE.
1545     CASE blart.
1546       WHEN 'BU' OR 'BP' OR 'EP' OR 'KZ' OR 'LB' OR 'ZP' OR 'KA'.
1547         WRITE: 'Bank Payment'.
1548       WHEN 'BR' OR 'DZ' OR 'KI' OR 'UB' .
1549         WRITE: 'Bank Receipt'.
1550       WHEN 'CP' OR 'CU' OR 'EC' OR 'LC' OR 'OC' .
1551         WRITE: 'Cash Payment'.
1552       WHEN 'CR' OR 'UC'.
1553         WRITE: 'Cash Receipt'.
1554       WHEN 'EB' OR 'OB' OR 'KC' OR 'KR' OR 'KS' OR 'RV'.
1555         WRITE : 'Invoice'.
1556       WHEN 'AB' OR 'DJ' OR 'IU' OR 'KJ' OR 'PJ' OR 'RG' OR 'SA'.
1557         WRITE : 'Journal Voucher'.
1558       WHEN 'AA' OR 'AF'.
1559         WRITE : 'Asset Voucher'.
1560       WHEN 'GR' OR 'GI' OR 'GX'.
1561         WRITE : 'Material Voucher'.
1562       WHEN 'RK' OR 'RD' OR 'RP' OR 'GL' OR 'RC' OR 'RR' OR 'ER'.
1563         WRITE : 'Reversal Voucher'.
1564       WHEN 'ES' .
1565         WRITE : 'Salary Voucher'.
1566       WHEN 'ZV' .
1567         WRITE : 'Clearing Document'.
1568       WHEN 'BG' .
1569         WRITE : 'Bank Guarantee'.
1570       WHEN 'DA'.
1571         WRITE : 'Customer Advance/Deposit'.
1572       WHEN 'TD'.
1573         WRITE : 'TDS Voucher'.
1574     ENDCASE.
1575   ENDFORM.                    "doctype
1576   *--------------------------------------------------------------------- *
1577   *       FORM CONVERT                                                   *
1578   *       Function to convert amount from figures to words               *
1579   *--------------------------------------------------------------------- *
1580   FORM convert USING totamt.
1581   *FM Y_FI_CONVERT_AMOUNT was replaced by ZFI_AMOUNT_CONVERT for Currency
1582   *for Sudan Company code as requested by Mr Rohit on 12/01/06-Madhukar
1583     CALL FUNCTION 'ZFI_AMT_WRDS_CONVERT'
1584       EXPORTING
1585         amt    = totamt
1586         curren = header-waers
1587       IMPORTING
1588         word   = word.
1589     CONDENSE word .
1590   ENDFORM.                    "convert
1591   *&---------------------------------------------------------------------*
1592   *&      Form  CALCULATE_NET_AMOUNT
1593   *----------------------------------------------------------------------*
1594   FORM calculate_net_amount.
1595
1596     IF bseg-shkzg = 'H'.
1597   *start of change 12/01/06 As requested by Rohit
1598   *    netamt = netamt + bseg-dmbtr.      "bseg-wrbtr.
1599       netamt = netamt + bseg-wrbtr.      "bseg-wrbtr.
1600     ELSEIF bseg-shkzg = 'S'.
1601   *    netamt = netamt - bseg-dmtr.      "bseg-wrbtr.
1602       netamt = netamt - bseg-wrbtr.      "bseg-wrbtr.
1603   *end of change 12/01/06 As requested by Rohit
1604
1605     ENDIF.
1606
1607   ENDFORM.                               " CALCULATE_NET_AMOUNT
1608   *&---------------------------------------------------------------------*
1609   *&      Form  DR_CR_TOTAL
1610   *&---------------------------------------------------------------------*
1611   FORM dr_cr_total.
1612     IF inrec-shkzg = 'H'.
1613       net_cr_lc = net_cr_lc + inrec-dmbtr.
1614       net_cr = net_cr + inrec-wrbtr.
1615     ELSEIF inrec-shkzg = 'S'.
1616       net_dr_lc = net_dr_lc - inrec-dmbtr.
1617       net_dr = net_dr - inrec-wrbtr.
1618     ENDIF.
1619
1620   ENDFORM.                               " DR_CR_TOTAL
1621   *&---------------------------------------------------------------------*
1622   *&      Form  SPL_IND
1623   *&---------------------------------------------------------------------*
1624   FORM spl_ind.
1625     CHECK inrec-umskz NE space.
1626     READ TABLE intspl WITH KEY umskz = inrec-umskz.
1627     IF sy-subrc <> 0.
1628       intspl-umskz = inrec-umskz.
1629       SELECT SINGLE * FROM t074t WHERE shbkz = inrec-umskz
1630                                 AND spras = 'E'.
1631       intspl-desc = t074t-ltext.
1632       APPEND intspl.
1633     ENDIF.
1634   ENDFORM.                               " SPL_IND
1635
1636   *&---------------------------------------------------------------------*
1637   *&      Form  ADD_ENTRIES_BSEG
1638   *&---------------------------------------------------------------------*
1639   *       text
1640   *----------------------------------------------------------------------*
1641   *  -->  p1        text
1642   *  <--  p2        text
1643   *----------------------------------------------------------------------*
1644   FORM add_entries_bseg TABLES p_it_bseg      STRUCTURE bseg
1645                                p_it_with_item STRUCTURE with_item
1646                         USING  p_it_bkpf      STRUCTURE bkpf.
1647   *----------------------------------------------------------------------*
1648     DATA : wrk_lines TYPE i.
1649
1650     DESCRIBE TABLE p_it_bseg LINES wrk_lines.
1651
1652     LOOP AT p_it_with_item.
1653       CLEAR p_it_bseg.
1654       p_it_bseg-mandt = sy-mandt.
1655       p_it_bseg-bukrs = tbukrs.
1656   *   p_it_bseg-belnr = belnr-low. "190501-yaseen - multiple doc pbm
1657       p_it_bseg-belnr = p_it_with_item-belnr. "190501-yaseen as above
1658       p_it_bseg-gjahr = gjahr.
1659
1660       wrk_lines = wrk_lines + 1.
1661       p_it_bseg-buzei = wrk_lines.
1662       p_it_bseg-koart = 'S'.
1663
1664       p_it_bseg-qsskz = p_it_with_item-wt_withcd.
1665
1666       IF p_it_with_item-wt_qsshh < 0.
1667         p_it_bseg-bschl = '50'.
1668         p_it_bseg-shkzg = 'H'.
1669       ELSE.
1670         p_it_bseg-bschl = '40'.
1671         p_it_bseg-shkzg = 'S'.
1672       ENDIF.
1673
1674       CLEAR p_it_bseg-gsber.
1675       READ TABLE p_it_bseg WITH KEY buzei = p_it_with_item-buzei
1676                                 TRANSPORTING gsber.
1677
1678       p_it_bseg-dmbtr = abs( p_it_with_item-wt_qbshh ).
1679       p_it_bseg-wrbtr = abs( p_it_with_item-wt_qbshb ).
1680       p_it_bseg-pswsl = p_it_bkpf-waers.
1681
1682       p_it_bseg-saknr = p_it_with_item-hkont.
1683       p_it_bseg-hkont = p_it_with_item-hkont.
1684
1685       APPEND p_it_bseg.
1686
1687       IF NOT p_it_with_item-hkont_opp IS INITIAL.
1688
1689         p_it_bseg-buzei = p_it_bseg-buzei + 1.
1690
1691         IF p_it_bseg-bschl = '40'.
1692           p_it_bseg-bschl = '50'.
1693           p_it_bseg-shkzg = 'H'.
1694         ELSEIF p_it_bseg-bschl = '50'.
1695           p_it_bseg-bschl = '40'.
1696           p_it_bseg-shkzg = 'S'.
1697         ENDIF.
1698
1699         p_it_bseg-saknr = p_it_with_item-hkont_opp.
1700         p_it_bseg-hkont = p_it_with_item-hkont_opp.
1701
1702         APPEND p_it_bseg.
1703       ENDIF.
1704     ENDLOOP.
1705   *----------------------------------------------------------------------*
1706   ENDFORM.                               " ADD_ENTRIES_BSEG
1707   *&---------------------------------------------------------------------*
1708   *&      Form  CONVERT_TO_NONDECIMAL
1709   *&---------------------------------------------------------------------*
1710   *       text
1711   *----------------------------------------------------------------------*
1712   *      -->P_INREC_WRBTR  text
1713   *      <--P_GV_WRBTR  text
1714   *----------------------------------------------------------------------*
1715   FORM convert_to_nondecimal  USING    p_inrec_wrbtr
1716                               CHANGING p_gv_wrbtr.
1717     WRITE p_inrec_wrbtr TO p_gv_wrbtr DECIMALS 0 LEFT-JUSTIFIED.
1718   ENDFORM.                    " CONVERT_TO_NONDECIMAL
*--- End of ZFI_VOUCHER_PRINT - 1718 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZFI_VOUCHER_PRINT                         Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:45
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
Object           ZFI_VOUCHER_PRINT                         Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:45
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
Object           ZFI_VOUCHER_PRINT                         Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:45
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
Object           ZFI_VOUCHER_PRINT                         Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:45
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
