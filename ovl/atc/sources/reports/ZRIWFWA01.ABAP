----------------------------------------------------------------------------------------------------
Main program     ZRIWFWA01                                 Level 0    Page 1
Object           ZRIWFWA01                                 Lines 1907
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      * Programm ZRIWFWA01
3      *-----------------------------------------------------------------------
4      * Purpose: Implementation of object type ZWCA
5      ************************************************************************
6      *
7      * type-pools
8
9      * elementary types
10
11     * structures types
12
13     * tables types
14
15     * constants
16
17     * includes
18     INCLUDE <object>.
19     BEGIN_DATA OBJECT. " Do not change.. DATA is generated
20     * only private members may be inserted into structure private
21     DATA:
22     " begin of private,
23     "   to declare private attributes remove comments and
24     "   insert private attributes here ...
25     " end of private,
26       BEGIN OF KEY,
27           NUMBER LIKE WCAAP-WAPINR,
28       END OF KEY.
29     END_DATA OBJECT. " Do not change.. DATA is generated
30
31     *-----------------------------------------------*
32     *  Method Issue : Issue Approvals
33     *-----------------------------------------------*
34     begin_method issue changing container.
35     *Data Declaration.
36     DATA: flag            TYPE wcagns-geniakt,
37           custom_approval TYPE wcagns-geniakt,
38           wapinr          TYPE wcewapinr,
39           user_approve    TYPE wfsyst-initiator,
40           approval        TYPE pmsog,
41           lt_approve_tab  TYPE TABLE OF wcagns,
42           lt_approve_std  TYPE TABLE OF wcagns,
43           wa_approve_tab  TYPE  wcagns,
44           wa_approve_std  TYPE wcagns,
45           lv_objnr        TYPE j_objnr,
46           lv_counter      TYPE i_count,
47           lt_counters     TYPE TABLE OF i_count,
48
49           lv_counters     TYPE i_count,
50     * Begin of <> 03022016
51           app_cycle    TYPE zwcm_wcagns-app_cycle,
52           lv_app_cycle TYPE zwcm_wcagns-app_cycle,              "22022016
53           wcagns       TYPE zwcm_wcagns,
54           lt_approve_tab1  TYPE TABLE OF zwcm_wcagns,
55           wa_approve_tab1  TYPE zwcm_wcagns,
56           wa_hierarchy    TYPE zwcm_hierarchy,
57           it_hierarchy    TYPE table of zwcm_hierarchy,
58           wa_hierarchy1   TYPE zwcm_hierarchy,
59           wa_wcaapwa   TYPE wctp1_wcaapwa_type,
60           l_processtyp type zwcm_config-PROCESSTYP,
61           ZACTIVITY      type table of  ZWCM_ASACTIVITY,        "19022016
62           wa_activity    type zwcm_asactivity,                  "19022016
63           l_lineas  type i,                                     "19022016
64           it_wcagns type table of wcagns,                       "23022016
65           wa_wcagns type          wcagns,                       "23022016
66     "24022016
67           l_genbdate type zwcm_wcagns-genbdate,
68           l_genvtime type zwcm_wcagns-genvtime,
69           l_genbtime type zwcm_wcagns-genbtime.
70     "24022016
71     * End of <> 03022016
72     TYPES: BEGIN OF lt_counters2,                               "04022016
73             counters  TYPE  i_count,
74             app_cycle  TYPE zwcm_wcagns-app_cycle,
75           END OF lt_counters2.
76     data : lt_counters1       TYPE TABLE OF lt_counters2,
77            wa_counters1       type lt_counters2.
78
79     *Getting APPROVE_TAB data in container element.
80     swc_get_element container 'WAPINR' wapinr.
81     swc_get_element container 'USER_APPROVE' user_approve.
82     swc_get_element container 'APPROVAL' approval.
83     swc_get_table container   'ACTIVITIES' zactivity.             "19022016
84     "24022016
85     swc_get_element container 'GENBDATE' L_GENBDATE.
86     swc_get_element container 'GENVTIME' L_GENVTIME.
87     swc_get_element container 'GENBTIME' L_GENBTIME.
88     "24022016
89
90
91     IF wapinr IS NOT INITIAL.
92
93     * Get Object Number from WCM Application Data
94       SELECT SINGLE objnr
95            FROM wcaap
96            INTO lv_objnr
97            WHERE wapinr = wapinr.
98
99     * Check Application Exist or Not
100      IF sy-subrc EQ 0.
101    * Get  Counter for differentiation from WCM Approvals
102    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
103    *    SELECT SINGLE counter
104    *      FROM wcagn
105    *      INTO lv_counter
106    *      WHERE objnr EQ lv_objnr AND
107    *            pmsog EQ approval.
108     SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
109    EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
110    ENDSELECT.
111    " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
112    * Begin of <> on 23022016
113    ** Get  Counters for differentiation from WCM Approval Segment
114    *    SELECT counters FROM wcagns
115    *           INTO TABLE lt_counters
116    *           WHERE objnr EQ lv_objnr AND
117    *                 counter EQ lv_counter.
118    *
119    ** Sort Counters internal table in Descending to get highest counter value.
120    *    SORT lt_counters DESCENDING.
121    *    READ TABLE lt_counters INTO lv_counters INDEX 1.
122    *
123    ** Create Work Area for Approval
124    *    IF lv_counters IS NOT INITIAL.
125    *      wa_approve_tab-counters =  lv_counters + 1.
126    *    ELSE.
127    *      wa_approve_tab-counters = 1.
128    *    ENDIF.
129    ** Get  Counters for differentiation from WCM Approval Segment
130        select * from wcagns into corresponding fields of table it_wcagns where objnr eq lv_objnr and counter eq lv_counter.
131    ** Sort Counters internal table in Descending to get highest counter value.
132        sort it_wcagns descending by counters.
133        read table it_wcagns into wa_wcagns index 1.
134        if wa_wcagns-counters is not initial.
135          wa_approve_tab-counters = wa_wcagns-counters + 1.
136        else.
137          wa_approve_tab-counters = 1.
138        endif.
139    * End of <> on 23022016
140        wa_approve_tab-objnr    = lv_objnr.
141        wa_approve_tab-counter  = lv_counter.
142        wa_approve_tab-genname  = user_approve.
143        wa_approve_tab-gendatum = sy-datum.
144        wa_approve_tab-gentime  = sy-uzeit.
145
146    * Appending Work Area to Internal Table for DB Update.
147        APPEND wa_approve_tab TO lt_approve_tab.
148        CLEAR wa_approve_tab.
149
150      ENDIF.
151    ENDIF.
152    "23022016
153    if wa_wcagns-counters > 1.
154      if wa_wcagns-geniakt = 'X'.
155    * Issuing Approvals by Updating Table WCAGNS .
156        CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
157          EXPORTING
158            i_instab = lt_approve_tab
159          EXCEPTIONS
160            error    = 1
161            OTHERS   = 2.
162        COMMIT WORK AND WAIT.
163      endif.
164    else.
165    "23022016
166    * Issuing Approvals by Updating Table WCAGNS .
167      CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
168        EXPORTING
169          i_instab = lt_approve_tab
170        EXCEPTIONS
171          error    = 1
172          OTHERS   = 2.
173      COMMIT WORK AND WAIT.
174    endif.
175
176    * When update is successful mark flagf as X.
177    IF sy-subrc EQ 0.
178      clear : lv_counter, lv_counters.                                                          "08022016  23022016
179    * Updating ZWCM_WCANGS in case of Process type 'DC' 08022016
180      CALL FUNCTION 'WCFA_READ_SINGLE'
181        EXPORTING
182          i_wapinr  = wapinr
183        IMPORTING
184          e_wcaapwa = wa_wcaapwa
185        EXCEPTIONS
186          error     = 1
187          OTHERS    = 2.
188    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
189    *  select single processtyp into l_processtyp from zwcm_config where plant = wa_wcaapwa-iwerk.
190     SELECT PROCESSTYP FROM ZWCM_CONFIG   UP TO 1 ROWS INTO L_PROCESSTYP
191    WHERE PLANT = WA_WCAAPWA-IWERK  ORDER BY  PLANT PLANT_SECTION APPROVAL
192    USAG .   ENDSELECT.
193    " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
194      if sy-subrc = 0 and l_processtyp = 'DC'.
195
196    * 08022016
197    * 04022016
198
199    * Get  Counter for differentiation from WCM Approvals
200        IF wcagns-counter IS NOT INITIAL.
201          lv_counter = wcagns-counter.
202        ELSE.
203    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
204    *      SELECT SINGLE counter
205    *        FROM wcagn
206    *        INTO lv_counter
207    *        WHERE objnr EQ lv_objnr AND
208    *              pmsog EQ approval.
209     SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
210    EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
211    ENDSELECT.
212    " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
213        ENDIF.
214
215    * Get  Counters for differentiation from WCM Approval Segment
216        SELECT counters app_cycle FROM zwcm_wcagns
217               INTO TABLE lt_counters1
218               WHERE objnr EQ lv_objnr AND
219                     counter EQ lv_counter.
220
221    * Sort Counters internal table in Descending to get highest counter value.
222        SORT lt_counters1 DESCENDING .
223        READ TABLE lt_counters1 INTO wa_counters1 INDEX 1.
224    * End of <> on 04022016
225    * Begin of <> on 22022016
226        select max( app_cycle ) into lv_app_cycle from zwcm_wcagns where objnr = lv_objnr. "23022016
227
228        if wa_counters1-APP_CYCLE <> lv_app_cycle or lv_app_cycle is initial. "23022016
229    * End of <> on 22022016
230    * Begin of <> on 03022016 by Sudhir Sharma
231
232    * Check Application Exist or Not
233    *      IF lv_app_cycle < 2. "is initial or wa_counters1-app_cycle = 1 .  "22022016  wa_counters1-app_cycle 23022016
234          if lv_app_cycle is initial.
235            wa_approve_tab1-app_cycle = 1 .
236            lv_app_cycle              = 1.
237          else.
238            wa_approve_tab1-app_cycle = lv_app_cycle .
239          endif.
240
241    * Get  Counter for differentiation from WCM Approvals
242          SELECT SINGLE * FROM zwcm_hierarchy
243           INTO wa_hierarchy
244           WHERE iwerk = wa_wcaapwa-iwerk AND
245                 objart  = 'WA' AND
246                 pmsog = approval.
247
248    * Create Work Area for Approval
249          IF wa_counters1-COUNTERS IS NOT INITIAL.    " 23022016 lv_counters
250            wa_approve_tab1-counters =  wa_counters1-COUNTERS + 1.
251          ELSE.
252            wa_approve_tab1-counters = 1.
253          ENDIF.
254          wa_approve_tab1-objnr    = lv_objnr.
255          wa_approve_tab1-counter  = lv_counter.
256    *      wa_approve_tab1-app_cycle  = lv_app_cycle.     "wa_counters1-app_cycle.
257    *    wa_approve_tab1-completion_flag  = wcagns-completion_flag.
258          wa_approve_tab1-hilvl            = wa_hierarchy-hilvl.
259          wa_approve_tab1-genname  = user_approve.
260          wa_approve_tab1-gendatum = sy-datum.
261          wa_approve_tab1-gentime  = sy-uzeit.
262          wa_approve_tab1-genbdate = L_GENBDATE.  "24022016 sy-datum
263          wa_approve_tab1-genvtime = l_genvtime. " 24022016 sy-uzeit. "'07:00'.   "sy-uzeit.  " Time values pass here
264          wa_approve_tab1-genbtime = l_genbtime.  " 24022016sy-uzeit. "'18:00'.
265          wa_approve_tab1-pmsog    = approval.
266          wa_approve_tab1-gntxt    = wa_hierarchy-gntxt.
267    * Begin of <> on Deciding Permit Status 04022016
268          SELECT  * FROM zwcm_hierarchy INTO table it_hierarchy
269          WHERE iwerk = wa_wcaapwa-iwerk AND  objart  = 'WA' AND category = wa_hierarchy-category.
270          if sy-subrc = 0.
271    * Sort Counters internal table in Descending to get highest counter value.
272            SORT  it_hierarchy DESCENDING by hilvl.
273            READ TABLE  it_hierarchy INTO  wa_hierarchy1 INDEX 1.
274            if wa_hierarchy-hilvl = wa_hierarchy1-hilvl.
275              wa_approve_tab1-permitstat    =  'F'.
276            else.
277              wa_approve_tab1-permitstat    = wa_hierarchy1-category.
278            endif.
279          endif.
280    * End of <> on 04022016
281    * Appending Work Area to Internal Table for DB Update.
282          APPEND wa_approve_tab1 TO lt_approve_tab1.
283    *      ENDIF.
284        endif.
285    * Issuing Approvals by Updating Table WCAGNS .
286        if not  lt_approve_tab1 is initial.
287          CALL FUNCTION 'ZWCFG_WCAGNS_UPDATE'
288            EXPORTING
289              i_instab = lt_approve_tab1
290            EXCEPTIONS
291              error    = 1
292              OTHERS   = 2.
293          clear : lv_counter , wa_counters1, l_genbdate, l_genvtime, l_genbtime.                    "23022016
294        endif.
295    * Begin of <> on 19022016`
296        delete zactivity where objnr <> lv_objnr.               "21022016
297        delete ADJACENT DUPLICATES FROM zactivity COMPARING ALL FIELDS.
298        sort zactivity ASCENDING by actcount.
299        DESCRIBE TABLE zactivity lines l_lineas.
300        if l_lineas > 0.
301          loop at zactivity into wa_activity where objnr = lv_objnr .
302            wa_activity-app_cycle = wa_approve_tab1-app_cycle.
303            wa_activity-counter   = wa_approve_tab1-counter.
304            wa_activity-counters  = wa_approve_tab1-counters.
305            modify zwcm_asactivity from wa_activity.
306          endloop.
307        endif.
308        clear : l_processtyp, wa_approve_tab1, lv_app_cycle.                  " 22022016
309
310    * End of <> on 19022016
311        refresh : zactivity, lt_approve_tab,  lt_approve_tab1 .                                     " 21022016 22022016
312        COMMIT WORK AND WAIT.
313
314      endif.
315    * End of <> on 03022016
316      flag = 'X'.
317    ENDIF.
318
319    *Setting Flag data in container element.
320    swc_set_element container 'FLAG' flag.
321    swc_set_element container 'CUSTOM_APPROVAL' custom_approval.
322    "24022016
323    swc_set_table container   'ACTIVITIES' zactivity.
324    swc_set_element container 'GENBDATE' L_GENBDATE.
325    swc_set_element container 'GENVTIME' L_GENVTIME.
326    swc_set_element container 'GENBTIME' L_GENBTIME.
327    "24022016
328
329    end_method.
330    *-----------------------------------------------*
331    *  End of Method Issue : Issue Approvals
332    *-----------------------------------------------*
333
334    *-----------------------------------------------*
335    *  Method Revoke : Revoke Approvals
336    *-----------------------------------------------*
337    begin_method revoke changing container.
338
339    *Data Declaration.
340    DATA:
341          flag TYPE wcagns-geniakt,
342          wapinr          TYPE wcewapinr,
343          approval        TYPE pmsog,
344          lt_approve_tab  TYPE TABLE OF wcagns,
345          wa_approve_tab  TYPE wcagns,
346          previous_approver TYPE wfsyst-initiator,
347          lv_objnr        TYPE j_objnr,
348          lv_counter      TYPE i_count,
349          lt_counters     TYPE TABLE OF i_count,
350          lv_counters     TYPE i_count,
351          lt_revoke_tab   TYPE wctp1_wcagnstab_type,
352          lt_permit       TYPE wctpc_permittab_type,
353          r_email_id      TYPE pa0105-usrid_long,
354          previous_approval TYPE wcagn-pmsog,
355          permit_txt      TYPE wcspermit-gntxt,
356          wa_permit       TYPE wctpc_permitwa_type,
357          lv_index  TYPE i,
358    *        lv_permit TYPE pmsog,
359            lv_previous_permit TYPE pmsog,
360          wa_revoke       TYPE wctp1_wcagnswa_type.
361    TYPES: BEGIN OF lty_user,
362         user TYPE sysid,
363        END OF lty_user,
364    BEGIN OF ty_email_data,
365      pernr TYPE persno,
366      usrid	TYPE sysid,
367      usrid_long  TYPE comm_id_long,
368    END OF ty_email_data.
369    DATA: "{lt_emp_id TYPE TABLE OF ty_email_data,
370          wa_emp_id TYPE ty_email_data,
371          lt_user TYPE TABLE OF lty_user,
372          lv_user TYPE lty_user.
373
374
375    CONSTANTS: lc_check TYPE char1 VALUE 'X'.
376    *Getting REVOKE TAB data in container element.
377    swc_get_element container 'WAPINR' wapinr.
378    swc_get_element container 'APPROVAL' approval.
379
380    IF wapinr IS NOT INITIAL.
381      CALL FUNCTION 'ZWCA_GET_APPROVALS'
382        EXPORTING
383          wapinr   = wapinr
384        IMPORTING
385          t_permit = lt_permit.
386      LOOP AT lt_permit INTO wa_permit.
387        IF wa_permit-pmsog = approval.
388          lv_index = sy-tabix - 1.
389          EXIT.
390        ENDIF.
391      ENDLOOP.
392      READ TABLE lt_permit INTO wa_permit INDEX lv_index.
393      IF sy-subrc EQ 0.
394
395        lv_previous_permit = wa_permit-pmsog.
396        permit_txt   = wa_permit-gntxt.
397      ENDIF.
398    * Get Object Number from WCM Application Data
399      SELECT SINGLE objnr
400           FROM wcaap
401           INTO lv_objnr
402           WHERE wapinr = wapinr.
403
404    * Check Application Exist or Not
405      IF sy-subrc EQ 0.
406
407    * Get  Counter for differentiation from WCM Approvals
408    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
409    *    SELECT SINGLE counter
410    *      FROM wcagn
411    *      INTO lv_counter
412    *      WHERE objnr EQ lv_objnr AND
413    *            pmsog EQ lv_previous_permit.
414     SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
415    EQ LV_OBJNR AND PMSOG EQ LV_PREVIOUS_PERMIT  ORDER BY  OBJNR COUNTER .
416     ENDSELECT.
417    " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
418
419    * Get  Counters for differentiation from WCM Approval Segment
420        SELECT * FROM wcagns
421               INTO TABLE lt_revoke_tab
422               WHERE objnr EQ lv_objnr AND
423                     counter EQ lv_counter.
424
425    * Sort Counters internal table in Descending to get highest counter value.
426        SORT lt_revoke_tab BY counters DESCENDING .
427        READ TABLE lt_revoke_tab INTO wa_revoke INDEX 1.
428
429        CLEAR lt_revoke_tab.
430    * Create Work Area for Approval
431        wa_revoke-geniname = sy-uname.
432        wa_revoke-genidate = sy-datum.
433        wa_revoke-genitime = sy-uzeit.
434        wa_revoke-geniakt  = lc_check.
435
436    * Appending Work Area to Internal Table for DB Update.
437        APPEND wa_revoke TO lt_revoke_tab.
438    *    CLEAR wa_revoke.
439
440      ENDIF.
441    ENDIF.
442
443    * Revoking Approval by Updating Table WCAGNS and marking flag GENIAKT as X.
444    CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
445      EXPORTING
446        i_updtab = lt_revoke_tab
447      EXCEPTIONS
448        error    = 1
449        OTHERS   = 2.
450    * When update is successful mark flagf as X.
451    IF sy-subrc EQ 0.
452      flag = 'X'.
453
454      CONCATENATE 'US' wa_revoke-genname INTO previous_approver.
455    ENDIF.
456
457    previous_approval = lv_previous_permit.
458
459    ** Start of Email Logic**
460    *LOOP AT gt_users INTO gw_users.
461    lv_user = wa_revoke-genname.
462    *  APPEND wa_user TO lt_user.
463    *ENDLOOP.
464    *gt_users-approver
465    *IF gt_users IS NOT INITIAL.
466
467    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
468    *SELECT SINGLE pernr usrid usrid_long FROM pa0105
469    *  INTO wa_emp_id
470    **    FOR ALL ENTRIES IN lt_user
471    *  WHERE usrid = lv_user AND
472    *        usrty = '0001'.
473     SELECT PERNR USRID USRID_LONG FROM PA0105   UP TO 1 ROWS INTO
474    WA_EMP_ID WHERE USRID = LV_USER AND USRTY = '0001'  ORDER BY  PERNR
475    SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
476    " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
477
478    IF sy-subrc EQ 0.
479      SELECT SINGLE usrid_long FROM pa0105
480       INTO r_email_id
481       WHERE pernr = wa_emp_id-pernr AND
482             usrty = '0010'.
483    ENDIF.
484
485    *ENDIF.
486    ** End of Email Logic**
487
488    *Setting Flag data in container element.
489    swc_set_element container 'FLAG' flag.
490    swc_set_element container 'PREVIOUS_APPROVER' previous_approver.
491    swc_set_element container 'R_EMAIL_ID' r_email_id.
492    swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
493    swc_set_element container 'PERMIT_TXT' permit_txt.
494
495    end_method.
496    *-----------------------------------------------*
497    *  End of Method Revoke : Revoke Approvals
498    *-----------------------------------------------*
499
500    *-----------------------------------------------*
501    *  Method generate_spool : Generate Spool
502    *-----------------------------------------------*
503    begin_method generate_spool changing container.
504    DATA:
505    * Interface Parameters
506          wapinr       TYPE wcaap-wapinr,
507          spool_req    TYPE tsp01-rqident,
508
509    *Local Internal Table
510          lt_wcvltab   TYPE wctp1_wcvltab_type,
511          lt_permit    TYPE wctpc_permittab_type,
512          lt_wcagnstab_cop TYPE wctp1_wcagnstab_type,
513          lt_wcagnstab TYPE   wctp1_wcagnstab_type  ,
514          lt_wccp      TYPE TABLE OF wccp,
515    * Local Work Area
516          wa_wcaapwa   TYPE wctp1_wcaapwa_type,
517          wa_wcsccobj  TYPE wcsccobj,
518          wa_wcswapi   TYPE wcswapi,
519          wa_wcsheader TYPE wcsheader,
520          wa_wcsadm    TYPE wcsadm,
521          wa_wcsloc    TYPE wcsloc,
522          wa_wcsresp   TYPE wcsresp,
523          wa_wcsplan   TYPE wcsplan,
524          wa_wcsprint  TYPE wcsprint,
525          wa_sapscript TYPE wctpd_sapscript_type,
526          wa_wcvlwa    TYPE wctp1_wcvlwa_type,
527          wa_gnwa     TYPE wctp1_gnwa_type,
528          wa_permit    TYPE wctpc_permitwa_type,
529          wa_wccp_permit    TYPE wctpc_permitwa_type,
530          wa_wcagnstab TYPE wctp1_wcagnswa_type,
531          wa_wccp      TYPE wccp,
532    * Local Variables
533          lv_objnr        TYPE j_objnr,
534          lv_cnt       TYPE i,
535          lv_form      TYPE wctpd_form_type,
536          lv_tabix     TYPE i,
537          lv_str       TYPE string.
538    * Field Sysmbol
539    FIELD-SYMBOLS: <fs_spool_id> TYPE itcpp.
540    swc_get_element container 'WAPINR' wapinr.
541
542
543    CALL FUNCTION 'WCFA_READ_SINGLE'
544      EXPORTING
545        i_wapinr  = wapinr
546      IMPORTING
547        e_wcaapwa = wa_wcaapwa
548      EXCEPTIONS
549        error     = 1
550        OTHERS    = 2.
551    IF sy-subrc EQ 0.
552      MOVE-CORRESPONDING wa_wcaapwa TO wa_wcswapi.              "#EC ENHOK
553      MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsadm.               "#EC ENHOK
554      MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsheader.            "#EC ENHOK
555      MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsccobj.             "#EC ENHOK
556      MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsplan.
557
558      CALL FUNCTION 'WCFC_WCVLTAB_GET'
559        EXPORTING
560          i_iwerk   = wa_wcaapwa-iwerk
561          i_prttyp  = '1'
562        IMPORTING
563          e_wcvltab = lt_wcvltab
564        EXCEPTIONS
565          error     = 1
566          OTHERS    = 2.
567      IF sy-subrc EQ 0.
568        READ TABLE lt_wcvltab INTO wa_wcvlwa WITH KEY
569          prtformat = wctpd_prtformat-wapi.
570        lv_form      = wctpd_form-wapi_header.
571      ENDIF.
572    ENDIF.
573
574    CALL FUNCTION 'ZWCA_GET_APPROVALS'
575      EXPORTING
576        wapinr   = wapinr
577      IMPORTING
578        t_permit = lt_permit.
579
580    wa_wcsprint-iwerk = '10P2'.
581    wa_wcsprint-prttyp = '1'.
582    wa_wcsprint-prtformat = 'WAPI'.
583    wa_wcsprint-repid     = 'WCMPRTA4'.
584    wa_wcsprint-form      = 'WCM_WAPI_A4'.
585    wa_wcsprint-tddest    = 'LOCL'.
586    wa_wcsprint-tdcopies  = 0.
587    wa_wcsprint-tddelete  = 'X'.
588    wa_wcsprint-tdnewid   = 'X'.
589    wa_wcsprint-tdlifetime = 0.
590    wa_wcsprint-prttl  = 0.
591    wa_wcsprint-stxt = 'Header data'.
592    * End of get permit
593
594    CALL FUNCTION 'WCFW_CCOBJ_INFO'
595      EXPORTING
596        i_authflg  = wctp1_unmarked
597        i_aktyp    = 'V'             " need to check "inf-aktype
598        i_iwerk    = wa_wcaapwa-iwerk
599        i_tplnr    = wa_wcsccobj-tplnr
600        i_equnr    = wa_wcsccobj-equnr
601        i_lnkflg   = wa_wcsccobj-lnkflg
602        i_train    = wa_wcsccobj-train
603      IMPORTING
604        e_wcsccobj = wa_wcsccobj
605        e_wcsloc   = wa_wcsloc
606      EXCEPTIONS
607        error      = 1
608        OTHERS     = 2.
609    IF sy-subrc <> 0.
610    * Implement suitable error handling here
611    ENDIF.
612
613    CALL FUNCTION 'WCFW_WCSRESP_SET'
614      EXPORTING
615        i_iwerk   = wa_wcaapwa-iwerk
616        i_ingrp   = wa_wcaapwa-ingrp
617        i_wkcrtyp = wa_wcaapwa-wkcrtyp
618        i_wkcrid  = wa_wcaapwa-wkcrid
619        i_begru   = wa_wcaapwa-begru
620      IMPORTING
621        e_wcsresp = wa_wcsresp
622      EXCEPTIONS
623        error     = 1
624        OTHERS    = 2.
625    *wa_wcsloc-swerk = '10P2'.
626
627    wa_wcsresp-ingrp = '112'.
628
629    wa_sapscript-open_form = 0.
630    wa_sapscript-write_form = 0.
631    wa_sapscript-close_form = 0.
632
633    EXPORT
634     wcsprint FROM wa_wcsprint
635    TO MEMORY ID wctpc_memory_id-prtformat.
636
637    EXPORT
638    found     FROM wctp1_true
639    sapscript FROM wa_sapscript
640    TO MEMORY ID 'PRINT'.
641    EXPORT
642      wcswapi   FROM wa_wcswapi
643      wcsheader FROM wa_wcsheader
644      wcsadm    FROM wa_wcsadm
645      wcsccobj  FROM wa_wcsccobj
646      wcsloc    FROM wa_wcsloc
647      wcsresp   FROM wa_wcsresp
648      wcsplan   FROM wa_wcsplan
649      TO MEMORY ID 'PRT2'.
650    EXPORT permittab FROM lt_permit TO MEMORY ID wctpc_memory_id-prt_approval.
651    *  * call subroutine in print program
652    PERFORM (lv_form) IN PROGRAM (wa_wcvlwa-repid) IF FOUND.
653    lv_str = '(SAPLSTXC)ITCPP'.
654
655    ASSIGN (lv_str) TO <fs_spool_id>.
656    spool_req = <fs_spool_id>-tdspoolid.
657    swc_set_element container 'SPOOL_REQ' spool_req.
658    end_method.
659    *-----------------------------------------------*
660    * End Method generate_spool : Generate Spool
661    *-----------------------------------------------*
662
663    begin_method get_current_users changing container.
664    DATA:
665          wapinr TYPE wcaap-wapinr,
666          approval TYPE wcagn-pmsog,
667          next_approval TYPE wcagn-pmsog,
668          bname TYPE wfsyst-initiator OCCURS 0,
669          wa_bname TYPE wfsyst-initiator,
670
671       wa_wcaapwa   TYPE wctp1_wcaapwa_type,
672       lv_permit TYPE pmsog,
673            wa_wcsccobj  TYPE wcsccobj,
674            wa_wcsloc    TYPE wcsloc,
675            wapi_desc    TYPE wcaap-stxt,
676    permit_txt TYPE wcspermit-gntxt,
677            lt_custom TYPE TABLE OF zwcm_custom,
678            wa_custom TYPE zwcm_custom,
679          lt_permit TYPE wctpc_permittab_type,
680          approver_number TYPE wcagns-counter,
681          lv_index  TYPE i,
682          wa_permit TYPE wctpc_permitwa_type.
683
684    CONSTANTS lc_wca TYPE string VALUE 'WCA'.
685    swc_get_element container 'WAPINR' wapinr.
686    swc_get_element container 'APPROVAL' approval.
687
688    CALL FUNCTION 'ZWCA_GET_APPROVALS'
689      EXPORTING
690        wapinr   = wapinr
691      IMPORTING
692        t_permit = lt_permit.
693    IF approval IS NOT INITIAL.
694      READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = approval.
695      lv_permit = wa_permit-pmsog.
696      CLEAR wa_permit.
697    ELSE.
698      READ TABLE lt_permit INTO wa_permit INDEX 1.
699      lv_permit = wa_permit-pmsog.
700      CLEAR wa_permit.
701    ENDIF.
702    approval = lv_permit.
703    CALL FUNCTION 'WCFA_READ_SINGLE'
704      EXPORTING
705        i_wapinr  = wapinr
706      IMPORTING
707        e_wcaapwa = wa_wcaapwa
708      EXCEPTIONS
709        error     = 1
710        OTHERS    = 2.
711
712
713    IF sy-subrc EQ 0.
714      wapi_desc = wa_wcaapwa-stxt.
715
716      MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsccobj.             "#EC ENHOK
717      CALL FUNCTION 'WCFW_CCOBJ_INFO'
718        EXPORTING
719          i_authflg  = wctp1_unmarked
720          i_aktyp    = 'V'             " need to check "inf-aktype
721          i_iwerk    = wa_wcaapwa-iwerk
722          i_tplnr    = wa_wcsccobj-tplnr
723          i_equnr    = wa_wcsccobj-equnr
724          i_lnkflg   = wa_wcsccobj-lnkflg
725          i_train    = wa_wcsccobj-train
726        IMPORTING
727          e_wcsccobj = wa_wcsccobj
728          e_wcsloc   = wa_wcsloc
729        EXCEPTIONS
730          error      = 1
731          OTHERS     = 2.
732      IF sy-subrc <> 0.
733    * Implement suitable error handling here
734      ENDIF.
735      SELECT * FROM zwcm_custom
736          INTO TABLE lt_custom
737          WHERE doc_type = lc_wca AND
738                plant    = wa_wcaapwa-iwerk AND
739                plant_section = wa_wcsloc-beber AND
740                approval = lv_permit AND
741                usag     = wa_wcaapwa-wapiuse AND " +for usage
742                from_date LE sy-datum AND
743                to_date GE sy-datum .
744      IF sy-subrc NE 0.
745        SELECT * FROM zwcm_custom
746        INTO TABLE lt_custom
747        WHERE doc_type = lc_wca AND
748              plant    = wa_wcaapwa-iwerk AND
749              plant_section = '000'  AND
750              approval = lv_permit AND
751              usag     = wa_wcaapwa-wapiuse AND " +for usage
752              from_date LE sy-datum AND
753              to_date GE sy-datum .
754      ENDIF.
755
756      LOOP AT lt_custom INTO wa_custom.
757        MOVE wa_custom-approver TO wa_bname.
758        CONCATENATE 'US' wa_bname INTO wa_bname.
759        APPEND wa_bname TO bname.
760      ENDLOOP.
761    ENDIF.
762    LOOP AT lt_permit INTO wa_permit.
763      IF lv_index IS NOT INITIAL AND
764         lv_index EQ sy-tabix.
765
766        next_approval = wa_permit-pmsog.
767
768      ENDIF.
769      IF lv_permit = wa_permit-pmsog.
770        lv_index = sy-tabix + 1.
771      ENDIF.
772    ENDLOOP.
773    READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = approval.
774    IF sy-subrc EQ 0.
775
776      permit_txt = wa_permit-gntxt.
777    ENDIF.
778    DESCRIBE TABLE bname LINES approver_number.
779    swc_set_table container 'BNAME' bname.
780    swc_set_element container 'APPROVER_NUMBER' approver_number.
781    swc_set_element container 'NEXT_APPROVAL' next_approval.
782    swc_set_element container 'APPROVAL' approval.
783    swc_set_element container 'PERMIT_TXT' permit_txt.
784    swc_set_element container 'WAPI_DESC' wapi_desc.
785
786    end_method.
787
788    begin_method call_form changing container.
789    DATA:
790    * Method Interface
791          wapinr        TYPE wcaap-wapinr,
792          approval      TYPE wcagn-pmsog,
793          spool_req     TYPE tsp01-rqident,
794          next_approval TYPE wcagn-pmsog,
795          previous_approval TYPE wcagn-pmsog,
796          revoke_text   TYPE rdgprint-stadd1 OCCURS 0,
797          user_sel      TYPE wfsyst-initiator OCCURS 0,
798          t_email_id    TYPE pa0105-usrid_long OCCURS 0,
799          user_approve  TYPE wfsyst-initiator,
800          appr_number   TYPE wcagns-counter,
801          appr_status   TYPE wcagns-geniakt,
802          auto_pause   TYPE wcagns-geniakt,
803          flag_loop     TYPE zwcm_custom-beg_loop_flag,
804          wcd_docnum    TYPE zwcm_hierarchy-hilvl,
805          completion_auth TYPE zwcm_hierarchy-completion_auth,
806          renewal_auth TYPE zwcm_hierarchy-renewal_auth ,
807          single_flag     TYPE zwcm_hierarchy-single_flag,
808          work_itemid TYPE swwwihead-wi_id,
809          sms_uname  TYPE suid_st_bname-bname,
810          sms_number TYPE threic_contact-mobile,
811          permit_txt TYPE wcspermit-gntxt,
812          wapi_desc    TYPE wcaap-stxt,
813    * Local Internal Table
814          lt_text           TYPE lvc_t_htline,
815    * Local Work Area
816          wa_user_approve   TYPE wfsyst-initiator OCCURS 0,
817          wa_user_sel       TYPE swp_initia OCCURS 0,
818          wa_appr_status    TYPE  geniakt,
819          wa_next_approval  TYPE  pmsog,
820          wa_user           TYPE wfsyst-initiator,
821    * Local  Variables
822          lt_permit       TYPE wctpc_permittab_type,
823          lt_wcahe        TYPE TABLE OF wcahe,
824          wa_wcahe        TYPE wcahe,
825          lt_wcd          TYPE wctpc_wcmflgtab_type,
826          wa_permit       TYPE wctpc_permitwa_type,
827          lv_plant        TYPE iwerk,
828          lv_user         TYPE sy-uname,
829          lv_wcaap        TYPE wcaap,
830          lx_flag         TYPE wcsstatflg,
831          zactivity1 type table of zwcm_asactivity,             " 19022016
832    "24022016
833          l_genbdate type zwcm_wcagns-genbdate,
834          l_genvtime type zwcm_wcagns-genvtime,
835          l_genbtime type zwcm_wcagns-genbtime.
836    "24022016
837
838    swc_get_element container 'WAPINR'    wapinr.
839    swc_get_element container 'APPROVAL'  approval.
840    swc_get_element container 'SPOOL_REQ' spool_req.
841    swc_get_element container 'SMS_NUMBER' sms_number.
842    swc_get_element container 'WORK_ITEMID' work_itemid.
843    swc_get_element container 'SMS_UNAME' sms_uname.
844    swc_get_element container 'PERMIT_TXT' permit_txt.
845    swc_get_element container 'WAPI_DESC' wapi_desc.
846    swc_get_table container 'ACTIVITIES' zactivity1.            "19022016
847
848    * Calling Form
849    CALL FUNCTION 'ZWCM_FORM'
850      EXPORTING
851        im_spool           = spool_req
852        im_permit          = approval
853        im_appl            = wapinr
854        im_work_itemid     = work_itemid
855      IMPORTING
856        ex_appr_status     = appr_status
857        ex_user_aprove     = user_approve
858        et_user            = user_sel
859        ex_next_permit     = next_approval
860        et_text            = lt_text
861        et_email_id        = t_email_id
862        ex_flag_loop       = flag_loop
863        ex_wcd_docnum      = wcd_docnum
864        ex_completion_auth = completion_auth
865        ex_renewal_auth    = renewal_auth
866        ex_single_flag     = single_flag
867        ex_prev_permit     = previous_approval
868        ex_auto_pause      = auto_pause
869    *   ex_sms_uname       = sms_uname
870        EX_GENBDATE        = l_genbdate
871        EX_GENVTIME        = l_genvtime
872        EX_GENBTIME        = l_genbtime
873       TABLEs
874        ex_activity        = ZACTIVITY1
875      CHANGING
876        ch_sms_uname       = sms_uname
877        ch_sms_number      = sms_number.
878
879
880    * Getting Revoke Text.
881    revoke_text = lt_text.
882
883    * Concatenating user name with US.
884    LOOP AT user_sel INTO wa_user.
885      CONCATENATE 'US' wa_user INTO wa_user.
886      MODIFY user_sel FROM wa_user INDEX sy-tabix.
887    ENDLOOP.
888
889    DESCRIBE TABLE user_sel LINES appr_number.
890
891    CALL FUNCTION 'ZWCA_GET_APPROVALS'
892      EXPORTING
893        wapinr   = wapinr
894      IMPORTING
895        t_permit = lt_permit.
896
897    SELECT SINGLE * FROM wcaap
898      INTO lv_wcaap
899      WHERE wapinr = wapinr.
900
901    READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
902    IF sy-subrc EQ 0.
903      permit_txt = wa_permit-gntxt.
904      IF permit_txt IS INITIAL.
905
906        SELECT SINGLE gntxt INTO permit_txt
907          FROM zwcm_hierarchy
908          WHERE iwerk = lv_wcaap-iwerk AND
909                pmsog EQ approval AND
910                objart EQ 'WA'.
911
912    *    permit_txt = 'Approval by Area Incharge'.
913
914      ENDIF.
915    ENDIF.
916
917    IF  ( appr_number IS INITIAL OR
918       appr_number EQ '000000' ) AND
919        appr_status NE 'B' AND
920        appr_status NE 'R'.
921
922      lx_flag-clsd = 'X'.
923      CALL FUNCTION 'WCFS_CLOSED'
924        EXPORTING
925          i_iwerk      = lv_wcaap-iwerk
926          i_objart     = 'WA'
927          i_objnr      = lv_wcaap-objnr
928          i_wcsstatflg = lx_flag
929          i_cp         = wctp1_exception-pass_over
930        EXCEPTIONS
931          error        = 1
932          OTHERS       = 2.
933
934
935      IF sy-subrc EQ 0.
936        CALL FUNCTION 'WCFX_WCMFLGTAB_GET'
937          EXPORTING
938            i_objnr     = lv_wcaap-objnr
939            i_direction = 'DN'
940          IMPORTING
941            e_wcmflgtab = lt_wcd
942    *       E_SIZE      =
943          EXCEPTIONS
944            error       = 1
945            OTHERS      = 2.
946    *      CLEAR lt_wca.
947        IF lt_wcd IS NOT INITIAL.
948          SELECT * FROM wcahe
949            INTO TABLE lt_wcahe
950            FOR ALL ENTRIES IN lt_wcd
951            WHERE objnr = lt_wcd-objnr.
952        ENDIF.
953        LOOP AT lt_wcahe INTO wa_wcahe.
954          CALL FUNCTION 'WCFS_CLOSED'
955            EXPORTING
956              i_iwerk      = lv_wcaap-iwerk
957              i_objart     = 'WD'
958              i_objnr      = wa_wcahe-objnr
959              i_wcsstatflg = lx_flag
960              i_cp         = wctp1_exception-pass_over
961            EXCEPTIONS
962              error        = 1
963              OTHERS       = 2.
964          IF sy-subrc <> 0.
965    * Implement suitable error handling here
966          ENDIF.
967
968        ENDLOOP.
969      ENDIF.
970    ENDIF.
971    "19022016
972    swc_set_table container 'ACTIVITIES' zactivity1.
973    "24022016
974    swc_set_element container 'GENBDATE' L_GENBDATE.
975    swc_set_element container 'GENVTIME' L_GENVTIME.
976    swc_set_element container 'GENBTIME' L_GENBTIME.
977    "24022016
978    swc_set_element container 'APPR_STATUS'   appr_status.
979    swc_set_element container 'NEXT_APPROVAL' next_approval.
980    swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
981    swc_set_element container 'USER_APPROVE'  user_approve.
982    swc_set_element container 'APPR_NUMBER'   appr_number.
983    *swc_set_element container 'APPR_NUMBER'   appr_number.   "commented on 12022016
984    swc_set_element container 'REVOKE_TEXT'   revoke_text.
985    swc_set_element container 'FLAG_LOOP'     flag_loop.
986    swc_set_element container 'WCD_DOCNUM'    wcd_docnum.
987    swc_set_element container 'SMS_UNAME'    sms_uname.
988    swc_set_element container 'AUTO_PAUSE'    auto_pause.
989    swc_set_element container 'SMS_NUMBER'    sms_number.
990    swc_set_element container 'RENEWAL_AUTH'    renewal_auth.
991    swc_set_element container 'COMPLETION_AUTH'    completion_auth.
992    swc_set_element container 'SINGLE_FLAG'    single_flag.
993    swc_set_table   container 'T_EMAIL_ID'    t_email_id.
994    swc_set_table   container 'USER_SEL'      user_sel.
995    swc_set_element container 'PERMIT_TXT' permit_txt.
996    end_method.
997
998    begin_method call_loop_form changing container.
999    DATA:
1000         wapinr          TYPE wcaap-wapinr,
1001         approval        TYPE wcagn-pmsog,
1002         user_sel        TYPE wfsyst-initiator OCCURS 0,
1003         appr_status     TYPE wcagns-geniakt,
1004         appr_number     TYPE wcagns-counter,
1005         next_approval   TYPE wcagn-pmsog,
1006         previous_approval   TYPE wcagn-pmsog,
1007         ext_appr        TYPE zwcm_hierarchy-ext_appr,
1008         revoke_text     TYPE rdgprint-stadd1 OCCURS 0,
1009         wcd_docnum      TYPE zwcm_hierarchy-hilvl,
1010         user_approve    TYPE wfsyst-initiator,
1011         app_cycle       TYPE zwcm_wcagns-app_cycle,
1012         completion_auth TYPE zwcm_hierarchy-completion_auth,
1013         renewal_auth    TYPE zwcm_hierarchy-renewal_auth ,
1014         sms_uname       TYPE suid_st_bname-bname,
1015         single_flag     TYPE zwcm_hierarchy-single_flag,
1016         wcagns          TYPE zwcm_wcagns,
1017         sms_number      TYPE threic_contact-mobile,
1018         work_itemid     TYPE swwwihead-wi_id,
1019         permit_txt      TYPE wcspermit-gntxt,
1020         stop_auth       TYPE zwcm_hierarchy-stop_auth,
1021         wapi_desc       TYPE wcaap-stxt,
1022         t_email_id      TYPE pa0105-usrid_long OCCURS 0,
1023         lt_text         TYPE lvc_t_htline,
1024         wa_user         TYPE wfsyst-initiator,
1025         lt_permit       TYPE wctpc_permittab_type,
1026         lv_plant        TYPE iwerk,
1027         wa_permit       TYPE wctpc_permitwa_type,
1028         zactivity1 type table of zwcm_asactivity.             " 20022016
1029
1030
1031   swc_get_element container 'WAPINR' wapinr.
1032   swc_get_element container 'APPROVAL' approval.
1033   swc_get_element container 'APP_CYCLE' app_cycle.
1034   swc_get_element container 'COMPLETION_AUTH' completion_auth.
1035   swc_get_element container 'RENEWAL_AUTH' renewal_auth.
1036   swc_get_element container 'PREVIOUS_APPROVAL' previous_approval.
1037   swc_get_element container 'WORK_ITEMID' work_itemid.
1038   swc_get_element container 'SMS_UNAME' sms_uname.
1039   swc_get_element container 'SMS_NUMBER' sms_number.
1040   swc_get_element container 'WAPI_DESC' wapi_desc.
1041   swc_get_element container 'STOP_AUTH' stop_auth.
1042   swc_get_element container 'EXT_APPR' ext_appr.
1043   swc_get_table container 'ACTIVITIES' zactivity1.            "20022016
1044
1045
1046   CALL FUNCTION 'ZWCM_LOOP_FORM'
1047     EXPORTING
1048       im_permit          = approval
1049       im_appl            = wapinr
1050       im_app_cycle       = app_cycle
1051       im_prev_permit     = previous_approval
1052       im_work_itemid     = work_itemid
1053       im_ext_appr        = ext_appr
1054     IMPORTING
1055       ex_appr_status     = appr_status
1056       ex_user_aprove     = user_approve
1057       et_user            = user_sel
1058       ex_next_permit     = next_approval
1059       et_text            = lt_text
1060       et_email_id        = t_email_id
1061       ex_single_flag     = single_flag
1062       ex_wcd_docnum      = wcd_docnum
1063       ex_wcagns          = wcagns
1064     TABLES
1065       ex_activity        = ZACTIVITY1
1066     CHANGING
1067       ch_completion_auth = completion_auth
1068       ch_renewal_auth    = renewal_auth
1069       ch_sms_uname       = sms_uname
1070       ch_sms_number      = sms_number
1071       ch_stop_auth       = stop_auth.
1072
1073   * Getting Revke Text.
1074   revoke_text = lt_text.
1075
1076   * Concatenating user name with US.
1077   LOOP AT user_sel INTO wa_user.
1078     CONCATENATE 'US' wa_user INTO wa_user.
1079     MODIFY user_sel FROM wa_user INDEX sy-tabix.
1080   ENDLOOP.
1081
1082   DESCRIBE TABLE user_sel LINES appr_number.
1083
1084   CALL FUNCTION 'ZWCA_GET_APPROVALS'
1085     EXPORTING
1086       wapinr   = wapinr
1087     IMPORTING
1088       t_permit = lt_permit.
1089
1090   READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
1091   IF sy-subrc EQ 0.
1092     permit_txt = wa_permit-gntxt.
1093
1094   ENDIF.
1095   IF permit_txt IS INITIAL AND appr_number IS NOT INITIAL.
1096
1097     SELECT SINGLE iwerk FROM wcaap
1098       INTO lv_plant
1099       WHERE wapinr = wapinr.
1100
1101     SELECT SINGLE gntxt INTO permit_txt
1102       FROM zwcm_hierarchy
1103       WHERE iwerk = lv_plant AND
1104             pmsog EQ next_approval AND
1105             objart EQ 'WA'.
1106   *  permit_txt = 'Approval by Area Incharge'.
1107
1108   ENDIF.
1109
1110   swc_set_table container 'ACTIVITIES' zactivity1.            "20022016
1111
1112   swc_set_table container 'USER_SEL' user_sel.
1113   swc_set_element container 'APPR_STATUS' appr_status.
1114   swc_set_element container 'APPR_NUMBER' appr_number.
1115   swc_set_element container 'NEXT_APPROVAL' next_approval.
1116   swc_set_table container 'REVOKE_TEXT' revoke_text.
1117   swc_set_element container 'USER_APPROVE' user_approve.
1118   swc_set_element container 'COMPLETION_AUTH' completion_auth.
1119   swc_set_element container 'RENEWAL_AUTH' renewal_auth.
1120   swc_set_element container 'SINGLE_FLAG' single_flag.
1121   swc_set_element container 'WCAGNS' wcagns.
1122   swc_set_table container 'T_EMAIL_ID' t_email_id.
1123   swc_set_element container 'SMS_UNAME'    sms_uname.
1124   swc_set_element container 'WCD_DOCNUM'    wcd_docnum.
1125   swc_set_element container 'PERMIT_TXT'    permit_txt.
1126   swc_set_element container 'SMS_NUMBER'    sms_number.
1127   swc_set_element container 'STOP_AUTH'    stop_auth.
1128   end_method.
1129
1130   begin_method get_current_loop_users changing container.
1131   DATA:
1132   * Interface Parameters
1133         wapinr          TYPE wcaap-wapinr,
1134         next_approval   TYPE wcagn-pmsog,
1135         approval        TYPE wcagn-pmsog,
1136         bname           TYPE wfsyst-initiator OCCURS 0,
1137         approver_number TYPE wcagns-counter,
1138         completion_auth TYPE zwcm_hierarchy-completion_auth,
1139         renewal_auth TYPE zwcm_hierarchy-renewal_auth,
1140   * Local Internal Tables
1141         lt_hierarchy    TYPE TABLE OF zwcm_hierarchy,
1142         lt_custom       TYPE TABLE OF zwcm_custom,
1143   * Local work Area
1144         wa_wcaapwa      TYPE wctp1_wcaapwa_type,
1145         wa_wcsccobj     TYPE wcsccobj,
1146         wa_wcsloc       TYPE wcsloc,
1147         wa_custom       TYPE zwcm_custom,
1148         wa_bname        TYPE wfsyst-initiator,
1149         wa_hierarchy    TYPE zwcm_hierarchy,
1150   * local Variales
1151         lv_index        TYPE int4,
1152         lv_permit       TYPE pmsog.
1153   CONSTANTS lc_wca      TYPE string VALUE 'WCA'.
1154
1155   swc_get_element container 'WAPINR' wapinr.
1156   swc_get_element container 'APPROVAL' approval.
1157
1158   * Read Header Data
1159   CALL FUNCTION 'WCFA_READ_SINGLE'
1160     EXPORTING
1161       i_wapinr  = wapinr
1162     IMPORTING
1163       e_wcaapwa = wa_wcaapwa
1164     EXCEPTIONS
1165       error     = 1
1166       OTHERS    = 2.
1167
1168
1169   IF sy-subrc EQ 0.
1170     MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsccobj.             "#EC ENHOK
1171
1172   * Read Location data
1173     CALL FUNCTION 'WCFW_CCOBJ_INFO'
1174       EXPORTING
1175         i_authflg  = wctp1_unmarked
1176         i_aktyp    = 'V'             " need to check "inf-aktype
1177         i_iwerk    = wa_wcaapwa-iwerk
1178         i_tplnr    = wa_wcsccobj-tplnr
1179         i_equnr    = wa_wcsccobj-equnr
1180         i_lnkflg   = wa_wcsccobj-lnkflg
1181         i_train    = wa_wcsccobj-train
1182       IMPORTING
1183         e_wcsccobj = wa_wcsccobj
1184         e_wcsloc   = wa_wcsloc
1185       EXCEPTIONS
1186         error      = 1
1187         OTHERS     = 2.
1188     IF sy-subrc <> 0.
1189   * Implement suitable error handling here
1190     ENDIF.
1191
1192   * Read hierarchy for custom loop
1193     SELECT * FROM zwcm_hierarchy
1194       INTO TABLE lt_hierarchy
1195       WHERE iwerk = wa_wcaapwa-iwerk AND
1196             objart = 'WA'.
1197
1198     IF sy-subrc EQ 0.
1199       SORT lt_hierarchy BY hilvl.
1200
1201   * If approval is initial, intialize it with first permit.
1202       IF approval IS NOT INITIAL.
1203         READ TABLE lt_hierarchy INTO wa_hierarchy WITH KEY pmsog = approval.
1204         lv_permit = wa_hierarchy-pmsog.
1205       ELSE.
1206         READ TABLE lt_hierarchy INTO wa_hierarchy INDEX 1.
1207         lv_permit = wa_hierarchy-pmsog.
1208       ENDIF.
1209
1210       approval = lv_permit.
1211   * Getting check for completion authority
1212       completion_auth =  wa_hierarchy-completion_auth.
1213   * Getting check for completion authority
1214       renewal_auth =  wa_hierarchy-renewal_auth.
1215
1216   * If Distribution List is initial, get the user list from custom table
1217       IF wa_hierarchy-dist_list IS INITIAL.
1218         SELECT * FROM zwcm_custom
1219          INTO TABLE lt_custom
1220          WHERE doc_type = lc_wca AND
1221                plant    = wa_wcaapwa-iwerk AND
1222                plant_section = wa_wcsloc-beber AND
1223                approval = lv_permit AND
1224                usag     = wa_wcaapwa-wapiuse AND " +for usage
1225               from_date LE sy-datum AND
1226               to_date GE sy-datum .
1227         IF sy-subrc NE 0.
1228           SELECT * FROM zwcm_custom
1229             INTO TABLE lt_custom
1230             WHERE doc_type = lc_wca AND
1231                    plant    = wa_wcaapwa-iwerk AND
1232                    plant_section = '000' AND
1233                    approval = lv_permit AND
1234                    usag     = wa_wcaapwa-wapiuse AND " +for usage
1235                   from_date LE sy-datum AND
1236                   to_date GE sy-datum .
1237         ENDIF.
1238         LOOP AT lt_custom INTO wa_custom.
1239           MOVE wa_custom-approver TO wa_bname.
1240           CONCATENATE 'US' wa_bname INTO wa_bname.
1241           APPEND wa_bname TO bname.
1242         ENDLOOP.
1243       ELSE.
1244   *   Need to add logic to read users from distribution list.
1245
1246       ENDIF.
1247     ENDIF.
1248   ENDIF.
1249
1250   * Get Next Approval Level
1251   LOOP AT lt_hierarchy INTO wa_hierarchy.
1252     IF lv_index IS NOT INITIAL AND
1253        lv_index EQ sy-tabix.
1254
1255       next_approval = wa_hierarchy-pmsog.
1256
1257     ENDIF.
1258
1259     IF lv_permit = wa_hierarchy-pmsog.
1260       lv_index = sy-tabix + 1.
1261     ENDIF.
1262   ENDLOOP.
1263
1264   DESCRIBE TABLE bname LINES approver_number.
1265
1266   swc_set_element container 'NEXT_APPROVAL' next_approval.
1267   swc_set_element container 'APPROVAL' approval.
1268   swc_set_table container 'BNAME' bname.
1269   swc_set_element container 'APPROVER_NUMBER' approver_number.
1270   swc_set_element container 'COMPLETION_AUTH' completion_auth.
1271   swc_set_element container 'RENEWAL_AUTH' renewal_auth.
1272   end_method.
1273
1274   begin_method custom_issue changing container.
1275   DATA:
1276         approval TYPE wcagn-pmsog,
1277         wapinr TYPE wcaap-wapinr,
1278         flag TYPE wcagns-geniakt,
1279         app_cycle  TYPE zwcm_wcagns-app_cycle,
1280         user_approve TYPE wfsyst-initiator,
1281         wcagns      TYPE zwcm_wcagns,
1282   *      completion_auth TYPE zwcm_hierarchy-completion_auth,
1283         lt_approve_tab  TYPE TABLE OF zwcm_wcagns,
1284         lt_approve_std  TYPE TABLE OF wcagns,
1285         wa_approve_tab  TYPE zwcm_wcagns,
1286         wa_approve_std  TYPE wcagns,
1287         wa_hierarchy   TYPE zwcm_hierarchy,
1288         wa_wcaapwa   TYPE wctp1_wcaapwa_type,
1289         lv_objnr        TYPE j_objnr,
1290         lv_counter      TYPE i_count,
1291         lt_counters     TYPE TABLE OF i_count,
1292         lv_counters     TYPE i_count,
1293         lt_approve_tab1  TYPE TABLE OF zwcm_wcagns,           "11022016
1294         wa_approve_tab1  TYPE zwcm_wcagns,                    "11022016
1295         it_hierarchy    TYPE table of zwcm_hierarchy,         "11022016
1296         wa_hierarchy1   TYPE zwcm_hierarchy,                  "11022016
1297         l_processtyp    type zwcm_config-PROCESSTYP,          "11022016
1298         it_hierarchy1   TYPE table of zwcm_hierarchy,         "15022016
1299         first_permit           TYPE wcagn-pmsog,              "15022016
1300         zactivity       type table of zwcm_asactivity,        "18022016
1301         it_activity    type table of zwcm_asactivity,         "17022016
1302         wa_activity    type zwcm_asactivity,                  "17022016
1303         l_lineas       type i.                                "19022016
1304
1305
1306   swc_get_element container 'APPROVAL' approval.
1307   swc_get_element container 'WAPINR' wapinr.
1308   swc_get_element container 'USER_APPROVE' user_approve.
1309   swc_get_element container 'WCAGNS' wcagns.
1310   swc_get_element container 'APP_CYCLE' app_cycle.
1311   swc_get_element container 'FIRST_PERMIT' first_permit.      " 15022016
1312   swc_get_table container 'ACTIVITIES' zactivity.                            " 17022016 18022016
1313
1314   * Need to be implemented
1315   IF wapinr IS NOT INITIAL.
1316   * Get Object Number from WCM Application Data
1317     SELECT SINGLE objnr
1318          FROM wcaap
1319          INTO lv_objnr
1320          WHERE wapinr = wapinr.
1321
1322   * Check Application Exist or Not
1323     IF sy-subrc EQ 0.
1324       CALL FUNCTION 'WCFA_READ_SINGLE'
1325         EXPORTING
1326           i_wapinr  = wapinr
1327         IMPORTING
1328           e_wcaapwa = wa_wcaapwa
1329         EXCEPTIONS
1330           error     = 1
1331           OTHERS    = 2.
1332
1333   * Get  Counter for differentiation from WCM Approvals
1334       SELECT SINGLE * FROM zwcm_hierarchy
1335        INTO wa_hierarchy
1336        WHERE iwerk = wa_wcaapwa-iwerk AND
1337              objart  = 'WA' AND
1338              pmsog = approval.
1339
1340   ** Getting check for completion authority
1341   *    completion_auth =  wa_hierarchy-completion_auth.
1342
1343       SELECT SINGLE objnr
1344          FROM wcaap
1345          INTO lv_objnr
1346          WHERE wapinr = wapinr.
1347
1348   * Get  Counter for differentiation from WCM Approvals
1349       IF wcagns-counter IS NOT INITIAL.
1350         lv_counter = wcagns-counter.
1351       ELSE.
1352   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
1353   *      SELECT SINGLE counter
1354   *        FROM wcagn
1355   *        INTO lv_counter
1356   *        WHERE objnr EQ lv_objnr AND
1357   *              pmsog EQ approval.
1358    SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
1359   EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
1360   ENDSELECT.
1361   " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
1362
1363       ENDIF.
1364
1365   *    lv_counter = wa_hierarchy-hilvl / 10.
1366
1367   * Get  Counters for differentiation from WCM Approval Segment
1368       SELECT counters FROM zwcm_wcagns
1369              INTO TABLE lt_counters
1370              WHERE objnr EQ lv_objnr AND
1371                    counter EQ lv_counter.
1372
1373   * Sort Counters internal table in Descending to get highest counter value.
1374       SORT lt_counters DESCENDING.
1375       READ TABLE lt_counters INTO lv_counters INDEX 1.
1376   * Create Work Area for Approval
1377       IF lv_counters IS NOT INITIAL.
1378         wa_approve_tab-counters =  lv_counters + 1.
1379       ELSE.
1380         wa_approve_tab-counters = 1.
1381       ENDIF.
1382       wa_approve_tab-objnr    = lv_objnr.
1383       wa_approve_tab-counter  = lv_counter.
1384       wa_approve_tab-app_cycle  = app_cycle.
1385       wa_approve_tab-completion_flag  = wcagns-completion_flag.
1386       wa_approve_tab-hilvl            = wcagns-hilvl.
1387       wa_approve_tab-genname  = user_approve.
1388       wa_approve_tab-gendatum = sy-datum.
1389       wa_approve_tab-gentime  = sy-uzeit.
1390       wa_approve_tab-genbdate = wcagns-genbdate.
1391       wa_approve_tab-genvtime = wcagns-genvtime.
1392       wa_approve_tab-genbtime = wcagns-genbtime.
1393       wa_approve_tab-pmsog    = wcagns-pmsog.
1394       wa_approve_tab-gntxt    = wcagns-gntxt.
1395   * Begin of <> on Deciding Permit Status 11022016
1396   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
1397   *    select single processtyp into l_processtyp from zwcm_config where plant = wa_wcaapwa-iwerk.
1398    SELECT PROCESSTYP FROM ZWCM_CONFIG   UP TO 1 ROWS INTO L_PROCESSTYP
1399   WHERE PLANT = WA_WCAAPWA-IWERK  ORDER BY  PLANT PLANT_SECTION APPROVAL
1400   USAG .   ENDSELECT.
1401   " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
1402       if sy-subrc = 0 and l_processtyp = 'DC'.
1403   * 15022016
1404   *      if first_permit is initial.
1405         SELECT  * FROM zwcm_hierarchy INTO table it_hierarchy1
1406         WHERE iwerk = wa_wcaapwa-iwerk AND  objart  = 'WA'.
1407         if sy-subrc = 0.
1408   * Sort Counters internal table in Descending to get highest counter value.
1409           SORT  it_hierarchy1 ASCENDING by hilvl.
1410           READ TABLE  it_hierarchy1 INTO  wa_hierarchy1 INDEX 1.
1411           if first_permit <> wa_hierarchy1-pmsog.
1412             first_permit = wa_hierarchy1-pmsog.
1413           endif.
1414   *          swc_set_element container 'FIRST_PERMIT' first_permit.
1415           refresh : it_hierarchy1.
1416           clear: wa_hierarchy1.
1417         endif.
1418
1419   * 15022016
1420         SELECT  * FROM zwcm_hierarchy INTO table it_hierarchy
1421         WHERE iwerk = wa_wcaapwa-iwerk AND  objart  = 'WA' AND category = wa_hierarchy-category.
1422         if sy-subrc = 0.
1423   * Sort Counters internal table in Descending to get highest counter value.
1424           SORT  it_hierarchy DESCENDING by hilvl.
1425           READ TABLE  it_hierarchy INTO  wa_hierarchy1 INDEX 1.
1426           if wa_hierarchy-hilvl = wa_hierarchy1-hilvl.
1427             if wa_hierarchy1-category = 'I'.
1428               wa_approve_tab-permitstat    =  'F'.
1429             elseif wa_hierarchy1-category = 'C'.
1430               wa_approve_tab-permitstat    =  'X'.
1431             endif.
1432           else.
1433             wa_approve_tab-permitstat    = wa_hierarchy1-category.
1434           endif.
1435         endif.
1436       endif.
1437   * End of <> on 11022016
1438   * Appending Work Area to Internal Table for DB Update.
1439       APPEND wa_approve_tab TO lt_approve_tab.
1440   *    CLEAR wa_approve_tab.
1441
1442     ENDIF.
1443   ENDIF.
1444
1445   * Issuing Approvals by Updating Table WCAGNS .
1446   CALL FUNCTION 'ZWCFG_WCAGNS_UPDATE'
1447     EXPORTING
1448       i_instab = lt_approve_tab
1449     EXCEPTIONS
1450       error    = 1
1451       OTHERS   = 2.
1452
1453   * When update is successful mark flagf as X.
1454   IF sy-subrc EQ 0.
1455     IF wa_hierarchy-std_map EQ 'X' AND app_cycle EQ 1.
1456
1457       SELECT SINGLE objnr
1458          FROM wcaap
1459          INTO lv_objnr
1460          WHERE wapinr = wapinr.
1461
1462   * Check Application Exist or Not
1463       IF sy-subrc EQ 0.
1464
1465   * Get  Counter for differentiation from WCM Approvals
1466   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
1467   *      SELECT SINGLE counter
1468   *        FROM wcagn
1469   *        INTO lv_counter
1470   *        WHERE objnr EQ lv_objnr AND
1471   *              pmsog EQ approval.
1472    SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
1473   EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
1474   ENDSELECT.
1475   " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
1476
1477   * Get  Counters for differentiation from WCM Approval Segment
1478         SELECT counters FROM wcagns
1479                INTO TABLE lt_counters
1480                WHERE objnr EQ lv_objnr AND
1481                      counter EQ lv_counter.
1482
1483   * Sort Counters internal table in Descending to get highest counter value.
1484         SORT lt_counters DESCENDING.
1485         READ TABLE lt_counters INTO lv_counters INDEX 1.
1486
1487   * Create Work Area for Approval
1488         IF lv_counters IS NOT INITIAL.
1489           wa_approve_std-counters =  lv_counters + 1.
1490         ELSE.
1491           wa_approve_std-counters = 1.
1492         ENDIF.
1493
1494   *      wa_approve_std-counters =  lv_counters.
1495         wa_approve_std-objnr    = wa_approve_tab-objnr.
1496         wa_approve_std-counter  =  lv_counter.
1497         wa_approve_std-genname  = wa_approve_tab-genname.
1498         wa_approve_std-gendatum = wa_approve_tab-gendatum.
1499         wa_approve_std-gentime  = wa_approve_tab-gentime.
1500         APPEND wa_approve_std TO lt_approve_std.
1501         CLEAR wa_approve_std.
1502   * Issuing Approvals by Updating Table WCAGNS .
1503         CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
1504           EXPORTING
1505             i_instab = lt_approve_std
1506           EXCEPTIONS
1507             error    = 1
1508             OTHERS   = 2.
1509
1510       ENDIF.
1511     ENDIF.
1512     flag = 'X'.
1513   ENDIF.
1514   * Begin of <> on 17022016
1515   *   IMPORT : ZACTIVITY FROM MEMORY ID 'ZACTIVITY'.                             "18022016
1516   if L_PROCESSTYP = 'DC'.
1517     delete zactivity where objnr <> lv_objnr.                 "21022016
1518     delete ADJACENT DUPLICATES FROM zactivity COMPARING ALL FIELDS.
1519     SORT zactivity ascending by actcount.
1520     DESCRIBE TABLE zactivity lines l_lineas.
1521     if l_lineas > 0.
1522       loop at zactivity into wa_activity where objnr = lv_objnr .
1523         wa_activity-APP_CYCLE = WA_APPROVE_TAB-APP_CYCLE.
1524         wa_activity-COUNTER   = WA_APPROVE_TAB-COUNTER.
1525         wa_activity-COUNTERS  = WA_APPROVE_TAB-COUNTERs.
1526         modify zwcm_asactivity from wa_activity.
1527       endloop.
1528     endif.
1529     clear : l_processtyp.
1530   endif.
1531   refresh zactivity.                                          " 21022016
1532   * End of <> on 17022016
1533   COMMIT WORK AND WAIT.
1534   swc_set_element container 'FIRST_PERMIT' first_permit.      "15022016
1535   swc_set_element container 'FLAG' flag.
1536   *swc_set_element container 'COMPLETION_AUTH' completion_auth.
1537   end_method.
1538
1539   begin_method custom_revoke changing container.
1540   DATA:
1541         wapinr TYPE wcaap-wapinr,
1542         approval TYPE wcagn-pmsog,
1543         previous_approver TYPE wfsyst-initiator,
1544         previous_approval TYPE wcagn-pmsog,
1545         r_email_id TYPE pa0105-usrid_long,
1546         app_cycle  TYPE zwcm_wcagns-app_cycle,
1547         flag TYPE wcagns-geniakt,
1548         permit_txt  TYPE wcspermit-gntxt,
1549         lt_permit TYPE TABLE OF zwcm_hierarchy,
1550         lt_permit_std TYPE wctpc_permittab_type,
1551         wa_permit TYPE zwcm_hierarchy,
1552         wa_permit_std TYPE wctpc_permitwa_type,
1553         wa_wcaapwa   TYPE wctp1_wcaapwa_type,
1554         lt_approve_tab  TYPE TABLE OF zwcm_wcagns,
1555         wa_approve_tab  TYPE zwcm_wcagns,
1556         lv_objnr        TYPE j_objnr,
1557         lv_counter      TYPE i_count,
1558         lt_counters     TYPE TABLE OF i_count,
1559         lv_counters     TYPE i_count,
1560         lt_revoke_tab   TYPE ztt_wcagnstab_type,
1561   *      lt_permit       TYPE wctpc_permittab_type,
1562   *            wa_permit       TYPE wctpc_permitwa_type,
1563         lv_index  TYPE i,
1564   *        lv_permit TYPE pmsog,
1565           lv_previous_permit TYPE pmsog,
1566         wa_revoke       TYPE zwcm_wcagns.
1567   TYPES: BEGIN OF lty_user,
1568        user TYPE sysid,
1569       END OF lty_user,
1570   BEGIN OF ty_email_data,
1571     pernr TYPE persno,
1572     usrid	TYPE sysid,
1573     usrid_long  TYPE comm_id_long,
1574   END OF ty_email_data.
1575   DATA: "{lt_emp_id TYPE TABLE OF ty_email_data,
1576         wa_emp_id TYPE ty_email_data,
1577         lt_user TYPE TABLE OF lty_user,
1578         lv_user TYPE lty_user.
1579
1580
1581   CONSTANTS: lc_check TYPE char1 VALUE 'X'.
1582
1583
1584
1585
1586   swc_get_element container 'WAPINR' wapinr.
1587   swc_get_element container 'APPROVAL' approval.
1588   swc_get_element container 'APP_CYCLE' app_cycle.
1589
1590   *   Need to be implemented
1591   IF wapinr IS NOT INITIAL.
1592     CALL FUNCTION 'WCFA_READ_SINGLE'
1593       EXPORTING
1594         i_wapinr  = wapinr
1595       IMPORTING
1596         e_wcaapwa = wa_wcaapwa
1597       EXCEPTIONS
1598         error     = 1
1599         OTHERS    = 2.
1600
1601     SELECT * FROM zwcm_hierarchy
1602       INTO TABLE lt_permit
1603       WHERE iwerk = wa_wcaapwa-iwerk AND
1604             objart = 'WA'.
1605   *          PMSOG  = approval.
1606
1607     DELETE lt_permit WHERE stop_auth EQ 'X' OR ext_appr EQ 'X'.
1608     SORT lt_permit BY hilvl.
1609     LOOP AT lt_permit INTO wa_permit.
1610       IF wa_permit-pmsog = approval.
1611         lv_index = sy-tabix - 1.
1612       ENDIF.
1613     ENDLOOP.
1614
1615     READ TABLE lt_permit INTO wa_permit INDEX lv_index.
1616
1617     IF sy-subrc EQ 0.
1618       lv_previous_permit = wa_permit-pmsog.
1619       CALL FUNCTION 'ZWCA_GET_APPROVALS'
1620         EXPORTING
1621           wapinr   = wapinr
1622   *       WCD_FLAG =
1623         IMPORTING
1624           t_permit = lt_permit_std.
1625       READ TABLE lt_permit_std INTO wa_permit_std WITH KEY pmsog = lv_previous_permit.
1626       IF sy-subrc EQ 0.
1627         permit_txt   = wa_permit_std-gntxt.
1628       ENDIF.
1629
1630   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
1631   *    SELECT SINGLE counter FROM wcagn
1632   *      INTO lv_counter
1633   *      WHERE objnr = wa_wcaapwa-objnr AND
1634   *      pmsog = lv_previous_permit."wa_permit-pmsog.
1635    SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR =
1636   WA_WCAAPWA-OBJNR AND PMSOG = LV_PREVIOUS_PERMIT  ORDER BY  OBJNR
1637   COUNTER .   ENDSELECT.
1638   " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
1639   *    lv_counter = wa_permit-hilvl / 10.
1640
1641     ENDIF.
1642   * Check Application Exist or Not
1643     IF sy-subrc EQ 0.
1644
1645   * Get Object Number from WCM Application Data
1646       SELECT SINGLE objnr
1647            FROM wcaap
1648            INTO lv_objnr
1649            WHERE wapinr = wapinr.
1650
1651   * Get  Counters for differentiation from WCM Approval Segment
1652       SELECT * FROM zwcm_wcagns
1653              INTO TABLE lt_revoke_tab
1654              WHERE objnr EQ lv_objnr AND
1655                    counter EQ lv_counter.
1656
1657   * Sort Counters internal table in Descending to get highest counter value.
1658       SORT lt_revoke_tab BY counters DESCENDING .
1659       READ TABLE lt_revoke_tab INTO wa_revoke INDEX 1.
1660
1661       CLEAR lt_revoke_tab.
1662   * Create Work Area for Approval
1663       wa_revoke-geniname = sy-uname.
1664       wa_revoke-genidate = sy-datum.
1665       wa_revoke-genitime = sy-uzeit.
1666       wa_revoke-geniakt  = lc_check.
1667
1668   * Appending Work Area to Internal Table for DB Update.
1669       APPEND wa_revoke TO lt_revoke_tab.
1670   *    CLEAR wa_revoke.
1671
1672     ENDIF.
1673
1674   ENDIF.
1675   CALL FUNCTION 'ZWCFG_WCAGNS_UPDATE'
1676     EXPORTING
1677       i_updtab = lt_revoke_tab
1678     EXCEPTIONS
1679       error    = 1
1680       OTHERS   = 2.
1681   * When update is successful mark flagf as X.
1682   IF sy-subrc EQ 0.
1683     flag = 'X'.
1684
1685     CONCATENATE 'US' wa_revoke-genname INTO previous_approver.
1686   ENDIF.
1687
1688   previous_approval = lv_previous_permit.
1689
1690   ** Start of Email Logic**
1691   *LOOP AT gt_users INTO gw_users.
1692   lv_user = wa_revoke-genname.
1693   *  APPEND wa_user TO lt_user.
1694   *ENDLOOP.
1695   *gt_users-approver
1696   *IF gt_users IS NOT INITIAL.
1697
1698   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
1699   *SELECT SINGLE pernr usrid usrid_long FROM pa0105
1700   *  INTO wa_emp_id
1701   **    FOR ALL ENTRIES IN lt_user
1702   *  WHERE usrid = lv_user AND
1703   *        usrty = '0001'.
1704    SELECT PERNR USRID USRID_LONG FROM PA0105   UP TO 1 ROWS INTO
1705   WA_EMP_ID WHERE USRID = LV_USER AND USRTY = '0001'  ORDER BY  PERNR
1706   SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
1707   " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
1708
1709   IF sy-subrc EQ 0.
1710     SELECT SINGLE usrid_long FROM pa0105
1711      INTO r_email_id
1712      WHERE pernr = wa_emp_id-pernr AND
1713            usrty = '0010'.
1714   ENDIF.
1715
1716   *ENDIF.
1717   ** End of Email Logic**
1718
1719   swc_set_element container 'PREVIOUS_APPROVER' previous_approver.
1720   swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
1721   swc_set_element container 'R_EMAIL_ID' r_email_id.
1722   swc_set_element container 'FLAG' flag.
1723   swc_set_element container 'PERMIT_TXT' permit_txt.
1724   end_method.
1725
1726   begin_method send_approval_mail changing container.
1727   DATA:
1728         permit TYPE wcagn-pmsog,
1729         application TYPE wcaap-wapinr,
1730         email_id    TYPE pa0105-usrid_long OCCURS 0,
1731         revoke_text   TYPE rdgprint-stadd1 OCCURS 0,
1732         revoke_flag   TYPE wcagns-geniakt.
1733
1734   swc_get_element container 'PERMIT' permit.
1735   swc_get_element container 'APPLICATION' application.
1736   swc_get_table container 'EMAIL_ID' email_id.
1737   swc_get_table container 'REVOKE_TEXT' revoke_text.
1738   swc_get_element container 'REVOKE_FLAG' revoke_flag.
1739
1740   CALL FUNCTION 'ZWCM_SEND_MAIL'
1741     EXPORTING
1742       im_permit      = permit
1743       im_appl        = application
1744       it_email_id    = email_id
1745       it_revoke_text = revoke_text
1746       im_revoke_flag = revoke_flag.
1747
1748   end_method.
1749
1750
1751   *DATA:
1752   *      wapinr TYPE wcaap-wapinr,
1753   *
1754   **      appr_stat
1755   *
1756   *      flag_loop TYPE zwcm_custom-beg_loop_flag,
1757   *      sms_uname TYPE suid_st_bname-bname,
1758   *      sms_number TYPE threic_contact-mobile,
1759   *      permit_tx
1760   *      wa_permit   TYPE wctpc_permitwa_type.
1761   *swc_get_element container 'APPROVAL' approval.
1762   *swc_get_element container 'SMS_NUMBER' sms_number.
1763   *
1764   *CALL FUNCTION 'ZWCM_AUTO_APPROVAL'
1765   *  EXPORTING
1766   **   im_spool           =
1767   *    im_permit          = approval
1768   *    im_appl            = wapinr
1769   **   IM_WCD_FLAG        =
1770   **   IM_WORK_ITEMID     =
1771   *  IMPORTING
1772   *    ex_appr_status     = appr_status
1773   **   EX_USER_APROVE     =
1774   **   ET_USER            =
1775   *    ex_next_permit     = next_approval
1776   **   ET_TEXT            =
1777   **   ET_EMAIL_ID        =
1778   *    ex_flag_loop       = flag_loop
1779   **   EX_WCD_DOCNUM      =
1780   **   EX_COMPLETION_AUTH =
1781   **   EX_RENEWAL_AUTH    =
1782   **   EX_SINGLE_FLAG     =
1783   **   EX_PREV_PERMIT     =
1784   *  CHANGING
1785   *    ch_sms_uname       = sms_uname
1786   *    ch_sms_number      = sms_number.
1787   *
1788   *CALL FUNCTION 'ZWCA_GET_APPROVALS'
1789   *  EXPORTING
1790   *    wapinr   = wapinr
1791   **   WCD_FLAG =
1792   *  IMPORTING
1793   *    t_permit = lt_permit.
1794   *
1795   *  READ TABLE lt_permit INTO wa_permit with key pmsog = next_approval.
1796   *  IF sy-subrc eq 0.
1797   *    permit_txt = wa_permit-
1798   *
1799   *  ENDIF.
1800   *swc_set_element container 'APPR_STATUS' appr_status.
1801   *swc_set_element container 'NEXT_APPROVAL' next_approval.
1802   *swc_set_element container 'FLAG_LOOP' flag_loop.
1803   *swc_set_element container 'SMS_UNAME' sms_uname.
1804   *swc_set_element container 'SMS_NUMBER' sms_number.
1805   *swc_set_element container 'PERMIT_TXT' permit_txt.
1806   *end_method.
1807   *BEGIN_DATA OBJECT. " Do not change.. DATA is generated
1808   ** only private members may be inserted into structure private
1809   *DATA:
1810   *" begin of private,
1811   *"   to declare private attributes remove comments and
1812   *"   insert private attributes here ...
1813   *" end of private,
1814   *  BEGIN OF KEY,
1815   *      NUMBER LIKE WCAAP-WAPINR,
1816   *  END OF KEY.
1817   *END_DATA OBJECT. " Do not change.. DATA is generated
1818   *BEGIN_DATA OBJECT. " Do not change.. DATA is generated
1819   ** only private members may be inserted into structure private
1820   *DATA:
1821   *" begin of private,
1822   *"   to declare private attributes remove comments and
1823   *"   insert private attributes here ...
1824   *" end of private,
1825   *  BEGIN OF KEY,
1826   *      NUMBER LIKE WCAAP-WAPINR,
1827   *  END OF KEY.
1828   *END_DATA OBJECT. " Do not change.. DATA is generated
1829
1830   begin_method auto_approval changing container.
1831   DATA:
1832         wapinr TYPE wcaap-wapinr,
1833         approval TYPE wcagn-pmsog,
1834         appr_status TYPE wcagns-geniakt,
1835         next_approval TYPE wcagn-pmsog,
1836         flag_loop TYPE zwcm_custom-beg_loop_flag,
1837         previous_approval TYPE wcagn-pmsog,
1838         wcd_flag   TYPE wcagns-geniakt,
1839         sms_uname TYPE suid_st_bname-bname,
1840         sms_number TYPE threic_contact-mobile,
1841         permit_txt TYPE wcspermit-gntxt,
1842         lt_permit TYPE wctpc_permittab_type,
1843         wcd_docnum    TYPE zwcm_hierarchy-hilvl,
1844         wa_permit   TYPE wctpc_permitwa_type.
1845   swc_get_element container 'WAPINR' wapinr.
1846   swc_get_element container 'APPROVAL' approval.
1847   swc_get_element container 'SMS_NUMBER' sms_number.
1848   swc_get_element container 'WCD_FLAG' wcd_flag.
1849
1850   CALL FUNCTION 'ZWCM_AUTO_APPROVAL'
1851     EXPORTING
1852   *   im_spool           =
1853       im_permit          = approval
1854       im_appl            = wapinr
1855       im_wcd_flag        = wcd_flag
1856   *   IM_WORK_ITEMID     =
1857     IMPORTING
1858       ex_appr_status     = appr_status
1859   *   EX_USER_APROVE     =
1860   *   ET_USER            =
1861       ex_next_permit     = next_approval
1862   *   ET_TEXT            =
1863   *   ET_EMAIL_ID        =
1864       ex_flag_loop       = flag_loop
1865       ex_wcd_docnum      = wcd_docnum
1866   *   EX_COMPLETION_AUTH =
1867   *   EX_RENEWAL_AUTH    =
1868   *   EX_SINGLE_FLAG     =
1869       ex_prev_permit     = previous_approval
1870     CHANGING
1871       ch_sms_uname       = sms_uname
1872       ch_sms_number      = sms_number.
1873
1874   CALL FUNCTION 'ZWCA_GET_APPROVALS'
1875     EXPORTING
1876       wapinr   = wapinr
1877       wcd_flag = wcd_flag
1878     IMPORTING
1879       t_permit = lt_permit.
1880
1881   READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
1882   IF sy-subrc EQ 0.
1883     permit_txt = wa_permit-gntxt.
1884
1885   ENDIF.
1886   swc_set_element container 'APPR_STATUS' appr_status.
1887   swc_set_element container 'NEXT_APPROVAL' next_approval.
1888   swc_set_element container 'FLAG_LOOP' flag_loop.
1889   swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
1890   swc_set_element container 'SMS_UNAME' sms_uname.
1891   swc_set_element container 'PERMIT_TXT' permit_txt.
1892   swc_set_element container 'WCD_DOCNUM'    wcd_docnum.
1893   end_method.
1894
1895   begin_method revoke_all_approvals changing container.
1896   DATA:
1897         wapinr TYPE wcaap-wapinr,
1898         uname TYPE suid_st_bname-bname.
1899   swc_get_element container 'wapinr' wapinr.
1900   swc_get_element container 'uname' uname.
1901
1902   CALL FUNCTION 'ZWCM_WF_REVOKE_CLOSE'
1903     EXPORTING
1904       im_appl  = wapinr
1905       im_uname = uname.
1906
1907   end_method.
*--- End of ZRIWFWA01 - 1907 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 2
Object           ZRIWFWA01                                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
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
Generated incl.  %_CSLIS                                   Level 1    Page 3
Object           ZRIWFWA01                                 Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      type-pool slis .
2
3      types: slis_list_type(1) type n,
4             slis_char_1(1) type c,
5             slis_text40(40) type c.
6
7      types: slis_tabname(30) type c,
8             slis_fieldname(30) type c,
9             slis_sel_tab_field(60) type c,
10            slis_formname(30) type c,
11            slis_entry(60) type c,
12            slis_edit_mask(60) type c,
13            slis_coldesc(4) type c.
14
15     *Accessibility
16     types: slis_qinfo_alv type alv_s_qinf,
17            slis_t_qinfo_alv type slis_qinfo_alv occurs 0.
18
19     *types: begin of slis_filtered_entries,
20     *         index type i,
21     *       end of slis_filtered_entries.
22     types: slis_t_filtered_entries type i occurs 0.
23
24     *--- Structure for additional fieldcat
25     types: begin of slis_add_fieldcat,
26              fieldname type slis_fieldname,
27              web_field type slis_fieldname,
28              href_hndl type i,
29            end of slis_add_fieldcat.
30     types: slis_t_add_fieldcat type slis_add_fieldcat occurs 0.
31
32     *--- Structure for reprep-initialization
33     types: begin of slis_reprep_id,
34              tool(2) type c,
35              appl(4) type c,
36              subc(2) type c,
37              onam(54) type c,
38            end of slis_reprep_id.
39
40     types: begin of slis_reprep_communication,
41              stop(1) type c,
42            end of slis_reprep_communication.
43
44     *** Structure for colors
45     types: begin of slis_color,
46              col type i,
47              int type i,
48              inv type i,
49            end of slis_color.
50
51     types: begin of slis_coltypes,
52              heacolfir      type slis_color, " heading_cols_first
53              heacolnex      type slis_color, " heading_cols_nex
54              hearowfir      type slis_color, " heading_rows_first
55              hearownex      type slis_color, " heading_rows_next
56              lisbodfir      type slis_color, " list_body_first
57              lisbodnex      type slis_color, " list_body_next
58              lisbod         type slis_color, " list_body
59              higcolkey      type slis_color, " highlight_col_key
60              higcol         type slis_color, " highlight_col
61              higrow         type slis_color, " highlight_row
62              higsum         type slis_color, " highlight_sum
63              higsumhig      type slis_color, " highlight_sum_high
64              higsumlow      type slis_color, " highlight_sum_low
65              higins         type slis_color, " highlight_inserted
66              higpos         type slis_color, " highlight_positive
67              higneg         type slis_color, " highlight_negative
68              hig            type slis_color, " highlight
69              heahie         type slis_color, " heading_hier
70              lisbodhie      type slis_color, " list_body_hierinfo
71            end of slis_coltypes.
72
73     *** Fieldcat
74     types: begin of slis_fieldcat_main0,
75              row_pos        like sy-curow, " output in row
76              col_pos        like sy-cucol, " position of the column
77              fieldname      type slis_fieldname,
78              tabname        type slis_tabname,
79              currency(5)    type c,
80              cfieldname     type slis_fieldname, " field with currency unit
81              ctabname       type slis_tabname,   " and table
82              ifieldname     type slis_fieldname, " initial column
83              quantity(3)    type c,
84              qfieldname     type slis_fieldname, " field with quantity unit
85              qtabname       type slis_tabname,   " and table
86              round          type i,        " round in write statement
87              exponent(3)       type c,     " exponent for floats
88              key(1)         type c,        " column with key-color
89              icon(1)        type c,        " as icon
90              symbol(1)      type c,        " as symbol
91              checkbox(1)    type c,        " as checkbox
92              just(1)        type c,        " (R)ight (L)eft (C)ent.
93              lzero(1)       type c,        " leading zero
94              no_sign(1)     type c,        " write no-sign
95              no_zero(1)     type c,        " write no-zero
96              no_convext(1)  type c,
97              edit_mask      type slis_edit_mask,                "
98              emphasize(4)   type c,        " emphasize
99              fix_column(1)   type c,       " Spalte fixieren
100             do_sum(1)      type c,        " sum up
101             no_out(1)      type c,        " (O)blig.(X)no out
102             tech(1)        type c,        " technical field
103             outputlen      like dd03p-outputlen,
104             offset         type dd03p-outputlen,     " offset
105             seltext_l      like dd03p-scrtext_l, " long key word
106             seltext_m      like dd03p-scrtext_m, " middle key word
107             seltext_s      like dd03p-scrtext_s, " short key word
108             ddictxt(1)     type c,        " (S)hort (M)iddle (L)ong
109             rollname       like dd03p-rollname,
110             datatype       like dd03p-datatype,
111             inttype        like dd03p-inttype,
112             intlen         like dd03p-intlen,
113             lowercase      like dd03p-lowercase,
114             decfloat_style type outputstyle,          " B20K8A2GF0
115             parameter0     type char30,
116             parameter1     type char30,
117             parameter2     type char30,
118             parameter3     type char30,
119             parameter4     type char30,
120             parameter5     type int4,
121             parameter6     type int4,
122             parameter7     type int4,
123             parameter8     type int4,
124             parameter9     type int4,
125           end of slis_fieldcat_main0.
126
127    types: begin of slis_fieldcat_main1,
128             ref_fieldname  like dd03p-fieldname,
129             ref_tabname    like dd03p-tabname,
130             roundfieldname type slis_fieldname,
131             roundtabname   type slis_tabname,
132             decimalsfieldname type slis_fieldname,
133             decimalstabname   type slis_tabname,
134             decimals_out(6)   type c,     " decimals in write statement
135             text_fieldname type slis_fieldname,
136             reptext_ddic   like dd03p-reptext,   " heading (ddic)
137             ddic_outputlen like dd03p-outputlen,
138           end of slis_fieldcat_main1.
139
140    types: begin of slis_fieldcat_main.
141    include type slis_fieldcat_main0.
142    include type slis_fieldcat_main1.
143    types: end of slis_fieldcat_main.
144
145    types: begin of slis_fieldcat_alv_spec,
146             key_sel(1)     type c,        " field not obligatory
147             no_sum(1)      type c,        " do not sum up
148             sp_group(4)    type c,        " group specification
149             reprep(1)      type c,        " selection for rep/rep
150             input(1)       type c,        " input
151             edit(1)        type c,        " internal use only
152             hotspot(1)     type c,        " hotspot
153           end of slis_fieldcat_alv_spec.
154
155    types: begin of slis_fieldcat_alv.
156    include type slis_fieldcat_main.
157    include type slis_fieldcat_alv_spec.
158    types: end of slis_fieldcat_alv.
159
160    types: begin of slis_fieldcat_alv1.
161    include type slis_fieldcat_main1.
162    types: end of slis_fieldcat_alv1.
163
164    types: slis_t_fieldcat_alv type slis_fieldcat_alv occurs 1.
165
166    * Events for Callback
167    types: begin of slis_event_exit.
168    types:   ucomm like sy-ucomm,
169             before(1) type c,
170             after(1) type c,
171           end of slis_event_exit.
172    types: slis_t_event_exit type slis_event_exit occurs 1.
173
174    * Callback Interface structure for non display subtotals text
175    types: begin of slis_subtot_text,
176             criteria type slis_fieldname,
177             keyword  like dd03p-reptext,
178             criteria_text(255) type c,
179             max_len  like dd03p-outputlen,
180             display_text_for_subtotal(255) type c,
181           end of slis_subtot_text.
182
183    *** Layout
184    types: begin of slis_print_alv0,
185             print(1) type c,              " print to spool
186             prnt_title(1) type c,         " moment to print the title
187           end of slis_print_alv0.
188
189    types: begin of slis_print_alv1,
190             no_print_selinfos(1) type c,  " display no selection infos
191             no_coverpage(1) type c,                            "
192             no_new_page(1) type c,                             "
193             reserve_lines type i,         " lines reserved for end of page
194             no_print_listinfos(1) type c, " display no listinfos
195             no_change_print_params(1) type c,  " don't change linesize
196             no_print_hierseq_item(1) type c,  "don't expand item
197             print_ctrl type ALV_S_Pctl,
198           end of slis_print_alv1.
199
200    types: begin of slis_print_alv.
201    include type alv_s_prnt.
202    include type slis_print_alv1.
203    types: end of slis_print_alv.
204
205    types: begin of slis_layout_main,
206             dummy,
207           end of slis_layout_main.
208
209    types: begin of slis_layout_alv_spec0,
210             no_colhead(1) type c,         " no headings
211             no_hotspot(1) type c,         " headings not as hotspot
212             zebra(1) type c,              " striped pattern
213             no_vline(1) type c,           " columns separated by space
214             no_hline(1) type c,        "rows separated by space B20K8A0N5D
215             cell_merge(1) type c,         " not suppress field replication
216             edit(1) type c,               " for grid only
217             edit_mode(1) type c,          " for grid only
218             numc_sum(1)     type c,       " totals for NUMC-Fields possib.
219             no_input(1) type c,           " only display fields
220             f2code like sy-ucomm,                              "
221             reprep(1) type c,             " report report interface active
222             no_keyfix(1) type c,          " do not fix keycolumns
223             expand_all(1) type c,         " Expand all positions
224             no_author(1) type c,          " No standard authority check
225    *        PF-status
226             def_status(1) type c,         " default status  space or 'A'
227             item_text(20) type c,         " Text for item button
228             countfname type lvc_fname,
229           end of slis_layout_alv_spec0.
230
231    types: begin of slis_layout_alv_spec1,
232    *        Display options
233             colwidth_optimize(1) type c,
234             no_min_linesize(1) type c,    " line size = width of the list
235             min_linesize like sy-linsz,   " if initial min_linesize = 80
236             max_linesize like sy-linsz,   " Default 250
237             window_titlebar like sy-title,
238             no_uline_hs(1) type c,
239    *        Exceptions
240             lights_fieldname type slis_fieldname," fieldname for exception
241             lights_tabname type slis_tabname, " fieldname for exception
242             lights_rollname like dfies-rollname," rollname f. exceptiondocu
243             lights_condense(1) type c,    " fieldname for exception
244    *        Sums
245             no_sumchoice(1) type c,       " no choice for summing up
246             no_totalline(1) type c,       " no total line
247             no_subchoice(1) type c,       " no choice for subtotals
248             no_subtotals(1) type c,       " no subtotals possible
249             no_unit_splitting type c,     " no sep. tot.lines by inh.units
250             totals_before_items type c,   " diplay totals before the items
251             totals_only(1) type c,        " show only totals
252             totals_text(60) type c,       " text for 1st col. in total line
253             subtotals_text(60) type c,    " text for 1st col. in subtotals
254    *        Interaction
255             box_fieldname type slis_fieldname, " fieldname for checkbox
256             box_tabname type slis_tabname," tabname for checkbox
257             box_rollname like dd03p-rollname," rollname for checkbox
258             expand_fieldname type slis_fieldname, " fieldname flag 'expand'
259             hotspot_fieldname type slis_fieldname, " fieldname flag hotspot
260             confirmation_prompt,          " confirm. prompt when leaving
261             key_hotspot(1) type c,        " keys as hotspot " K_KEYHOT
262             flexible_key(1) type c,       " key columns movable,...
263             group_buttons(1) type c,      " buttons for COL1 - COL5
264             get_selinfos(1) type c,       " read selection screen
265             group_change_edit(1) type c,  " Settings by user for new group
266             no_scrolling(1) type c,       " no scrolling
267    *        Detailed screen
268             detail_popup(1) type c,       " show detail in popup
269             detail_initial_lines(1) type c, " show also initial lines
270             detail_titlebar like sy-title," Titlebar for detail
271    *        Display variants
272             header_text(20) type c,       " Text for header button
273             default_item(1) type c,       " Items as default
274    *        colour
275             info_fieldname type slis_fieldname, " infofield for listoutput
276             coltab_fieldname type slis_fieldname, " colors
277    *        others
278             list_append(1) type c,       " no call screen
279             xifunckey type aqs_xikey,    " eXtended interaction(SAPQuery)
280             xidirect type flag,          " eXtended INTeraction(SAPQuery)
281             dtc_layout type dtc_s_layo,  "Layout for configure the Tabstip
282             allow_switch_to_list(1) type c, "ACC: Switch from FullGrid to List
283           end of slis_layout_alv_spec1.
284
285    types: begin of slis_layout_alv_spec.
286    include type slis_layout_alv_spec0.
287    include type slis_layout_alv_spec1.
288    types: end of slis_layout_alv_spec.
289
290    types: begin of slis_layout_alv.
291    include type slis_layout_main.
292    include type slis_layout_alv_spec.
293    types: end of slis_layout_alv.
294
295    types: begin of slis_layout_alv1.
296    include type slis_layout_main.
297    include type slis_layout_alv_spec1.
298    types: end of slis_layout_alv1.
299
300    *--- Structure for the excluding table (function codes)
301    types: begin of slis_extab,
302             fcode like rsmpe-func,
303           end of slis_extab.
304    *--- Lineinfo before output
305    types: begin of slis_lineinfo,
306             tabname type slis_tabname,
307             tabindex like sy-tabix,
308             subtot(1) type c,
309             subtot_level(2) type n,
310             endsum(1) type c,
311             sumindex like sy-tabix,
312             linsz like sy-linsz,
313             linno like sy-linno,
314           end of slis_lineinfo.
315    *--- Structure for scrolling in list
316    types: begin of slis_list_scroll,
317             lsind like sy-lsind,
318             cpage like sy-cpage,
319             staro like sy-staro,
320             staco like sy-staco,
321             cursor_line like sy-curow,
322             cursor_offset like sy-cucol,
323           end of slis_list_scroll.
324    * information cursor position ALV
325    types: begin of slis_selfield,
326             tabname type slis_tabname,
327             tabindex like sy-tabix,
328             sumindex like sy-tabix,
329             endsum(1) type c,
330             sel_tab_field type slis_sel_tab_field,
331             value type slis_entry,
332             before_action(1) type c,
333             after_action(1) type c,
334             refresh(1) type c,
335             ignore_multi(1) type c, " ignore selection by checkboxes (F2)
336             col_stable(1) type c,
337             row_stable(1) type c,
338    *        colwidth_optimize(1) type c,
339             exit(1) type c,
340             fieldname type slis_fieldname,
341             grouplevel type i,
342             collect_from type i,
343             collect_to type i,
344           end of slis_selfield.
345
346    *--- excluding table
347    types: slis_t_extab type slis_extab occurs 1.
348    * special groups for column selection
349    types: begin of slis_sp_group_alv,
350             sp_group(4) type c,
351             text(40) type c,
352           end of slis_sp_group_alv.
353    types: slis_t_sp_group_alv type slis_sp_group_alv occurs 1.
354
355    * information for sort and subtotals
356    types: begin of slis_sortinfo_alv,
357    *        spos(2) type n,
358             spos like alvdynp-sortpos,
359             fieldname type slis_fieldname,
360             tabname type slis_fieldname,
361    *        up(1) type c,
362    *        down(1) type c,
363    *        group(2) type c,
364    *        subtot(1) type c,
365             up like alvdynp-sortup,
366             down like alvdynp-sortdown,
367             group like alvdynp-grouplevel,
368             subtot like alvdynp-subtotals,
369             comp(1) type c,
370             expa(1) type c,
371             obligatory(1) type c,
372           end of slis_sortinfo_alv.
373    types: slis_t_sortinfo_alv type slis_sortinfo_alv occurs 1.
374    * information for selections
375    types: begin of slis_seldis1_alv,
376             field like dfies-fieldname,
377             table like dfies-tabname,
378             stext(40),
379             valuf(80),
380             valut(80),
381             sign0(1),
382             optio(2),
383             ltext(40),
384             stype(1),
385             length type p,
386             no_text(1),
387             inttype like dfies-inttype,
388             fieldname type slis_fieldname,
389             tabname type slis_tabname,
390             org_selname type rsscr_name,  "introduced this FO 09.01.00
391           end of slis_seldis1_alv.
392
393    types: slis_seldis_alv type slis_seldis1_alv occurs 1.
394
395    * filter
396    types: begin of slis_filter_alv0,
397             fieldname type slis_fieldname,
398             tabname type slis_tabname,
399             seltext(40),
400             valuf(80),
401             valut(80),
402             valuf_int(80),
403             valut_int(80),
404             sign0(1),
405             sign_icon(4),
406             optio(2),
407             stype(1),
408             decimals like dfies-decimals,
409             intlen like dfies-intlen,
410             convexit like dfies-convexit,
411             edit_mask type slis_edit_mask,
412             lowercase like dfies-lowercase,
413             inttype like dfies-inttype,
414             datatype like dfies-datatype,
415             exception(1) type c,
416             no_sign(1) type c,
417             or(1) type c,
418             order type order,
419             cqvalue(5) type c,
420           end of slis_filter_alv0.
421
422    types: begin of slis_filter_alv1,
423             ref_fieldname like dfies-fieldname,
424             ref_tabname like dfies-tabname,
425             ddic_outputlen like dfies-outputlen,
426           end of slis_filter_alv1.
427
428    types: begin of slis_filter_alv.
429    include type slis_filter_alv0.
430    include type slis_filter_alv1.
431    types: end of slis_filter_alv.
432    types: slis_t_filter_alv type slis_filter_alv occurs 1.
433
434    * delete or add an entry in the select-option info
435    types: begin of slis_selentry_hide_alv,
436             mode(1) type c,               "(D)elete (A)dd
437             selname like rsparams-selname.
438    include type slis_seldis1_alv.
439    types  end of slis_selentry_hide_alv.
440    types: slis_t_selentry_hide_alv type slis_selentry_hide_alv occurs 1.
441
442    * delete or add an entry in the select-option info
443    types: begin of slis_sel_hide_alv,
444             mode(1) type c,               "(R)eplace or (C)hange
445             t_entries type slis_t_selentry_hide_alv,
446           end of slis_sel_hide_alv.
447    * Header table for top of page
448    types: begin of slis_listheader,
449             typ(1) type c,   " H = Header, S = Selection, A = Action
450             key(20) type c,
451             info type slis_entry,
452           end of slis_listheader.
453    types: slis_t_listheader type slis_listheader occurs 1.
454    *--- Structure for specific color settings
455    types: begin of slis_specialcol_alv,
456             fieldname type slis_fieldname,
457             color     type slis_color,
458             nokeycol(1) type c,
459           end of slis_specialcol_alv.
460    types: slis_t_specialcol_alv type slis_specialcol_alv occurs 1.
461    *--- Structure for event handling
462    types: begin of slis_alv_event,
463            name(30),
464            form(30),
465          end of slis_alv_event.
466    types: slis_t_event type slis_alv_event occurs 0.
467    *--- Structure for key information
468    types: begin of slis_keyinfo_alv,
469             header01 type slis_fieldname,
470             item01 type slis_fieldname,
471             header02 type slis_fieldname,
472             item02 type slis_fieldname,
473             header03 type slis_fieldname,
474             item03 type slis_fieldname,
475             header04 type slis_fieldname,
476             item04 type slis_fieldname,
477             header05 type slis_fieldname,
478             item05 type slis_fieldname,
479           end of slis_keyinfo_alv.
480    *--- Structure for callback CALLER_EXIT and REUSE_ALV_POPUP_TO_SELECT
481    types: begin of slis_data_caller_exit,
482            dummy like sy-repid,
483            without_load_variant(1),
484            callback_header_transport type slis_formname,
485            columnopt(1),
486          end of slis_data_caller_exit.
487
488    types: begin of slis_status,
489             callback_program like sy-repid,
490             callback_pf_status_set type slis_formname,
491             callback_user_command  type slis_formname,
492             counter_of_lists_added type i,
493             actual_list_to_display type i,
494             flg_to_be_refreshed,
495             it_excluding type slis_t_extab,
496             print type slis_print_alv,
497             flg_checkboxes_active,
498             flg_overview_active,
499             flg_intcheck(1) type c,
500           end of slis_status.
501    * Exporting structure
502    types: begin of slis_exit_by_user,
503             back(1) type c,
504             exit(1) type c,
505             cancel(1) type c,
506           end of slis_exit_by_user.
507
508    constants:
509    * Events
510    slis_ev_item_data_expand   type slis_formname value 'ITEM_DATA_EXPAND',
511    slis_ev_reprep_sel_modify  type slis_formname value 'REPREP_SEL_MODIFY',
512    slis_ev_caller_exit_at_start type slis_formname value 'CALLER_EXIT',
513    slis_ev_user_command       type slis_formname value 'USER_COMMAND',
514    slis_ev_top_of_page        type slis_formname value 'TOP_OF_PAGE',
515    slis_ev_data_changed       type slis_formname value 'DATA_CHANGED',
516    slis_ev_top_of_coverpage   type slis_formname value 'TOP_OF_COVERPAGE',
517    slis_ev_end_of_coverpage   type slis_formname value 'END_OF_COVERPAGE',
518    slis_ev_foreign_top_of_page type slis_formname
519                                           value 'FOREIGN_TOP_OF_PAGE',
520    slis_ev_foreign_end_of_page type slis_formname
521                                           value 'FOREIGN_END_OF_PAGE',
522    slis_ev_pf_status_set      type slis_formname value 'PF_STATUS_SET',
523    slis_ev_list_modify        type slis_formname value 'LIST_MODIFY',
524    slis_ev_top_of_list        type slis_formname value 'TOP_OF_LIST',
525    slis_ev_end_of_page        type slis_formname value 'END_OF_PAGE',
526    slis_ev_end_of_list        type slis_formname value 'END_OF_LIST',
527    slis_ev_after_line_output  type slis_formname value 'AFTER_LINE_OUTPUT',
528    slis_ev_before_line_output type slis_formname value
529                                                       'BEFORE_LINE_OUTPUT',
530    slis_ev_subtotal_text      type slis_formname value 'SUBTOTAL_TEXT',
531    slis_ev_grouplevel_change  type slis_formname value 'GROUPLEVEL_CHANGE',
532    slis_ev_context_menu       type slis_formname value 'CONTEXT_MENU',
533
534    slis_ev_print_top_of_list  type slis_formname value 'PRINT_TOP_OF_LIST',
535    slis_ev_print_end_of_list  type slis_formname value 'PRINT_END_OF_LIST'.
536
537    *lowercase for DDIC_SCAN
538    types: slis_fieldinfo type fieldinfo.
539    types: begin of slis_fieldinfo2.
540    types: lowercase type c.
541           include type slis_fieldinfo.
542    types: end of slis_fieldinfo2.
543    types: slis_t_fieldinfo2 type standard table of slis_fieldinfo2.
*--- End of %_CSLIS - 543 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTP1                                  Level 1    Page 4
Object           ZRIWFWA01                                 Lines 2012
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTP1
3      *-----------------------------------------------------------------------
4      *  Purpose: general definitions
5      ************************************************************************
6      TYPE-POOL wctp1.
7
8      * elementary types *****************************************************
9      TYPES: wctp1_task_type               TYPE wcetask.
10     TYPES: wctp1_action_type             TYPE wceaction.
11     TYPES: wctp1_store_type(1)           TYPE c.
12     TYPES: wctp1_lckg_obj_type(3)        TYPE c.
13     TYPES: wctp1_boolean_type            TYPE wceboolean.
14     TYPES: wctp1_flg_type                TYPE wceflg.
15     TYPES: wctp1_sign_type               TYPE ddsign.
16     TYPES: wctp1_option_type             TYPE ddoption.
17     TYPES: wctp1_cnt_type                TYPE i.
18     TYPES: wctp1_tlcnt_type              TYPE wcetlcnt.
19     TYPES: wctp1_vercnt_type             TYPE i.
20     TYPES: wctp1_pacnt_type              TYPE i.
21     TYPES: wctp1_aktyp_type              TYPE aktyp.
22     TYPES: wctp1_reftyp_type             TYPE wcetypref.
23     TYPES: wctp1_stxt_type               TYPE wcefsdstxt.
24     TYPES: wctp1_ptxt_type               TYPE wcefsdptxt.
25     TYPES: wctp1_direction_type          TYPE wceway.
26     TYPES: wctp1_objnr_type              TYPE j_objnr.
27     TYPES: wctp1_objart_type             TYPE wceobjart.
28     TYPES: wctp1_objtyp_type             TYPE wcetyp.
29     TYPES: wctp1_objkey_type             TYPE wceno.
30     TYPES: wctp1_subkey_type             TYPE wceitm.
31     TYPES: wctp1_iwerk_type              TYPE iwerk.
32     TYPES: wctp1_ccobj_type              TYPE wceccobj.
33     TYPES: wctp1_cctyp_type              TYPE wcecctyp.
34     TYPES: wctp1_dataloss_type           TYPE dialog.
35     TYPES: wctp1_date_type               TYPE sydatum.
36     TYPES: wctp1_time_type               TYPE syuzeit.
37     TYPES: wctp1_dokob_type              TYPE dokob.
38     TYPES: wctp1_objky_type              TYPE objky.
39     TYPES: wctp1_icon_id_type            TYPE icon_d.
40     TYPES: wctp1_icon_text_type          TYPE gui_ictext.
41     TYPES: wctp1_tooltip_type            TYPE gui_info.
42     TYPES: wctp1_variable_text_type(2)   TYPE c.
43     TYPES: wctp1_menu_stxt_type          TYPE cua_text_s.
44     TYPES: wctp1_field_type              TYPE dynfnam.
45     TYPES: wctp1_value_type              TYPE dline.
46     TYPES: wctp1_answer_type(1)          TYPE c.
47     TYPES: wctp1_radio_type(1)           TYPE c.
48     TYPES: wctp1_popup_radio_hide(6)     TYPE c.
49     TYPES: wctp1_header_type(100)        TYPE c.
50     TYPES: wctp1_color_type              TYPE wcecolor.
51     TYPES: wctp1_tl_type                 TYPE wcetl.
52     TYPES: wctp1_popup_type              TYPE wcepopupctrl.
53     TYPES: wctp1_menue_type              TYPE wcemenuctrl.
54     TYPES: wctp1_exception_type(6)       TYPE c.
55     TYPES: wctp1_screen_type             TYPE wcescreenctrl.
56     TYPES: wctp1_affix_typ_type          TYPE wcetxtaffix.
57     TYPES: wctp1_tdname_type             TYPE objnr_tx.
58     TYPES: wctp1_tdobject_type           TYPE tdobject.
59     TYPES: wctp1_tdid_type               TYPE tdid.
60     TYPES: wctp1_usable_type             TYPE wceusable.
61     TYPES: wctp1_model_type              TYPE wcemodel.
62     TYPES: wctp1_conversion_type(1)      TYPE c.
63     TYPES: wctp1_character_type(1)       TYPE c.
64     TYPES: wctp1_output_mode_type(1)     TYPE c.
65     TYPES: wctp1_operational_tag_type(1) TYPE c.
66     TYPES: wctp1_check_type(1)           TYPE c.
67     TYPES: wctp1_point_in_time_type(5)   TYPE c.
68     TYPES: wctp1_statement_type(3)       TYPE c.
69     TYPES: wctp1_userid_type             TYPE xubname.
70     TYPES: wctp1_line_type               TYPE sylilli.
71     TYPES: wctp1_usrfld_type             TYPE wcefselusrfld.
72     TYPES: wctp1_position_type(1)        TYPE c.
73     TYPES: wctp1_assgn_chklvl_type       TYPE wctp1_cnt_type.
74     TYPES: wctp1_opcode_type(1)          TYPE c.
75     TYPES: wctp1_dynpblock_type(1)       TYPE c.
76     TYPES: wctp1_badge_type              TYPE wcebadge.
77     TYPES: wctp1_appl_class_type(1)      TYPE c.
78     TYPES: wctp1_upd_mode_type(1)        TYPE c.
79
80     * structure types ******************************************************
81     * ENQUEUE DATA
82     TYPES:
83       BEGIN OF wctp1_enqdata_type,
84         uname TYPE eqeuname,
85         date  TYPE eqedate,
86         time  TYPE eqetime,
87         tcode TYPE eqetcode,
88         mode  TYPE eqegramode,
89       END   OF wctp1_enqdata_type.
90     * AFFIX
91     TYPES:
92       BEGIN OF wctp1_affix_type,
93         typ TYPE wctp1_affix_typ_type,
94         cnt TYPE i_count,
95       END  OF wctp1_affix_type.
96     * REFERENCE
97     TYPES: wctp1_reference_type TYPE wcsreference.
98     * TABLE OF FUNCTION CODES
99     TYPES: wctp1_stackwa_type TYPE wcsstack.
100    TYPES: wctp1_stacktab_type TYPE wctstack.
101    * INFLUENCE (call transaction)
102    TYPES: wctp1_influence_type TYPE wcsinfluence.
103    * GENERAL STRUCTURE
104    TYPES: wctp1_inf_type TYPE wcsinf.
105    * SPA / GPA parameters
106    TYPES:
107      BEGIN OF wctp1_pid_type,
108        iwk TYPE wctp1_iwerk_type, "planning plant
109        anr TYPE aufnr,            "order number
110        wc1 TYPE wcewapnr,         "work approval
111        wc2 TYPE wcewapinr,        "application
112        wc3 TYPE wcewcnr,          "WC document
113        wc4 TYPE wcetyp,           "type of WCM object
114      END   OF wctp1_pid_type.
115    * COPY (create by reference)
116    TYPES:
117      BEGIN OF wctp1_copy_type,
118        memflg       TYPE wctp1_flg_type,
119    *   document management
120        dokob_new    TYPE wctp1_dokob_type,
121        objky_new    TYPE wctp1_objky_type,
122        dokob_old    TYPE wctp1_dokob_type,
123        objky_old    TYPE wctp1_objky_type,
124    *   long text
125        org_tdobject TYPE wctp1_tdobject_type,
126        org_tdid     TYPE wctp1_tdid_type,
127        org_objnr    TYPE wctp1_objnr_type,
128        ref_tdobject TYPE wctp1_tdobject_type,
129        ref_tdid     TYPE wctp1_tdid_type,
130        ref_objnr    TYPE wctp1_objnr_type,
131    *   catalogues
132        objart_org   TYPE wctp1_objart_type,
133        objtyp_org   TYPE wctp1_objtyp_type,
134        objart_ref   TYPE wctp1_objart_type,
135        objtyp_ref   TYPE wctp1_objtyp_type,
136      END   OF wctp1_copy_type.
137    * CURSOR (get cursor ...)
138    TYPES:
139      BEGIN OF wctp1_cursor_type,
140        fieldname  TYPE wctp1_field_type, "field name
141        fieldvalue TYPE wctp1_value_type, "formatted content of the screen element
142        line       TYPE wctp1_cnt_type,   "number of the row of the table control or the group of the step loop
143        offset     TYPE wctp1_cnt_type,   "position of the cursor within the screen element
144        length     TYPE wctp1_cnt_type,   "length of the screen element
145        dynnr      TYPE sydynnr,          "dynpro number
146      END   OF wctp1_cursor_type.
147    * WCM OBJECT
148    TYPES:
149      BEGIN OF wctp1_wcmobj_type,
150        iwerk  TYPE wctp1_iwerk_type,  "planning plant
151        objart TYPE wctp1_objart_type, "object type
152        objtyp TYPE wctp1_objtyp_type, "subobject type
153        stxt   TYPE wctp1_stxt_type,   "descriptive short text
154        ptxt   TYPE wctp1_ptxt_type,   "descriptive short text in plural
155      END   OF wctp1_wcmobj_type.
156    * LINEUP
157    TYPES:
158      BEGIN OF wctp1_lineup_type,
159        iwerk  TYPE wctp1_iwerk_type,  "planning plant
160        objart TYPE wctp1_objart_type, "object type
161        lutyp  TYPE wcelutyp,          "subobject type
162        stxt   TYPE wctp1_stxt_type,   "descriptive short text
163        ptxt   TYPE wctp1_ptxt_type,   "descriptive short text in plural
164      END   OF wctp1_lineup_type.
165    * ASSIGNMENTs
166    TYPES:
167      BEGIN OF wctp1_updn_type,
168        objart  TYPE wctp1_objart_type, "object type
169        objtyp  TYPE wctp1_objtyp_type, "subobject type
170        stxt    TYPE wctp1_stxt_type,   "descriptive short text
171        ptxt    TYPE wctp1_ptxt_type,   "descriptive short text in plural
172        text    TYPE itex132,           "text
173        replace TYPE itex132,           "text replacement
174        custcnt TYPE wctp1_cnt_type,    "maximum number of assignments
175        applcnt TYPE wctp1_cnt_type,    "current number of assignments
176        applflg TYPE wctp1_flg_type,    "assignments exist
177      END   OF wctp1_updn_type.
178    * COMMON INFORMATION OF SLAVEs
179    TYPES:
180      BEGIN OF wctp1_slaves_type,
181        objart    TYPE wctp1_objart_type, "object type
182        objtyp    TYPE wctp1_objtyp_type, "subobject type
183        number    TYPE wctp1_cnt_type,    "number of slave types
184        stxt      TYPE wctp1_stxt_type,   "descriptive short text in singular
185        ptxt      TYPE wctp1_ptxt_type,   "descriptive short text in plural
186        m2sseflg  TYPE wceseflg,          "SLAVE can be chosen by the MASTER {space,X := can be chosen}
187        m2scrflg  TYPE wcecrflg,          "SLAVE can be created by the MASTER {space,X := can be created}
188        m2schflg  TYPE wcechflg,          "SLAVE can be changed by the MASTER {space,X := can be changed}
189        m2slnkcnt TYPE wctp1_cnt_type,    "maximum number of assignments (MASTER -> SLAVEs)
190        s2mlnkcnt TYPE wctp1_cnt_type,    "maximum number of assignments (SLAVE -> MASTERs)
191      END   OF wctp1_slaves_type.
192    * COPY REFERENCE FOR WORK TYPEs AND NEEDs
193    TYPES:
194      BEGIN OF wctp1_wkneedref_type,
195        objnr   TYPE wctp1_objnr_type, "object number
196        wkflg   TYPE wcewkflg,         "work exists
197        needflg TYPE wceneedflg,       "requirement exists
198      END   OF wctp1_wkneedref_type.
199    * INDEX
200    TYPES:
201      BEGIN OF wctp1_index_type,
202        max TYPE syindex, "number of entries
203        bas TYPE syindex, "new basis index
204        pag TYPE syindex, "number of entries per page
205        top TYPE syindex, "first row
206      END   OF wctp1_index_type.
207    * DB COUNTERs
208    TYPES:
209      BEGIN OF wctp1_dbcnt_type,
210        del TYPE wctp1_cnt_type, "number of deleted entries
211        ins TYPE wctp1_cnt_type, "number of added entries
212        upd TYPE wctp1_cnt_type, "number of changed entries
213      END   OF wctp1_dbcnt_type.
214    * FLAG COUNTERs
215    TYPES:
216      BEGIN OF wctp1_flgcnt_type,
217        marked   TYPE wctp1_cnt_type, "number of marked entries
218        unmarked TYPE wctp1_cnt_type, "number of marked entries
219        total    TYPE wctp1_cnt_type, "number of all entries
220      END   OF wctp1_flgcnt_type.
221    * MESSAGE TYPES COUNTERs
222    TYPES:
223      BEGIN OF wctp1_msgcnt_type,
224        error   TYPE wctp1_cnt_type, "number of errors
225        warning TYPE wctp1_cnt_type, "number of warnings
226        nothing TYPE wctp1_cnt_type, "number of notes
227      END   OF wctp1_msgcnt_type.
228    * DATE/TIME TUPLES
229    TYPES:
230      BEGIN OF wctp1_datetime_type,
231        date TYPE wctp1_date_type, "date
232        time TYPE wctp1_time_type, "time
233      END   OF wctp1_datetime_type.
234    *WCM_PTW (WORK_AREA)
235    TYPES: wctp1_wrkpmtsftyrqmtwa_type TYPE wrkpmtsftyrqmt.
236    TYPES: wctp1_wrkpmtisshistwa_type TYPE wrkpmtisshist.
237    TYPES: wctp1_sftycertsftyrqmtwa_type TYPE sftycertsftyrqmt.
238    * APPLICATION (work area)
239    TYPES: wctp1_wcaapwa_type TYPE wcaap.
240    TYPES: wctp1_wcvapwa_type TYPE wcvap.
241    * VALUATIONS (work area)
242    TYPES: wctp1_wcabwa_type TYPE wcab.
243    * LOG FOR VALUATION (work area)
244    TYPES: wctp1_wcabqwa_type TYPE wcabq.
245    * OPERATIONAL CLASSES <-> TECHNICAL OBJECTs (work area)
246    TYPES: wctp1_wcacdwa_type TYPE wcacd.
247    * OPERATIONAL CONDITIONs <-> OPERATIONAL CLASSES (work area)
248    TYPES: wctp1_wcacewa_type TYPE wcace.
249    * WCM OBJECTSs <-> CATALOGs (work area)
250    TYPES: wctp1_wcacgwa_type TYPE wcacg.
251    * LOG FOR  CATALOGs (work area)
252    TYPES: wctp1_wcacgqwa_type TYPE wcacgq.
253    * (TEMPORARY) TIME FRAME LOG (work area)
254    TYPES: wctp1_wcachwa_type TYPE wcach.
255    * (TEMPORARY) SWITCHING LOG (work area)
256    TYPES: wctp1_wcaciwa_type TYPE wcaci.
257    * OPERATIONAL CONDITION/TYPE (work area)
258    TYPES: wctp1_wcacmwa_type TYPE wcacm.
259    * (TEMPORARY) LOG FOR OPERATIONAL TAGS (work area)
260    TYPES: wctp1_wcacnwa_type TYPE wcacn.
261    * LOG FOR OPERATIONAL TAGS (work area)
262    TYPES: wctp1_wcacnqwa_type TYPE wcacnq.
263    * (TEMPORARY) LOG FOR REFERENCE OBJECT (work area)
264    TYPES: wctp1_wcacowa_type TYPE wcaco.
265    * SWITCHING LOG (work area)
266    TYPES: wctp1_wcacqwa_type TYPE wcacq.
267    * (TEMPORARY) LOG FOR PROHIBITED AREA (work area)
268    TYPES: wctp1_wcacswa_type TYPE wcacs.
269    * APPROVAL GROUP (work area)
270    TYPES: wctp1_wcadwa_type TYPE wcad.
271    * LOG FOR APPROVAL GROUPS (work area)
272    TYPES: wctp1_wcadqwa_type TYPE wcadq.
273    * WCM OPERATIONs <-> APPROVAL GROUPs (work area)
274    TYPES: wctp1_wcaewa_type TYPE wcae.
275    * LOG FOR APPROVAL GROUPs ASSIGNMENTS (work area)
276    TYPES: wctp1_wcaeqwa_type TYPE wcaeq.
277    * WCM OPERATIONs <-> WCD (work area)
278    TYPES: wctp1_wcafwa_type TYPE wcaf.
279    * WCM OPERATIONs <-> WAPI (work area)
280    TYPES: wctp1_wcaswa_type TYPE wcas.
281    * LOG FOR WCD ASSIGNMENTs (work area)
282    TYPES: wctp1_wcafqwa_type TYPE wcafq.
283    * LOG FOR WAPI ASSIGNMENTs (work area)
284    TYPES: wctp1_wcasqwa_type TYPE wcasq.
285    * SWITCHING DATA - MODE DEPENDENT (work area)
286    TYPES: wctp1_wcagwa_type TYPE wcag.
287    * OPERATIONAL STEPs (work area)
288    TYPES: wctp1_wcarwa_type TYPE wcar.
289    * APPROVAL TABLE (work area)
290    TYPES: wctp1_wcagnwa_type TYPE wcagn.
291    * APPROVAL SEGMENT (work area)
292    TYPES: wctp1_wcagnswa_type TYPE wcagns.
293    * WORK CLEARANCE DOCUMENT (HEADER) (work area)
294    TYPES: wctp1_wcahewa_type TYPE wcahe.
295    TYPES: wctp1_wcvhewa_type TYPE wcvhe.
296    * WORK CLEARANCE DOCUMENT (ITEMS) (work area)
297    TYPES: wctp1_wcaitwa_type  TYPE wcait.
298    TYPES: wctp1_wcvitxwa_type TYPE wcvitx.
299    * WCM OBJECT <-> WCM OBJECT (work area)
300    TYPES: wctp1_wcalawa_type TYPE wcala.
301    * LOG FOR ASSIGNMENTs (work area)
302    TYPES: wctp1_wcalqwa_type TYPE wcalq.
303    * USER <-> DEVICE SETTINGs (work area)
304    TYPES: wctp1_wcamawa_type TYPE wcama.
305    * USER,PLANNING PLANT <-> PLANNING PLANT SPECIFIC SETTINGs (work area)
306    TYPES: wctp1_wcambwa_type TYPE wcamb.
307    * LOG FOR OPERATIONAL LISTs - HEADER DATA (work area)
308    TYPES: wctp1_wcamcwa_type TYPE wcamc.
309    * USER,PLANNING PLANT <-> PLANNING PLANT SPECIFIC SETTINGs (work area)
310    TYPES: wctp1_wcamdwa_type TYPE wcamd.
311    * LOG FOR WORK PERMITS (work area)
312    TYPES: wctp1_wcamfwa_type TYPE wcamf.
313    * (TEMPORARY) LOG FOR OPERATIONAL LISTs - ITEMS (work area)
314    TYPES: wctp1_wcamewa_type TYPE wcame.
315    * LOG FOR OPERATIONAL LISTs - ITEMS (work area)
316    TYPES: wctp1_wcamiwa_type TYPE wcami.
317    * OBJECT LIST (work area)
318    TYPES: wctp1_wcaodwa_type  TYPE wcaod.
319    TYPES: wctp1_wcvodxwa_type TYPE wcvodx.
320    * PRINT LOG (work area)
321    TYPES: wctp1_wcaplwa_type TYPE wcapl.
322    * WORK APPROVAL (work area)
323    TYPES: wctp1_wcawwa_type TYPE wcaw.
324    TYPES: wctp1_wcvwwa_type TYPE wcvw.
325    * LINEUP (work area)
326    TYPES: wctp1_wcajwa_type TYPE wcaj.
327    * VERIFICATION LIST - HEADER DATA (work area)
328    TYPES: wctp1_wcakwa_type TYPE wcak.
329    * VERIFICATION LIST - ITEMs (work area)
330    TYPES: wctp1_wcaqwa_type TYPE wcaq.
331    * SWITCHING DATA (work area)
332    TYPES: wctp1_wccawa_type TYPE wcca.
333    * OPERATIONAL CONDITIONs (work area)
334    TYPES: wctp1_wccbwa_type  TYPE wccb.
335    TYPES: wctp1_wccbtwa_type TYPE wccbt.
336    * OPERATIONAL CATEGORY (work area)
337    TYPES: wctp1_wcccwa_type  TYPE wccc.
338    TYPES: wctp1_wccctwa_type TYPE wccct.
339    * OPERATIONAL GROUP (work area)
340    TYPES: wctp1_wccdwa_type  TYPE wccd.
341    TYPES: wctp1_wccdtwa_type TYPE wccdt.
342    * CONFLICT RULES (work area)
343    TYPES: wctp1_wccewa_type TYPE wcce.
344    * SPECIAL GROUPING OF TECHNICAL OBJECTs (work area)
345    TYPES: wctp1_wcchwa_type  TYPE wcch.
346    TYPES: wctp1_wcchtwa_type TYPE wccht.
347    * TAG <-> (OPERATIONAL GROUP,OPERATIONAL TYPE;TEST TAG) (work area)
348    TYPES: wctp1_wcciwa_type TYPE wcci.
349    * OPERATIONAL CLASS (work area)
350    TYPES: wctp1_wcckwa_type  TYPE wcck.
351    TYPES: wctp1_wccktwa_type TYPE wcckt.
352    * GENERIC PRINT TABLE (work area)
353    TYPES: wctp1_wcclwa_type  TYPE wccl.
354    TYPES: wctp1_wccltwa_type TYPE wcclt.
355    * USER SPECIFIC PRINT TABLE (work area)
356    TYPES: wctp1_wcclxwa_type TYPE wcclx.
357    * PM ORDER <-> WCM OBJECT (work area)
358    TYPES: wctp1_wccmwa_type TYPE wccm.
359    * VALUTION OF WAPIs (work area)
360    TYPES: wctp1_wccnwa_type TYPE wccn.
361    * WCM OBJECT <-> APPROVALs (work area)
362    TYPES: wctp1_wccpwa_type TYPE wccp.
363    * PERMIT GROUP (work area)
364    TYPES: wctp1_wccpnwa_type TYPE wccpn.
365    * GROUP (work area)
366    TYPES: wctp1_wccqwa_type  TYPE wccq.
367    TYPES: wctp1_wccqtwa_type TYPE wccqt.
368    * GENERAL CUSTOMIZING SETTINGs (work area)
369    TYPES: wctp1_wccrwa_type TYPE wccr.
370    * SELECTION FIELDs FOR DATA TRANSFER (work area)
371    TYPES: wctp1_wccswa_type  TYPE wccs.
372    TYPES: wctp1_wccstwa_type TYPE wccst.
373    * STATUS GROUPS (work area)
374    TYPES: wctp1_wcctawa_type TYPE wccta.
375    * APPROVAL STATUS GROUPs (work area)
376    TYPES: wctp1_wcctbwa_type TYPE wcctb.
377    * INTERFACE GROUPs (work area)
378    TYPES: wctp1_wcctcwa_type TYPE wcctc.
379    * BLOCKING TABLE - CHANGEs (work area)
380    TYPES: wctp1_wccwawa_type TYPE wccwa.
381    * BLOCKING TABLE - ASSIGNMENTs (work area)
382    TYPES: wctp1_wccwbwa_type TYPE wccwb.
383    * USE OF WAP (work area)
384    TYPES: wctp1_wccxwa_type TYPE wccx.
385    TYPES: wctp1_wccxtwa_type TYPE wccxt.
386    * USE OF WAPI (work area)
387    TYPES: wctp1_wccywa_type TYPE wccy.
388    TYPES: wctp1_wccytwa_type TYPE wccyt.
389    * USE OF WCD (work area)
390    TYPES: wctp1_wccuwa_type TYPE wccu.
391    TYPES: wctp1_wccutwa_type TYPE wccut.
392    * USE OF LINEUP (work area)
393    TYPES: wctp1_wccluwa_type TYPE wcclu.
394    TYPES: wctp1_wcclutwa_type TYPE wcclut.
395    * WCM-RELEVANT OPERATIONs (work area)
396    TYPES: wctp1_wccmrwa_type TYPE wccmr.
397    * OPERATIONAL STEPs (work area)
398    TYPES: wctp1_wccmuwa_type TYPE wccmu.
399    TYPES: wctp1_wccmswa_type TYPE wccms.
400    * WORK PERMITs (work area)
401    TYPES: wctp1_wcc1wa_type TYPE wcc1.
402    * WORK TYPES (work area)
403    TYPES: wctp1_wcc2wwa_type TYPE wcc2w.
404    TYPES:
405      BEGIN OF wctp1_wkwa_type,
406        iwerk     TYPE iwerk,
407        wkid      TYPE rollname,
408        scrtext_l TYPE scrtext_l,
409      END   OF wctp1_wkwa_type.
410    * NEEDs (work area)
411    TYPES: wctp1_wcc2nwa_type TYPE wcc2n.
412    TYPES:
413      BEGIN OF wctp1_ndwa_type,
414        iwerk     TYPE iwerk,
415        needid    TYPE rollname,
416        scrtext_l TYPE scrtext_l,
417      END   OF wctp1_ndwa_type.
418    * WAPI <-> WORK TYPEs AND NEEDs (work area)
419    TYPES: wctp1_wca2wa_type TYPE wca2.
420    * WCM TEMPLATEs <-> WCM TEMPLATEs (work area)
421    TYPES: wctp1_wcatwa_type TYPE wcat.
422    * LOG FOR LINKs (work area)
423    TYPES: wctp1_wcatqwa_type TYPE wcatq.
424    * TEXT PROCESSING
425    TYPES: wctp1_wcczwa_type TYPE wccz.
426    *WCM_PTW Objects
427    TYPES: wctp1_wpsafreq_type TYPE wrkpmtsftyrqmt,
428           wctp1_isshist_type TYPE wrkpmtisshist,
429           wctp1_safcertreq_type TYPE sftycertsftyrqmt.
430    * MULTI-OBJECT TEXT LINE BUFFER (work area)
431    TYPES: wctp1_tlineswa_type TYPE wcs_api_objnr_ltxt. "object long text (e.g. for WCD header or WCD item)
432    * MULTI-OBJECT MULTI TEXT LINE BUFFER (work area)
433    TYPES:
434      BEGIN OF wctp1_multi_tlineswa_type,
435        objnr  TYPE wctp1_objnr_type,     "object number (e.g. for WCD header)
436        txttab TYPE wctp1_tlinestab_type, "multi object long text table (e.g. for items of a given WCD)
437      END   OF wctp1_multi_tlineswa_type.
438    * MULTI-OBJECT TEXT FUNCTIONS (work area)
439    TYPES: wctp1_tlines_fcodewa_type TYPE wcs_api_objnr_tlines_func. "object text function (e.g. for WCD header or WCD item)
440    * MULTI-OBJECT MULTI TEXT FUNCTIONS (work area)
441    TYPES:
442      BEGIN OF wctp1_multi_tlines_fcdwa_type,
443        objnr  TYPE wctp1_objnr_type,     "object number (e.g. for WCD header)
444        txttab TYPE wct_api_objnr_tlines, "multi object text line table (e.g. for items of a given WCD)
445        fcode  TYPE wctpf_fcode_type,     "function code for all entries from multi object text line table
446      END   OF wctp1_multi_tlines_fcdwa_type.
447    * MULTI-OBJECT APPROVAL BUFFER - EXTERNALLY (work area)
448    TYPES:
449      BEGIN OF wctp1_permitwa_type,
450        objnr   TYPE wctp3_objnr_type,
451        lnktab  TYPE wctpc_permittab_type,
452        sgmttab TYPE wctp1_wcagnstab_type,
453      END   OF wctp1_permitwa_type.
454    * MULTI-OBJECT APPROVAL BUFFER - INTERNALLY (work area)
455    TYPES:
456      BEGIN OF wctp1_aprvlswa_type,
457        objnr  TYPE wctp3_objnr_type,
458        gntab  TYPE wctp1_gntab_type,
459        gnstab TYPE wctp1_gnstab_type,
460      END   OF wctp1_aprvlswa_type.
461    * APPROVAL FUNCTIONS (work area)
462    TYPES:
463      BEGIN OF wctp1_pmsogwa_type,
464        pmsog  TYPE pmsog,
465        issuer TYPE genvname,
466      END   OF wctp1_pmsogwa_type.
467    * MULTI-OBJECT APPROVAL FUNCTIONS (work area)
468    TYPES:
469      BEGIN OF wctp1_permit_fcodewa_type,
470        objnr    TYPE wctp3_objnr_type,
471        pmsogtab TYPE wctp1_pmsogtab_type,
472        fcode    TYPE wctpf_fcode_type,
473      END   OF wctp1_permit_fcodewa_type.
474    * MULTI-OBJECT CATALOG BUFFER (work area)
475    TYPES:
476      BEGIN OF wctp1_ctlgwa_type,
477        objnr  TYPE wctp3_objnr_type,
478        cattab TYPE wctcatalog,
479      END   OF wctp1_ctlgwa_type.
480    * MULTI-OBJECT CATALOG FUNCTIONS (work area)
481    TYPES:
482      BEGIN OF wctp1_ctlg_fcodewa_type,
483        objnr    TYPE wctp3_objnr_type,
484        wcacgtab TYPE wctp1_wcacgtab_type,
485        fcode    TYPE wctpf_fcode_type,
486      END   OF wctp1_ctlg_fcodewa_type.
487    * MULTI-OBJECT OBJECT LIST BUFFER (work area)
488    TYPES:
489      BEGIN OF wctp1_objlstwa_type,
490        objnr  TYPE wctp3_objnr_type,
491        objtab TYPE wctobjlst,
492      END   OF wctp1_objlstwa_type.
493    * MULTI-OBJECT OBJECT LIST FUNCTIONS (work area)
494    TYPES:
495      BEGIN OF wctp1_objlst_fcodewa_type,
496        objnr    TYPE wctp3_objnr_type,
497        wcaodtab TYPE wctp1_wcaodtab_type,
498        fcode    TYPE wctpf_fcode_type,
499      END   OF wctp1_objlst_fcodewa_type.
500    * MULTI-OBJECT ASSIGNMENT BUFFER (work area)
501    TYPES:
502      BEGIN OF wctp1_asgnmtwa_type,
503        objnr    TYPE wctp3_objnr_type,
504        wcalatab TYPE wctp1_wcalatab_type,
505      END   OF wctp1_asgnmtwa_type.
506    * MULTI-OBJECT ASSIGNMENT FUNCTIONS (work area)
507    TYPES:
508      BEGIN OF wctp1_asgnmt_fcodewa_type,
509        objnr      TYPE wctp3_objnr_type,
510        asgnobjtab TYPE wctp3_objtab_type,
511        fcode      TYPE wctpf_fcode_type,
512      END   OF wctp1_asgnmt_fcodewa_type.
513    * MULTI-OBJECT TEMPLATE ASSIGNMENT BUFFER (work area)
514    TYPES:
515      BEGIN OF wctp1_tmplasgnwa_type,
516        objnr   TYPE wctp3_objnr_type,
517        wcattab TYPE wctp1_wcattab_type,
518      END   OF wctp1_tmplasgnwa_type.
519    * MULTI-OBJECT TEMPLATE ASSIGNMENT FUNCTIONS (work area)
520    TYPES:
521      BEGIN OF wctp1_tmplasgn_fcodewa_type,
522        objnr      TYPE wctp3_objnr_type,
523        tmplobjtab TYPE wctp3_objtab_type,
524        fcode      TYPE wctpf_fcode_type,
525      END   OF wctp1_tmplasgn_fcodewa_type.
526    * MULTI-OBJECT WCD ITEM BUFFER (work area)
527    TYPES:
528      BEGIN OF wctp1_wcditmwa_type,
529        objnr    TYPE wctp3_objnr_type,
530        wcnr     TYPE wcewcnr,
531        wcaittab TYPE wctp1_wcaittab_type,
532      END   OF wctp1_wcditmwa_type.
533    * MULTI-OBJECT WCD ITEM FUNCTIONS (work area)
534    TYPES:
535      BEGIN OF wctp1_wcditm_fcodewa_type,
536        objnr    TYPE wctp3_objnr_type,
537        wcaittab TYPE wctp1_wcaittab_type,
538        fcode    TYPE wctpf_fcode_type,
539      END   OF wctp1_wcditm_fcodewa_type.
540    * PRINT (work area)
541    TYPES:
542      BEGIN OF wctp1_wcvlwa_type.
543        INCLUDE TYPE wccl AS wccl.
544    TYPES:
545        stxt TYPE wctp1_stxt_type,
546      END   OF wctp1_wcvlwa_type.
547    * WCM OBJECT (work area)
548    TYPES: wctp1_wccowa_type   TYPE wcco.
549    TYPES: wctp1_wccotwa_type  TYPE wccot.
550    TYPES: wctp1_wccogtwa_type TYPE wccogt.
551    TYPES:
552      BEGIN OF wctp1_wcvowa_type,
553        iwerk      TYPE wctp1_iwerk_type,
554        objart     TYPE wceobjart,
555        objtyp     TYPE wcetyp,
556        objtcode   TYPE sytcode,
557        objflg     TYPE wctp1_flg_type,
558        crobjflg   TYPE wcecrflg,
559        chobjflg   TYPE wcechflg,
560        asgnflg    TYPE wceasgnflg,
561        direction  TYPE wceway,
562        crtcode    TYPE wcecrtcode,
563        chtcode    TYPE wcechtcode,
564        dptcode    TYPE wcedptcode,
565        setcode    TYPE wcesetcode,
566        priotyp    TYPE artpr,
567        nr_object  TYPE nrobj,
568        int_range  TYPE numki,
569        ext_range  TYPE numke,
570        pargr      TYPE pargr,
571        stsma      TYPE j_stsma,
572        cattyp1    TYPE qkatart,
573        cattxt1    TYPE qswortpk,
574        catlst1    TYPE wcecatlst,
575        cattyp2    TYPE qkatart,
576        cattxt2    TYPE qswortpk,
577        catlst2    TYPE wcecatlst,
578        catprofile TYPE wcecatprofile,
579        bor_objtyp TYPE swo_objtyp,
580        popupflg   TYPE wcedialogflg,
581        wcmuse     TYPE wceusage,
582        refblstgrp TYPE wcerefblstgrp,
583        refbltlgrp TYPE wcerefbltlgrp,
584        genrefart  TYPE wcegenrefart,
585        genreftyp  TYPE wcegenreftyp,
586        stxt       TYPE wctp1_stxt_type,
587        ptxt       TYPE wctp1_ptxt_type,
588      END   OF wctp1_wcvowa_type.
589    * WCM OBJECT (MASTER) <-> WCM OBJECT (SLAVE)
590    TYPES: wctp1_wccorwa_type TYPE wccor.
591    * (POSSIBLE) SLAVES (work area)
592    TYPES:
593      BEGIN OF wctp1_slavewa_type,
594        button    TYPE wctpz_checkbox_type,   "checkbox
595        coltab    TYPE slis_t_specialcol_alv, "colors
596        objart    TYPE wctp1_objart_type,     "object type
597        objtyp    TYPE wctp1_objtyp_type,     "subobject type
598        reftcode  TYPE wcereftcode,           "transaction code for creating with template (:= MASTER)
599        chtcode   TYPE wcechtcode,            "transaction code for changing a SLAVE
600        dptcode   TYPE wcedptcode,            "transaction code for displaying a SLAVE
601        setcode   TYPE wcesetcode,            "transaction code for choosing a SLAVE
602        ext_range TYPE wceext_range,          "number range for external number assignment
603        m2sseflg  TYPE wceseflg,              "SLAVE can be chosen by the MASTER {space,X := can be chosen}
604        m2scrflg  TYPE wcecrflg,              "SLAVE can be created by the MASTER {space,X := can be created}
605        m2schflg  TYPE wcechflg,              "SLAVE can be changed by the MASTER {space,X := can be changed}
606        m2slnkcnt TYPE wctp1_cnt_type,        "maximum number of assignments (MASTER -> SLAVEs)
607        m2stotcnt TYPE wctp1_cnt_type,        "current number of assignments (MASTER -> SLAVEs)
608        s2mlnkcnt TYPE wctp1_cnt_type.        "maximum number of assignments (SLAVE -> MASTERs)
609        INCLUDE   TYPE wcsalv07 AS wcsalv07.
610    TYPES:
611      END   OF wctp1_slavewa_type.
612    * WCM OBJECT KEY (work area)
613    TYPES:
614      BEGIN OF wctp1_objkeywa_type,
615        objkey TYPE wctp1_objkey_type,
616      END   OF wctp1_objkeywa_type.
617    * WCM OBJECT COUNTER (work area)
618    TYPES:
619      BEGIN OF wctp1_objcntwa_type,
620        objkey TYPE wctp1_objkey_type,
621        objnr  TYPE wctp1_objnr_type,
622        cnt    TYPE wctpc_cnt_type,
623      END   OF wctp1_objcntwa_type.
624    * VIEW PROFILE (work area)
625    TYPES: wctp1_wcc0wa_type    TYPE wcc0.
626    TYPES: wctp1_wcc0swa_type   TYPE wcc0s.
627    TYPES: wctp1_wcc0stwa_type  TYPE wcc0st.
628    TYPES: wctp1_wcc0suwa_type  TYPE wcc0su.
629    TYPES: wctp1_wcc0sutwa_type TYPE wcc0sut.
630    TYPES: wctp1_wcc0srwa_type  TYPE wcc0sr.
631    TYPES: wctp1_wcc0awa_type   TYPE wcc0a.
632    TYPES: wctp1_wcc0bwa_type   TYPE wcc0b.
633    TYPES: wctp1_wcc0btwa_type  TYPE wcc0bt.
634    TYPES: wctp1_wcc0cwa_type   TYPE wcc0c.
635    * GROUP DEPENDENT FIELD COUNTER (work area)
636    TYPES:
637      BEGIN OF wctp1_fldgrpcntwa_type,
638        fldgrp   TYPE wcedynfldgrp,
639        is_delta TYPE wctp1_boolean_type,
640        fldcnt   TYPE wctp1_cnt_type,
641      END   OF wctp1_fldgrpcntwa_type.
642    * WCD ITEMs (work area)
643    TYPES:
644      BEGIN OF wctp1_wcitmwa_type,
645        button     TYPE wctp1_flg_type,
646        icon1      TYPE wceicon,
647        actproc    TYPE wceactproc,
648        acttyp     TYPE wceacttyp,
649        updltxtflg TYPE wctp1_flg_type,
650        upddocflg  TYPE wctp1_flg_type.
651        INCLUDE    TYPE wcait AS wcait.
652    TYPES:
653      END   OF wctp1_wcitmwa_type.
654    * BLOCKING TABLE BASED ON ...
655    * - STATUS - ASSIGNMENTs (work area)
656    TYPES:
657      BEGIN OF wctp1_lnkblstwa_type,
658        objart1 TYPE wceobjart,
659        objtyp1 TYPE wcetyp,
660        objart2 TYPE wceobjart,
661        objtyp2 TYPE wcetyp,
662        status2 TYPE j_istat,
663      END  OF wctp1_lnkblstwa_type.
664    * - APPROVAL STATUS - ASSIGNMENTs (work area)
665    TYPES:
666      BEGIN OF wctp1_lnkbltlwa_type,
667        objart1 TYPE wceobjart,
668        objtyp1 TYPE wcetyp,
669        tlcnt1  TYPE wcetl,
670        objart2 TYPE wceobjart,
671        objtyp2 TYPE wcetyp,
672        tlcnt2  TYPE wcetl,
673      END   OF wctp1_lnkbltlwa_type.
674    * - STATUS - CHANGES (work area)
675    TYPES:
676      BEGIN OF wctp1_updblstwa_type,
677        objart    TYPE wceobjart,
678        objtyp    TYPE wcetyp,
679        interface TYPE wceif,
680        status    TYPE j_istat,
681      END   OF wctp1_updblstwa_type.
682    * - APPROVAL STATUS - CHANGES (work area)
683    TYPES:
684      BEGIN OF wctp1_updbltlwa_type,
685        objart    TYPE wceobjart,
686        objtyp    TYPE wcetyp,
687        interface TYPE wceif,
688        tlcnt     TYPE wcetl,
689      END   OF wctp1_updbltlwa_type.
690    * - STATUS - CREATE BY REFERENCE (work area)
691    TYPES:
692      BEGIN OF wctp1_refblstwa_type,
693        objart TYPE wceobjart,
694        objtyp TYPE wcetyp,
695        status TYPE j_istat,
696      END   OF wctp1_refblstwa_type.
697    * - APPROVAL STATUS - CREATE BY REFERENCE (work area)
698    TYPES:
699      BEGIN OF wctp1_refbltlwa_type,
700        objart TYPE wceobjart,
701        objtyp TYPE wcetyp,
702        tlcnt  TYPE wcetl,
703      END   OF wctp1_refbltlwa_type.
704    * - STATUS - CREATE WCD ASSIGNMENT TO OPERATION (work area)
705    TYPES:
706      BEGIN OF wctp1_wcdlnkblstwa_type,
707        status TYPE j_istat,
708      END   OF wctp1_wcdlnkblstwa_type.
709    * - STATUS - REMOVE WCD ASSIGNMENT TO OPERATION (work area)
710    TYPES:
711      BEGIN OF wctp1_wcdlnkrejblstwa_type,
712        status TYPE j_istat,
713      END   OF wctp1_wcdlnkrejblstwa_type.
714    * REJECTION TABLE BASED ON STATUS ...
715    * - APPROVALS (work area)
716    TYPES:
717      BEGIN OF wctp1_rejaprvstwa_type,
718        objart1 TYPE wceobjart,
719        objtyp1 TYPE wcetyp,
720        pmsog   TYPE pmsog,
721        status  TYPE j_istat,
722      END  OF wctp1_rejaprvstwa_type.
723    * - ASSIGNMENTs (work area)
724    TYPES:
725      BEGIN OF wctp1_rejlnkstwa_type,
726        objart1 TYPE wceobjart,
727        objtyp1 TYPE wcetyp,
728        objart2 TYPE wceobjart,
729        objtyp2 TYPE wcetyp,
730        status1 TYPE j_istat,
731      END  OF wctp1_rejlnkstwa_type.
732    * APPROVAL STATUS (work area)
733    TYPES:
734      BEGIN OF wctp1_aprvwa_type,
735        objnr   TYPE wctp1_objnr_type,
736        planned TYPE wctp1_cnt_type,
737        actual  TYPE wctp1_cnt_type,
738        tlcnt   TYPE wctp1_tlcnt_type,
739        dyntxt  TYPE smp_dyntxt,
740        icon    TYPE wceaprvicon,
741      END   OF wctp1_aprvwa_type.
742    * LIFECYCLE PHASE (work area)
743    TYPES:
744      BEGIN OF wctp1_lcphasewa_type,
745        objnr  TYPE wctp1_objnr_type,
746        objkey TYPE wctp1_objkey_type,
747        phase  TYPE wcelcphase,
748        dyntxt TYPE smp_dyntxt,
749        icon   TYPE wcelcphaseicon,
750      END   OF wctp1_lcphasewa_type.
751    * LINKED (work area)
752    TYPES:
753      BEGIN OF wctp1_lnkwa_type,
754        objnr      TYPE wctp1_objnr_type,
755        objart     TYPE wctp1_objart_type,
756        objtyp     TYPE wctp1_objtyp_type,
757        slaveart   TYPE wctp1_objart_type,
758        slavetyp   TYPE wctp1_objtyp_type,
759        m2scustcnt TYPE wctp1_cnt_type,
760        m2sapplcnt TYPE wctp1_cnt_type,
761        m2sapplflg TYPE wctp1_flg_type,
762        masterart  TYPE wctp1_objart_type,
763        mastertyp  TYPE wctp1_objtyp_type,
764        s2mcustcnt TYPE wctp1_cnt_type,
765        s2mapplcnt TYPE wctp1_cnt_type,
766        s2mapplflg TYPE wctp1_flg_type,
767      END   OF wctp1_lnkwa_type.
768    * ORDER (work area)
769    TYPES: wctp1_orderwa_type TYPE rihaufk_list.
770    * MAINTENANCE ORDER HEADER (work area)
771    TYPES: wctp1_afihwa_type TYPE afih.
772    * OPERATION WITHIN AN ORDER (work area)
773    TYPES: wctp1_afvcwa_type TYPE afvc.
774    * DB STRUCTURE OF THE USER FIELDS OF AN OPERATION (work area)
775    TYPES: wctp1_afvuwa_type TYPE afvu.
776    * ORDER HEADER DATA PP ORDERS (work area)
777    TYPES: wctp1_afkowa_type TYPE afko.
778    * OPERATION INCL. UPDATE INDICATOR (work area)
779    TYPES: wctp1_afvgdgetwa_type TYPE afvgdget.
780    * PARTNER (work area)
781    TYPES: wctp1_ihpawa_type TYPE ihpa.
782    * REFERENCE STRUCTURE FOR PARTNER (work area)
783    TYPES: wctp1_ihpavbwa_type TYPE ihpavb.
784    * DOCUMENTS (work area)
785    TYPES: wctp1_dradwa_type TYPE drad.
786    * WORK CENTER (work area)
787    TYPES: wctp1_crhdwa_type TYPE crhd.
788    * FUNCTIONAL LOCATION (VIEW) (work area)
789    TYPES: wctp1_iflowa_type TYPE iflo.
790    * EQUIPMENT (VIEW) (work area)
791    TYPES: wctp1_v_equiwa_type TYPE v_equi.
792    * SCREEN (work area)
793    TYPES: wctp1_dynpreadwa_type TYPE dynpread.
794    * INTERFACE STRUCTURE SEARCH HELP <-> HELP SYSTEM (work area)
795    TYPES: wctp1_ddshretvalwa_type TYPE ddshretval.
796    TYPES: wctp1_dselcwa_type      TYPE dselc.
797    * PAGING
798    * - INDEX TABLE (work area)
799    TYPES: wctp1_indexwa_type TYPE inxx.
800    * - SCROLL TABLE
801    TYPES: wctp1_scrollwa_type TYPE inxx.
802    * FIELD NAME (work area)
803    TYPES:
804      BEGIN OF wctp1_fieldwa_type,
805        name TYPE dynfnam,
806      END   OF wctp1_fieldwa_type.
807    TYPES: wctp1_fieldtab_type TYPE STANDARD TABLE OF wctp1_fieldwa_type WITH DEFAULT KEY.
808    * ALIAS (work area)
809    TYPES:
810      BEGIN OF wctp1_aliaswa_type,
811        before TYPE wctp1_objnr_type,
812        after  TYPE wctp1_objnr_type,
813      END   OF wctp1_aliaswa_type.
814    * TABLE FOR COLORS (work area)
815    TYPES:
816      BEGIN OF wctp1_colwa_type,
817        objkey1   TYPE wctp1_objkey_type, "1. object key
818        subkey1   TYPE wctp1_subkey_type, "1. subkey
819        objkey2   TYPE wctp1_objkey_type, "2. object key
820        subkey2   TYPE wctp1_subkey_type, "2. subkey
821        field     TYPE slis_fieldname,    "field name
822        color     TYPE wctp1_cnt_type,    "background color for output
823        intensity TYPE wctp1_cnt_type,    "intensity of the background color
824        inverse   TYPE wctp1_cnt_type,    "sets the background color or the foreground color
825      END   OF wctp1_colwa_type.
826    * LIST COMPARISON (work area)
827    * - WORK TABLE
828    TYPES:
829      BEGIN OF wctp1_cmpwa_type,
830        objnr      TYPE wctp1_aliaswa_type,
831        valid      TYPE wctp1_boolean_type,
832        task       TYPE wctp1_task_type,
833        comparison TYPE wctp1_option_type,  "only relevant for task == UPDATE
834        BEGIN OF datawa,
835          before TYPE cmp_wcditm_datawa,
836          after  TYPE cmp_wcditm_datawa,
837        END OF datawa,
838        msgtab     TYPE bal_t_msg,
839      END   OF wctp1_cmpwa_type.
840    * - LOG TABLE
841    TYPES:
842      BEGIN OF wctp1_cmplogwa_type,
843        objnr      TYPE wctp1_objnr_type,
844        valid      TYPE wctp1_boolean_type,
845        task       TYPE wctp1_task_type,
846        comparison TYPE wctp1_option_type,
847        icon       TYPE wcecompicon,
848        fieldtab   TYPE wctp1_fieldtab_type,
849      END   OF wctp1_cmplogwa_type.
850    * ASSIGNMENT CHECK LEVEL RESULT
851    TYPES:
852      BEGIN OF wctp1_assgn_resultwa_type,
853        general_display        TYPE wctp1_flg_type,
854        general_maintenance    TYPE wctp1_flg_type,
855        general_deletion       TYPE wctp1_flg_type,
856        individual_maintenance TYPE wctp1_flg_type,
857        individual_deletion    TYPE wctp1_flg_type,
858        correct_maintenance    TYPE wctp1_flg_type,
859        info_steps             TYPE wctp1_flg_type,
860        info_mandatory         TYPE wctp1_flg_type,
861        info_injective         TYPE wctp1_flg_type,
862        error_maintenance      TYPE sysubrc,
863        error_deletion         TYPE sysubrc,
864        error_info_status      TYPE wctp3_status_type,
865        error_info_operation   TYPE co_aplzl,
866      END   OF wctp1_assgn_resultwa_type.
867    * PLANNING PLANT (work area)
868    TYPES:
869      BEGIN OF wctp1_iwerkwa_type,
870        iwerk TYPE wctp1_iwerk_type, "planning plant
871      END   OF wctp1_iwerkwa_type.
872    * PM PERMIT ATTRIBUTES (work area)
873    TYPES:
874      BEGIN OF wctp1_permattrwa_type,
875        pmsog    TYPE pmsog, "permit key
876        gntyp    TYPE gntyp, "permit category
877        gntyptxt TYPE gytxt, "permit category text
878        gntxt    TYPE gntxt, "permit text
879        kzltx    TYPE kzltx, "long text exists
880      END   OF wctp1_permattrwa_type.
881    * APPROVAL TABLE with processing data (work area)
882    TYPES:
883      BEGIN OF wctp1_gnwa_type.
884        INCLUDE     TYPE wcagn AS wcagn. "master data of permit
885    TYPES:
886        button      TYPE wctp1_flg_type, "check box
887        delflg      TYPE wctp1_flg_type, "permit is deleted
888        insflg      TYPE wctp1_flg_type, "permit is created
889        updltxtflg  TYPE wctp1_flg_type, "long text has changed
890        gntyp       TYPE gntyp,          "permit category
891        gntxt       TYPE gntxt,          "permit text
892        k_genehm    TYPE k_genehm,       "permit is issued
893        hilvl       TYPE wcehilvl,       "hierarchy level
894        procflg     TYPE wceprocflg,     "approval process accross WCM objects
895        direction   TYPE wceway,         "direction according to architecture
896        copyflg     TYPE wceflgcopy,     "copy approval automatically
897        mandflg     TYPE wceflgmand,     "approval is obligatory
898        deacflg     TYPE wceflgdeac,     "revoke approval automatically
899        tlflg       TYPE wceflgtl,       "display approval status as traffic light
900        status      TYPE wcestat,        "controlled system status for Issuing approvals
901        user_status TYPE wceblusrst,     "controlled user status for issuing approval
902        rejstgrp    TYPE wcerejstgrp,    "status group for revoking approvals
903        asgnflg     TYPE wceflgasgn,     "assignment required
904        wcmuse      TYPE wceusage,       "usage
905        valflg      TYPE wceblvalflg,    "validity required
906        autoflg     TYPE wceflgauto,     "issue approvals automatically
907        agent       TYPE swp_agent,      "WF agent
908      END   OF wctp1_gnwa_type.
909    * APPROVAL SEGMENT with processing data (work area)
910    TYPES:
911      BEGIN OF wctp1_gnswa_type.
912        INCLUDE TYPE wcagns AS wcagns.   "master data of permit segment
913    TYPES:
914        updflg TYPE wctp1_flg_type,     "update indicator
915        insflg TYPE wctp1_flg_type,     "indicator for new entries
916      END   OF wctp1_gnswa_type.
917    * CONTROL TABLE (work area)
918    TYPES:
919      BEGIN OF wctp1_ctrlwa_type,
920        aktyp     TYPE wctp1_aktyp_type,     "activity category
921        iwerk     TYPE wctp1_iwerk_type,     "planning plant
922        objart    TYPE wctp1_objart_type,    "object type
923        objtyp    TYPE wctp1_objtyp_type,    "subobject type
924        objnr     TYPE wctp1_objnr_type,     "object number
925        objkey    TYPE wctp1_objkey_type,    "object key
926        text      TYPE text40,               "short text
927        direction TYPE wctp1_direction_type, "direction
928        stxt      TYPE wctp1_stxt_type,      "descriptive short text in singular
929        ptxt      TYPE wctp1_ptxt_type,      "descriptive short text in plural
930        sysst     TYPE ilom_sttxs,           "display lines for system status
931        usrst     TYPE ilom_sttxu,           "display lines for user status
932        time      TYPE wcecrtime,            "time at which entry was created
933      END OF wctp1_ctrlwa_type.
934    * ASSIGNMENT TABLE with processing data (work area)
935    TYPES:
936      BEGIN OF wctp1_asgnwa_type,
937        fatherobj TYPE wctp1_objnr_type,     "1st object number
938        fatherart TYPE wcefatherart,         "1st object type
939        fathertyp TYPE wcefathertyp,         "1st subobject type
940        childobj  TYPE wctp1_objnr_type,     "2nd object number
941        childart  TYPE wcechildart,          "2nd object type
942        childtyp  TYPE wcechildtyp,          "2nd subobject type
943        task      TYPE wctp1_task_type,      "database action := {insert,delete}
944        direction TYPE wctp1_direction_type, "direction
945        lckgobj   TYPE wctp1_lckg_obj_type,  "lock object {space := nothing to do,(DEQ)ueue,(ENQ)ueue}
946      END   OF wctp1_asgnwa_type.
947    * MESSAGE LOG (work area)
948    TYPES:
949      BEGIN OF wctp1_msglogwa_type,
950        objkey TYPE wctp1_objkey_type, "object key
951        objnr  TYPE wctp1_objnr_type,  "object number
952        errflg TYPE wctp1_flg_type,    "error exists
953        msgtab TYPE bal_t_msg,         "table with messages
954      END   OF wctp1_msglogwa_type.
955    * CHANGE HISTORY (work area)
956    TYPES:
957      BEGIN OF wctp1_historywa_type,
958        masterobj TYPE wctp1_objnr_type,     "master object number
959        masterart TYPE wctp1_objart_type,    "master object type
960        mastertyp TYPE wctp1_objtyp_type,    "master subobject type
961        masterkey TYPE wctp1_objkey_type,    "master object key
962        objtxt    TYPE wctp1_stxt_type,      "text of dependent object
963        acttxt    TYPE char30,               "text of executed action
964        objkey_1  TYPE char40,               "1st key of dependent object
965        objkey_2  TYPE char40,               "2nd key of dependent object
966        objkey_3  TYPE char40,               "3rd key of dependent object
967        objkey_4  TYPE char40,               "4th key of dependent object
968        date      TYPE sydatum,              "date when action was performed
969        time      TYPE syuzeit,              "time when action was performed
970        user      TYPE syuname,              "user who performed the action
971        objintf   TYPE wctpc_interface_type, "internal interface type of dependent object
972        intcount  TYPE wcecnt,               "internal counter per interface
973        acttyp    TYPE char3,                "internal type of executed action
974        objid_1   TYPE char22,               "1st internal identifier of dependent object
975        objid_2   TYPE char22,               "2nd internal identifier of dependent object
976      END   OF wctp1_historywa_type.
977
978    * tables types *********************************************************
979    * APPLICATIONs
980    TYPES: wctp1_wcaaptab_type TYPE STANDARD TABLE OF wctp1_wcaapwa_type WITH DEFAULT KEY.
981    TYPES: wctp1_wcvaptab_type TYPE STANDARD TABLE OF wctp1_wcvapwa_type WITH DEFAULT KEY.
982    * VALUATION
983    TYPES: wctp1_wcabtab_type TYPE STANDARD TABLE OF wctp1_wcabwa_type WITH DEFAULT KEY.
984    * LOG FOR VALUATION
985    TYPES: wctp1_wcabqtab_type TYPE STANDARD TABLE OF wctp1_wcabqwa_type WITH DEFAULT KEY.
986    * OPERATIONAL CLASSEs <-> TECHNICAL OBJECTs
987    TYPES: wctp1_wcacdtab_type TYPE STANDARD TABLE OF wctp1_wcacdwa_type WITH DEFAULT KEY.
988    * OPERATIONAL CONDITIONs <-> OPERATIONAL CLASSEs
989    TYPES: wctp1_wcacetab_type TYPE STANDARD TABLE OF wctp1_wcacewa_type WITH DEFAULT KEY.
990    * WCM OBJECT <-> CATALOGs
991    TYPES: wctp1_wcacgtab_type TYPE STANDARD TABLE OF wctp1_wcacgwa_type WITH DEFAULT KEY.
992    * LOG FOR CATALOGs
993    TYPES: wctp1_wcacgqtab_type TYPE STANDARD TABLE OF wctp1_wcacgqwa_type WITH DEFAULT KEY.
994    * (TEMPORARY) TIME FRAME LOG
995    TYPES: wctp1_wcachtab_type TYPE STANDARD TABLE OF wctp1_wcachwa_type WITH DEFAULT KEY.
996    * (TEMPORARY) SWITCHING LOG
997    TYPES: wctp1_wccitab_type TYPE STANDARD TABLE OF wctp1_wcciwa_type WITH DEFAULT KEY.
998    * OPERATIONAL CONDITION/TYPE
999    TYPES: wctp1_wcacmtab_type TYPE STANDARD TABLE OF wctp1_wcacmwa_type WITH DEFAULT KEY.
1000   * (TEMPORARY) LOG FOR OPERATIONAL TAGs
1001   TYPES: wctp1_wcacntab_type TYPE STANDARD TABLE OF wctp1_wcacnwa_type WITH DEFAULT KEY.
1002   * LOG FOR OPERATIONAL TAGs
1003   TYPES: wctp1_wcacnqtab_type TYPE STANDARD TABLE OF wctp1_wcacnqwa_type WITH DEFAULT KEY.
1004   * (TEMPORARY) LOG FOR REFERENCE OBJECT
1005   TYPES: wctp1_wcacotab_type TYPE STANDARD TABLE OF wctp1_wcacowa_type WITH DEFAULT KEY.
1006   * SWITCHING LOG
1007   TYPES: wctp1_wcacqtab_type TYPE STANDARD TABLE OF wctp1_wcacqwa_type WITH DEFAULT KEY.
1008   * (TEMPORARY) LOG FOR PROHIBITED AREA
1009   TYPES: wctp1_wcacstab_type TYPE STANDARD TABLE OF wctp1_wcacswa_type WITH DEFAULT KEY.
1010   * APPROVAL GROUPs
1011   TYPES: wctp1_wcadtab_type TYPE STANDARD TABLE OF wctp1_wcadwa_type WITH DEFAULT KEY.
1012   * LOG FOR APPROVAL GROUPs
1013   TYPES: wctp1_wcadqtab_type TYPE STANDARD TABLE OF wctp1_wcadqwa_type WITH DEFAULT KEY.
1014   * WCM OPERATIONs <-> APPROVAL GROUPs
1015   TYPES: wctp1_wcaetab_type TYPE STANDARD TABLE OF wctp1_wcaewa_type WITH DEFAULT KEY.
1016   * LOG FOR APPROVAL GROUPs ASSIGNMENTS
1017   TYPES: wctp1_wcaeqtab_type TYPE STANDARD TABLE OF wctp1_wcaeqwa_type WITH DEFAULT KEY.
1018   * WCM OPERATIONs <-> WCD
1019   TYPES: wctp1_wcaftab_type TYPE STANDARD TABLE OF wctp1_wcafwa_type WITH DEFAULT KEY.
1020   * WCM OPERATIONs <-> WAPI
1021   TYPES: wctp1_wcastab_type TYPE STANDARD TABLE OF wctp1_wcaswa_type WITH DEFAULT KEY.
1022   * LOG FOR WCD ASSIGNMENTs
1023   TYPES: wctp1_wcafqtab_type TYPE STANDARD TABLE OF wctp1_wcafqwa_type WITH DEFAULT KEY.
1024   * LOG FOR WAPI ASSIGNMENTs
1025   TYPES: wctp1_wcasqtab_type TYPE STANDARD TABLE OF wctp1_wcasqwa_type WITH DEFAULT KEY.
1026   * SWITCHING DATA - MODE DEPENDENT
1027   TYPES: wctp1_wcagtab_type TYPE STANDARD TABLE OF wctp1_wcagwa_type WITH DEFAULT KEY.
1028   * OPERATIONAL STEPs
1029   TYPES: wctp1_wcartab_type TYPE STANDARD TABLE OF wctp1_wcarwa_type WITH DEFAULT KEY.
1030   * APPROVAL TABLE
1031   TYPES: wctp1_wcagntab_type TYPE STANDARD TABLE OF wctp1_wcagnwa_type WITH DEFAULT KEY.
1032   * APPROVAL SEGMENT
1033   TYPES: wctp1_wcagnstab_type TYPE STANDARD TABLE OF wctp1_wcagnswa_type WITH DEFAULT KEY.
1034   * WORK CLEARANCE DOCUMENT (HEADER)
1035   TYPES: wctp1_wcahetab_type TYPE STANDARD TABLE OF wctp1_wcahewa_type WITH DEFAULT KEY.
1036   TYPES: wctp1_wcvhetab_type TYPE STANDARD TABLE OF wctp1_wcvhewa_type WITH DEFAULT KEY.
1037   * WORK CLEARANCE DOCUMENT (ITEMs)
1038   TYPES: wctp1_wcaittab_type TYPE STANDARD TABLE OF wctp1_wcaitwa_type WITH DEFAULT KEY.
1039   TYPES: wctp1_wcvitxtab_type TYPE STANDARD TABLE OF wctp1_wcvitxwa_type WITH DEFAULT KEY.
1040   * WCM OBJECT <-> WCM OBJECT
1041   TYPES: wctp1_wcalatab_type TYPE STANDARD TABLE OF wctp1_wcalawa_type WITH DEFAULT KEY.
1042   * LOG FOR ASSIGNMENTs
1043   TYPES: wctp1_wcalqtab_type TYPE STANDARD TABLE OF wctp1_wcalqwa_type WITH DEFAULT KEY.
1044   * USER <-> DEVICE SETTINGs
1045   TYPES: wctp1_wcamatab_type TYPE STANDARD TABLE OF wctp1_wcamawa_type WITH DEFAULT KEY.
1046   * USER,PLANNING PLANT <-> PLANNING PLANT SPECIFIC USER SETTINGs
1047   TYPES: wctp1_wcambtab_type TYPE STANDARD TABLE OF wctp1_wcambwa_type WITH DEFAULT KEY.
1048   * LOG FOR OPERATIONAL LISTs - HEADER DATA
1049   TYPES: wctp1_wcamctab_type TYPE STANDARD TABLE OF wctp1_wcamcwa_type WITH DEFAULT KEY.
1050   * USER,PLANNING PLANT <-> PLANNING PLANT SPECIFIC USER SETTINGs
1051   TYPES: wctp1_wcamdtab_type TYPE STANDARD TABLE OF wctp1_wcamdwa_type WITH DEFAULT KEY.
1052   * LOG FOR WORK PERMITS
1053   TYPES: wctp1_wcamftab_type TYPE STANDARD TABLE OF wctp1_wcamfwa_type WITH DEFAULT KEY.
1054   * (TEMPORARY) LOG FOR OPERATIONAL LISTs - ITEMs
1055   TYPES: wctp1_wcametab_type TYPE STANDARD TABLE OF wctp1_wcamewa_type WITH DEFAULT KEY.
1056   * LOG FOR OPERATIONAL LISTs - ITEMs
1057   TYPES: wctp1_wcamitab_type TYPE STANDARD TABLE OF wctp1_wcamiwa_type WITH DEFAULT KEY.
1058   * OBJECT LIST
1059   TYPES: wctp1_wcaodtab_type  TYPE STANDARD TABLE OF wctp1_wcaodwa_type WITH DEFAULT KEY.
1060   TYPES: wctp1_wcvodxtab_type TYPE STANDARD TABLE OF wctp1_wcvodxwa_type WITH DEFAULT KEY.
1061   * PRINT LOG
1062   TYPES: wctp1_wcapltab_type TYPE STANDARD TABLE OF wctp1_wcaplwa_type WITH DEFAULT KEY.
1063   * WORK APPROVAL
1064   TYPES: wctp1_wcawtab_type TYPE STANDARD TABLE OF wctp1_wcawwa_type WITH DEFAULT KEY.
1065   TYPES: wctp1_wcvwtab_type TYPE STANDARD TABLE OF wctp1_wcvwwa_type WITH DEFAULT KEY.
1066   * LINEUP
1067   TYPES: wctp1_wcajtab_type TYPE STANDARD TABLE OF wctp1_wcajwa_type WITH DEFAULT KEY.
1068   * VERIFICATION LIST - HEADER DATA
1069   TYPES: wctp1_wcaktab_type TYPE STANDARD TABLE OF wctp1_wcakwa_type WITH DEFAULT KEY.
1070   * VERIFICATION LIST - ITEMS
1071   TYPES: wctp1_wcaqtab_type TYPE STANDARD TABLE OF wctp1_wcaqwa_type WITH DEFAULT KEY.
1072   * SWITCHING DATA
1073   TYPES: wctp1_wccatab_type TYPE STANDARD TABLE OF wctp1_wccawa_type WITH DEFAULT KEY.
1074   * OPERATIONAL CONDITIONs
1075   TYPES: wctp1_wccbtab_type  TYPE STANDARD TABLE OF wctp1_wccbwa_type WITH DEFAULT KEY.
1076   TYPES: wctp1_wccbttab_type TYPE STANDARD TABLE OF wctp1_wccbtwa_type WITH DEFAULT KEY.
1077   * OPERATIONAL TYPEs
1078   TYPES: wctp1_wccctab_type  TYPE STANDARD TABLE OF wctp1_wcccwa_type WITH DEFAULT KEY.
1079   TYPES: wctp1_wcccttab_type TYPE STANDARD TABLE OF wctp1_wccctwa_type WITH DEFAULT KEY.
1080   * OPERATIONAL GROUPs
1081   TYPES: wctp1_wccdtab_type  TYPE STANDARD TABLE OF wctp1_wccdwa_type WITH DEFAULT KEY.
1082   TYPES: wctp1_wccdttab_type TYPE STANDARD TABLE OF wctp1_wccdtwa_type WITH DEFAULT KEY.
1083   * CONFLICT RULEs
1084   TYPES: wctp1_wccetab_type TYPE STANDARD TABLE OF wctp1_wccewa_type WITH DEFAULT KEY.
1085   * SPECIAL GROUPING OF TECHNICAL OBJECTs
1086   TYPES: wctp1_wcchtab_type  TYPE STANDARD TABLE OF wctp1_wcchwa_type WITH DEFAULT KEY.
1087   TYPES: wctp1_wcchttab_type TYPE STANDARD TABLE OF wctp1_wcchtwa_type WITH DEFAULT KEY.
1088   * TAG <-> (OPERATIONAL GROUP,OPERATIONAL TYPE;TEST TAG)
1089   TYPES: wctp1_wcacitab_type TYPE STANDARD TABLE OF wctp1_wcaciwa_type WITH DEFAULT KEY.
1090   * OPERATIONAL CLASS
1091   TYPES: wctp1_wccktab_type  TYPE STANDARD TABLE OF wctp1_wcckwa_type WITH DEFAULT KEY.
1092   TYPES: wctp1_wcckttab_type TYPE STANDARD TABLE OF wctp1_wccktwa_type WITH DEFAULT KEY.
1093   * GENERIC PRINT TABLE
1094   TYPES: wctp1_wccltab_type  TYPE STANDARD TABLE OF wctp1_wcclwa_type WITH DEFAULT KEY.
1095   TYPES: wctp1_wcclttab_type TYPE STANDARD TABLE OF wctp1_wccltwa_type WITH DEFAULT KEY.
1096   * USER SPECIFIC PRINT TABLE
1097   TYPES: wctp1_wcclxtab_type TYPE STANDARD TABLE OF wctp1_wcclxwa_type WITH DEFAULT KEY.
1098   * PM ORDER <-> WCM OBJECT
1099   TYPES: wctp1_wccmtab_type TYPE STANDARD TABLE OF wctp1_wccmwa_type WITH DEFAULT KEY.
1100   * VALUTION OF WAPIs
1101   TYPES: wctp1_wccntab_type TYPE STANDARD TABLE OF wctp1_wccnwa_type WITH DEFAULT KEY.
1102   * WCM OBJECT <-> APPROVALs
1103   TYPES: wctp1_wccptab_type TYPE STANDARD TABLE OF wctp1_wccpwa_type WITH DEFAULT KEY.
1104   * PERMIT GROUP
1105   TYPES: wctp1_wccpntab_type TYPE STANDARD TABLE OF wctp1_wccpnwa_type WITH DEFAULT KEY.
1106   * GROUP
1107   TYPES: wctp1_wccqtab_type  TYPE STANDARD TABLE OF wctp1_wccqwa_type WITH DEFAULT KEY.
1108   TYPES: wctp1_wccqttab_type TYPE STANDARD TABLE OF wctp1_wccqtwa_type WITH DEFAULT KEY.
1109   * GENERAL CUSTOMIZING SETTINGs
1110   TYPES: wctp1_wccrtab_type TYPE STANDARD TABLE OF wctp1_wccrwa_type WITH DEFAULT KEY.
1111   * SELECTION FIELDs FOR DATA TRANSFER
1112   TYPES: wctp1_wccstab_type  TYPE STANDARD TABLE OF wctp1_wccswa_type WITH DEFAULT KEY.
1113   TYPES: wctp1_wccsttab_type TYPE STANDARD TABLE OF wctp1_wccstwa_type WITH DEFAULT KEY.
1114   * STATUS GROUPs
1115   TYPES: wctp1_wcctatab_type TYPE STANDARD TABLE OF wctp1_wcctawa_type WITH DEFAULT KEY.
1116   * APPROVAL STATUS GROUPs
1117   TYPES: wctp1_wcctbtab_type TYPE STANDARD TABLE OF wctp1_wcctbwa_type WITH DEFAULT KEY.
1118   * INTERFACE GROUPs
1119   TYPES: wctp1_wcctctab_type TYPE STANDARD TABLE OF wctp1_wcctcwa_type WITH DEFAULT KEY.
1120   * BLOCKING TABLE - CHANGEs
1121   TYPES: wctp1_wccwatab_type TYPE STANDARD TABLE OF wctp1_wccwawa_type WITH DEFAULT KEY.
1122   * BLOCKING TABLE - ASSIGNMENTs
1123   TYPES: wctp1_wccwbtab_type TYPE STANDARD TABLE OF wctp1_wccwbwa_type WITH DEFAULT KEY.
1124   * USE OF WAPs
1125   TYPES: wctp1_wccxtab_type  TYPE STANDARD TABLE OF wctp1_wccxwa_type WITH DEFAULT KEY.
1126   TYPES: wctp1_wccxttab_type TYPE STANDARD TABLE OF wctp1_wccxtwa_type WITH DEFAULT KEY.
1127   * USE OF WAPIs
1128   TYPES: wctp1_wccytab_type  TYPE STANDARD TABLE OF wctp1_wccywa_type WITH DEFAULT KEY.
1129   TYPES: wctp1_wccyttab_type TYPE STANDARD TABLE OF wctp1_wccytwa_type WITH DEFAULT KEY.
1130   * USE OF WCDs
1131   TYPES: wctp1_wccutab_type  TYPE STANDARD TABLE OF wctp1_wccuwa_type WITH DEFAULT KEY.
1132   TYPES: wctp1_wccuttab_type TYPE STANDARD TABLE OF wctp1_wccutwa_type WITH DEFAULT KEY.
1133   * USE OF LINEUPs
1134   TYPES: wctp1_wcclutab_type TYPE STANDARD TABLE OF wctp1_wccluwa_type WITH DEFAULT KEY.
1135   * OPERATIONAL STEPs
1136   TYPES: wctp1_wccmstab_type TYPE STANDARD TABLE OF wctp1_wccmswa_type WITH DEFAULT KEY.
1137   * NEEDs
1138   TYPES: wctp1_wcc2ntab_type TYPE STANDARD TABLE OF wctp1_wcc2nwa_type WITH DEFAULT KEY.
1139   TYPES: wctp1_ndtab_type TYPE SORTED TABLE OF wctp1_ndwa_type WITH UNIQUE KEY iwerk needid.
1140   * WORK TYPEs
1141   TYPES: wctp1_wcc2wtab_type TYPE STANDARD TABLE OF wctp1_wcc2wwa_type WITH DEFAULT KEY.
1142   TYPES: wctp1_wktab_type TYPE SORTED TABLE OF wctp1_wkwa_type WITH UNIQUE KEY iwerk wkid.
1143   * WAPI <-> WORK TYPEs AND NEEDs
1144   TYPES: wctp1_wca2tab_type TYPE STANDARD TABLE OF wctp1_wca2wa_type WITH DEFAULT KEY.
1145   * WCM TEMPLATEs <-> WCM TEMPLATEs
1146   TYPES: wctp1_wcattab_type TYPE STANDARD TABLE OF wctp1_wcatwa_type WITH DEFAULT KEY.
1147   * LOG FOR LINKs (work area)
1148   TYPES: wctp1_wcatqtab_type TYPE STANDARD TABLE OF wctp1_wcatqwa_type WITH DEFAULT KEY.
1149   * TEXT PROCESSING
1150   TYPES: wctp1_wccztab_type TYPE STANDARD TABLE OF wctp1_wcczwa_type WITH DEFAULT KEY.
1151   * MULTI-OBJECT TEXT LINE BUFFER
1152   TYPES: wctp1_tlinestab_type TYPE STANDARD TABLE OF wctp1_tlineswa_type WITH DEFAULT KEY.
1153   * MULTI-OBJECT MULTI TEXT LINE BUFFER
1154   TYPES: wctp1_multi_tlinestab_type TYPE STANDARD TABLE OF wctp1_multi_tlineswa_type WITH DEFAULT KEY.
1155   * MULTI-OBJECT TEXT FUNCTIONS
1156   TYPES: wctp1_tlines_fcodetab_type TYPE STANDARD TABLE OF wctp1_tlines_fcodewa_type WITH DEFAULT KEY.
1157   * MULTI-OBJECT MULTI TEXT FUNCTIONS
1158   TYPES: wctp1_multi_tlines_fcdtab_type TYPE STANDARD TABLE OF wctp1_multi_tlines_fcdwa_type WITH DEFAULT KEY.
1159   * MULTI-OBJECT APPROVAL BUFFER - EXTERNALLY
1160   TYPES: wctp1_permittab_type TYPE STANDARD TABLE OF wctp1_permitwa_type WITH DEFAULT KEY.
1161   * MULTI-OBJECT APPROVAL BUFFER - INTERNALLY
1162   TYPES: wctp1_aprvlstab_type TYPE STANDARD TABLE OF wctp1_aprvlswa_type WITH DEFAULT KEY.
1163   * APPROVAL FUNCTIONS
1164   TYPES: wctp1_pmsogtab_type TYPE STANDARD TABLE OF wctp1_pmsogwa_type WITH DEFAULT KEY.
1165   * MULTI-OBJECT APPROVAL FUNCTIONS
1166   TYPES: wctp1_permit_fcodetab_type TYPE STANDARD TABLE OF wctp1_permit_fcodewa_type WITH DEFAULT KEY.
1167   * MULTI-OBJECT CATALOG BUFFER
1168   TYPES: wctp1_ctlgtab_type TYPE STANDARD TABLE OF wctp1_ctlgwa_type WITH DEFAULT KEY.
1169   * MULTI-OBJECT CATALOG FUNCTIONS
1170   TYPES: wctp1_ctlg_fcodetab_type TYPE STANDARD TABLE OF wctp1_ctlg_fcodewa_type WITH DEFAULT KEY.
1171   * MULTI-OBJECT OBJECT LIST BUFFER
1172   TYPES: wctp1_objlsttab_type TYPE STANDARD TABLE OF wctp1_objlstwa_type WITH DEFAULT KEY.
1173   * MULTI-OBJECT OBJECT LIST FUNCTIONS
1174   TYPES: wctp1_objlst_fcodetab_type TYPE STANDARD TABLE OF wctp1_objlst_fcodewa_type WITH DEFAULT KEY.
1175   * MULTI-OBJECT ASSIGNMENT BUFFER
1176   TYPES: wctp1_asgnmttab_type TYPE STANDARD TABLE OF wctp1_asgnmtwa_type WITH DEFAULT KEY.
1177   * MULTI-OBJECT ASSIGNMENT FUNCTIONS
1178   TYPES: wctp1_asgnmt_fcodetab_type TYPE STANDARD TABLE OF wctp1_asgnmt_fcodewa_type WITH DEFAULT KEY.
1179   * MULTI-OBJECT TEMPLATE ASSIGNMENT BUFFER
1180   TYPES: wctp1_tmplasgntab_type TYPE STANDARD TABLE OF wctp1_tmplasgnwa_type WITH DEFAULT KEY.
1181   * MULTI-OBJECT TEMPLATE ASSIGNMENT FUNCTIONS
1182   TYPES: wctp1_tmplasgn_fcodetab_type TYPE STANDARD TABLE OF wctp1_tmplasgn_fcodewa_type WITH DEFAULT KEY.
1183   * MULTI-OBJECT WCD ITEM BUFFER
1184   TYPES: wctp1_wcditmtab_type TYPE STANDARD TABLE OF wctp1_wcditmwa_type WITH DEFAULT KEY.
1185   * MULTI-OBJECT WCD ITEM FUNCTIONS
1186   TYPES: wctp1_wcditm_fcodetab_type TYPE STANDARD TABLE OF wctp1_wcditm_fcodewa_type WITH DEFAULT KEY.
1187   * PRINT
1188   TYPES: wctp1_wcvltab_type TYPE STANDARD TABLE OF wctp1_wcvlwa_type WITH DEFAULT KEY.
1189   * WCM OBJECTs
1190   TYPES: wctp1_wccotab_type  TYPE STANDARD TABLE OF wctp1_wccowa_type WITH DEFAULT KEY.
1191   TYPES: wctp1_wccottab_type TYPE STANDARD TABLE OF wctp1_wccotwa_type WITH DEFAULT KEY.
1192   TYPES: wctp1_wcvotab_type  TYPE STANDARD TABLE OF wctp1_wcvowa_type WITH DEFAULT KEY.
1193   * WCM OBJECT (MASTER) <-> WCM OBJECT
1194   TYPES: wctp1_wccortab_type TYPE STANDARD TABLE OF wctp1_wccorwa_type WITH DEFAULT KEY.
1195   *WCM_PTW Objects
1196   TYPES: wctp1_wpsafreqtab_type  TYPE STANDARD TABLE OF wctp1_wpsafreq_type WITH DEFAULT KEY.
1197   TYPES: wctp1_isshisttab_type  TYPE STANDARD TABLE OF wctp1_isshist_type WITH DEFAULT KEY.
1198   TYPES: wctp1_safcertreqtab_type TYPE STANDARD TABLE OF wctp1_safcertreq_type WITH DEFAULT KEY.
1199   * (POSSIBLE) SLAVES
1200   TYPES: wctp1_slavetab_type TYPE STANDARD TABLE OF wctp1_slavewa_type WITH DEFAULT KEY.
1201   * WCM OBJECT KEYs
1202   TYPES: wctp1_objkeytab_type TYPE STANDARD TABLE OF wctp1_objkeywa_type WITH DEFAULT KEY.
1203   * WCM OBJECT COUNTERs
1204   TYPES: wctp1_objcnttab_type TYPE STANDARD TABLE OF wctp1_objcntwa_type WITH DEFAULT KEY.
1205   * VIEW PROFILE (sorted tables; unique keys)
1206   TYPES: wctp1_wcc0stab_type   TYPE SORTED TABLE OF wctp1_wcc0swa_type WITH UNIQUE KEY scrnr.
1207   TYPES: wctp1_wcc0sttab_type  TYPE SORTED TABLE OF wctp1_wcc0stwa_type WITH UNIQUE KEY scrnr.
1208   TYPES: wctp1_wcc0sutab_type  TYPE SORTED TABLE OF wctp1_wcc0suwa_type WITH UNIQUE KEY scrnr.
1209   TYPES: wctp1_wcc0suttab_type TYPE SORTED TABLE OF wctp1_wcc0sutwa_type WITH UNIQUE KEY scrnr.
1210   TYPES: wctp1_wcc0srtab_type  TYPE SORTED TABLE OF wctp1_wcc0srwa_type WITH UNIQUE KEY scrnr objart objtyp.
1211   TYPES: wctp1_wcc0atab_type   TYPE SORTED TABLE OF wctp1_wcc0awa_type WITH UNIQUE KEY areanr scrnr.
1212   TYPES: wctp1_wcc0btab_type   TYPE SORTED TABLE OF wctp1_wcc0bwa_type WITH UNIQUE KEY tabscrnr tabname.
1213   TYPES: wctp1_wcc0bttab_type  TYPE SORTED TABLE OF wctp1_wcc0btwa_type WITH UNIQUE KEY tabscrnr tabname.
1214   TYPES: wctp1_wcc0ctab_type   TYPE SORTED TABLE OF wctp1_wcc0cwa_type WITH UNIQUE KEY tabscrnr tabname tabareanr tabareascrnr.
1215   * GROUP DEPENDENT FIELD COUNTER (sorted table; unique key)
1216   TYPES: wctp1_fldgrpcnttab_type TYPE SORTED TABLE OF wctp1_fldgrpcntwa_type WITH UNIQUE KEY fldgrp is_delta.
1217   * WCD ITEMs
1218   TYPES: wctp1_wcitmtab_type TYPE STANDARD TABLE OF wctp1_wcitmwa_type WITH DEFAULT KEY.
1219   * BLOCKING TABLE BASED ...
1220   * - STATUS - ASSIGNMENTs
1221   TYPES: wctp1_lnkblsttab_type TYPE STANDARD TABLE OF wctp1_lnkblstwa_type WITH DEFAULT KEY.
1222   * - TRAFFIC LIGHTs - ASSIGNMENTs
1223   TYPES: wctp1_lnkbltltab_type TYPE STANDARD TABLE OF wctp1_lnkbltlwa_type WITH DEFAULT KEY.
1224   * - STATUS - CHANGEs
1225   TYPES: wctp1_updblsttab_type TYPE STANDARD TABLE OF wctp1_updblstwa_type WITH DEFAULT KEY.
1226   * - TRAFFIC LIGHTS - CHANGESs
1227   TYPES: wctp1_updbltltab_type TYPE STANDARD TABLE OF wctp1_updbltlwa_type WITH DEFAULT KEY.
1228   * - STATUS - CREATE BY REFERENCE
1229   TYPES: wctp1_refblsttab_type TYPE STANDARD TABLE OF wctp1_refblstwa_type WITH DEFAULT KEY.
1230   * - STATUS - CREATE WCD ASSIGNMENT TO OPERATION
1231   TYPES: wctp1_wcdlnkblsttab_type TYPE STANDARD TABLE OF wctp1_wcdlnkblstwa_type WITH DEFAULT KEY.
1232   * - STATUS - REMOVE WCD ASSIGNMENT TO OPERATION
1233   TYPES: wctp1_wcdlnkrejblsttab_type TYPE STANDARD TABLE OF wctp1_wcdlnkrejblstwa_type WITH DEFAULT KEY.
1234   * - TRAFFIC LIGHT - CREATE BY REFERENCE
1235   TYPES: wctp1_refbltltab_type TYPE STANDARD TABLE OF wctp1_refbltlwa_type WITH DEFAULT KEY.
1236   * REJECTION TABLE BASED ON STATUS ...
1237   * - APPROVALs
1238   TYPES: wctp1_rejaprvsttab_type TYPE STANDARD TABLE OF wctp1_rejaprvstwa_type WITH DEFAULT KEY.
1239   * - ASSIGNMENTs
1240   TYPES: wctp1_rejlnksttab_type TYPE STANDARD TABLE OF wctp1_rejlnkstwa_type WITH DEFAULT KEY.
1241   * APPROVAL STATUSES
1242   TYPES: wctp1_aprvtab_type TYPE STANDARD TABLE OF wctp1_aprvwa_type WITH DEFAULT KEY.
1243   * LIFECYCLE PHASE (sorted table; unique key)
1244   TYPES: wctp1_lcphasetab_type TYPE SORTED TABLE OF wctp1_lcphasewa_type WITH UNIQUE KEY objnr.
1245   * LINKED
1246   TYPES: wctp1_lnktab_type TYPE STANDARD TABLE OF wctp1_lnkwa_type WITH DEFAULT KEY.
1247   * ORDER
1248   TYPES: wctp1_ordertab_type TYPE STANDARD TABLE OF wctp1_orderwa_type WITH DEFAULT KEY.
1249   * MAINTENANCE ORDER HEADER
1250   TYPES: wctp1_afihtab_type TYPE STANDARD TABLE OF wctp1_afihwa_type WITH DEFAULT KEY.
1251   * OPERATION WITHIN AN ORDER
1252   TYPES: wctp1_afvctab_type TYPE STANDARD TABLE OF wctp1_afvcwa_type WITH DEFAULT KEY.
1253   * DB STRUCTURE OF THE USER FIELDS OF THE OPERATION
1254   TYPES: wctp1_afvutab_type TYPE STANDARD TABLE OF wctp1_afvuwa_type WITH DEFAULT KEY.
1255   * ORDER HEADER DATA PP ORDERs
1256   TYPES: wctp1_afkotab_type TYPE STANDARD TABLE OF wctp1_afkowa_type WITH DEFAULT KEY.
1257   * OPERATION INCL. UPDATE INDICATOR
1258   TYPES: wctp1_afvgdgettab_type TYPE STANDARD TABLE OF wctp1_afvgdgetwa_type WITH DEFAULT KEY.
1259   * PARTNER
1260   TYPES: wctp1_ihpatab_type TYPE STANDARD TABLE OF wctp1_ihpawa_type WITH DEFAULT KEY.
1261   * REFERENCE STRUCTURE FOR PARTNER
1262   TYPES: wctp1_ihpavbtab_type TYPE STANDARD TABLE OF wctp1_ihpavbwa_type WITH DEFAULT KEY.
1263   * DOCUMENTs
1264   TYPES: wctp1_dradtab_type TYPE STANDARD TABLE OF wctp1_dradwa_type WITH DEFAULT KEY.
1265   * WORK CENTER
1266   TYPES: wctp1_crhdtab_type TYPE STANDARD TABLE OF wctp1_crhdwa_type WITH DEFAULT KEY.
1267   * SCREEN
1268   TYPES: wctp1_dynpreadtab_type TYPE STANDARD TABLE OF wctp1_dynpreadwa_type WITH DEFAULT KEY.
1269   * FUNCTIONAL LOCATION (VIEW)
1270   TYPES: wctp1_iflotab_type TYPE STANDARD TABLE OF wctp1_iflowa_type WITH DEFAULT KEY.
1271   * EQUIPMENT (VIEW)
1272   TYPES: wctp1_v_equitab_type TYPE STANDARD TABLE OF wctp1_v_equiwa_type WITH DEFAULT KEY.
1273   * INTERFACE STRUCTURE SEARCH HELP <-> HELP SYSTEM
1274   TYPES: wctp1_ddshretvaltab_type TYPE STANDARD TABLE OF wctp1_ddshretvalwa_type WITH DEFAULT KEY.
1275   TYPES: wctp1_dselctab_type TYPE STANDARD TABLE OF wctp1_dselcwa_type WITH DEFAULT KEY.
1276   * PAGING
1277   * - INDEX TABLE
1278   TYPES: wctp1_indextab_type TYPE STANDARD TABLE OF wctp1_indexwa_type WITH DEFAULT KEY.
1279   * - SCROLL TABLE
1280   TYPES: wctp1_scrolltab_type TYPE STANDARD TABLE OF wctp1_scrollwa_type WITH DEFAULT KEY.
1281   * ALIAS TABLE
1282   TYPES: wctp1_aliastab_type TYPE STANDARD TABLE OF wctp1_aliaswa_type WITH DEFAULT KEY.
1283   * TABLE FOR COLORS
1284   TYPES: wctp1_coltab_type TYPE STANDARD TABLE OF wctp1_colwa_type WITH DEFAULT KEY.
1285   * LIST COMPARISON
1286   * - WORK TABLE
1287   TYPES: wctp1_cmptab_type TYPE STANDARD TABLE OF wctp1_cmpwa_type WITH DEFAULT KEY.
1288   * - LOG TABLE
1289   TYPES: wctp1_cmplogtab_type TYPE STANDARD TABLE OF wctp1_cmplogwa_type WITH DEFAULT KEY.
1290   * PLANNING PLANT (sorted table; unique key)
1291   TYPES: wctp1_iwerktab_type TYPE SORTED TABLE OF wctp1_iwerkwa_type WITH UNIQUE KEY iwerk.
1292   * PM PERMIT ATTRIBUTES (sorted table; unique key)
1293   TYPES: wctp1_permattrtab_type TYPE SORTED TABLE OF wctp1_permattrwa_type WITH UNIQUE KEY pmsog.
1294   * APPROVAL TABLE with processing data
1295   TYPES: wctp1_gntab_type TYPE STANDARD TABLE OF wctp1_gnwa_type WITH DEFAULT KEY.
1296   * APPROVAL SEGMENT with processing data
1297   TYPES: wctp1_gnstab_type TYPE STANDARD TABLE OF wctp1_gnswa_type WITH DEFAULT KEY.
1298   * CONTROL TABLE
1299   TYPES: wctp1_ctrltab_type TYPE STANDARD TABLE OF wctp1_ctrlwa_type WITH DEFAULT KEY.
1300   * ASSIGNMENT TABLE with processing data
1301   TYPES: wctp1_asgntab_type TYPE STANDARD TABLE OF wctp1_asgnwa_type WITH DEFAULT KEY.
1302   * MESSAGE LOG
1303   TYPES: wctp1_msglogtab_type TYPE STANDARD TABLE OF wctp1_msglogwa_type WITH DEFAULT KEY.
1304   * CHANGE HISTORY
1305   TYPES: wctp1_historytab_type TYPE SORTED TABLE OF wctp1_historywa_type WITH NON-UNIQUE KEY masterobj date time objintf acttyp intcount.
1306
1307   * constants ************************************************************
1308   * POPUP WITH RADIOBUTTONs
1309   CONSTANTS:
1310     BEGIN OF wctp1_radio,
1311       cancel TYPE wctp1_radio_type VALUE 'C',
1312       first  TYPE wctp1_radio_type VALUE '1',
1313       second TYPE wctp1_radio_type VALUE '2',
1314       third  TYPE wctp1_radio_type VALUE '3',
1315       fourth TYPE wctp1_radio_type VALUE '4',
1316       fifth  TYPE wctp1_radio_type VALUE '5',
1317       sixth  TYPE wctp1_radio_type VALUE '6',
1318     END   OF wctp1_radio.
1319   * ANSWERs (POPUP TO CONFIRM)
1320   CONSTANTS:
1321     BEGIN OF wctp1_answer,
1322       yes    TYPE wctp1_answer_type VALUE '1',
1323       no     TYPE wctp1_answer_type VALUE '2',
1324       cancel TYPE wctp1_answer_type VALUE 'A',
1325     END   OF wctp1_answer.
1326   * GENERAL COUNTER FOR TABLEs
1327   CONSTANTS:
1328     BEGIN OF wctp1_entry,
1329       no     TYPE wctp1_cnt_type VALUE 0,
1330       single TYPE wctp1_cnt_type VALUE 1,
1331       two    TYPE wctp1_cnt_type VALUE 2,
1332     END   OF wctp1_entry.
1333   * NUMBERS
1334   CONSTANTS:
1335     BEGIN OF wctp1_number,
1336       even        TYPE wctp1_cnt_type VALUE 0,
1337       odd         TYPE wctp1_cnt_type VALUE 1,
1338       zero        TYPE wctp1_cnt_type VALUE 0,
1339       one         TYPE wctp1_cnt_type VALUE 1,
1340       two         TYPE wctp1_cnt_type VALUE 2,
1341       three       TYPE wctp1_cnt_type VALUE 3,
1342       four        TYPE wctp1_cnt_type VALUE 4,
1343       five        TYPE wctp1_cnt_type VALUE 5,
1344       six         TYPE wctp1_cnt_type VALUE 6,
1345       seven       TYPE wctp1_cnt_type VALUE 7,
1346       eight       TYPE wctp1_cnt_type VALUE 8,
1347       nine        TYPE wctp1_cnt_type VALUE 9,
1348       ten         TYPE wctp1_cnt_type VALUE 10,
1349       eleven      TYPE wctp1_cnt_type VALUE 11,
1350       twelve      TYPE wctp1_cnt_type VALUE 12,
1351       thirteen    TYPE wctp1_cnt_type VALUE 13,
1352       fourteen    TYPE wctp1_cnt_type VALUE 14,
1353       fifteen     TYPE wctp1_cnt_type VALUE 15,
1354       twenty      TYPE wctp1_cnt_type VALUE 20,
1355       twentytwo   TYPE wctp1_cnt_type VALUE 22,
1356       twentyfive  TYPE wctp1_cnt_type VALUE 25,
1357       twentyeight TYPE wctp1_cnt_type VALUE 28,
1358       thirty      TYPE wctp1_cnt_type VALUE 30,
1359       thirtytwo   TYPE wctp1_cnt_type VALUE 32,
1360       thirtyfive  TYPE wctp1_cnt_type VALUE 35,
1361       fourty      TYPE wctp1_cnt_type VALUE 40,
1362       fourtyfive  TYPE wctp1_cnt_type VALUE 45,
1363       fifty       TYPE wctp1_cnt_type VALUE 50,
1364       fiftyfive   TYPE wctp1_cnt_type VALUE 55,
1365       sixty       TYPE wctp1_cnt_type VALUE 60,
1366       sixtyfive   TYPE wctp1_cnt_type VALUE 65,
1367       seventy     TYPE wctp1_cnt_type VALUE 70,
1368       ninety      TYPE wctp1_cnt_type VALUE 90,
1369     END   OF wctp1_number.
1370   * PUSHBUTTONs
1371   CONSTANTS:
1372     BEGIN OF wctp1_pb,
1373       zero  TYPE wcepb VALUE 0,
1374       one   TYPE wcepb VALUE 1,
1375       two   TYPE wcepb VALUE 2,
1376       three TYPE wcepb VALUE 3,
1377     END   OF wctp1_pb.
1378   * SYMBOL MODE
1379   CONSTANTS:
1380     BEGIN OF wctp1_output_mode,
1381       active_pb   TYPE wctp1_output_mode_type VALUE 'A',
1382       inactive_pb TYPE wctp1_output_mode_type VALUE 'I',
1383       pressed     TYPE wctp1_output_mode_type VALUE 'P',
1384     END   OF wctp1_output_mode.
1385   * SPECIAL CHARACTERs
1386   CONSTANTS:
1387     BEGIN OF wctp1_character,
1388       asterisk      TYPE wctp1_character_type VALUE '*',
1389       hyphen        TYPE wctp1_character_type VALUE '-',
1390       question_mark TYPE wctp1_character_type VALUE '?',
1391       ampersand     TYPE wctp1_character_type VALUE '&',
1392       underscore    TYPE wctp1_character_type VALUE '_',
1393       percent_sign  TYPE wctp1_character_type VALUE '%',
1394       slash         TYPE wctp1_character_type VALUE '/',
1395       left_bracket  TYPE wctp1_character_type VALUE '(',
1396       right_bracket TYPE wctp1_character_type VALUE ')',
1397     END   OF wctp1_character.
1398   * VARIABLE TEXTS
1399   CONSTANTS:
1400     BEGIN OF wctp1_variable_text,
1401       one   TYPE wctp1_variable_text_type VALUE '&1',
1402       two   TYPE wctp1_variable_text_type VALUE '&2',
1403       three TYPE wctp1_variable_text_type VALUE '&3',
1404       four  TYPE wctp1_variable_text_type VALUE '&4',
1405     END   OF wctp1_variable_text.
1406   * DATA TRANSFER WHEN CREATING WITH REFERENCE
1407   CONSTANTS:
1408     BEGIN OF wctp1_popup,
1409       use_settings TYPE wctp1_popup_type VALUE 'U',
1410       display      TYPE wctp1_popup_type VALUE 'D',
1411       suppress     TYPE wctp1_popup_type VALUE 'S',
1412       undefined    TYPE wctp1_popup_type VALUE IS INITIAL,
1413     END   OF wctp1_popup.
1414   * EXCEPTIONs
1415   * - MENUE
1416   CONSTANTS:
1417     BEGIN OF wctp1_menue,
1418       deactivate TYPE wctp1_menue_type VALUE 'DEACTIVATE',
1419     END   OF wctp1_menue.
1420   * - GENERAL
1421   CONSTANTS:
1422     BEGIN OF wctp1_exception,
1423       pass_over TYPE wctp1_exception_type VALUE 'PASS',
1424       return    TYPE wctp1_exception_type VALUE 'RETURN',
1425     END   OF wctp1_exception,
1426     wctp1_except_return TYPE wctp1_exception_type VALUE wctp1_exception-return.
1427   * - SCREEN MODIFICATION
1428   CONSTANTS:
1429     BEGIN OF wctp1_screen,
1430       pass_over TYPE wctp1_screen_type VALUE 'PASS',
1431     END   OF wctp1_screen.
1432   * TYPE OF REFERENCES
1433   CONSTANTS:
1434     BEGIN OF wctp1_reftyp,
1435       memory   TYPE wctp1_reftyp_type VALUE 'MEMORY',
1436       order    TYPE wctp1_reftyp_type VALUE 'ORDER',
1437       wap      TYPE wctp1_reftyp_type VALUE 'WAP',
1438       wapi     TYPE wctp1_reftyp_type VALUE 'WAPI',
1439       wcdoc    TYPE wctp1_reftyp_type VALUE 'WCDOC',
1440       template TYPE wctp1_reftyp_type VALUE 'TEMPLATE',
1441     END   OF wctp1_reftyp.
1442   * DIRECTIONS
1443   CONSTANTS:
1444     BEGIN OF wctp1_direction,
1445       up      TYPE wctp1_direction_type VALUE 'UP',
1446       down    TYPE wctp1_direction_type VALUE 'DN',
1447       generic TYPE wctp1_direction_type VALUE space,
1448     END   OF wctp1_direction.
1449   * WCM ARCHITECTURE
1450   CONSTANTS:
1451     BEGIN OF wctp1_model,
1452       standard TYPE wctp1_model_type VALUE 'S',
1453       enhanced TYPE wctp1_model_type VALUE 'E',
1454     END   OF wctp1_model.
1455   * TYPE OF CHECK
1456   CONSTANTS:
1457     BEGIN OF wctp1_check,
1458       test_cycle TYPE wctp1_check_type VALUE '1',
1459       untagging  TYPE wctp1_check_type VALUE '2',
1460     END   OF wctp1_check.
1461   * TASKs
1462   CONSTANTS:
1463     BEGIN OF wctp1_task,
1464       display  TYPE wctp1_task_type VALUE 'DIS',
1465       insert   TYPE wctp1_task_type VALUE 'INS',
1466       delete   TYPE wctp1_task_type VALUE 'DEL',
1467       update   TYPE wctp1_task_type VALUE 'UPD',
1468       import   TYPE wctp1_task_type VALUE 'IMP',
1469       export   TYPE wctp1_task_type VALUE 'EXP',
1470       add      TYPE wctp1_task_type VALUE 'ADD',
1471       set      TYPE wctp1_task_type VALUE 'SET',
1472       reset    TYPE wctp1_task_type VALUE 'RST',
1473       get      TYPE wctp1_task_type VALUE 'GET',
1474       save     TYPE wctp1_task_type VALUE 'SAV',
1475       restore  TYPE wctp1_task_type VALUE 'RES',
1476       complete TYPE wctp1_task_type VALUE 'COM',
1477       create   TYPE wctp1_task_type VALUE 'CRE',
1478       assign   TYPE wctp1_task_type VALUE 'ASG',
1479       generic  TYPE wctp1_task_type VALUE space,
1480     END   OF wctp1_task.
1481   * ACTIONs
1482   CONSTANTS:
1483     BEGIN OF wctp1_action,
1484       insert TYPE wceaction VALUE 'I',
1485       delete TYPE wceaction VALUE 'D',
1486       update TYPE wceaction VALUE 'U',
1487     END   OF wctp1_action.
1488   * POINTS OF TIME
1489   CONSTANTS:
1490     BEGIN OF wctp1_point_of_time,
1491       before TYPE wcetimepoint VALUE 'BEFORE',
1492       after  TYPE wcetimepoint VALUE 'AFTER',
1493     END   OF wctp1_point_of_time.
1494   * POINTS IN TIME
1495   CONSTANTS:
1496     BEGIN OF wctp1_point_in_time,
1497       start TYPE wctp1_point_in_time_type VALUE 'START',
1498       end   TYPE wctp1_point_in_time_type VALUE 'END',
1499     END   OF wctp1_point_in_time.
1500   * STORE
1501   CONSTANTS:
1502     BEGIN OF wctp1_store,
1503       add_entry    TYPE wctp1_store_type VALUE 'A',
1504       delete_entry TYPE wctp1_store_type VALUE 'D',
1505       pass_over    TYPE wctp1_store_type VALUE 'P',
1506       carry_out    TYPE wctp1_store_type VALUE 'C',
1507     END   OF wctp1_store.
1508   * LOCKING OBJECTs
1509   CONSTANTS:
1510     BEGIN OF wctp1_lckgobj,
1511       dequeue TYPE wctp1_lckg_obj_type VALUE 'DEQ',
1512       enqueue TYPE wctp1_lckg_obj_type VALUE 'ENQ',
1513     END   OF wctp1_lckgobj.
1514   * POSITIONs
1515   CONSTANTS:
1516     BEGIN OF wctp1_position,
1517       invalid TYPE wctp1_position_type VALUE 'E',
1518       valid   TYPE wctp1_position_type VALUE space,
1519     END   OF wctp1_position.
1520   * FLAGs
1521   CONSTANTS: wctp1_marked   TYPE wctp1_flg_type VALUE 'X'.
1522   CONSTANTS: wctp1_unmarked TYPE wctp1_flg_type VALUE space.
1523   * BOOLEANs
1524   CONSTANTS: wctp1_true  TYPE wctp1_boolean_type VALUE '1'.
1525   CONSTANTS: wctp1_false TYPE wctp1_boolean_type VALUE '0'.
1526   * CONDITIONS FOR DATA SELECTION
1527   CONSTANTS:
1528     BEGIN OF wctp1_sign,
1529       incl TYPE wctp1_sign_type VALUE 'I',
1530       excl TYPE wctp1_sign_type VALUE 'E',
1531     END   OF wctp1_sign.
1532   CONSTANTS:
1533     BEGIN OF wctp1_option,
1534       equal            TYPE wctp1_option_type VALUE 'EQ',
1535       not_equal        TYPE wctp1_option_type VALUE 'NE',
1536       between          TYPE wctp1_option_type VALUE 'BT',
1537       contains_pattern TYPE wctp1_option_type VALUE 'CP',
1538       less_than        TYPE wctp1_option_type VALUE 'LT',
1539       less_equal       TYPE wctp1_option_type VALUE 'LE',
1540       greater_than     TYPE wctp1_option_type VALUE 'GT',
1541       greater_equal    TYPE wctp1_option_type VALUE 'GE',
1542     END   OF wctp1_option.
1543   * STATEMENTS FOR SELECTION
1544   CONSTANTS:
1545     BEGIN OF wctp1_statement,
1546       standard        TYPE wctp1_statement_type VALUE 'STD',
1547       for_all_entries TYPE wctp1_statement_type VALUE 'FAE',
1548     END   OF wctp1_statement.
1549   * MAXIMUM NUMBER OF ENTRIEs
1550   CONSTANTS: wctp1_maxcnt TYPE wctp1_cnt_type VALUE 50.
1551   * PROCESSING STATUS
1552   CONSTANTS:
1553     BEGIN OF wctp1_processing_status,
1554       open          TYPE wcecompleted VALUE 3,
1555       released      TYPE wcecompleted VALUE 0, ":<=> WCTP1_FALSE
1556       completed     TYPE wcecompleted VALUE 1, ":<=> WCTP1_TRUE
1557       not_completed TYPE wcecompleted VALUE 2,
1558     END   OF wctp1_processing_status.
1559   * APPROVAL STATUS (domain WCDTL)
1560   CONSTANTS:
1561     BEGIN OF wctp1_tl,
1562       green  TYPE wctp1_tl_type VALUE 0,
1563       yellow TYPE wctp1_tl_type VALUE 1,
1564       red    TYPE wctp1_tl_type VALUE 2,
1565     END   OF wctp1_tl.
1566   * APPROVAL STATUS (COUNTERs)
1567   CONSTANTS:
1568     BEGIN OF wctp1_tlcnt,
1569       completly  TYPE wctp1_tlcnt_type VALUE 0,
1570       partly     TYPE wctp1_tlcnt_type VALUE 1,
1571       not_at_all TYPE wctp1_tlcnt_type VALUE 2,
1572       undefined  TYPE wctp1_tlcnt_type VALUE -1,
1573     END   OF wctp1_tlcnt.
1574   * VERIFICATION NOTES (domain WCDVERNOTE)
1575   CONSTANTS:
1576     BEGIN OF wctp1_vernote,
1577       changed_current_position    TYPE wcevernote VALUE 1,
1578       corrected_current_position  TYPE wcevernote VALUE 2,
1579       confirmed_current_position  TYPE wcevernote VALUE 3,
1580       confirmed_expected_position TYPE wcevernote VALUE 4,
1581       active_tagout_lockout       TYPE wcevernote VALUE 5,
1582     END   OF wctp1_vernote.
1583   * VERIFICATION STATUS
1584   CONSTANTS:
1585     BEGIN OF wctp1_verstat,
1586       undefined  TYPE wceverstat VALUE 0,
1587       normal     TYPE wceverstat VALUE 1,
1588       off_normal TYPE wceverstat VALUE 2,
1589       tagged     TYPE wceverstat VALUE 3,
1590     END   OF wctp1_verstat.
1591   * PROTECTED AREA
1592   CONSTANTS:
1593     BEGIN OF wctp1_pacnt,
1594       outside TYPE wctp1_pacnt_type VALUE 3,
1595       inside  TYPE wctp1_pacnt_type VALUE 2,
1596       not_set TYPE wctp1_pacnt_type VALUE 1,
1597     END   OF wctp1_pacnt.
1598   * VALUATION (domain WCDVAL)
1599   CONSTANTS:
1600     BEGIN OF wctp1_val,
1601       yes       TYPE wceval VALUE 'Y',
1602       no        TYPE wceval VALUE 'N',
1603       undefined TYPE wceval VALUE space,
1604     END   OF wctp1_val.
1605   * COLORs
1606   CONSTANTS:
1607     BEGIN OF wctp1_color,
1608       no                     TYPE wctp1_color_type VALUE 2,
1609       red                    TYPE wctp1_color_type VALUE 6,
1610       blue                   TYPE wctp1_color_type VALUE 4,
1611       yellow                 TYPE wctp1_color_type VALUE 3,
1612       green                  TYPE wctp1_color_type VALUE 5,
1613       purple                 TYPE wctp1_color_type VALUE 7,
1614       valuation              TYPE wctp1_color_type VALUE 5,
1615       approval_groups        TYPE wctp1_color_type VALUE 7,
1616       work_permits           TYPE wctp1_color_type VALUE 7,
1617       catalogue              TYPE wctp1_color_type VALUE 1,
1618       unprocessed_objects    TYPE wctp1_color_type VALUE 4,
1619       edited_objects         TYPE wctp1_color_type VALUE 7,
1620       last_objects_processed TYPE wctp1_color_type VALUE 6,
1621     END   OF wctp1_color.
1622   * OPERATIONAL TAGs
1623   CONSTANTS:
1624     BEGIN OF wctp1_operational_tag,
1625       tag      TYPE wctp1_operational_tag_type VALUE '1',
1626       test_tag TYPE wctp1_operational_tag_type VALUE '2',
1627     END   OF wctp1_operational_tag.
1628   * OPERATIONAL PHASEs
1629   CONSTANTS:
1630     BEGIN OF wctp1_next,
1631       tagging   TYPE wcenext VALUE 'TG',
1632       untagging TYPE wcenext VALUE 'UN',
1633       undefined TYPE wcenext VALUE IS INITIAL,
1634     END   OF wctp1_next.
1635   * AIM OF SWITCHING (domain WCDOPTYP)
1636   CONSTANTS:
1637     BEGIN OF wctp1_optyp,
1638       tagging   TYPE wceoptyp VALUE 'TG',
1639       untagging TYPE wceoptyp VALUE 'UN',
1640       undefined TYPE wceoptyp VALUE IS INITIAL,
1641     END   OF wctp1_optyp.
1642   * OBJECT
1643   * - TYPEs
1644   CONSTANTS:
1645     BEGIN OF wctp1_objart,
1646       order     TYPE wctp1_objart_type VALUE 'OR',
1647       wap       TYPE wctp1_objart_type VALUE 'WW',
1648       wapi      TYPE wctp1_objart_type VALUE 'WA',
1649       wcd       TYPE wctp1_objart_type VALUE 'WD',
1650       wcditm    TYPE wctp1_objart_type VALUE 'WI',
1651       step      TYPE wctp1_objart_type VALUE 'WR',
1652       lineup    TYPE wctp1_objart_type VALUE 'WV',
1653       verlst    TYPE wctp1_objart_type VALUE 'WL',
1654       func_loc  TYPE wctp1_objart_type VALUE 'IF',
1655       equipment TYPE wctp1_objart_type VALUE 'IE',
1656       tm        TYPE wctp1_objart_type VALUE 'TM',
1657       dummy     TYPE wctp1_objart_type VALUE space,
1658       generic   TYPE wctp1_objart_type VALUE space,
1659     END   OF wctp1_objart.
1660   * - SUBTYPEs
1661   CONSTANTS:
1662     BEGIN OF wctp1_objtyp,
1663       wca     TYPE wctp1_objtyp_type VALUE '1',
1664       wapi    TYPE wctp1_objtyp_type VALUE 'Z',
1665       wctm    TYPE wctp1_objtyp_type VALUE 'T',
1666       opwc    TYPE wctp1_objtyp_type VALUE 'O',
1667       dummy   TYPE wctp1_objtyp_type VALUE space,
1668       generic TYPE wctp1_objtyp_type VALUE space,
1669     END   OF wctp1_objtyp.
1670   * LINEUP TYPEs (domain WCDLINEUPTYPE)
1671   CONSTANTS:
1672     BEGIN OF wctp1_lutyp,
1673       lutm    TYPE wcelutyp VALUE 'T',
1674       oplu    TYPE wcelutyp VALUE 'O',
1675       generic TYPE wcelutyp VALUE space,
1676     END   OF wctp1_lutyp.
1677   * TEXT (SE75)
1678   * - IDs
1679   CONSTANTS:
1680     BEGIN OF wctp1_tdid,
1681       ltxt TYPE wctp1_tdid_type VALUE 'LTXT',
1682       qpct TYPE wctp1_tdid_type VALUE 'QPCT',
1683     END   OF wctp1_tdid.
1684   * - APPLICATION OBJECTs
1685   CONSTANTS:
1686     BEGIN OF wctp1_tdobject,
1687       order    TYPE wctp1_tdobject_type VALUE 'AUFK',
1688       wap      TYPE wctp1_tdobject_type VALUE 'WAP',
1689       wapi     TYPE wctp1_tdobject_type VALUE 'WAPI',
1690       wcd      TYPE wctp1_tdobject_type VALUE 'WCDOC',
1691       wcditm   TYPE wctp1_tdobject_type VALUE 'WCDOCITM',
1692       approval TYPE wctp1_tdobject_type VALUE 'APPROVAL',
1693       catalog  TYPE wctp1_tdobject_type VALUE 'CATALOG',
1694       qkatalog TYPE wctp1_tdobject_type VALUE 'QKATALOG',
1695       t357g    TYPE wctp1_tdobject_type VALUE 'T357G',
1696       lineup   TYPE wctp1_tdobject_type VALUE 'LINEUP',
1697       verlst   TYPE wctp1_tdobject_type VALUE 'VERLST',
1698     END   OF wctp1_tdobject.
1699   * - AFFIX TYPEs
1700   CONSTANTS:
1701     BEGIN OF wctp1_affix_typ,
1702       ltxt      TYPE wctp1_affix_typ_type VALUE 'LTXT',
1703       tgtxt     TYPE wctp1_affix_typ_type VALUE 'TXT1',
1704       untgtxt   TYPE wctp1_affix_typ_type VALUE 'TXT2',
1705       rejctxt   TYPE wctp1_affix_typ_type VALUE 'REJC',
1706       requaltxt TYPE wctp1_affix_typ_type VALUE 'REQU',
1707       remark_1  TYPE wctp1_affix_typ_type VALUE 'REM1',
1708       remark_2  TYPE wctp1_affix_typ_type VALUE 'REM2',
1709     END   OF wctp1_affix_typ.
1710   * - TYPES (domain WCDTXTTYP)
1711   CONSTANTS:
1712     BEGIN OF wctp1_txttyp,
1713       header          TYPE wcetxttyp VALUE 'GH1',
1714       rejection       TYPE wcetxttyp VALUE 'GH2',
1715       approval        TYPE wcetxttyp VALUE 'GH3',
1716       catalog         TYPE wcetxttyp VALUE 'GH4',
1717       remark_1        TYPE wcetxttyp VALUE 'GH5',
1718       remark_2        TYPE wcetxttyp VALUE 'GH6',
1719       requalification TYPE wcetxttyp VALUE 'SH1',
1720       tagging         TYPE wcetxttyp VALUE 'SH2',
1721       untagging       TYPE wcetxttyp VALUE 'SH3',
1722       item            TYPE wcetxttyp VALUE 'SI1',
1723     END   OF wctp1_txttyp.
1724   * - DOCUMENTATION OBJECTs
1725   CONSTANTS:
1726     BEGIN OF wctp1_docobj,
1727       wcm_general_checks           TYPE doku_obj VALUE 'WCM_GENERAL_CHECKS',
1728       wcm_check_tagged_untagged    TYPE doku_obj VALUE 'WCM_CHECK_TAGGED_UNTAGGED',
1729       wcm_check_reference_object   TYPE doku_obj VALUE 'WCM_CHECK_REFERENCE_OBJECT',
1730       wcm_check_time_frame         TYPE doku_obj VALUE 'WCM_CHECK_TIME_FRAME',
1731       wcm_check_conflict           TYPE doku_obj VALUE 'WCM_CHECK_CONFLICT',
1732       wcm_completeness_correctness TYPE doku_obj VALUE 'WCM_COMPLETENESS_CORRECTNESS',
1733       wcm_check_test_cycle         TYPE doku_obj VALUE 'WCM_CHECK_TEST_CYCLE',
1734       wcm_check_untagging          TYPE doku_obj VALUE 'WCM_CHECK_UNTAGGING',
1735       wcm_clipboard                TYPE doku_obj VALUE 'WCM_CLIPBOARD',
1736       wcm_filter                   TYPE doku_obj VALUE 'WCM_FILTER',
1737       wcm_ignored_conflicts        TYPE doku_obj VALUE 'WCM_IGNORED_CONFLICTS',
1738       wcm_multiple_tagging         TYPE doku_obj VALUE 'WCM_MULTIPLE_TAGGING',
1739       wcm_operational_protection   TYPE doku_obj VALUE 'WCM_OPERATIONAL_PROTECTION',
1740       wcm_unused_operational_tags  TYPE doku_obj VALUE 'WCM_UNUSED_OPERATIONAL_TAGS',
1741       wcm_user_specific_settings   TYPE doku_obj VALUE 'WCM_USER_SPECIFIC_SETTINGS',
1742       wcm_operational_lists        TYPE doku_obj VALUE 'WCM_OPERATIONAL_LISTS',
1743       wcm_operational_steps        TYPE doku_obj VALUE 'WCM_OPERATIONAL_STEPS',
1744       wcm_list_editing_oplst       TYPE doku_obj VALUE 'WCM_LIST_EDITING_OPLST',
1745       wcm_adjust_untagging         TYPE doku_obj VALUE 'WCM_ADJUST_UNTAGGING',
1746       wcm_approval_groups          TYPE doku_obj VALUE 'WCM_APPROVAL_GROUPS',
1747       wcm_valuation                TYPE doku_obj VALUE 'WCM_VALUATION',
1748       wcm_approval                 TYPE doku_obj VALUE 'WCM_APPROVAL',
1749       wcm_mode_dependent_tagging   TYPE doku_obj VALUE 'WCM_MODE_DEPENDENT_TAGGING',
1750       wcm_work_permits             TYPE doku_obj VALUE 'WCM_WORK_PERMITS',
1751     END   OF wctp1_docobj.
1752   * CHANGE DOCUMENTs
1753   CONSTANTS:
1754     BEGIN OF wctp1_cdhdr,
1755       wap    TYPE cdobjectcl VALUE 'WAP',    "work approval
1756       wapi   TYPE cdobjectcl VALUE 'WAPI',   "application
1757       wcd    TYPE cdobjectcl VALUE 'WCD',    "WC document
1758       wcdi   TYPE cdobjectcl VALUE 'WCDI',   "WCD items
1759       lineup TYPE cdobjectcl VALUE 'LINEUP', "lineup
1760       verlst TYPE cdobjectcl VALUE 'VERLST', "verification list
1761     END   OF wctp1_cdhdr.
1762   CONSTANTS:
1763     BEGIN OF wctp1_cdind,
1764       upd TYPE cdchngind VALUE 'U',
1765     END   OF wctp1_cdind.
1766   * TRANSACTION TYPEs
1767   CONSTANTS: wctp1_aktyp_h TYPE wctp1_aktyp_type VALUE 'H'. "creation mode
1768   CONSTANTS: wctp1_aktyp_v TYPE wctp1_aktyp_type VALUE 'V'. "change mode
1769   CONSTANTS: wctp1_aktyp_a TYPE wctp1_aktyp_type VALUE 'A'. "display mode
1770   * OPERATION CODES FOR DOCUMENTs
1771   CONSTANTS:
1772     BEGIN OF wctp1_opcode,
1773       create  TYPE wctp1_opcode_type VALUE '1', "creation mode
1774       change  TYPE wctp1_opcode_type VALUE '2', "change mode
1775       display TYPE wctp1_opcode_type VALUE '3', "display mode
1776     END   OF wctp1_opcode.
1777   * USABILITY OF OPERATIONAL CONDITION (domain WCDUSABLE)
1778   CONSTANTS:
1779     BEGIN OF wctp1_usable,
1780       tagging   TYPE wctp1_usable_type VALUE '1',   "operational condition is to be used for tagging
1781       untagging TYPE wctp1_usable_type VALUE '2',   "operational condition is to be used for untagging
1782       generic   TYPE wctp1_usable_type VALUE space, "operational condition is to be used for both processes
1783     END   OF wctp1_usable.
1784   * SPECIFICATION OF OPERATIONAL CYCLE (domain WCDPHASECTRL)
1785   CONSTANTS:
1786     BEGIN OF wctp1_usectrl,
1787       complete     TYPE wcephasectrl VALUE space, "Tagging cycle with temporary untagging phase
1788       no_untagging TYPE wcephasectrl VALUE '1',   "Test cycle
1789       no_test      TYPE wcephasectrl VALUE '2',   "Tagging cycle without temporary untagging phase
1790       no_cycle     TYPE wcephasectrl VALUE 'X',   "without items
1791     END   OF wctp1_usectrl.
1792   * ITEM CATEGORY (domain WCDITMTYP)
1793   CONSTANTS:
1794     BEGIN OF wctp1_itmtyp,
1795       func_loc  TYPE wceitmtyp VALUE 'F', "functional location
1796       equipment TYPE wceitmtyp VALUE 'E', "equipment
1797       neutral   TYPE wceitmtyp VALUE 'N', "technical object without master data
1798       comment   TYPE wceitmtyp VALUE 'C', "comment
1799     END   OF wctp1_itmtyp.
1800   * TYPE OF TECHNICAL OBJECTs (domain WCDCCTYP)
1801   CONSTANTS:
1802     BEGIN OF wctp1_cctyp,
1803       func_loc  TYPE wctp1_cctyp_type VALUE 'F', "functional location
1804       equipment TYPE wctp1_cctyp_type VALUE 'E', "equipment
1805       neutral   TYPE wctp1_cctyp_type VALUE 'N', "technical object without master data
1806     END   OF wctp1_cctyp.
1807   * TYPE OF CONVERSIONs
1808   CONSTANTS:
1809     BEGIN OF wctp1_conversion,
1810       output TYPE wctp1_conversion_type VALUE 'O', "internal -> external
1811       input  TYPE wctp1_conversion_type VALUE 'I', "external -> internal
1812     END   OF wctp1_conversion.
1813   * LINKED OBJECT (DOCUMENT MANAGEMENT)
1814   CONSTANTS:
1815     BEGIN OF wctp1_dokob,
1816       order  TYPE wctp1_dokob_type VALUE space,   "order
1817       wap    TYPE wctp1_dokob_type VALUE 'WCAW',  "WAP
1818       wapi   TYPE wctp1_dokob_type VALUE 'WCAAP', "WAP'
1819       wcd    TYPE wctp1_dokob_type VALUE 'WCAHE', "WCD
1820       wcditm TYPE wctp1_dokob_type VALUE 'WCAIT', "WCD item
1821     END   OF wctp1_dokob.
1822   * SPA / GPA PARAMETERs
1823   CONSTANTS:
1824     BEGIN OF wctp1_pid,
1825       wc0  TYPE memoryid VALUE 'WC0',  "subobject type
1826       wc1  TYPE memoryid VALUE 'WC1',  "WAP number
1827       wc2  TYPE memoryid VALUE 'WC2',  "WAPI number
1828       wc3  TYPE memoryid VALUE 'WC3',  "WCD number
1829       wc4  TYPE memoryid VALUE 'WC4',  "suboject type (WCD)
1830       wc5  TYPE memoryid VALUE 'WC5',  "subobject type (WAPI)
1831       wc6  TYPE memoryid VALUE 'WC6',  "template (WAP)
1832       wc7  TYPE memoryid VALUE 'WC7',  "template (WAPI)
1833       wc8  TYPE memoryid VALUE 'WC8',  "template (WCD)
1834       wc9  TYPE memoryid VALUE 'WC9',  "subobject type
1835       wc10 TYPE memoryid VALUE 'WC10', "work center for WCM
1836       wc11 TYPE memoryid VALUE 'WC11', "list comparizon (user specific settings)
1837       wc12 TYPE memoryid VALUE 'WC12', "WCD (user specific settings)
1838       wc13 TYPE memoryid VALUE 'WC13', "WAPI (user specific settings)
1839       wc14 TYPE memoryid VALUE 'WC14', "WAP (user specific settings)
1840       wc15 TYPE memoryid VALUE 'WC15', "lineup number
1841       wc16 TYPE memoryid VALUE 'WC16', "type of lineup
1842       wc17 TYPE memoryid VALUE 'WC17', "general settings
1843       wc18 TYPE memoryid VALUE 'WC18', "specific settings
1844       wc19 TYPE memoryid VALUE 'WC19', "list display
1845       wcm  TYPE memoryid VALUE 'WCM',  "maintenance plant (F4-help)
1846       wcn  TYPE memoryid VALUE 'WCN',  "message control
1847       iwk  TYPE memoryid VALUE 'IWK',  "planning plant
1848       anr  TYPE memoryid VALUE 'ANR',  "order number
1849       ifl  TYPE memoryid VALUE 'IFL',  "functional location
1850       eqn  TYPE memoryid VALUE 'EQN',  "equipment
1851       agr  TYPE memoryid VALUE 'AGR',  "work center
1852       wrk  TYPE memoryid VALUE 'WRK',  "plant
1853     END   OF wctp1_pid.
1854   * CONTROL KEY
1855   CONSTANTS: wctp1_ctrlkey TYPE steus VALUE 'WCM'.
1856   * GENERIC SYSTEM CONDITION
1857   CONSTANTS: wctp1_anlzu_generic TYPE anlzu VALUE space.
1858   * LANGUAGE KEYs
1859   CONSTANTS:
1860     BEGIN OF wctp1_language_key,
1861       german  TYPE spras VALUE 'D', "German
1862       english TYPE spras VALUE 'E', "English
1863     END   OF wctp1_language_key.
1864   * BADGEs
1865   CONSTANTS:
1866     BEGIN OF wctp1_badge,
1867       lwcgbf01_generate_opwc     TYPE wctp1_badge_type VALUE '1', "automatic generation of Op. WCDs
1868       lwcgbf01_generate_wap      TYPE wctp1_badge_type VALUE '2', "automatic generation of WAPs
1869       lwcgbf01_generate_wapi     TYPE wctp1_badge_type VALUE '3', "automatic generation of WAPIs
1870       wcfx_wcmobj2order_asgn     TYPE wctp1_badge_type VALUE '4', "create WCM object & assign order to the WCM object
1871       wcfx_wapi2wap_dialog       TYPE wctp1_badge_type VALUE '5', "create WAPI & assign WAP to the WAPI
1872       wcfx_wapi2wap_asgn         TYPE wctp1_badge_type VALUE '6', "change WAPI & assign several WAPs to the WAPI
1873       lwcfxf01_creation          TYPE wctp1_badge_type VALUE '7', "create WCM object (dialog for assignments)
1874       lwcfxf01_obj_dialog        TYPE wctp1_badge_type VALUE '8', "display/change WCM object (dialog for assignment)
1875       wcfx_obj_dialog            TYPE wctp1_badge_type VALUE '9', "display/change Work Permit
1876       wcfw_obj_dialog            TYPE wctp1_badge_type VALUE 'A', "display/change WCM object/orders (standard FM)
1877       wcfy_display_rfc           TYPE wctp1_badge_type VALUE 'B', "RFC-FM (internal used)
1878       wcmrif29_function_execute  TYPE wctp1_badge_type VALUE 'C', "mass functionality for Work Permits
1879       wcmrif39_function_execute  TYPE wctp1_badge_type VALUE 'D', "mass functionality for WCM objects
1880       riwc0021                   TYPE wctp1_badge_type VALUE 'E', "mobile processing (background job)
1881       riwc0023                   TYPE wctp1_badge_type VALUE 'F', "automatic updating of WCM objects
1882       enhancement                TYPE wctp1_badge_type VALUE 'G', "enhancement
1883       wcmobj_transaction_process TYPE wctp1_badge_type VALUE 'H', "transaction processed by CL_WCM_BL_WCMOBJ
1884     END   OF wctp1_badge.
1885   * ASSIGNMENT CHECK LEVELs
1886   CONSTANTS:
1887     BEGIN OF wctp1_assgn_chklvl,
1888       general_display        TYPE wctp1_assgn_chklvl_type VALUE 1,
1889       general_maintenance    TYPE wctp1_assgn_chklvl_type VALUE 2,
1890       general_deletion       TYPE wctp1_assgn_chklvl_type VALUE 3,
1891       individual_maintenance TYPE wctp1_assgn_chklvl_type VALUE 4,
1892       individual_deletion    TYPE wctp1_assgn_chklvl_type VALUE 5,
1893       correct_maintenance    TYPE wctp1_assgn_chklvl_type VALUE 6,
1894     END   OF wctp1_assgn_chklvl.
1895   * DYNPRO PROCESSING BLOCK
1896   CONSTANTS:
1897     BEGIN OF wctp1_dynpblock,
1898       output TYPE wctp1_dynpblock_type VALUE 'O',
1899       input  TYPE wctp1_dynpblock_type VALUE 'I',
1900     END   OF wctp1_dynpblock.
1901   * SCREEN FIELDs
1902   CONSTANTS:
1903     BEGIN OF wctp1_field,
1904       equnr        TYPE wctp1_field_type VALUE 'WCSCCOBJ-EQUNR',
1905       tplnr        TYPE wctp1_field_type VALUE 'WCSCCOBJ-TPLNR',
1906       iwerk        TYPE wctp1_field_type VALUE 'WCSRESP-IWERK',
1907       wkcr         TYPE wctp1_field_type VALUE 'WCSRESP-WKCR',
1908       refkey       TYPE wctp1_field_type VALUE 'WCSHEADER-REFKEY',
1909       wapnr        TYPE wctp1_field_type VALUE 'WCSWAP-WAPNR',
1910       wapuse       TYPE wctp1_field_type VALUE 'WCSWAP-WAPUSE',
1911       wapinr       TYPE wctp1_field_type VALUE 'WCSWAPI-WAPINR',
1912       wapiuse      TYPE wctp1_field_type VALUE 'WCSWAPI-WAPIUSE',
1913       wcnr         TYPE wctp1_field_type VALUE 'WCSWCDOC-WCNR',
1914       wcuse        TYPE wctp1_field_type VALUE 'WCSWCDOC-WCUSE',
1915       aufnr_io6    TYPE wctp1_field_type VALUE 'WCSIO6-AUFNR',
1916       wapinr_io7   TYPE wctp1_field_type VALUE 'WCSIO7-WAPINR',
1917       wcnr_io7     TYPE wctp1_field_type VALUE 'WCSIO7-WCNR',
1918       equnr_io7    TYPE wctp1_field_type VALUE 'WCSIO7-EQUNR',
1919       tplnr_io7    TYPE wctp1_field_type VALUE 'WCSIO7-TPLNR',
1920       wapinr_io8   TYPE wctp1_field_type VALUE 'WCSIO8-WAPINR',
1921       wapnr_io8    TYPE wctp1_field_type VALUE 'WCSIO8-WAPNR',
1922       equnr_io8    TYPE wctp1_field_type VALUE 'WCSIO8-EQUNR',
1923       tplnr_io8    TYPE wctp1_field_type VALUE 'WCSIO8-TPLNR',
1924       wcnr_io9     TYPE wctp1_field_type VALUE 'WCSIO9-WCNR',
1925       wapinr_io9   TYPE wctp1_field_type VALUE 'WCSIO9-WAPINR',
1926       equnr_io9    TYPE wctp1_field_type VALUE 'WCSIO9-EQUNR',
1927       tplnr_io9    TYPE wctp1_field_type VALUE 'WCSIO9-TPLNR',
1928       ltxt_aprvl   TYPE wctp1_field_type VALUE 'WCSPERMIT-ICON_KZLTX',
1929       ltxt_ctlg    TYPE wctp1_field_type VALUE 'WCSCATALOG-ICON_LTXTFLG',
1930       tplnr_objlst TYPE wctp1_field_type VALUE 'WCSOBJLST-TPLNR',
1931       equnr_objlst TYPE wctp1_field_type VALUE 'WCSOBJLST-EQUNR',
1932       pmsog_aprvl  TYPE wctp1_field_type VALUE 'WCSPERMIT-PMSOG',
1933     END   OF wctp1_field.
1934   * PHASEs (domain WCDLCPHASE)
1935   CONSTANTS:
1936     BEGIN OF wctp1_phase,
1937       planning_phase        TYPE wcelcphase VALUE 'NEW',
1938       approval_phase        TYPE wcelcphase VALUE 'APRV',
1939       wkpt_is_printed       TYPE wcelcphase VALUE 'PWP',
1940       wkpt_is_handed_out    TYPE wcelcphase VALUE 'WPHO',
1941       wkpt_is_released      TYPE wcelcphase VALUE 'REL',
1942       validity_was_extended TYPE wcelcphase VALUE 'EXT',
1943       validity_has_expired  TYPE wcelcphase VALUE 'EXP',
1944       wcmobj_is_inactive    TYPE wcelcphase VALUE 'INAC',
1945       wcmobj_is_closed      TYPE wcelcphase VALUE 'CLSD',
1946       wcmobj_is_rejected    TYPE wcelcphase VALUE 'REJC',
1947       wcmobj_is_deleted     TYPE wcelcphase VALUE 'DLFL',
1948     END   OF wctp1_phase.
1949   * EDIT ABILITY (domain WCDEDITABLE)
1950   CONSTANTS:
1951     BEGIN OF wctp1_editable,
1952       yes        TYPE wceeditable VALUE 'Y',
1953       restricted TYPE wceeditable VALUE 'R',
1954       no         TYPE wceeditable VALUE 'N',
1955     END   OF wctp1_editable.
1956   * URL PARAMETERs
1957   CONSTANTS:
1958     BEGIN OF wctp1_url_param,
1959       iwerk   TYPE string VALUE 'IWERK',
1960       wapityp TYPE string VALUE 'WAPITYP',
1961       wctyp   TYPE string VALUE 'WCTYP',
1962       usectrl TYPE string VALUE 'USECTRL',
1963       wapiuse TYPE string VALUE 'WAPIUSE',
1964       wcuse   TYPE string VALUE 'WCUSE',
1965       refobj  TYPE string VALUE 'REFOBJ',
1966       asgnobj TYPE string VALUE 'ASGNOBJ',
1967     END   OF wctp1_url_param.
1968   * APPLICATION CLASSes
1969   CONSTANTS:
1970     BEGIN OF wctp1_appl_class,
1971       transaction TYPE wctp1_appl_class_type VALUE '0',
1972       webdynpro   TYPE wctp1_appl_class_type VALUE '1',
1973       api         TYPE wctp1_appl_class_type VALUE '2',
1974       default     TYPE wctp1_appl_class_type VALUE space,
1975     END   OF wctp1_appl_class.
1976   * FIELD UPDATE CONTROL (domain WCDAPI_UPDFLGCTRL)
1977   CONSTANTS:
1978     BEGIN OF wctp1_updflgctrl,
1979       flag_setting   TYPE wceapi_updflgctrl VALUE space,
1980       all_fields     TYPE wceapi_updflgctrl VALUE 'A',
1981       set_fields     TYPE wceapi_updflgctrl VALUE 'S',
1982       initial_fields TYPE wceapi_updflgctrl VALUE 'I',
1983     END   OF wctp1_updflgctrl.
1984   * SAVE MODEs
1985   CONSTANTS:
1986     BEGIN OF wctp1_upd_mode,
1987       buffer TYPE wctp1_upd_mode_type VALUE '1',
1988       post   TYPE wctp1_upd_mode_type VALUE '2',
1989       commit TYPE wctp1_upd_mode_type VALUE '3',
1990     END   OF wctp1_upd_mode.
1991   * SWITCHES (business functions)
1992   CONSTANTS:
1993     BEGIN OF wctp1_switch_id,
1994       worker_safety_01 TYPE sfw_switch_id VALUE 'EAM_SFWS_WCM_WS_EA_1',
1995     END   OF wctp1_switch_id.
1996   * CHANGE HISTORY ACTION TYPEs (NB: 1st digit := sort sequence; 2nd+3rd digit := action)
1997   CONSTANTS:
1998     BEGIN OF wctp1_history_acttyp,
1999       being_assigned   TYPE char3 VALUE '0B+',
2000       assigned         TYPE char3 VALUE '1A+',
2001       being_unassigned TYPE char3 VALUE '2B-',
2002       unassigned       TYPE char3 VALUE '3A-',
2003       changed          TYPE char3 VALUE '4CH',
2004       checked_yes      TYPE char3 VALUE '5C+',
2005       checked_no       TYPE char3 VALUE '6C-',
2006       issued           TYPE char3 VALUE '5I+',
2007       revoked          TYPE char3 VALUE '6I-',
2008       set              TYPE char3 VALUE '5S+',
2009       reset            TYPE char3 VALUE '6S-',
2010       printed_original TYPE char3 VALUE '7PO',
2011       printed_copy     TYPE char3 VALUE '8PC',
2012     END   OF wctp1_history_acttyp.
*--- End of %_CWCTP1 - 2012 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTP3                                  Level 1    Page 5
Object           ZRIWFWA01                                 Lines 358
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTP3
3      *-----------------------------------------------------------------------
4      *  Purpose: status / business transactions
5      ************************************************************************
6      TYPE-POOL wctp3.
7
8      * elementary types *****************************************************
9      TYPES: wctp3_status_type  TYPE j_status.
10     TYPES: wctp3_txt04_type   TYPE j_txt04.
11     TYPES: wctp3_txt30_type   TYPE j_txt30.
12     TYPES: wctp3_obtyp_type   TYPE j_obtyp.
13     TYPES: wctp3_vrgng_type   TYPE j_vorgang.
14     TYPES: wctp3_flg_type     TYPE wceflg.
15     TYPES: wctp3_exec_type(3) TYPE c.
16     TYPES: wctp3_cnt_type(4)  TYPE n.
17     TYPES: wctp3_objnr_type   TYPE j_objnr.
18
19     * structures types *****************************************************
20     * SHORT TEXTs OF STATUS
21     TYPES:
22       BEGIN OF wctp3_stattxt04_type,
23         crea TYPE wctp3_txt04_type,  "CREATED
24         prep TYPE wctp3_txt04_type,  "PREPARED
25         hprp TYPE wctp3_txt04_type,  "CHANGE MODE
26         clsd TYPE wctp3_txt04_type,  "CLOSED
27         rejc TYPE wctp3_txt04_type,  "REJECTED
28         dlfl TYPE wctp3_txt04_type,  "DELETED
29         inak TYPE wctp3_txt04_type,  "INACTIVE
30         tent TYPE wctp3_txt04_type,  "TEMPORARY ENTRY
31         unt  TYPE wctp3_txt04_type,  "UNTAGGABLE
32         test TYPE wctp3_txt04_type,  "TEST CYCLE
33         proc TYPE wctp3_txt04_type,  "PROCESSING
34         conf TYPE wctp3_txt04_type,  "CONFLICT
35         itg  TYPE wctp3_txt04_type,  "INITIAL
36         btg  TYPE wctp3_txt04_type,  "TO BE TAGGED
37         ptag TYPE wctp3_txt04_type,  "TAG PRINTED
38         etg  TYPE wctp3_txt04_type,  "TAGGED
39         btug TYPE wctp3_txt04_type,  "TO BE TEMPORARY UNTAGGED
40         ptst TYPE wctp3_txt04_type,  "TEST TAG PRINTED
41         etug TYPE wctp3_txt04_type,  "TEMPORARY UNTAGGED
42         bug  TYPE wctp3_txt04_type,  "TO BE UNTAGGED
43         eug  TYPE wctp3_txt04_type,  "UNTAGGED
44         post TYPE wctp3_txt04_type,  "POSTSCRIPT
45         prot TYPE wctp3_txt04_type,  "OPERATIONAL PROTECTION
46         pwp  TYPE wctp3_txt04_type,  "WORK PERMIT PRINTED
47         wpho TYPE wctp3_txt04_type,  "WORK PERMIT HANDED OUT
48         mobi TYPE wctp3_txt04_type,  "DATA ON MOBILE DEVICE
49       END   OF wctp3_stattxt04_type.
50     * LONG TEXTs OF STATUS
51     TYPES:
52       BEGIN OF wctp3_stattxt30_type,
53         crea TYPE wctp3_txt30_type,  "CREATED
54         prep TYPE wctp3_txt30_type,  "PREPARED
55         hprp TYPE wctp3_txt30_type,  "CHANGE MODE
56         clsd TYPE wctp3_txt30_type,  "CLOSED
57         rejc TYPE wctp3_txt30_type,  "REJECTED
58         dlfl TYPE wctp3_txt30_type,  "DELETED
59         inak TYPE wctp3_txt30_type,  "INACTIVE
60         tent TYPE wctp3_txt30_type,  "TEMPORARY ENTRY
61         unt  TYPE wctp3_txt30_type,  "UNTAGGABLE
62         test TYPE wctp3_txt30_type,  "TEST CYCLE
63         proc TYPE wctp3_txt30_type,  "PROCESSING
64         conf TYPE wctp3_txt30_type,  "CONFLICT
65         itg  TYPE wctp3_txt30_type,  "INITIAL
66         btg  TYPE wctp3_txt30_type,  "TO BE TAGGED
67         ptag TYPE wctp3_txt30_type,  "TAG PRINTED
68         etg  TYPE wctp3_txt30_type,  "TAGGED
69         btug TYPE wctp3_txt30_type,  "TO BE TEMPORARY UNTAGGED
70         ptst TYPE wctp3_txt30_type,  "TEST TAG PRINTED
71         etug TYPE wctp3_txt30_type,  "TEMPORARY UNTAGGED
72         bug  TYPE wctp3_txt30_type,  "TO BE UNTAGGED
73         eug  TYPE wctp3_txt30_type,  "UNTAGGED
74         post TYPE wctp3_txt30_type,  "POSTSCRIPT
75         prot TYPE wctp3_txt30_type,  "OPERATIONAL PROTECTION
76         pwp  TYPE wctp3_txt30_type,  "WORK PERMIT PRINTED
77         wpho TYPE wctp3_txt30_type,  "WORK PERMIT HANDED OUT
78         mobi TYPE wctp3_txt30_type,  "DATA ON MOBILE DEVICE
79       END   OF wctp3_stattxt30_type.
80     * STATUS COUNTERs
81     TYPES:
82       BEGIN OF wctp3_statcnt_type,
83         conf TYPE wctp3_cnt_type,    "CONFLICT
84         itg  TYPE wctp3_cnt_type,    "INITIAL
85         btg  TYPE wctp3_cnt_type,    "TO BE TAGGED
86         ptag TYPE wctp3_cnt_type,    "TAG PRINTED
87         etg  TYPE wctp3_cnt_type,    "TAGGED
88         btug TYPE wctp3_cnt_type,    "TO BE TEMPORARY UNTAGGED
89         ptst TYPE wctp3_cnt_type,    "TEST TAG PRINTED
90         etug TYPE wctp3_cnt_type,    "TEMPORARY UNTAGGED
91         bug  TYPE wctp3_cnt_type,    "TO BE UNTAGGED
92         eug  TYPE wctp3_cnt_type,    "UNTAGGED
93         mobi TYPE wctp3_cnt_type,    "DATA ON MOBILE DEVICE
94         prot TYPE wctp3_cnt_type,    "OPERATIONAL PROTECTION
95         post TYPE wctp3_cnt_type,    "POSTSCRIPT
96         inak TYPE wctp3_cnt_type,    "INACTIVE
97         sum  TYPE wctp3_cnt_type,    "TOTAL
98       END   OF wctp3_statcnt_type.
99     * LOG
100    TYPES:
101      BEGIN OF wctp3_log_type,
102        date TYPE sydatum,           "date
103        time TYPE syuzeit,           "time
104        BEGIN OF wcmobj,
105          BEGIN OF status,
106            start TYPE wcsstatflg,   "indicator for status (before)
107            end   TYPE wcsstatflg,   "indicator for status (after)
108          END   OF status,
109          BEGIN OF tlcnt,
110            start TYPE i,            "approval status (before)
111            end   TYPE i,            "approval status (after)
112          END   OF tlcnt,
113        END OF wcmobj,
114        BEGIN OF order,
115          BEGIN OF status,
116            start TYPE iwcsorderflg, "indicator for status (before)
117            end   TYPE iwcsorderflg, "indicator for status (after)
118          END   OF status,
119        END   OF order,
120      END   OF wctp3_log_type.
121    * OBJECT KEYs (work area)
122    TYPES:
123      BEGIN OF wctp3_objkeywa_type,
124        objkey TYPE wceno, "object key
125      END   OF wctp3_objkeywa_type.
126    * OBJECT NUMBERs (work area)
127    TYPES: wctp3_objwa_type TYPE wcm_objwa_type.
128    * STATUS (work area)
129    TYPES:
130      BEGIN OF wctp3_statwa_type,
131        status TYPE wctp3_status_type, "system status
132      END   OF wctp3_statwa_type.
133    TYPES: wctp3_statuswa_type TYPE jest.
134    * TEXTs OF ... STATUS (work area)
135    * - SYSTEM
136    TYPES: wctp3_tj02twa_type TYPE tj02t.
137    * - USER
138    TYPES: wctp3_tj30twa_type TYPE tj30t.
139    * - USER INCL. STATUS ATTRIBUTES
140    TYPES:
141      BEGIN OF wctp3_usrstatattrwa_type.
142        INCLUDE TYPE v_tj30 AS v_tj30.
143    TYPES:
144        spras TYPE spras,
145      END   OF wctp3_usrstatattrwa_type.
146    * MULTI-OBJECT STATUS INDICATORs (work area)
147    TYPES:
148      BEGIN OF wctp3_statusflgwa_type,
149        objnr TYPE wctp3_objnr_type,
150        sysst TYPE wcsstatflg,
151      END   OF wctp3_statusflgwa_type.
152    * MULTI-OBJECT ACTIVE USER STATUS (work area)
153    TYPES:
154      BEGIN OF wctp3_usrstatwa_type,
155        objnr TYPE wctp3_objnr_type,
156        stsma TYPE j_stsma,
157        sttab TYPE wctusrst, "sorted by ESTAT
158      END   OF wctp3_usrstatwa_type.
159    * MULTI-ITEM STATUS INDICATORs (work area)
160    TYPES:
161      BEGIN OF wctp3_itmstatflgwa_type,
162        objnr TYPE wctp3_objnr_type,
163        sysst TYPE wcsitmflg,
164      END   OF wctp3_itmstatflgwa_type.
165    * MULTI-OBJECT ITEM STATUS INDICATORs (work area)
166    TYPES:
167      BEGIN OF wctp3_item_statusflgwa_type,
168        objnr      TYPE wctp3_objnr_type,
169        itmstattab TYPE wctp3_itmstatflgtab_type,
170      END   OF wctp3_item_statusflgwa_type.
171    * BUSINESS TRANSACTIONs (work area)
172    TYPES:
173      BEGIN OF wctp3_vrgngwa_type,
174        objnr TYPE wctp3_objnr_type,  "object number (WCD item)
175        from  TYPE wctp3_status_type, "current system status
176        to    TYPE wctp3_status_type, "planned system status
177        vrgng TYPE wctp3_vrgng_type,  "business transaction
178        exec  TYPE wctp3_exec_type,   "execution type {undefined,user,system,exception}
179      END   OF wctp3_vrgngwa_type.
180    * STATUS COUNTERs (work area)
181    TYPES:
182      BEGIN OF wctp3_statcntwa_type,
183        optyp TYPE wceoptyp,           "aim of switching {tagging,untagging,undefined}
184        step  TYPE wceactstep,         "step
185        objnr TYPE wctp3_objnr_type,   "object number
186        cnt   TYPE wctp3_statcnt_type, "counter
187      END   OF wctp3_statcntwa_type.
188    * FILTER (work area)
189    TYPES:
190      BEGIN OF wctp3_filterwa_type,
191        objart TYPE wceobjart,         "object type
192        objtyp TYPE wcetyp,            "subobject type
193        cnt    TYPE i,                 "number of entries
194        objtab TYPE wctp3_objtab_type, "table of object numbers
195      END  OF wctp3_filterwa_type.
196    * ASSIGNMENTs (work area)
197    TYPES:
198      BEGIN OF wctp3_lnkwa_type,
199        or TYPE wctp3_objnr_type, "order (object number)
200        ww TYPE wctp3_objnr_type, "WAP   (object number)
201        wa TYPE wctp3_objnr_type, "WAPI  (object number)
202        wd TYPE wctp3_objnr_type, "WCD   (object number)
203      END  OF wctp3_lnkwa_type.
204
205    * tables types *********************************************************
206    * OBJECT KEYs
207    TYPES: wctp3_objkeytab_type TYPE STANDARD TABLE OF wctp3_objkeywa_type WITH DEFAULT KEY.
208    * OBJECT NUMBERs
209    TYPES: wctp3_objtab_type TYPE STANDARD TABLE OF wctp3_objwa_type WITH DEFAULT KEY.
210    * STATUS
211    TYPES: wctp3_stattab_type   TYPE STANDARD TABLE OF wctp3_statwa_type   WITH DEFAULT KEY.
212    TYPES: wctp3_statustab_type TYPE STANDARD TABLE OF wctp3_statuswa_type WITH DEFAULT KEY.
213    * TEXTs FOR ... STATUS
214    * - SYSTEM
215    TYPES: wctp3_tj02ttab_type TYPE STANDARD TABLE OF wctp3_tj02twa_type WITH DEFAULT KEY.
216    * - USER
217    TYPES: wctp3_tj30ttab_type TYPE STANDARD TABLE OF wctp3_tj30twa_type WITH DEFAULT KEY.
218    * - USER INCL. STATUS ATTRIBUTES (sorted by logical status order number + 4-letter status code)
219    TYPES: wctp3_usrstatattrtab_type TYPE SORTED TABLE OF wctp3_usrstatattrwa_type WITH UNIQUE KEY stsma stonr txt04.
220    * MULTI-OBJECT STATUS INDICATORs
221    TYPES: wctp3_statusflgtab_type TYPE STANDARD TABLE OF wctp3_statusflgwa_type WITH DEFAULT KEY.
222    * MULTI-OBJECT ACTIVE USER STATUS
223    TYPES: wctp3_usrstattab_type TYPE STANDARD TABLE OF wctp3_usrstatwa_type WITH DEFAULT KEY.
224    * MULTI-ITEM STATUS INDICATORs
225    TYPES: wctp3_itmstatflgtab_type TYPE STANDARD TABLE OF wctp3_itmstatflgwa_type WITH DEFAULT KEY.
226    * MULTI-OBJECT ITEM STATUS INDICATORs
227    TYPES: wctp3_item_statusflgtab_type TYPE STANDARD TABLE OF wctp3_item_statusflgwa_type WITH DEFAULT KEY.
228    * BUSINESS TRANSACTIONs
229    TYPES: wctp3_vrgngtab_type TYPE STANDARD TABLE OF wctp3_vrgngwa_type WITH DEFAULT KEY.
230    * STATUS COUNTERs
231    TYPES: wctp3_statcnttab_type TYPE STANDARD TABLE OF wctp3_statcntwa_type WITH DEFAULT KEY.
232    * FILTER (e.g multilevel list)
233    TYPES: wctp3_filtertab_type TYPE STANDARD TABLE OF wctp3_filterwa_type WITH DEFAULT KEY.
234    * ASSIGNMENTS
235    TYPES: wctp3_lnktab_type TYPE STANDARD TABLE OF wctp3_lnkwa_type WITH DEFAULT KEY.
236
237    * constants ************************************************************
238    * OBJECT TYPES
239    CONSTANTS:
240      BEGIN OF wctp3_obtyp,
241        order  TYPE wctp3_obtyp_type VALUE 'ORI',
242        wap    TYPE wctp3_obtyp_type VALUE 'WWI',
243        wapi   TYPE wctp3_obtyp_type VALUE 'WAI',
244        wcdoc  TYPE wctp3_obtyp_type VALUE 'WDI',
245        wcitm  TYPE wctp3_obtyp_type VALUE 'WII',
246        step   TYPE wctp3_obtyp_type VALUE 'WRI',
247        lineup TYPE wctp3_obtyp_type VALUE 'WVI',
248        verlst TYPE wctp3_obtyp_type VALUE 'WLI',
249      END   OF wctp3_obtyp.
250    *                                      |ORDER|WAP|WAPI|HEADER|ITEM
251    * -------------------------------------+-----+---+----+------+-----
252    *  TECHNICALLY COMPLETED    |TECO|I0045|  X  |   |    |      |
253    *  CLOSED                   |CLSD|I0046|     | X | X  |  X   |
254    *  DELETE                   |DLFL|I0076|     | X | X  |  X   |
255    *  CREATED                  |CRTE|I0098|     | X | X  |  X   |
256    *  PREPARED                 |PREP|I0175|     | X | X  |  X   |
257    *  REJECTED                 |REJC|I0176|     | X | X  |  X   |
258    *  INACTIVE                 |INAC|I0320|     | X | X  |  X   |  X
259    *  INITIAL TAGGING STATUS   |ITG |I0403|     |   |    |  X   |  X
260    *  TAG                      |BTG |I0404|     |   |    |  X   |  X
261    *  TAG PRINTED              |PTAG|I0405|     |   |    |  X   |  X
262    *  TAGGED                   |ETG |I0406|     |   |    |  X   |  X
263    *  UNTAG                    |BUG |I0407|     |   |    |  X   |  X
264    *  UNTAGGED                 |EUG |I0408|     |   |    |  X   |  X
265    *  UNTAG TEMPORARILY        |BTUG|I0409|     |   |    |  X   |  X
266    *  TEMPORARILY UNTAGGED     |ETUG|I0410|     |   |    |  X   |  X
267    *  CONFLICT                 |CONF|I0417|     |   |    |  X   |  X
268    *  WORK CLEARANCE MANAGEMENT|WCM |I0419|  X  |   |    |      |
269    *  UNTAGGABLE               |UNT |I0424|     |   |    |  X   |
270    *  WORK IN EXECUTION        |EXEC|I0425|  X  |   |    |      |
271    *  WORK COMPLETED           |WOCO|I0426|  X  |   |    |      |
272    *  PROCESSING               |PROC|I0427|     |   |    |  X   |
273    *  TEMPORARY ENTRY          |TENT|I0428|     |   | X  |      |
274    *  TEST CYCLE               |TEST|I0429|     |   |    |  X   |
275    *  BLOCK TECHNICAL COMPLETE |BLTC|I0430|  X  |   |    |      |
276    *  TEST TAG PRINTED         |PTST|I0431|     |   |    |  X   |  X
277    *  CHANGE MODE              |CHNG|I0445|     | X | X  |  X   |
278    *  POSTSCRIPT               |POST|I0446|     |   |    |      |  X
279    *  OPERATIONAL PROTECTION   |PROT|I0610|     |   |    |      |  X
280    *  WORK PERMIT PRINTED      |PWP |I0611|     | X | X  |  X   |
281    *  Work PERMIT HANDED OUT   |WPHO|I0642|     |   | X  |      |
282    *  DATA ON MOBILE DEVICE    |MOBI|I0630|     |   | X  |  X   |  X
283    CONSTANTS:
284      BEGIN OF wctp3_status,
285        closed                 TYPE wctp3_status_type VALUE 'I0046',
286        delete                 TYPE wctp3_status_type VALUE 'I0076',
287        create                 TYPE wctp3_status_type VALUE 'I0098',
288        prepared               TYPE wctp3_status_type VALUE 'I0175',
289        rejected               TYPE wctp3_status_type VALUE 'I0176',
290        inactive               TYPE wctp3_status_type VALUE 'I0320',
291        initial                TYPE wctp3_status_type VALUE 'I0403',
292        to_be_tagged           TYPE wctp3_status_type VALUE 'I0404',
293        tag_printed            TYPE wctp3_status_type VALUE 'I0405',
294        tagged                 TYPE wctp3_status_type VALUE 'I0406',
295        to_be_untagged         TYPE wctp3_status_type VALUE 'I0407',
296        untagged               TYPE wctp3_status_type VALUE 'I0408',
297        to_be_temp_untagged    TYPE wctp3_status_type VALUE 'I0409',
298        temp_untagged          TYPE wctp3_status_type VALUE 'I0410',
299        conflict               TYPE wctp3_status_type VALUE 'I0417',
300        untaggable             TYPE wctp3_status_type VALUE 'I0424',
301        processing             TYPE wctp3_status_type VALUE 'I0427',
302        temp_entry             TYPE wctp3_status_type VALUE 'I0428',
303        test                   TYPE wctp3_status_type VALUE 'I0429',
304        test_tag_printed       TYPE wctp3_status_type VALUE 'I0431',
305        prepared_reset         TYPE wctp3_status_type VALUE 'I0445',
306        postscript             TYPE wctp3_status_type VALUE 'I0446',
307        operational_protection TYPE wctp3_status_type VALUE 'I0610',
308        permit_printed         TYPE wctp3_status_type VALUE 'I0611',
309        permit_handed_out      TYPE wctp3_status_type VALUE 'I0642',
310        mobile_device          TYPE wctp3_status_type VALUE 'I0630',
311      END   OF wctp3_status.
312    * BUSINESS TRANSACTIONs
313    CONSTANTS:
314      BEGIN OF wctp3_vrgng,
315        delflg_set          TYPE wctp3_vrgng_type VALUE 'LVMS', "Mark for deletion
316        delflg_reset        TYPE wctp3_vrgng_type VALUE 'LVMZ', "Remove deletion flag
317        closed              TYPE wctp3_vrgng_type VALUE 'BABS', "Complete
318        active              TYPE wctp3_vrgng_type VALUE 'INAZ', "Reset object inactive
319        inactive            TYPE wctp3_vrgng_type VALUE 'INAK', "Set object inactive
320        untaggable_set      TYPE wctp3_vrgng_type VALUE 'WCME', "Untaggable
321        untaggable_reset    TYPE wctp3_vrgng_type VALUE 'WCMF', "Reset untaggable
322        processing_set      TYPE wctp3_vrgng_type VALUE 'WCMH', "Processing
323        processing_reset    TYPE wctp3_vrgng_type VALUE 'WCMI', "Reset in processing
324        temp_entry_set      TYPE wctp3_vrgng_type VALUE 'WCML', "Test phase
325        temp_entry_reset    TYPE wctp3_vrgng_type VALUE 'WCMM', "Test phase ended
326        test_set            TYPE wctp3_vrgng_type VALUE 'WCMO', "Test phase
327        test_reset          TYPE wctp3_vrgng_type VALUE 'WCMP', "Test phase ended
328        prepared            TYPE wctp3_vrgng_type VALUE 'WCM0', "Prepared
329        prepared_reset      TYPE wctp3_vrgng_type VALUE 'WCMN', "Reset prepared
330        rejected            TYPE wctp3_vrgng_type VALUE 'WCM1', "Rejected
331        clear               TYPE wctp3_vrgng_type VALUE 'WCMB', "Initialize process
332        initial             TYPE wctp3_vrgng_type VALUE 'WCM2', "Initial status
333        to_be_tagged        TYPE wctp3_vrgng_type VALUE 'WCM3', "Tag
334        tag_printed         TYPE wctp3_vrgng_type VALUE 'WCM4', "Tag printed
335        tagged              TYPE wctp3_vrgng_type VALUE 'WCM5', "Tagged
336        to_be_untagged      TYPE wctp3_vrgng_type VALUE 'WCM6', "Untag
337        untagged            TYPE wctp3_vrgng_type VALUE 'WCM7', "Untagged
338        to_be_temp_untagged TYPE wctp3_vrgng_type VALUE 'WCM8', "Untag temporarily
339        test_tag_printed    TYPE wctp3_vrgng_type VALUE 'WCMQ', "Test tag printed
340        temp_untagged       TYPE wctp3_vrgng_type VALUE 'WCM9', "Temporarily untagged
341        conflict_set        TYPE wctp3_vrgng_type VALUE 'WCMA', "Conflict
342        conflict_reset      TYPE wctp3_vrgng_type VALUE 'WCMD', "Reset conflict
343        pa_set              TYPE wctp3_vrgng_type VALUE 'WCMR', "Set operational protection
344        pa_reset            TYPE wctp3_vrgng_type VALUE 'WCMS', "Revoke operational protection
345        permit_printed      TYPE wctp3_vrgng_type VALUE 'WCMT', "Work permit printed
346        hand_out_permit     TYPE wctp3_vrgng_type VALUE 'WCMY', "Hand out work permit
347        return_permit       TYPE wctp3_vrgng_type VALUE 'WCMZ', "Return work permit
348        mobile_device_set   TYPE wctp3_vrgng_type VALUE 'DMGS', "Send data to mobile device
349        mobile_device_reset TYPE wctp3_vrgng_type VALUE 'DMGR', "Data from mobile device
350      END   OF wctp3_vrgng.
351    * EXECUTION TYPEs
352    CONSTANTS:
353      BEGIN OF wctp3_exec,
354        undefined TYPE wctp3_exec_type VALUE 'U/S',
355        user      TYPE wctp3_exec_type VALUE 'U',
356        system    TYPE wctp3_exec_type VALUE 'S',
357        exception TYPE wctp3_exec_type VALUE 'E',
358      END   OF wctp3_exec.
*--- End of %_CWCTP3 - 358 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTPC                                  Level 1    Page 6
Object           ZRIWFWA01                                 Lines 1098
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTPC
3      *-----------------------------------------------------------------------
4      *  Purpose: interfaces
5      ************************************************************************
6      TYPE-POOL wctpc.
7
8      * elementary types *****************************************************
9      TYPES: wctpc_memory_id_type      TYPE wcememid.
10     TYPES: wctpc_prefix_type         TYPE char3.
11     TYPES: wctpc_suffix_type         TYPE char3.
12     TYPES: wctpc_objnr_type          TYPE j_objnr.
13     TYPES: wctpc_action_type         TYPE char1.
14     TYPES: wctpc_single_hit_type     TYPE char1.
15     TYPES: wctpc_process_type        TYPE char1.
16     TYPES: wctpc_interface_type      TYPE wceif.
17     TYPES: wctpc_cnt_type            TYPE i.
18     TYPES: wctpc_cmp_display_type    TYPE wcedisplay.
19     TYPES: wctpc_cmp_filter_type     TYPE wcefilter.
20     TYPES: wctpc_cmp_with_type       TYPE char3.
21     TYPES: wctpc_text_type           TYPE itex132.
22     TYPES: wctpc_sign_type           TYPE char1.
23     TYPES: wctpc_option_type         TYPE char2.
24     TYPES: wctpc_clipboard_task_type TYPE i.
25     TYPES: wctpc_approval_state_type TYPE char1.
26     TYPES: wctpc_position_type       TYPE char1.
27
28     * structures types *****************************************************
29     * DYNAMIC MEMORY ID
30     TYPES:
31       BEGIN OF wctpc_id_type,
32         name(7) TYPE c,
33         cnt(1)  TYPE n,
34       END  OF wctpc_id_type.
35     * TECHNICAL OBJECTs (work area)
36     TYPES:
37       BEGIN OF wctpc_ccobjwa_type,
38         iwerk TYPE iwerk,
39         ccobj TYPE wceccobj,
40         cctyp TYPE wcecctyp,
41         stxt  TYPE wcestxt,
42         objnr TYPE j_objnr,
43       END OF  wctpc_ccobjwa_type.
44     TYPES:
45     * KEY FIELDS OF TAGGED OBJECTs
46       BEGIN OF wctpc_tgkey_type,
47         ccobj TYPE wceccobj,
48         cctyp TYPE wcecctyp,
49         tggrp TYPE wcetggrp,
50       END OF  wctpc_tgkey_type.
51     * TAGGED OBJECTS (work area)
52     TYPES:
53       BEGIN OF wctpc_tgobjwa_type.
54         INCLUDE TYPE wctpc_tgkey_type AS tgkey.
55     TYPES:
56       wcnr TYPE wcewcnr.
57       INCLUDE TYPE wcsadm AS wcsadm.
58     TYPES:
59       END OF  wctpc_tgobjwa_type.
60     * OPERATIONAL CLASSEs (work area)
61     TYPES:
62       BEGIN OF wctpc_classwa_type,
63         button TYPE wceflg,
64         iwerk  TYPE iwerk.
65         INCLUDE TYPE wcsalv09 AS wcsalv09.
66     TYPES:
67       END   OF wctpc_classwa_type.
68     * DOCUMENTs (work area)
69     TYPES:
70       BEGIN OF wctpc_docwa_type,
71         dokob TYPE dokob,
72         objky TYPE objky,
73       END  OF wctpc_docwa_type.
74     * MEMORY STACK (work area) - WORK FLOW
75     TYPES: wctpc_memwa_type TYPE wcswfmem.
76     * MESSAGE TYPEs (work area)
77     TYPES:
78       BEGIN OF wctpc_msgwa_type,
79         button TYPE wceflg.
80         INCLUDE TYPE wcsalv11 AS wcsalv11.
81     TYPES:
82       END   OF wctpc_msgwa_type.
83     * APPROVALs (work area)
84     TYPES:
85       BEGIN OF wctpc_permitwa_type.
86         INCLUDE TYPE wcspermit AS wcspermit.
87     TYPES:
88       objnr TYPE wctpc_objnr_type,
89       END   OF wctpc_permitwa_type.
90     TYPES:
91       BEGIN OF wctpc_pmsogwa_type,
92         pmsog TYPE pmsog,
93       END   OF wctpc_pmsogwa_type.
94     TYPES:
95       BEGIN OF wctpc_grantedwa_type,
96         objnr   TYPE j_objnr,
97         counter TYPE i_count,
98         granted TYPE wceflg,
99       END   OF wctpc_grantedwa_type.
100    * OPERATIONAL CONDITION/TYPEs (work area)
101    TYPES:
102      BEGIN OF wctpc_tagwa_type,
103        button TYPE wceflg.
104        INCLUDE TYPE wcsalv10 AS wcsalv10.
105    TYPES:
106      END   OF wctpc_tagwa_type.
107    * SUBTYPEs (work area)
108    TYPES:
109      BEGIN OF wctpc_typewa_type,
110        button TYPE wceflg,
111        iwerk  TYPE iwerk,
112        objart TYPE wceobjart,
113        objtyp TYPE wcetyp,
114        hide   TYPE wceboolean.
115        INCLUDE TYPE wcsalv07 AS wcsalv07.
116    TYPES:
117      END   OF wctpc_typewa_type.
118    * WCM OBJECTs ON BASIS OF THE USE (work area)
119    TYPES:
120      BEGIN OF wctpc_usewa_type,
121        button TYPE wceflg,
122        iwerk  TYPE iwerk.
123        INCLUDE TYPE wcsalv47 AS wcsalv47.
124    TYPES:
125      END   OF wctpc_usewa_type.
126    * WAPI (work area)
127    TYPES:
128      BEGIN OF wctpc_wapiwa_type,
129        objtyp2  TYPE wcetyp,
130        objflg   TYPE wceflg,
131        lnkcnt   TYPE wceobjcnt,
132        reftcode TYPE wcereftcode,
133        seltcode TYPE wcesetcode,
134        stxt     TYPE wcestxt,
135        ptxt     TYPE wceptxt,
136      END   OF wctpc_wapiwa_type.
137    * CONTROL TABLE FOR WCDs (work area)
138    TYPES:
139      BEGIN OF wctpc_wcdctrlwa_type,
140        wcnr    TYPE wcewcnr,
141        objtyp  TYPE wcetyp,
142        pred    TYPE wctpc_cnt_type,
143        succ    TYPE wctpc_cnt_type,
144        process TYPE wctpc_process_type,
145        BEGIN OF cmp,
146          display   TYPE wctpc_cmp_display_type,
147          with      TYPE wctpc_cmp_with_type,
148          clipboard TYPE wceboolean,
149        END   OF cmp,
150      END   OF wctpc_wcdctrlwa_type.
151    * WCD (work area)
152    TYPES:
153      BEGIN OF wctpc_wcdwa_type,
154        wcnr TYPE wcewcnr,
155      END   OF wctpc_wcdwa_type.
156    TYPES:
157      BEGIN OF wctpc_wcdcntwa_type,
158        wcnr TYPE wcewcnr,
159        cnt  TYPE wctpc_cnt_type,
160      END   OF wctpc_wcdcntwa_type.
161    * OPERATIONAL CONDITIONs (work area)
162    TYPES:
163      BEGIN OF wctpc_wccaxwa_type,
164        iwerk   TYPE iwerk,
165        tggrp   TYPE wcetggrp,
166        tgproc  TYPE wcetgproc,
167        tggrpx  TYPE wcestxt,
168        tgprocx TYPE wcestxt,
169      END OF  wctpc_wccaxwa_type.
170    * OPERATIONAL STEPs (work area)
171    TYPES:
172      BEGIN OF wctpc_tgunstepwa_type,
173        tgstep TYPE wceunstep,
174        unstep TYPE wceunstep,
175      END   OF wctpc_tgunstepwa_type.
176    * TAGGING STEPs (work area)
177    TYPES:
178      BEGIN OF wctpc_tgstepwa_type,
179        tgstep TYPE wcetgstep,
180      END   OF wctpc_tgstepwa_type.
181    * UNTAGGING STEPs (work area)
182    TYPES:
183      BEGIN OF wctpc_unstepwa_type,
184        unstep TYPE wceunstep,
185      END   OF wctpc_unstepwa_type.
186    * WCM TEMPLATEs (work area)
187    TYPES:
188      BEGIN OF wctpc_tmplwa_type,
189        iwerk   TYPE iwerk,
190        objart  TYPE wceobjart,
191        objtyp  TYPE wcetyp,
192        text    TYPE wcestxt,
193        objkey  TYPE wceno,
194        objnr   TYPE wctpc_objnr_type,
195        stxt    TYPE wcestxt,
196        ccobj   TYPE wceccobj,
197        cctyp   TYPE wcecctyp,
198        dptcode TYPE wcedptcode,
199      END   OF wctpc_tmplwa_type.
200    * WCM OBJECTs (work area)
201    TYPES: wctpc_wcmwa_type TYPE wcswcm.
202    TYPES:
203      BEGIN OF wctpc_wcmflgwa_type.
204        INCLUDE TYPE wcswcm AS wcswcm.
205    TYPES:
206      flg TYPE wceflg,
207      END   OF wctpc_wcmflgwa_type.
208    TYPES:
209      BEGIN OF wctpc_wcmobjwa_type,
210        objkey TYPE wceno,
211        objnr  TYPE wctpc_objnr_type,
212        objart TYPE wceobjart,
213        objtyp TYPE wcetyp,
214      END   OF wctpc_wcmobjwa_type.
215    TYPES:
216      BEGIN OF wctpc_wcmpermwa_type,
217        objnr TYPE wctpc_objnr_type,
218        pmsog TYPE pmsog,
219        flg   TYPE wceflg,
220      END   OF wctpc_wcmpermwa_type.
221    * LINEUPs (work area)
222    TYPES:
223      BEGIN OF wctpc_lineupwa_type,
224        lunr  TYPE wcelunr,
225        vernr TYPE wcevernr,
226        objnr TYPE wctpc_objnr_type,
227        lutyp TYPE wcelutyp,
228      END   OF wctpc_lineupwa_type.
229    * OPERATIONAL LISTs (work area)
230    TYPES:
231      BEGIN OF wctpc_oplstwa_type,
232        wcnr  TYPE wcewcnr,
233        lstid TYPE wcelstid,
234        wcitm TYPE wceitm,
235        objnr TYPE wctpc_objnr_type,
236      END   OF wctpc_oplstwa_type.
237    * CONFIRMATION OF OPERATIONAL LISTs (work area)
238    TYPES: wctpc_oplst_confirmwa_type TYPE wcs_mwcm_1_confirmation.
239    * CONFIRMATION OF WORK PERMITs (work area)
240    TYPES: wctpc_wkpt_confirmwa_type TYPE wcs_mwcm_1_response.
241    * WCM INTERFACEs (work area)
242    TYPES:
243      BEGIN OF wctpc_wcmifwa_type,
244        objnr      TYPE wctpc_objnr_type,
245        wapnr      TYPE wcewapnr,
246        wapinr     TYPE wcewapinr,
247        wcnr       TYPE wcewcnr,
248        rejcflg    TYPE wceflg,
249        requalflg  TYPE wceflg,
250        lflg       TYPE wceflg,
251        untgflg    TYPE wceflg,
252        tgflg      TYPE wceflg,
253        remarkflg1 TYPE wceflg,
254        remarkflg2 TYPE wceflg,
255        catflg1    TYPE wceflg,
256        catflg2    TYPE wceflg,
257        lnkflg     TYPE wceflg,
258        docflg     TYPE wceflg,
259      END   OF wctpc_wcmifwa_type.
260    * TRANSPORT ENTRIEs (work area)
261    TYPES:
262      BEGIN OF wctpc_trawa_type,
263        objname TYPE tabname,
264        tabkey  TYPE trobj_name,
265      END   OF wctpc_trawa_type.
266    * VAL STATISIC (work area)
267    TYPES:
268      BEGIN OF wctpc_valcntwa_type,
269        objtyp     TYPE wcetyp,
270        unvaluated TYPE wctpc_cnt_type,
271        valuated   TYPE wctpc_cnt_type,
272        yes        TYPE wctpc_cnt_type,
273        no         TYPE wctpc_cnt_type,
274      END   OF wctpc_valcntwa_type.
275    * FILTER DIALOG (work area)
276    TYPES:
277      BEGIN OF wctpc_fltrdlgwa_type,
278        objart TYPE wceobjart,
279        objtyp TYPE wcetyp,
280        ptxt   TYPE wceptxt,
281        color  TYPE i,
282        active TYPE wceboolean,
283        BEGIN OF input,
284          create  TYPE wceboolean,
285          refresh TYPE wceboolean,
286          delete  TYPE wceboolean,
287        END   OF input,
288        BEGIN OF selflg,
289          create  TYPE wceflg,
290          refresh TYPE wceflg,
291          delete  TYPE wceflg,
292        END   OF selflg,
293      END   OF wctpc_fltrdlgwa_type.
294    * ALV FOR TECHNICAL OBJECT (work area)
295    TYPES: wctpc_rihiflowa_type TYPE rihiflo.
296    TYPES: wctpc_rihequiwa_type TYPE rihequi.
297    TYPES: wctpc_rihiflo_listwa_type TYPE rihiflo_list.
298    TYPES: wctpc_rihequi_listwa_type TYPE rihequi_list.
299    * ALV FOR NETWORK (work area)
300    TYPES: wctpc_rihinetwa_type TYPE rihinet.
301    * NAMETAB (work area)
302    TYPES: wctpc_x031lwa_type TYPE x031l.
303    * DIALOG TEXT DISPLAY PARAMETERs/VALUEs (work area)
304    TYPES: wctpc_sparwa_type TYPE spar.
305    * INDEX TABLE (work area)
306    TYPES:
307      BEGIN OF wctpc_indexwa_type,
308        index TYPE wctpc_cnt_type,
309      END   OF wctpc_indexwa_type.
310    * MAPPING TABLE (work area)
311    TYPES:
312      BEGIN OF wctpc_mapwa_type,
313        index1 TYPE wctpc_cnt_type,
314        index2 TYPE wctpc_cnt_type,
315      END   OF wctpc_mapwa_type.
316    * OPERATIONAL CHECKS
317    * - HEADER (work area)
318    TYPES:
319      BEGIN OF wctpc_d5xxx_headerwa_type,
320        link TYPE wctp1_cnt_type. "HEADER <-> BODY
321        INCLUDE TYPE wcsalv19 AS wcsalv19.
322    TYPES:
323      END   OF wctpc_d5xxx_headerwa_type.
324    * - BODY TIME FRAME CHECK (work area)
325    TYPES:
326      BEGIN OF wctpc_d5100_body0wa_type,
327        link   TYPE wctp1_cnt_type,        "HEADER <-> BODY
328        coltab TYPE slis_t_specialcol_alv. "colors
329        INCLUDE TYPE wcsalv17 AS wcsalv17.
330    TYPES:
331      END   OF wctpc_d5100_body0wa_type.
332    * - BODY EXTERNAL CONFLICT VERIFICATION (work area)
333    TYPES:
334      BEGIN OF wctpc_d5100_body1wa_type,
335        link   TYPE wctp1_cnt_type,        "HEADER <-> BODY
336        msgtyp TYPE wctpm_msgtyp_type,     "message type
337        sfield TYPE wctp1_cnt_type,        "sort field
338        coltab TYPE slis_t_specialcol_alv. "colors
339        INCLUDE TYPE wcsalv17 AS wcsalv17.
340    TYPES:
341      END   OF wctpc_d5100_body1wa_type.
342    * - BODY INTERNAL CONFLICT VERIFICATION (work area)
343    TYPES:
344      BEGIN OF wctpc_d5200_body2wa_type,
345        link    TYPE wctp1_cnt_type,        "HEADER <-> BODY
346        msgtyp  TYPE wctpm_msgtyp_type,     "message type
347        objnr   TYPE wctp1_objnr_type,      "obect number
348        tgcolor TYPE wctp1_color_type,      "color for tagging data
349        uncolor TYPE wctp1_color_type,      "color for untagging data
350        coltab  TYPE slis_t_specialcol_alv. "colors
351        INCLUDE TYPE wcsalv19 AS wcsalv19.
352    TYPES:
353      END   OF wctpc_d5200_body2wa_type.
354    * - BODY REFERENCE OBJECT CHECK (work area)
355    TYPES:
356      BEGIN OF wctpc_d5100_body3wa_type,
357        link    TYPE wctp1_cnt_type.       "HEADER <-> BODY
358        INCLUDE TYPE wcsalv20 AS wcsalv20.
359    TYPES:
360      END   OF wctpc_d5100_body3wa_type.
361    * WCM COUNTERs
362    TYPES:
363      BEGIN OF wctpc_wcmcnt_type,
364        order TYPE wctpc_cnt_type,
365        wap   TYPE wctpc_cnt_type,
366        wapi  TYPE wctpc_cnt_type,
367        wcd   TYPE wctpc_cnt_type,
368      END   OF wctpc_wcmcnt_type.
369    * WCM FLAGs
370    TYPES:
371      BEGIN OF wctpc_wcmflg_type,
372        order TYPE wceflg,
373        wap   TYPE wceflg,
374        wapi  TYPE wceflg,
375        wcd   TYPE wceflg,
376      END   OF wctpc_wcmflg_type.
377    * COUNTERs FOR WCD ITEMs
378    TYPES:
379      BEGIN OF wctpc_itmcnt_type,
380        func_loc         TYPE wctpc_cnt_type,
381        equipment        TYPE wctpc_cnt_type,
382        neutral          TYPE wctpc_cnt_type,
383        technical_object TYPE wctpc_cnt_type,
384        comment          TYPE wctpc_cnt_type,
385        total            TYPE wctpc_cnt_type,
386        text             TYPE wctpc_cnt_type,
387        documents        TYPE wctpc_cnt_type,
388      END   OF wctpc_itmcnt_type.
389    * MSG COUNTERs
390    TYPES:
391      BEGIN OF wctpc_msgcnt_type,
392        error   TYPE wctpc_cnt_type,
393        warning TYPE wctpc_cnt_type,
394        note    TYPE wctpc_cnt_type,
395      END   OF wctpc_msgcnt_type.
396    * COMPARISON COUNTERs
397    TYPES:
398      BEGIN OF wctpc_cmpcnt_type,
399        del TYPE wctpc_cnt_type,
400        ins TYPE wctpc_cnt_type,
401        BEGIN OF upd,
402          eq TYPE wctpc_cnt_type,
403          ne TYPE wctpc_cnt_type,
404        END   OF upd,
405        err TYPE wctpc_cnt_type,
406      END   OF wctpc_cmpcnt_type.
407    * COMPARISON FLAGs
408    TYPES:
409      BEGIN OF wctpc_cmpflg_type,
410        delete TYPE wceflg,
411        insert TYPE wceflg,
412        BEGIN OF update,
413          equal     TYPE wceflg,
414          not_equal TYPE wceflg,
415        END   OF update,
416      END   OF wctpc_cmpflg_type.
417    * FILTER
418    TYPES:
419      BEGIN OF wctpc_filter_type,
420        active TYPE wctpc_cmpflg_type,
421        used   TYPE wctpc_cmpflg_type,
422      END   OF wctpc_filter_type.
423    * RETURN VALUEs
424    TYPES:
425      BEGIN OF wctpc_return_type,
426        fcode  TYPE fcode,
427        update TYPE wceboolean,
428      END   OF wctpc_return_type.
429    * VIEW (multilevel list)
430    TYPES:
431      BEGIN OF wctpc_view_type,
432        or TYPE wceflg,
433        ww TYPE wceflg,
434        wa TYPE wceflg,
435        wd TYPE wceflg,
436      END   OF wctpc_view_type.
437    * LINK COUNTERs
438    TYPES:
439      BEGIN OF wctpc_lnkcnt_type,
440        BEGIN OF up,
441          m2s TYPE wctpc_cnt_type,
442          s2m TYPE wctpc_cnt_type,
443        END   OF up,
444        BEGIN OF dn,
445          m2s TYPE wctpc_cnt_type,
446          s2m TYPE wctpc_cnt_type,
447        END   OF dn,
448      END   OF wctpc_lnkcnt_type.
449    * LINK FLAGs
450    TYPES:
451      BEGIN OF wctpc_lnkflg_type,
452        up TYPE wceflg,
453        dn TYPE wceflg,
454      END   OF wctpc_lnkflg_type.
455    * HIDE DIALOG BOX
456    TYPES:
457      BEGIN OF wctpc_lnkhide_type,
458        up TYPE wcelnkhide,
459        dn TYPE wcelnkhide,
460      END   OF wctpc_lnkhide_type.
461    * LINK OBJECTs
462    TYPES:
463      BEGIN OF wctpc_lnkobj_type,
464        upart TYPE wceobjart,
465        uptyp TYPE wcetyp,
466        dnart TYPE wceobjart,
467        dntyp TYPE wcetyp,
468      END   OF wctpc_lnkobj_type.
469    * ALTERNATIVE LABELING
470    TYPES:
471      BEGIN OF wctpc_labeling_type,
472        cust TYPE itobcust,
473        BEGIN OF used,
474          header TYPE wceboolean,
475          items  TYPE wceboolean,
476          objlst TYPE wceboolean,
477        END   OF used,
478      END   OF wctpc_labeling_type.
479    * OPERATIONAL CHECKS
480    * - TIME FRAME CHECK
481    TYPES:
482      BEGIN OF wctpc_d5100tab_wcfl_type,
483        header TYPE wctpc_d5xxx_headertab_type,
484        body   TYPE wctpc_d5100_body0tab_type,
485      END   OF wctpc_d5100tab_wcfl_type.
486    * - EXTERNAL CONFLICT VERIFICATION
487    TYPES:
488      BEGIN OF wctpc_d5100tab_wcfk_type,
489        header TYPE wctpc_d5xxx_headertab_type,
490        body   TYPE wctpc_d5100_body1tab_type,
491      END   OF wctpc_d5100tab_wcfk_type.
492    * - INTERNAL CONFLICT VERIFICATION
493    TYPES:
494      BEGIN OF wctpc_d5200tab_wcfk_type,
495        header TYPE wctpc_d5xxx_headertab_type,
496        body   TYPE wctpc_d5200_body2tab_type,
497      END   OF wctpc_d5200tab_wcfk_type.
498    * - REFERENCE OBJECT CHECK
499    TYPES:
500      BEGIN OF wctpc_d5100tab_wcfp_type,
501        header TYPE wctpc_d5xxx_headertab_type,
502        body   TYPE wctpc_d5100_body3tab_type,
503      END   OF wctpc_d5100tab_wcfp_type.
504
505    * table types **********************************************************
506    * TECHNICAL OBJECTs
507    TYPES: wctpc_ccobjtab_type TYPE STANDARD TABLE OF wctpc_ccobjwa_type WITH DEFAULT KEY.
508    * TAGGED OBJECTs
509    TYPES: wctpc_tgobjtab_type TYPE STANDARD TABLE OF wctpc_tgobjwa_type WITH DEFAULT KEY.
510    * OPERATIONAL CLASSEs
511    TYPES: wctpc_classtab_type TYPE STANDARD TABLE OF wctpc_classwa_type WITH DEFAULT KEY.
512    * DOCUMENTs
513    TYPES: wctpc_doctab_type TYPE STANDARD TABLE OF wctpc_docwa_type WITH DEFAULT KEY.
514    * MEMORY STACK
515    TYPES: wctpc_memtab_type TYPE STANDARD TABLE OF wctpc_memwa_type WITH DEFAULT KEY.
516    * MESSAGE TYPEs
517    TYPES: wctpc_msgtab_type TYPE STANDARD TABLE OF wctpc_msgwa_type WITH DEFAULT KEY.
518    * APPROVALs
519    TYPES: wctpc_permittab_type  TYPE STANDARD TABLE OF wctpc_permitwa_type  WITH DEFAULT KEY.
520    TYPES: wctpc_pmsogtab_type   TYPE STANDARD TABLE OF wctpc_pmsogwa_type   WITH DEFAULT KEY.
521    TYPES: wctpc_grantedtab_type TYPE STANDARD TABLE OF wctpc_grantedwa_type WITH DEFAULT KEY.
522    * OPERATIONAL CONDITIONs
523    TYPES: wctpc_tagtab_type TYPE STANDARD TABLE OF wctpc_tagwa_type WITH DEFAULT KEY.
524    * SUBTYPEs
525    TYPES: wctpc_typetab_type TYPE STANDARD TABLE OF wctpc_typewa_type WITH DEFAULT KEY.
526    * WCM OBJECTs ON BASIS OF THE USE
527    TYPES: wctpc_usetab_type TYPE STANDARD TABLE OF wctpc_usewa_type WITH DEFAULT KEY.
528    * WAPI
529    TYPES: wctpc_wapitab_type TYPE STANDARD TABLE OF wctpc_wapiwa_type WITH DEFAULT KEY.
530    * OPERATIONAL CONDITIONs
531    TYPES: wctpc_wccaxtab_type TYPE STANDARD TABLE OF wctpc_wccaxwa_type WITH DEFAULT KEY.
532    * WCD
533    TYPES: wctpc_wcdtab_type    TYPE STANDARD TABLE OF wctpc_wcdwa_type    WITH DEFAULT KEY.
534    TYPES: wctpc_wcdcnttab_type TYPE STANDARD TABLE OF wctpc_wcdcntwa_type WITH DEFAULT KEY.
535    * WCD CONTROL
536    TYPES: wctpc_wcdctrltab_type TYPE STANDARD TABLE OF wctpc_wcdctrlwa_type WITH DEFAULT KEY.
537    * OPERATIONAL STEPs
538    TYPES: wctpc_tgunsteptab_type TYPE SORTED TABLE OF wctpc_tgunstepwa_type WITH UNIQUE KEY tgstep unstep.
539    * TAGGING STEPs
540    TYPES: wctpc_tgsteptab_type TYPE SORTED TABLE OF wctpc_tgstepwa_type WITH UNIQUE KEY tgstep.
541    * UNTAGGING STEPs
542    TYPES: wctpc_unsteptab_type TYPE SORTED TABLE OF wctpc_unstepwa_type WITH UNIQUE KEY unstep.
543    * WCM TEMPLATEs
544    TYPES: wctpc_tmpltab_type TYPE STANDARD TABLE OF wctpc_tmplwa_type WITH DEFAULT KEY.
545    * WCM OBJECTs
546    TYPES: wctpc_wcmtab_type     TYPE STANDARD TABLE OF wctpc_wcmwa_type     WITH DEFAULT KEY.
547    TYPES: wctpc_wcmflgtab_type  TYPE STANDARD TABLE OF wctpc_wcmflgwa_type  WITH DEFAULT KEY.
548    TYPES: wctpc_wcmobjtab_type  TYPE STANDARD TABLE OF wctpc_wcmobjwa_type  WITH DEFAULT KEY.
549    TYPES: wctpc_wcmpermtab_type TYPE STANDARD TABLE OF wctpc_wcmpermwa_type WITH DEFAULT KEY.
550    * LINEUPS
551    TYPES: wctpc_lineuptab_type TYPE STANDARD TABLE OF wctpc_lineupwa_type WITH DEFAULT KEY.
552    * OPERATIONAL LISTs
553    TYPES: wctpc_oplsttab_type TYPE STANDARD TABLE OF wctpc_oplstwa_type WITH DEFAULT KEY.
554    * CONFIRMATION OF OPERATIONAL LISTs
555    TYPES: wctpc_oplst_confirmtab_type TYPE STANDARD TABLE OF wctpc_oplst_confirmwa_type WITH DEFAULT KEY.
556    * CONFIRMATION OF WORK PERMITs
557    TYPES: wctpc_wkpt_confirmtab_type TYPE STANDARD TABLE OF wctpc_wkpt_confirmwa_type WITH DEFAULT KEY.
558    * WCM INTERFACEs
559    TYPES: wctpc_wcmiftab_type TYPE STANDARD TABLE OF wctpc_wcmifwa_type WITH DEFAULT KEY.
560    * TRANSPORT ENTRIEs
561    TYPES: wctpc_tratab_type TYPE STANDARD TABLE OF wctpc_trawa_type WITH DEFAULT KEY.
562    * VAL STATISTIC
563    TYPES: wctpc_valcnttab_type TYPE STANDARD TABLE OF wctpc_valcntwa_type WITH DEFAULT KEY.
564    * FILTER DIALOG
565    TYPES: wctpc_fltrdlgtab_type TYPE STANDARD TABLE OF wctpc_fltrdlgwa_type WITH DEFAULT KEY.
566    * ALV FOR TECHNICAL OBJECT
567    TYPES: wctpc_rihiflotab_type TYPE STANDARD TABLE OF wctpc_rihiflowa_type WITH DEFAULT KEY.
568    TYPES: wctpc_rihequitab_type TYPE STANDARD TABLE OF wctpc_rihequiwa_type WITH DEFAULT KEY.
569    TYPES: wctpc_rihiflo_listtab_type TYPE STANDARD TABLE OF wctpc_rihiflo_listwa_type WITH DEFAULT KEY.
570    TYPES: wctpc_rihequi_listtab_type TYPE STANDARD TABLE OF wctpc_rihequi_listwa_type WITH DEFAULT KEY.
571    * ALV FOR NETWORK
572    TYPES: wctpc_rihinettab_type TYPE STANDARD TABLE OF wctpc_rihinetwa_type WITH DEFAULT KEY.
573    * NAMETAB
574    TYPES: wctpc_x031ltab_type TYPE STANDARD TABLE OF wctpc_x031lwa_type WITH DEFAULT KEY.
575    * DIALOG TEXT DISPLAY PARAMETERs/VALUEs
576    TYPES: wctpc_spartab_type TYPE STANDARD TABLE OF wctpc_sparwa_type WITH DEFAULT KEY.
577    * INDEX TABLE
578    TYPES: wctpc_indextab_type TYPE STANDARD TABLE OF  wctpc_indexwa_type WITH DEFAULT KEY.
579    * MAPPING TABLE
580    TYPES: wctpc_maptab_type TYPE STANDARD TABLE OF wctpc_mapwa_type WITH DEFAULT KEY.
581    * OPERATIONAL CHECKS
582    * - HEADER
583    TYPES: wctpc_d5xxx_headertab_type TYPE STANDARD TABLE OF wctpc_d5xxx_headerwa_type WITH DEFAULT KEY.
584    * - BODY TIME FRAME CHECK
585    TYPES: wctpc_d5100_body0tab_type TYPE STANDARD TABLE OF wctpc_d5100_body0wa_type WITH DEFAULT KEY.
586    * - BODY EXTERNAL CONFLICT VERIFICATION
587    TYPES: wctpc_d5100_body1tab_type TYPE STANDARD TABLE OF wctpc_d5100_body1wa_type WITH DEFAULT KEY.
588    * - BODY INTERNAL CONFLICT VERIFICATION
589    TYPES: wctpc_d5200_body2tab_type TYPE STANDARD TABLE OF wctpc_d5200_body2wa_type WITH DEFAULT KEY.
590    * - BODY REFERENCE OBJECT CHECK
591    TYPES: wctpc_d5100_body3tab_type TYPE STANDARD TABLE OF wctpc_d5100_body3wa_type WITH DEFAULT KEY.
592
593    * ranges ***************************************************************
594    * DOCUMENT TYPE
595    TYPES: wctpc_r_dokar_tab_type TYPE RANGE OF dokar.
596    TYPES: wctpc_r_dokar_wa_type TYPE LINE OF wctpc_r_dokar_tab_type.
597    * PARTNER FUNCTION
598    TYPES: wctpc_r_parvw_tab_type TYPE RANGE OF parvw.
599    TYPES: wctpc_r_parvw_wa_type TYPE LINE OF wctpc_r_parvw_tab_type.
600    * PARTNER
601    TYPES: wctpc_r_parnr_tab_type TYPE RANGE OF i_parnr.
602    TYPES: wctpc_r_parnr_wa_type TYPE LINE OF wctpc_r_parnr_tab_type.
603    * STATUS
604    TYPES: wctpc_r_status_tab_type TYPE RANGE OF j_status.
605    TYPES: wctpc_r_status_wa_type TYPE LINE OF wctpc_r_status_tab_type.
606    * CATALOG TYPES
607    TYPES: wctpc_r_qkatart_tab_type TYPE RANGE OF qkatart.
608    TYPES: wctpc_r_qkatart_wa_type TYPE LINE OF wctpc_r_qkatart_tab_type.
609    * CODE GROUP
610    TYPES: wctpc_r_qcodegrp_tab_type TYPE RANGE OF qcodegrp.
611    TYPES: wctpc_r_qcodegrp_wa_type TYPE LINE OF wctpc_r_qcodegrp_tab_type.
612    * CODE
613    TYPES: wctpc_r_qcode_tab_type TYPE RANGE OF qcode.
614    TYPES: wctpc_r_qcode_wa_type TYPE LINE OF wctpc_r_qcode_tab_type.
615    * WORK CENTER
616    TYPES: wctpc_r_wkcrid_tab_type TYPE RANGE OF cr_objid.
617    TYPES: wctpc_r_wkcrid_wa_type TYPE LINE OF wctpc_r_wkcrid_tab_type.
618    * TECHNICAL OBJECT
619    TYPES: wctpc_r_ccobj_tab_type TYPE RANGE OF wceccobj.
620    TYPES: wctpc_r_ccobj_wa_type TYPE LINE OF wctpc_r_ccobj_tab_type.
621    * FUNCTION LOCATION LABEL
622    TYPES: wctpc_r_ilom_strno_tab_type TYPE RANGE OF ilom_strno.
623    TYPES: wctpc_r_ilom_strno_wa_type TYPE LINE OF wctpc_r_ilom_strno_tab_type.
624    * ITEM CATEGORY
625    TYPES: wctpc_r_cctyp_tab_type TYPE RANGE OF wcecctyp.
626    TYPES: wctpc_r_cctyp_wa_type TYPE LINE OF wctpc_r_cctyp_tab_type.
627    * OBJECT KEY
628    TYPES: wctpc_r_objkey_tab_type TYPE RANGE OF wceno.
629    TYPES: wctpc_r_objkey_wa_type TYPE LINE OF wctpc_r_objkey_tab_type.
630    * OPERATION
631    TYPES: wctpc_r_aufpl_tab_type TYPE RANGE OF co_aufpl.
632    TYPES: wctpc_r_aufpl_wa_type TYPE LINE OF wctpc_r_aufpl_tab_type.
633    TYPES: wctpc_r_aplzl_tab_type TYPE RANGE OF co_aplzl.
634    TYPES: wctpc_r_aplzl_wa_type TYPE LINE OF wctpc_r_aplzl_tab_type.
635    * LINEUP
636    TYPES: wctpc_r_lunr_tab_type TYPE RANGE OF wcelunr.
637    TYPES: wctpc_r_lunr_wa_type TYPE LINE OF wctpc_r_lunr_tab_type.
638    * PLANNING PLANT
639    TYPES: wctpc_r_iwerk_tab_type TYPE RANGE OF iwerk.
640    TYPES: wctpc_r_iwerk_wa_type TYPE LINE OF wctpc_r_iwerk_tab_type.
641    * OBJECT TYPE
642    TYPES: wctpc_r_objart_tab_type TYPE RANGE OF wceobjart.
643    TYPES: wctpc_r_objart_wa_type TYPE LINE OF wctpc_r_objart_tab_type.
644    * OBJECT SUBTYPE
645    TYPES: wctpc_r_objtyp_tab_type TYPE RANGE OF wcetyp.
646    TYPES: wctpc_r_objtyp_wa_type TYPE LINE OF wctpc_r_objtyp_tab_type.
647    * OPERATIONAL CLASS
648    TYPES: wctpc_r_class_tab_type TYPE RANGE OF wceclass.
649    TYPES: wctpc_r_class_wa_type TYPE LINE OF wctpc_r_class_tab_type.
650    * OPERATIONAL GROUP
651    TYPES: wctpc_r_grp_tab_type TYPE RANGE OF wcetggrp.
652    TYPES: wctpc_r_grp_wa_type TYPE LINE OF wctpc_r_grp_tab_type.
653    * OPERATIONAL CONDITON
654    TYPES: wctpc_r_proc_tab_type TYPE RANGE OF wcetgproc.
655    TYPES: wctpc_r_proc_wa_type TYPE LINE OF wctpc_r_proc_tab_type.
656    * OPERATIONAL TYPE
657    TYPES: wctpc_r_typ_tab_type TYPE RANGE OF wcetgtyp.
658    TYPES: wctpc_r_typ_wa_type TYPE LINE OF wctpc_r_typ_tab_type.
659    * OPERATIONAL LIST
660    TYPES: wctpc_r_lstid_tab_type TYPE RANGE OF wcelstid.
661    TYPES: wctpc_r_lstid_wa_type TYPE LINE OF wctpc_r_lstid_tab_type.
662    * OPERATIONAL STEP
663    TYPES: wctpc_r_step_tab_type TYPE RANGE OF wceactstep.
664    TYPES: wctpc_r_step_wa_type TYPE LINE OF wctpc_r_step_tab_type.
665    * USABLE
666    TYPES: wctpc_r_usable_tab_type TYPE RANGE OF wceusable.
667    TYPES: wctpc_r_usable_wa_type TYPE LINE OF wctpc_r_usable_tab_type.
668    * PERMIT
669    TYPES: wctpc_r_pmsog_tab_type TYPE RANGE OF pmsog.
670    TYPES: wctpc_r_pmsog_wa_type TYPE LINE OF wctpc_r_pmsog_tab_type.
671    * PRINT FORMAT
672    TYPES: wctpc_r_form_tab_type TYPE RANGE OF wceprtform.
673    TYPES: wctpc_r_form_wa_type TYPE LINE OF wctpc_r_form_tab_type.
674    * USER NAME
675    TYPES: wctpc_r_userid_tab_type TYPE RANGE OF xubname.
676    TYPES: wctpc_r_userid_wa_type TYPE LINE OF wctpc_r_userid_tab_type.
677    *WAP                                                        "Nˇ3659199
678    TYPES: wctpc_r_wapnr_tab_type TYPE wct_wcewapnr.
679    TYPES: wctpc_r_wapnr_wa_type TYPE wcs_wcewapnr.
680    * OBJECT NUMBER
681    TYPES: wctpc_r_objnr_tab_type TYPE wct_objnr.
682    TYPES: wctpc_r_objnr_wa_type TYPE wcs_objnr.
683    * WAPI
684    TYPES: wctpc_r_wapinr_tab_type TYPE wct_wcewapinr.
685    TYPES: wctpc_r_wapinr_wa_type TYPE wcs_wcewapinr.
686    * WCD
687    TYPES: wctpc_r_wcnr_tab_type TYPE wct_wcewcnr.
688    TYPES: wctpc_r_wcnr_wa_type TYPE wcs_wcewcnr.               "N^3659199
689
690    * constants ************************************************************
691    * WCM INTERFACES (domain WCDIF)
692    CONSTANTS:
693      BEGIN OF wctpc_interface,
694        dummy             TYPE wctpc_interface_type VALUE space,
695    *   customizable interface constants (defined in DDIC domain WCDIF)
696        approval          TYPE wctpc_interface_type VALUE '1',
697        partner           TYPE wctpc_interface_type VALUE '2',
698        catalogue         TYPE wctpc_interface_type VALUE '3',
699        document          TYPE wctpc_interface_type VALUE '4',
700        description       TYPE wctpc_interface_type VALUE '5',
701        requal_comment    TYPE wctpc_interface_type VALUE '6',
702        tagging_comment   TYPE wctpc_interface_type VALUE '7',
703        untagging_comment TYPE wctpc_interface_type VALUE '8',
704        object_list       TYPE wctpc_interface_type VALUE '9',
705        item              TYPE wctpc_interface_type VALUE '10',
706        assignment        TYPE wctpc_interface_type VALUE '11',
707        work              TYPE wctpc_interface_type VALUE '12',
708        needs             TYPE wctpc_interface_type VALUE '13',
709        templates         TYPE wctpc_interface_type VALUE '14',
710        status_management TYPE wctpc_interface_type VALUE '15',
711        remarks_1         TYPE wctpc_interface_type VALUE '16',
712        remarks_2         TYPE wctpc_interface_type VALUE '17',
713        operations        TYPE wctpc_interface_type VALUE '18',
714        enhancement       TYPE wctpc_interface_type VALUE '20',
715    *   special interface constants (NOT defined in DDIC domain WCDIF)
716        header            TYPE wctpc_interface_type VALUE '51',
717        validity_end      TYPE wctpc_interface_type VALUE '52',
718        wkneed            TYPE wctpc_interface_type VALUE '53',
719      END   OF wctpc_interface.
720    * PROGRAM MODES
721    CONSTANTS:
722      BEGIN OF wctpc_mode,
723        no_selection      TYPE wceprgmode VALUE '0',
724        only_with_variant TYPE wceprgmode VALUE 'S',
725        only_one_object   TYPE wceprgmode VALUE '1',
726        several_objects   TYPE wceprgmode VALUE 'X',
727        all_in_background TYPE wceprgmode VALUE 'D',
728        preselection      TYPE wceprgmode VALUE 'P',
729      END   OF wctpc_mode.
730    * PROGRAM TYPES (domain WCDPRGTYP)
731    CONSTANTS:
732      BEGIN OF wctpc_prgtyp,
733        standard    TYPE wceprgtyp VALUE space,
734        search_help TYPE wceprgtyp VALUE 'SH',
735        filter      TYPE wceprgtyp VALUE 'FLTR',
736      END   OF wctpc_prgtyp.
737    * SINGLE HIT
738    CONSTANTS:
739      BEGIN OF wctpc_single_hit,
740        suppress_output TYPE wctpc_single_hit_type VALUE 'N',
741        display_output  TYPE wctpc_single_hit_type VALUE space,
742      END   OF wctpc_single_hit.
743    * STRUCTURES
744    CONSTANTS:
745      BEGIN OF wctpc_structure,
746        comparison       TYPE ddobjname VALUE 'WCSCMPCTRL',
747        graphical_system TYPE ddobjname VALUE 'RFC_WCDITM_CTRL',
748      END   OF wctpc_structure.
749    * FIELD NAMES
750    CONSTANTS:
751      BEGIN OF wctpc_name,
752        BEGIN OF comparison,
753          display TYPE fieldname VALUE 'DISPLAY',
754          filter  TYPE fieldname VALUE 'FILTER',
755          seq     TYPE fieldname VALUE 'SEQ',
756          tgform  TYPE fieldname VALUE 'TGFORM',
757          tgnr    TYPE fieldname VALUE 'TGNR',
758        END   OF comparison,
759        BEGIN OF graphical_system,
760          ccobjnr TYPE fieldname VALUE 'CCOBJNR',
761        END   OF graphical_system,
762        BEGIN OF common,
763          seq      TYPE fieldname VALUE 'SEQ',
764          cctyp    TYPE fieldname VALUE 'CCTYP',
765          ccobj    TYPE fieldname VALUE 'CCOBJ',
766          stxt     TYPE fieldname VALUE 'STXT',
767          tggrp    TYPE fieldname VALUE 'TGGRP',
768          tgstep   TYPE fieldname VALUE 'TGSTEP',
769          tgproc   TYPE fieldname VALUE 'TGPROC',
770          tgtyp    TYPE fieldname VALUE 'TGTYP',
771          tgseq    TYPE fieldname VALUE 'TGSEQ',
772          tgtxt    TYPE fieldname VALUE 'TGTXT',
773          unstep   TYPE fieldname VALUE 'UNSTEP',
774          unproc   TYPE fieldname VALUE 'UNPROC',
775          untyp    TYPE fieldname VALUE 'UNTYP',
776          unseq    TYPE fieldname VALUE 'UNSEQ',
777          untxt    TYPE fieldname VALUE 'UNTXT',
778          phblflg  TYPE fieldname VALUE 'PHBLFLG',
779          phbltyp  TYPE fieldname VALUE 'PHBLTYP',
780          phblnr   TYPE fieldname VALUE 'PHBLNR',
781          tgflg    TYPE fieldname VALUE 'TGFLG',
782          tgnr     TYPE fieldname VALUE 'TGNR',
783          location TYPE fieldname VALUE 'LOCATION',
784          control  TYPE fieldname VALUE 'CONTROL',
785        END   OF common,
786        BEGIN OF wkneed,
787          wk01   TYPE fieldname VALUE 'WK01',
788          wk02   TYPE fieldname VALUE 'WK02',
789          wk03   TYPE fieldname VALUE 'WK03',
790          wk04   TYPE fieldname VALUE 'WK04',
791          wk05   TYPE fieldname VALUE 'WK05',
792          wk06   TYPE fieldname VALUE 'WK06',
793          wk07   TYPE fieldname VALUE 'WK07',
794          wk08   TYPE fieldname VALUE 'WK08',
795          wk09   TYPE fieldname VALUE 'WK09',
796          wk10   TYPE fieldname VALUE 'WK10',
797          wk11   TYPE fieldname VALUE 'WK11',
798          wk12   TYPE fieldname VALUE 'WK12',
799          wk13   TYPE fieldname VALUE 'WK13',
800          wk14   TYPE fieldname VALUE 'WK14',
801          wk15   TYPE fieldname VALUE 'WK15',
802          wk16   TYPE fieldname VALUE 'WK16',
803          wk17   TYPE fieldname VALUE 'WK17',
804          wk18   TYPE fieldname VALUE 'WK18',
805          wk19   TYPE fieldname VALUE 'WK19',
806          wk20   TYPE fieldname VALUE 'WK20',
807          wk21   TYPE fieldname VALUE 'WK21',
808          wk22   TYPE fieldname VALUE 'WK22',
809          wk23   TYPE fieldname VALUE 'WK23',
810          wk24   TYPE fieldname VALUE 'WK24',
811          wk25   TYPE fieldname VALUE 'WK25',
812          wk26   TYPE fieldname VALUE 'WK26',
813          wk27   TYPE fieldname VALUE 'WK27',
814          wk28   TYPE fieldname VALUE 'WK28',
815          need01 TYPE fieldname VALUE 'NEED01',
816          need02 TYPE fieldname VALUE 'NEED02',
817          need03 TYPE fieldname VALUE 'NEED03',
818          need04 TYPE fieldname VALUE 'NEED04',
819          need05 TYPE fieldname VALUE 'NEED05',
820          need06 TYPE fieldname VALUE 'NEED06',
821          need07 TYPE fieldname VALUE 'NEED07',
822          need08 TYPE fieldname VALUE 'NEED08',
823          need09 TYPE fieldname VALUE 'NEED09',
824          need10 TYPE fieldname VALUE 'NEED10',
825          need11 TYPE fieldname VALUE 'NEED11',
826          need12 TYPE fieldname VALUE 'NEED12',
827          need13 TYPE fieldname VALUE 'NEED13',
828          need14 TYPE fieldname VALUE 'NEED14',
829          need15 TYPE fieldname VALUE 'NEED15',
830          need16 TYPE fieldname VALUE 'NEED16',
831          need17 TYPE fieldname VALUE 'NEED17',
832          need18 TYPE fieldname VALUE 'NEED18',
833          need19 TYPE fieldname VALUE 'NEED19',
834          need20 TYPE fieldname VALUE 'NEED20',
835          need21 TYPE fieldname VALUE 'NEED21',
836          need22 TYPE fieldname VALUE 'NEED22',
837          need23 TYPE fieldname VALUE 'NEED23',
838          need24 TYPE fieldname VALUE 'NEED24',
839          need25 TYPE fieldname VALUE 'NEED25',
840          need26 TYPE fieldname VALUE 'NEED26',
841          need27 TYPE fieldname VALUE 'NEED27',
842          need28 TYPE fieldname VALUE 'NEED28',
843        END   OF wkneed,
844      END   OF wctpc_name.
845    * PROCESS
846    CONSTANTS:
847      BEGIN OF wctpc_process,
848        import  TYPE wctpc_process_type VALUE 'X',
849        compare TYPE wctpc_process_type VALUE 'Y',
850      END   OF wctpc_process.
851    * COMPARISON
852    CONSTANTS:
853      BEGIN OF wctpc_cmp,
854        BEGIN OF display,
855          single TYPE wctpc_cmp_display_type VALUE 'S',
856          double TYPE wctpc_cmp_display_type VALUE 'D',
857        END   OF display,
858        BEGIN OF filter,
859          none      TYPE wctpc_cmp_filter_type VALUE '0',
860          equal     TYPE wctpc_cmp_filter_type VALUE '1',
861          not_equal TYPE wctpc_cmp_filter_type VALUE '2',
862          added     TYPE wctpc_cmp_filter_type VALUE '3',
863          deleted   TYPE wctpc_cmp_filter_type VALUE '4',
864        END   OF filter,
865        BEGIN OF with,
866          copy_model TYPE wctpc_cmp_with_type VALUE 'CM',
867          any_wcd    TYPE wctpc_cmp_with_type VALUE 'ANY',
868        END   OF with,
869      END   OF wctpc_cmp.
870    * CLIPBOARD TASKs
871    CONSTANTS:
872      BEGIN OF wctpc_clipboard_task,
873        pass    TYPE wctpc_clipboard_task_type VALUE 0,
874        replace TYPE wctpc_clipboard_task_type VALUE 1,
875        append  TYPE wctpc_clipboard_task_type VALUE 2,
876      END   OF wctpc_clipboard_task.
877    * STATUS FOR OPERATIONAL LISTS
878    CONSTANTS:
879      BEGIN OF wctpc_status,
880        undefined         TYPE wcestatus VALUE space,
881        released          TYPE wcestatus VALUE '1',
882        BEGIN OF partly_completed,
883          only_executed TYPE wcestatus VALUE '2',
884          with_rejected TYPE wcestatus VALUE '3',
885        END   OF partly_completed,
886        BEGIN OF completed,
887          only_executed TYPE wcestatus VALUE '4',
888          with_rejected TYPE wcestatus VALUE '5',
889        END   OF completed,
890        no_activity       TYPE wcestatus VALUE '6',
891        activity          TYPE wcestatus VALUE '7',
892        activity_rejected TYPE wcestatus VALUE '8',
893        activity_executed TYPE wcestatus VALUE '9',
894      END   OF wctpc_status.
895    * STEP (mobile WCM)
896    CONSTANTS:
897      BEGIN OF wctpc_step,
898        initial    TYPE wcestep VALUE '1',
899        log_save   TYPE wcestep VALUE '5',
900        switching  TYPE wcestep VALUE '6',
901        mobi_reset TYPE wcestep VALUE '7',
902        finished   TYPE wcestep VALUE '9',
903        additional TYPE wcestep VALUE 'X',
904      END   OF wctpc_step.
905    * VALIDITY (domain WCDVALID)
906    CONSTANTS:
907      BEGIN OF wctpc_validity,
908        planned TYPE wcevalid VALUE '0',
909        valid   TYPE wcevalid VALUE '1',
910        expired TYPE wcevalid VALUE '2',
911      END   OF wctpc_validity.
912    * APPROVAL STATE
913    CONSTANTS:
914      BEGIN OF wctpc_approval_state,
915        initial TYPE wctpc_approval_state_type VALUE space,
916        issued  TYPE wctpc_approval_state_type VALUE 'I',
917        revoked TYPE wctpc_approval_state_type VALUE 'R',
918      END   OF wctpc_approval_state.
919    * MEMORY COUNTER FOR DYNAMIC ABAP MEMORY IDs
920    CONSTANTS:
921      BEGIN OF wctpc_id_name,
922        mem1cnt TYPE wctpc_id_type-name VALUE 'MEM1CNT',
923        mem2cnt TYPE wctpc_id_type-name VALUE 'MEM2CNT',
924        mem3cnt TYPE wctpc_id_type-name VALUE 'MEM3CNT',
925      END  OF wctpc_id_name.
926    * PREFIX FOR DYNAMIC ABAP MEMORY IDs
927    CONSTANTS:
928      BEGIN OF wctpc_prefix,
929        one TYPE wctpc_prefix_type VALUE 'WCM',
930      END  OF wctpc_prefix.
931    * SUFFIX FOR DYNAMIC ABAP MEMORY IDs
932    CONSTANTS:
933      BEGIN OF wctpc_suffix,
934        one TYPE wctpc_suffix_type VALUE '1',
935      END  OF wctpc_suffix.
936    * ABAP MEMORY IDs
937    CONSTANTS:
938      BEGIN OF wctpc_memory_id,
939        options           TYPE wctpc_memory_id_type VALUE 'OPTIONS',
940        riaufk20          TYPE wctpc_memory_id_type VALUE 'RIAUFK20',
941        iw37n             TYPE wctpc_memory_id_type VALUE 'RI_ORDER_OPERATION_LIST',
942        riaufk20_fieldcat TYPE wctpc_memory_id_type VALUE 'RIAUFK20_FIELDCAT',
943        riafvc20          TYPE wctpc_memory_id_type VALUE 'RIAFVC20',
944        rinet0e0          TYPE wctpc_memory_id_type VALUE 'RINET0E0',
945        rinet0t0          TYPE wctpc_memory_id_type VALUE 'RINET0T0',
946        riequi20          TYPE wctpc_memory_id_type VALUE 'RIEQUI20',
947        riiflo20          TYPE wctpc_memory_id_type VALUE 'RIIFLO20',
948        riiflo10          TYPE wctpc_memory_id_type VALUE 'RIIFLO10',
949        riequi10          TYPE wctpc_memory_id_type VALUE 'RIEQUI10',
950        riwcwf01          TYPE wctpc_memory_id_type VALUE 'RIWCWF01',
951        riwcww02          TYPE wctpc_memory_id_type VALUE 'RIWCWW02',
952        riwcwa02          TYPE wctpc_memory_id_type VALUE 'RIWCWA02',
953        riwcwd02          TYPE wctpc_memory_id_type VALUE 'RIWCWD02',
954        riwcwv01          TYPE wctpc_memory_id_type VALUE 'RIWCWV01',
955        riwcwp01          TYPE wctpc_memory_id_type VALUE 'RIWCWP01',
956        riwc0010          TYPE wctpc_memory_id_type VALUE 'RIWC0010',
957        riwc0016          TYPE wctpc_memory_id_type VALUE 'RIWC0016',
958        riwc0018          TYPE wctpc_memory_id_type VALUE 'RIWC0018',
959        riwc0019          TYPE wctpc_memory_id_type VALUE 'RIWC0019',
960        riwc0021          TYPE wctpc_memory_id_type VALUE 'RIWC0021',
961        riwc0027          TYPE wctpc_memory_id_type VALUE 'RIWC0027',
962        return            TYPE wctpc_memory_id_type VALUE 'RETURN',
963        verlst            TYPE wctpc_memory_id_type VALUE 'VERLST',
964        pmwoc             TYPE wctpc_memory_id_type VALUE 'PMWOC',
965        pm_obtyp          TYPE wctpc_memory_id_type VALUE 'PM_OBTYP',
966        pm                TYPE wctpc_memory_id_type VALUE 'PM',
967        wccax             TYPE wctpc_memory_id_type VALUE 'WCCAX',
968        influence         TYPE wctpc_memory_id_type VALUE 'INFLUENCE',
969        darkflg           TYPE wctpc_memory_id_type VALUE 'DARKFLG',
970        reference         TYPE wctpc_memory_id_type VALUE 'REFERENCE',
971        asgn              TYPE wctpc_memory_id_type VALUE 'ASGN',
972        wcat              TYPE wctpc_memory_id_type VALUE 'WCAT',
973        mem1cnt           TYPE wctpc_memory_id_type VALUE 'MEM1CNT',
974        mem2cnt           TYPE wctpc_memory_id_type VALUE 'MEM2CNT',
975        mem3cnt           TYPE wctpc_memory_id_type VALUE 'MEM3CNT',
976        clipboard         TYPE wctpc_memory_id_type VALUE 'CLIPBOARD',
977        comparison        TYPE wctpc_memory_id_type VALUE 'COMPARISON',
978        objtab            TYPE wctpc_memory_id_type VALUE 'OBJTAB',
979        cattab            TYPE wctpc_memory_id_type VALUE 'CATTAB',
980        prt_wap           TYPE wctpc_memory_id_type VALUE 'PRT1',
981        prt_wapi          TYPE wctpc_memory_id_type VALUE 'PRT2',
982        prt_wcd           TYPE wctpc_memory_id_type VALUE 'PRT3',
983        prt_wcitm         TYPE wctpc_memory_id_type VALUE 'PRT4',
984        prt_objlst        TYPE wctpc_memory_id_type VALUE 'PRT5',
985        prt_approval      TYPE wctpc_memory_id_type VALUE 'PRT6',
986        prt_catalogue     TYPE wctpc_memory_id_type VALUE 'PRT7',
987        prt_asgn          TYPE wctpc_memory_id_type VALUE 'PRT8',
988        prt_wca2          TYPE wctpc_memory_id_type VALUE 'PRT9',
989        prtformat         TYPE wctpc_memory_id_type VALUE 'PRTFORMAT',
990        print             TYPE wctpc_memory_id_type VALUE 'PRINT',
991        itx1              TYPE wctpc_memory_id_type VALUE 'ITX1',
992        saplstxd          TYPE wctpc_memory_id_type VALUE 'SAPLSTXD',
993        wcm_stat_before   TYPE wctpc_memory_id_type VALUE 'WCM_STAT_BEFORE',
994        lifecycle_phase   TYPE wctpc_memory_id_type VALUE 'LIFECYCLE_PHASE',
995      END   OF wctpc_memory_id.
996    * STATUS OF ALTERNATIVE LABELING FUNCTIONALITY (domain ILOM_STATE)
997    CONSTANTS:
998      BEGIN OF wctpc_state,
999        inactive    TYPE ilom_state VALUE '1',
1000       active      TYPE ilom_state VALUE '2',
1001       deactivated TYPE ilom_state VALUE '3',
1002     END   OF wctpc_state.
1003   * ASSIGNMENT CRITERIA FOR WCM OPERATIONs - APPROVAL GROUPs (domain WCDDPCTRL2)
1004   CONSTANTS:
1005     BEGIN OF wctpc_grpdpctrl,
1006       aprvgrp TYPE wcegrpdpctrl VALUE space,
1007       none    TYPE wcegrpdpctrl VALUE 'N',
1008     END   OF wctpc_grpdpctrl.
1009   * LINK CRITERIA FOR WCM OPERATIONs - WCDs (domain WCDLNKCTRL)
1010   CONSTANTS:
1011     BEGIN OF wctpc_lnkctrl,
1012       no   TYPE wcelnkctrl VALUE 0,
1013       wcd  TYPE wcelnkctrl VALUE 1,
1014       step TYPE wcelnkctrl VALUE 2,
1015     END   OF wctpc_lnkctrl.
1016   * PROCESSING RULE FOR LINKs (domain WCDDPCTRL1)
1017   CONSTANTS:
1018     BEGIN OF wctpc_lnkdpctrl,
1019       mandatory TYPE wcelnkdpctrl VALUE 'M',
1020       optional  TYPE wcelnkdpctrl VALUE 'O',
1021     END   OF wctpc_lnkdpctrl.
1022   * CONFIRMATION PROMPTs
1023   CONSTANTS:
1024     BEGIN OF wctpc_cp,
1025       set_prepared               TYPE fieldname VALUE 'CPPREPFLG',
1026       reset_prepared             TYPE fieldname VALUE 'CPCHGNFLG',
1027       set_closed                 TYPE fieldname VALUE 'CPCLSDFLG',
1028       extend_validity            TYPE fieldname VALUE 'CPEXTENDFLG',
1029       delete_catalog_entries     TYPE fieldname VALUE 'CPCATFLG',
1030       delete_object_list_entries TYPE fieldname VALUE 'CPOBJLSTFLG',
1031       delete_approvals           TYPE fieldname VALUE 'CPAPRVFLG',
1032       delete_assignments         TYPE fieldname VALUE 'CPASGNFLG',
1033       delete_operation_assgn     TYPE fieldname VALUE 'CPOPERFLG',
1034       deactivate_items           TYPE fieldname VALUE 'CPINACFLG',
1035       print_work_permit          TYPE fieldname VALUE 'CPPWPFLG',
1036       create_work_permit         TYPE fieldname VALUE 'CPCWPFLG',
1037       hand_out_work_permit       TYPE fieldname VALUE 'CPHOWPFLG',
1038       return_work_permit         TYPE fieldname VALUE 'CPRWPFLG',
1039       print_operational_list     TYPE fieldname VALUE 'CPOPLST1FLG',
1040       create_operational_list    TYPE fieldname VALUE 'CPOPLST2FLG',
1041       cancel_catalog             TYPE fieldname VALUE 'CPCATCNCFLG',
1042       cancel_object_list         TYPE fieldname VALUE 'CPOBJLSTCNCFLG',
1043       cancel_approvals           TYPE fieldname VALUE 'CPAPRVCNCFLG',
1044       cancel_clipboard           TYPE fieldname VALUE 'CPCLBDCNCFLG',
1045       cancel_valuation           TYPE fieldname VALUE 'CPVALCNCFLG',
1046       cancel_operations          TYPE fieldname VALUE 'CPOPERCNCFLG',
1047       exit_display               TYPE fieldname VALUE 'CPDISPEXITFLG',
1048       save_changes               TYPE fieldname VALUE 'CPUPDFLG',
1049       conflict_check             TYPE fieldname VALUE 'CPCONFCHKFLG',
1050       untagging_check            TYPE fieldname VALUE 'CPUNTGCHKFLG',
1051       customizing_activity       TYPE fieldname VALUE 'CPCUSTFLG',
1052     END   OF wctpc_cp.
1053   * CONTROL FOR DYNAMIC (BADI-BASED) OPERATION DETERMINATION WITHIN WP (domain WCDWKPTOPERDYNCTRL)
1054   CONSTANTS:
1055     BEGIN OF wctpc_operdynctrl,
1056       none     TYPE wcewkptoperdynctrl VALUE space, "no dynamic operation determination within WP
1057       standard TYPE wcewkptoperdynctrl VALUE 'S',   "standard dynamic operation determination within WP
1058     END   OF wctpc_operdynctrl.
1059   * CONTROL FOR OPERATION ASSIGNMENT MAINTENANCE WITHIN WP (domain WCDWKPTOPERMNTCTRL)
1060   CONSTANTS:
1061     BEGIN OF wctpc_opermntctrl,
1062       none     TYPE wcewkptopermntctrl VALUE space, "no maintenance of operation assignments within WP
1063       standard TYPE wcewkptopermntctrl VALUE 'S',   "standard maintenance of operation assignments within WP
1064     END   OF wctpc_opermntctrl.
1065   * CONTROL FOR WORK PERMIT PUSHBUTTON (domain WCDWKPTPBCTRL)
1066   CONSTANTS:
1067     BEGIN OF wctpc_pbctrl,
1068       display TYPE wcewkptpbctrl VALUE 'X',   "display pushbutton
1069       hide    TYPE wcewkptpbctrl VALUE space, "do not display pushbutton
1070     END   OF wctpc_pbctrl.
1071   * COPY CONTROL (domain WCDCOPYCTRL)
1072   CONSTANTS:
1073     BEGIN OF wctpc_copyctrl,
1074       do_not_copy TYPE wcecopyctrl VALUE space, "do not copy assignments (standard setting)
1075       select      TYPE wcecopyctrl VALUE '1',   "select assignments to be copied
1076       copy        TYPE wcecopyctrl VALUE '2',   "copy assignments
1077     END   OF wctpc_copyctrl.
1078   * POSITION
1079   CONSTANTS:
1080     BEGIN OF wctpc_position,
1081       first TYPE wctpc_position_type VALUE 'F', "first position
1082       last  TYPE wctpc_position_type VALUE 'L', "last position
1083     END   OF wctpc_position.
1084   * BO TYPE (domain WCDBOTYP)
1085   CONSTANTS:
1086     BEGIN OF wctpc_botyp,
1087       order   TYPE wcebotyp VALUE '0', "order
1088       tl4floc TYPE wcebotyp VALUE 'T', "task list for the functional location
1089       tl4equi TYPE wcebotyp VALUE 'E', "task list for the equipment
1090       gentl   TYPE wcebotyp VALUE 'A', "general task list
1091     END   OF wctpc_botyp.
1092   * USE CONTROL (domain WCDUSECTRL)
1093   CONSTANTS:
1094     BEGIN OF wctpc_usectrl,
1095       generic     TYPE wceusectrl VALUE space, "generic (standard setting)
1096       operational TYPE wceusectrl VALUE 'O',   "operational use
1097       template    TYPE wceusectrl VALUE 'T',   "only as a template
1098     END   OF wctpc_usectrl.
*--- End of %_CWCTPC - 1098 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTPD                                  Level 1    Page 7
Object           ZRIWFWA01                                 Lines 105
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTPD
3      *-----------------------------------------------------------------------
4      *  Purpose: print
5      ************************************************************************
6      TYPE-POOL wctpd.
7
8      * elementary types *****************************************************
9      TYPES: wctpd_prttyp_type    TYPE wceprttyp.
10     TYPES: wctpd_form_type      TYPE nmodul.
11     TYPES: wctpd_prtformat_type TYPE wceprtform.
12
13     * structures types *****************************************************
14     * PRINT COUNTERs
15     TYPES:
16       BEGIN OF wctpd_prtcnt_type,
17         tag      TYPE i,
18         test_tag TYPE i,
19       END   OF wctpd_prtcnt_type.
20     * SAPscript FORMs
21     TYPES:
22       BEGIN OF wctpd_sapscript_type,
23         open_form  TYPE sysubrc,
24         write_form TYPE sysubrc,
25         close_form TYPE sysubrc,
26       END   OF wctpd_sapscript_type.
27     * MULTIPLE TAGGING (work area)
28     TYPES:
29       BEGIN OF wctpd_mtwa_type,
30         objnr TYPE j_objnr,
31         tgcnt TYPE i,
32         uncnt TYPE i,
33         tgnr  TYPE wcetgnr,
34         unnr  TYPE wceunnr,
35       END   OF wctpd_mtwa_type.
36     * MEMORY CONTROL STRUCTURE
37     TYPES:
38       BEGIN OF wctpd_memctrl_type,
39         wap       TYPE wceboolean,
40         wapi      TYPE wceboolean,
41         wcdoc     TYPE wceboolean,
42         wcitm     TYPE wceboolean,
43         objlst    TYPE wceboolean,
44         approval  TYPE wceboolean,
45         catalogue TYPE wceboolean,
46         asgn      TYPE wceboolean,
47         wca2      TYPE wceboolean,
48       END   OF wctpd_memctrl_type.
49
50     * tables types *********************************************************
51     * MULTIPLE TAGGING
52     TYPES: wctpd_mttab_type TYPE STANDARD TABLE OF wctpd_mtwa_type WITH DEFAULT KEY.
53
54     * constants ************************************************************
55     * PRINT TYPEs (domain WCDPRTTYP)
56     CONSTANTS:
57       BEGIN OF wctpd_prttyp,
58         header   TYPE wctpd_prttyp_type VALUE '1',
59         tglst    TYPE wctpd_prttyp_type VALUE '2',
60         untglst  TYPE wctpd_prttyp_type VALUE '3',
61         tag      TYPE wctpd_prttyp_type VALUE '4',
62         test_tag TYPE wctpd_prttyp_type VALUE '5',
63         permit   TYPE wctpd_prttyp_type VALUE '6',
64       END   OF wctpd_prttyp.
65     * PRINT SUBROUTINEs
66     CONSTANTS:
67       BEGIN OF wctpd_form,
68         wap_header       TYPE wctpd_form_type VALUE 'WAP_HEADER',
69         wapi_header      TYPE wctpd_form_type VALUE 'WAPI_HEADER',
70         wcd_header       TYPE wctpd_form_type VALUE 'WCD_HEADER',
71         wap_permit       TYPE wctpd_form_type VALUE 'WAP_PERMIT',
72         wap_permit_copy  TYPE wctpd_form_type VALUE 'WAP_PERMIT_COPY',
73         wapi_permit      TYPE wctpd_form_type VALUE 'WAPI_PERMIT',
74         wapi_permit_copy TYPE wctpd_form_type VALUE 'WAPI_PERMIT_COPY',
75         wcd_permit       TYPE wctpd_form_type VALUE 'WCD_PERMIT',
76         wcd_permit_copy  TYPE wctpd_form_type VALUE 'WCD_PERMIT_COPY',
77         tag              TYPE wctpd_form_type VALUE 'TAG',
78         tag_copy         TYPE wctpd_form_type VALUE 'TAG_COPY',
79         test_tag         TYPE wctpd_form_type VALUE 'TEST_TAG',
80         test_tag_copy    TYPE wctpd_form_type VALUE 'TEST_TAG_COPY',
81         tglst            TYPE wctpd_form_type VALUE 'TAGGING',
82         untglst          TYPE wctpd_form_type VALUE 'UNTAGGING',
83       END   OF wctpd_form.
84     * PRINT FORMATs
85     CONSTANTS:
86       BEGIN OF wctpd_prtformat,
87         wap   TYPE wctpd_prtformat_type VALUE 'WAP',
88         wapi  TYPE wctpd_prtformat_type VALUE 'WAPI',
89         wcd   TYPE wctpd_prtformat_type VALUE 'WCD',
90         oplst TYPE wctpd_prtformat_type VALUE IS INITIAL,
91       END   OF wctpd_prtformat.
92     * SAPscript
93     CONSTANTS:
94       BEGIN OF wctpd_subscript,
95         BEGIN OF open_form,
96           canceled TYPE sysubrc VALUE 1,
97         END   OF open_form,
98       END   OF wctpd_subscript.
99     * MEMORY CONTROL STRUCTUREs
100    CONSTANTS:
101      BEGIN OF wctpd_memctrl,
102        wap  TYPE wctpd_memctrl_type VALUE '100011110',
103        wapi TYPE wctpd_memctrl_type VALUE '010011111',
104        wcd  TYPE wctpd_memctrl_type VALUE '001111110',
105      END   OF wctpd_memctrl.
*--- End of %_CWCTPD - 105 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTPF                                  Level 1    Page 8
Object           ZRIWFWA01                                 Lines 602
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTPF
3      *-----------------------------------------------------------------------
4      *  Purpose: function codes
5      ************************************************************************
6      TYPE-POOL wctpf.
7
8      * elementary types *****************************************************
9      TYPES: wctpf_owner_type(2) TYPE c.
10     TYPES: wctpf_prefix_type   TYPE fcode.
11     TYPES: wctpf_fcode_type    TYPE fcode.
12
13     * structures types *****************************************************
14     * EXCLUDED FUNCTION CODES (work area)
15     TYPES:
16       BEGIN OF wctpf_exclwa_type,
17         fcode TYPE wctpf_fcode_type,
18       END OF wctpf_exclwa_type.
19     * KEY PRESSED
20     TYPES:
21       BEGIN OF wctpf_key_pressed_type,
22         first  TYPE wctpf_fcode_type,
23         second TYPE wctpf_fcode_type,
24         third  TYPE wctpf_fcode_type,
25       END   OF wctpf_key_pressed_type.
26
27     * tables types *********************************************************
28     * EXCLUDED FUNCTION CODEs
29     TYPES: wctpf_excltab_type TYPE STANDARD TABLE OF wctpf_exclwa_type WITH DEFAULT KEY.
30
31     * constants ************************************************************
32     * UNSTRUCTURED
33     CONSTANTS: wctpf_assign           TYPE wctpf_fcode_type VALUE 'ASGN'.
34     CONSTANTS: wctpf_create           TYPE wctpf_fcode_type VALUE 'CREA'.
35     CONSTANTS: wctpf_copy             TYPE wctpf_fcode_type VALUE 'COPY'.
36     CONSTANTS: wctpf_create_copy      TYPE wctpf_fcode_type VALUE 'CREA-COPY'.
37     CONSTANTS: wctpf_class            TYPE wctpf_fcode_type VALUE 'CLAS'.
38     CONSTANTS: wctpf_conditions       TYPE wctpf_fcode_type VALUE 'TAGC'.
39     CONSTANTS: wctpf_types            TYPE wctpf_fcode_type VALUE 'TAGT'.
40     CONSTANTS: wctpf_default          TYPE wctpf_fcode_type VALUE 'DEFAULT'.
41     CONSTANTS: wctpf_delete           TYPE wctpf_fcode_type VALUE 'DEL'.
42     CONSTANTS: wctpf_undelete         TYPE wctpf_fcode_type VALUE 'UDEL'.
43     CONSTANTS: wctpf_display          TYPE wctpf_fcode_type VALUE 'DISP'.
44     CONSTANTS: wctpf_enter            TYPE wctpf_fcode_type VALUE  space.
45     CONSTANTS: wctpf_generate         TYPE wctpf_fcode_type VALUE 'GEN'.
46     CONSTANTS: wctpf_go               TYPE wctpf_fcode_type VALUE 'GO'.
47     CONSTANTS: wctpf_header           TYPE wctpf_fcode_type VALUE 'HEAD'.
48     CONSTANTS: wctpf_hit              TYPE wctpf_fcode_type VALUE 'HIT'.
49     CONSTANTS: wctpf_hold             TYPE wctpf_fcode_type VALUE 'HOLD'.
50     CONSTANTS: wctpf_inactive         TYPE wctpf_fcode_type VALUE 'INAC'.
51     CONSTANTS: wctpf_info             TYPE wctpf_fcode_type VALUE 'INFO'.
52     CONSTANTS: wctpf_options          TYPE wctpf_fcode_type VALUE 'OPTIONS'.
53     CONSTANTS: wctpf_partner          TYPE wctpf_fcode_type VALUE 'PERS'.
54     CONSTANTS: wctpf_save             TYPE wctpf_fcode_type VALUE 'SAVE'.
55     CONSTANTS: wctpf_set              TYPE wctpf_fcode_type VALUE 'SET'.
56     CONSTANTS: wctpf_selection        TYPE wctpf_fcode_type VALUE 'SELE'.
57     CONSTANTS: wctpf_application_log  TYPE wctpf_fcode_type VALUE 'ALOG'.
58     CONSTANTS: wctpf_undo             TYPE wctpf_fcode_type VALUE 'UNDO'.
59     CONSTANTS: wctpf_unlock           TYPE wctpf_fcode_type VALUE 'UNLOCK'.
60     CONSTANTS: wctpf_update           TYPE wctpf_fcode_type VALUE 'UPD'.
61     CONSTANTS: wctpf_confirmed        TYPE wctpf_fcode_type VALUE 'CONFIRMED'.
62     CONSTANTS: wctpf_stepwise_tagging TYPE wctpf_fcode_type VALUE 'STTG'.
63     CONSTANTS: wctpf_msg_display      TYPE wctpf_fcode_type VALUE 'MSG_DISP'.
64     CONSTANTS: wctpf_extend_validity  TYPE wctpf_fcode_type VALUE 'EXTEND'.
65     CONSTANTS: wctpf_pa_overview      TYPE wctpf_fcode_type VALUE 'PAI'.
66
67     * FCODE OWNERs
68     CONSTANTS:
69       BEGIN OF wctpf_owner,
70         undefined       TYPE wctpf_owner_type VALUE space,
71         flexible_view   TYPE wctpf_owner_type VALUE '01',
72         partner         TYPE wctpf_owner_type VALUE '02',
73         document        TYPE wctpf_owner_type VALUE '03',
74         wcm_template    TYPE wctpf_owner_type VALUE '04',
75         badi_screen     TYPE wctpf_owner_type VALUE '05',
76         badi_screen_sap TYPE wctpf_owner_type VALUE '06',
77         approval        TYPE wctpf_owner_type VALUE '07',
78         catalog1        TYPE wctpf_owner_type VALUE '08',
79         catalog2        TYPE wctpf_owner_type VALUE '09',
80         operations      TYPE wctpf_owner_type VALUE '10',
81         object_list     TYPE wctpf_owner_type VALUE '11',
82       END   OF wctpf_owner.
83     * PREFIXES OF EXTERNAL FCODEs
84     CONSTANTS:
85       BEGIN OF wctpf_prefix,
86         partner         TYPE wctpf_prefix_type VALUE 'IPAR_',
87         document        TYPE wctpf_prefix_type VALUE 'CV140',
88         wcm_template    TYPE wctpf_prefix_type VALUE 'WCHB_',
89         badi_screen     TYPE wctpf_prefix_type VALUE 'ZWCM_',
90         badi_screen_sap TYPE wctpf_prefix_type VALUE 'XWCM_',
91         approval        TYPE wctpf_prefix_type VALUE 'WCFG_',
92         catalog1        TYPE wctpf_prefix_type VALUE 'WCFJ_1_',
93         catalog2        TYPE wctpf_prefix_type VALUE 'WCFJ_2_',
94         operations      TYPE wctpf_prefix_type VALUE 'WCGM_',
95         object_list     TYPE wctpf_prefix_type VALUE 'WCFH_',
96       END   OF wctpf_prefix.
97     * WCM OBJECTs
98     CONSTANTS:
99       BEGIN OF wctpf_wcm,
100        order        TYPE wctpf_fcode_type VALUE 'ORDER',
101        wap          TYPE wctpf_fcode_type VALUE 'WAP',
102        wapi         TYPE wctpf_fcode_type VALUE 'WAPI',
103        wcd          TYPE wctpf_fcode_type VALUE 'WCD',
104        wca          TYPE wctpf_fcode_type VALUE 'WCA',
105        opwc         TYPE wctpf_fcode_type VALUE 'OPWC',
106        wctm         TYPE wctpf_fcode_type VALUE 'WCTM',
107        list_change  TYPE wctpf_fcode_type VALUE 'WCLE',
108        list_display TYPE wctpf_fcode_type VALUE 'WCLB',
109      END   OF wctpf_wcm.
110    * WAP
111    CONSTANTS:
112      BEGIN OF wctpf_wap,
113        create       TYPE wctpf_fcode_type VALUE 'WCTA',
114        change       TYPE wctpf_fcode_type VALUE 'WCTB',
115        display      TYPE wctpf_fcode_type VALUE 'WCTC',
116        with_order   TYPE wctpf_fcode_type VALUE 'WCR8',
117        with_wap     TYPE wctpf_fcode_type VALUE 'WCRA',
118        with_wapi    TYPE wctpf_fcode_type VALUE 'WCR9',
119        with_wcd     TYPE wctpf_fcode_type VALUE 'WCRF',
120        other        TYPE wctpf_fcode_type VALUE 'NWAP',
121        list_change  TYPE wctpf_fcode_type VALUE 'WCL9',
122        list_display TYPE wctpf_fcode_type VALUE 'WCLA',
123      END   OF wctpf_wap.
124    * WAPI
125    CONSTANTS:
126      BEGIN OF wctpf_wapi,
127        create       TYPE wctpf_fcode_type VALUE 'WCTH',
128        change       TYPE wctpf_fcode_type VALUE 'WCTI',
129        display      TYPE wctpf_fcode_type VALUE 'WCTJ',
130        with_order   TYPE wctpf_fcode_type VALUE 'WCRJ',
131        with_wap     TYPE wctpf_fcode_type VALUE 'WCRK',
132        with_wapi    TYPE wctpf_fcode_type VALUE 'WCRM',
133        other        TYPE wctpf_fcode_type VALUE 'NAPI',
134        list_change  TYPE wctpf_fcode_type VALUE 'WCL7',
135        list_display TYPE wctpf_fcode_type VALUE 'WCL8',
136      END   OF wctpf_wapi.
137    * WCA
138    CONSTANTS:
139      BEGIN OF wctpf_wca,
140        create       TYPE wctpf_fcode_type VALUE 'WCTK',
141        change       TYPE wctpf_fcode_type VALUE 'WCTL',
142        display      TYPE wctpf_fcode_type VALUE 'WCTM',
143        with_order   TYPE wctpf_fcode_type VALUE 'WCR5',
144        with_wap     TYPE wctpf_fcode_type VALUE 'WCR6',
145        with_wapi    TYPE wctpf_fcode_type VALUE 'WCRD',
146        with_wcd     TYPE wctpf_fcode_type VALUE 'WCR7',
147        other        TYPE wctpf_fcode_type VALUE 'NWCA',
148        list_change  TYPE wctpf_fcode_type VALUE 'WCL5',
149        list_display TYPE wctpf_fcode_type VALUE 'WCL6',
150      END   OF wctpf_wca.
151    * WCD
152    CONSTANTS:
153      BEGIN OF wctpf_wcd,
154        list_change  TYPE wctpf_fcode_type VALUE 'WCLC',
155        list_display TYPE wctpf_fcode_type VALUE 'WCLD',
156      END   OF wctpf_wcd.
157    * OPERATIONAL WCD
158    CONSTANTS:
159      BEGIN OF wctpf_opwc,
160        create       TYPE wctpf_fcode_type VALUE 'WCT6',
161        change       TYPE wctpf_fcode_type VALUE 'WCT7',
162        display      TYPE wctpf_fcode_type VALUE 'WCT8',
163        with_order   TYPE wctpf_fcode_type VALUE 'WCRG',
164        with_wap     TYPE wctpf_fcode_type VALUE 'WCRC',
165        with_wapi    TYPE wctpf_fcode_type VALUE 'WCR3',
166        with_wcd     TYPE wctpf_fcode_type VALUE 'WCR4',
167        other        TYPE wctpf_fcode_type VALUE 'NOWC',
168        list_change  TYPE wctpf_fcode_type VALUE 'WCL3',
169        list_display TYPE wctpf_fcode_type VALUE 'WCL4',
170      END   OF wctpf_opwc.
171    * WCD TEMPLATE
172    CONSTANTS:
173      BEGIN OF wctpf_wctm,
174        create       TYPE wctpf_fcode_type VALUE 'WCT1',
175        change       TYPE wctpf_fcode_type VALUE 'WCT2',
176        display      TYPE wctpf_fcode_type VALUE 'WCT3',
177        with_order   TYPE wctpf_fcode_type VALUE 'WCRH',
178        with_wap     TYPE wctpf_fcode_type VALUE 'WCRB',
179        with_wapi    TYPE wctpf_fcode_type VALUE 'WCR2',
180        with_wcd     TYPE wctpf_fcode_type VALUE 'WCR1',
181        other        TYPE wctpf_fcode_type VALUE 'NTWC',
182        list_change  TYPE wctpf_fcode_type VALUE 'WCL1',
183        list_display TYPE wctpf_fcode_type VALUE 'WCL2',
184      END   OF wctpf_wctm.
185    * OPERATIONAL LIST
186    CONSTANTS:
187      BEGIN OF wctpf_oplst,
188        list_change  TYPE wctpf_fcode_type VALUE 'WCLG',
189        list_display TYPE wctpf_fcode_type VALUE 'WCLH',
190      END   OF wctpf_oplst.
191    * WORK PERMIT (MOBILE PROCESSING)
192    CONSTANTS:
193      BEGIN OF wctpf_mwcm_wkpt,
194        list_change  TYPE wctpf_fcode_type VALUE 'WCLQ',
195        list_display TYPE wctpf_fcode_type VALUE 'WCLR',
196      END   OF wctpf_mwcm_wkpt.
197    * MODE DEPENDENT TAGGING
198    CONSTANTS:
199      BEGIN OF wctpf_mdtg,
200        list_change  TYPE wctpf_fcode_type VALUE 'WCCD',
201        list_display TYPE wctpf_fcode_type VALUE 'WCCE',
202      END   OF wctpf_mdtg.
203    * LINEUP
204    CONSTANTS:
205      BEGIN OF wctpf_lineup,
206        list_change  TYPE wctpf_fcode_type VALUE 'WCLM',
207        list_display TYPE wctpf_fcode_type VALUE 'WCLN',
208      END   OF wctpf_lineup.
209    * OPERATIONAL LINEUP
210    CONSTANTS:
211      BEGIN OF wctpf_oplu,
212        create       TYPE wctpf_fcode_type VALUE 'WCV1',
213        change       TYPE wctpf_fcode_type VALUE 'WCV2',
214        display      TYPE wctpf_fcode_type VALUE 'WCV3',
215        with_lineup  TYPE wctpf_fcode_type VALUE 'WCRO',
216        list_change  TYPE wctpf_fcode_type VALUE 'WCLK',
217        list_display TYPE wctpf_fcode_type VALUE 'WCLL',
218      END   OF wctpf_oplu.
219    * LINEUP TEMPLATE
220    CONSTANTS:
221      BEGIN OF wctpf_lutm,
222        create       TYPE wctpf_fcode_type VALUE 'WCV4',
223        change       TYPE wctpf_fcode_type VALUE 'WCV5',
224        display      TYPE wctpf_fcode_type VALUE 'WCV6',
225        with_lineup  TYPE wctpf_fcode_type VALUE 'WCRN',
226        list_change  TYPE wctpf_fcode_type VALUE 'WCLI',
227        list_display TYPE wctpf_fcode_type VALUE 'WCLJ',
228      END   OF wctpf_lutm.
229    * WORK PERMIT
230    CONSTANTS:
231      BEGIN OF wctpf_wkpt,
232        list_change  TYPE wctpf_fcode_type VALUE 'WCLO',
233        list_display TYPE wctpf_fcode_type VALUE 'WCLP',
234      END   OF wctpf_wkpt.
235    * VERIFICATION LIST
236    CONSTANTS:
237      BEGIN OF wctpf_verlst,
238        create  TYPE wctpf_fcode_type VALUE 'VERLST_CREA',
239        change  TYPE wctpf_fcode_type VALUE 'VERLST_UPD',
240        display TYPE wctpf_fcode_type VALUE 'VERLST_DISP',
241      END   OF wctpf_verlst.
242    * FUNCTIONs FOR WCM OPERATIONs
243    CONSTANTS:
244      BEGIN OF wctpf_operation,
245        aprvgrp_assign   TYPE wctpf_fcode_type VALUE 'ASGN',
246        aprvgrp_unassign TYPE wctpf_fcode_type VALUE 'UASG',
247        wcd_link         TYPE wctpf_fcode_type VALUE 'LINK',
248        wcd_unlink       TYPE wctpf_fcode_type VALUE 'DEL',
249      END   OF wctpf_operation.
250    * WCD ITEMs
251    CONSTANTS:
252      BEGIN OF wctpf_wcitm,
253        dialog  TYPE wctpf_fcode_type VALUE 'ITM1',
254        process TYPE wctpf_fcode_type VALUE 'ITM3',
255      END   OF wctpf_wcitm.
256    * FUNCTIONs TO NAVIGATE
257    CONSTANTS:
258      BEGIN OF wctpf_navigation,
259        exit             TYPE wctpf_fcode_type VALUE 'EXIT',
260        back             TYPE wctpf_fcode_type VALUE 'BACK',
261        back_list        TYPE wctpf_fcode_type VALUE 'BCK',
262    * (your are reminded, that 'BACK' can not be controlled at user command)
263        cancel           TYPE wctpf_fcode_type VALUE 'CANC',
264        next             TYPE wctpf_fcode_type VALUE 'NEXT',
265        previous         TYPE wctpf_fcode_type VALUE 'PREV',
266        pick             TYPE wctpf_fcode_type VALUE 'PICK',
267        copy_model       TYPE wctpf_fcode_type VALUE 'CMDL',
268        graphical_system TYPE wctpf_fcode_type VALUE 'GSYS',
269        goto             TYPE wctpf_fcode_type VALUE 'GOTO',
270        job_overview     TYPE wctpf_fcode_type VALUE 'JOB_OVERVIEW',
271      END   OF wctpf_navigation.
272    * COPY MODELs
273    CONSTANTS:
274      BEGIN OF wctpf_copy_model,
275        header TYPE wctpf_fcode_type VALUE 'CMDL_HDR',
276        item   TYPE wctpf_fcode_type VALUE 'CMDL_ITM',
277      END   OF wctpf_copy_model.
278    * CHANGE DOCUMENTs
279    CONSTANTS:
280      BEGIN OF wctpf_change_document,
281        header TYPE wctpf_fcode_type VALUE 'CGD',
282        item   TYPE wctpf_fcode_type VALUE 'CGDI',
283      END   OF wctpf_change_document.
284    * TAB PAGEs
285    CONSTANTS:
286      BEGIN OF wctpf_tab_page,
287        one   TYPE wctpf_fcode_type VALUE 'TAB1',
288        two   TYPE wctpf_fcode_type VALUE 'TAB2',
289        three TYPE wctpf_fcode_type VALUE 'TAB3',
290        four  TYPE wctpf_fcode_type VALUE 'TAB4',
291        five  TYPE wctpf_fcode_type VALUE 'TAB5',
292        six   TYPE wctpf_fcode_type VALUE 'TAB6',
293        seven TYPE wctpf_fcode_type VALUE 'TAB7',
294        eight TYPE wctpf_fcode_type VALUE 'TAB8',
295        nine  TYPE wctpf_fcode_type VALUE 'TAB9',
296      END   OF wctpf_tab_page.
297    * PUSHBUTTONs
298    CONSTANTS:
299      BEGIN OF wctpf_pushbutton,
300        one TYPE wctpf_fcode_type VALUE 'PB1',
301        two TYPE wctpf_fcode_type VALUE 'PB2',
302      END   OF wctpf_pushbutton.
303    * ADMINISTRATION DATA
304    CONSTANTS:
305      BEGIN OF wctpf_administration_data,
306        header TYPE wctpf_fcode_type VALUE 'ADM_HDR',
307        item   TYPE wctpf_fcode_type VALUE 'ADM_ITM',
308      END   OF wctpf_administration_data.
309    * FUNCTIONs FOR APPROVALs
310    CONSTANTS:
311      BEGIN OF wctpf_approval,
312        dialog     TYPE wctpf_fcode_type VALUE 'APRV',
313        approve    TYPE wctpf_fcode_type VALUE 'APPR',
314        disapprove TYPE wctpf_fcode_type VALUE 'INAC',
315      END   OF wctpf_approval.
316    * LONG TEXT TYPEs
317    CONSTANTS:
318      BEGIN OF wctpf_text,
319        header    TYPE wctpf_fcode_type VALUE 'LTXT',
320        item      TYPE wctpf_fcode_type VALUE 'LTXI',
321        untagging TYPE wctpf_fcode_type VALUE 'TXT1',
322        tagging   TYPE wctpf_fcode_type VALUE 'TXT2',
323        rejection TYPE wctpf_fcode_type VALUE 'TXT3',
324        requal    TYPE wctpf_fcode_type VALUE 'REQU',
325      END   OF wctpf_text.
326    * DOCUMENT TYPEs
327    CONSTANTS:
328      BEGIN OF wctpf_document,
329        header TYPE wctpf_fcode_type VALUE 'DOCU',
330        item   TYPE wctpf_fcode_type VALUE 'DOCI',
331      END   OF wctpf_document.
332    * ASSIGNMENTs
333    CONSTANTS:
334      BEGIN OF wctpf_assignment,
335        up   TYPE wctpf_fcode_type VALUE 'UPLN',
336        down TYPE wctpf_fcode_type VALUE 'DNLN',
337      END   OF wctpf_assignment.
338    * MOBILE WCM - ACTIVITIEs
339    CONSTANTS:
340      BEGIN OF wctpf_activity,
341        completed TYPE wctpf_fcode_type VALUE 'TASK-CLSD',
342        rejected  TYPE wctpf_fcode_type VALUE 'TASK-REJC',
343        executed  TYPE wctpf_fcode_type VALUE 'TASK-EXEC',
344      END   OF wctpf_activity.
345    * FUNCTIONs FOR TECHNICAL OBJECTs
346    CONSTANTS:
347      BEGIN OF wctpf_object,
348        list           TYPE wctpf_fcode_type VALUE 'COBJ',
349        structure_list TYPE wctpf_fcode_type VALUE 'STLI',
350        predecessor    TYPE wctpf_fcode_type VALUE 'PRED',
351        equipment      TYPE wctpf_fcode_type VALUE 'EQUI',
352        func_loc       TYPE wctpf_fcode_type VALUE 'FLO ',
353      END   OF wctpf_object.
354    * INSERT
355    CONSTANTS:
356      BEGIN OF wctpf_insert,
357        line TYPE wctpf_fcode_type VALUE 'INSL',
358      END   OF wctpf_insert.
359    * FUNTION KEYs
360    CONSTANTS:
361      BEGIN OF wctpf_function_key,
362        one   TYPE wctpf_fcode_type VALUE 'FC01',
363        two   TYPE wctpf_fcode_type VALUE 'FC02',
364        three TYPE wctpf_fcode_type VALUE 'FC03',
365        four  TYPE wctpf_fcode_type VALUE 'FC04',
366        five  TYPE wctpf_fcode_type VALUE 'FC05',
367      END   OF wctpf_function_key.
368    * CHECKs
369    CONSTANTS:
370      BEGIN OF wctpf_check,
371        one    TYPE wctpf_fcode_type VALUE 'CHK1',
372        two    TYPE wctpf_fcode_type VALUE 'CHK2',
373        three  TYPE wctpf_fcode_type VALUE 'CHK3',
374        four   TYPE wctpf_fcode_type VALUE 'CHK4',
375        five   TYPE wctpf_fcode_type VALUE 'CHK5',
376        six    TYPE wctpf_fcode_type VALUE 'CHK6',
377        seven  TYPE wctpf_fcode_type VALUE 'CHK7',
378        eight  TYPE wctpf_fcode_type VALUE 'CHK8',
379        nine   TYPE wctpf_fcode_type VALUE 'CHK9',
380        ten    TYPE wctpf_fcode_type VALUE 'CHK10',
381        eleven TYPE wctpf_fcode_type VALUE 'CHK11',
382        twelve TYPE wctpf_fcode_type VALUE 'CHK12',
383      END   OF wctpf_check.
384    * LIST PROCESSING
385    CONSTANTS:
386      BEGIN OF wctpf_list,
387        sort_up                TYPE wctpf_fcode_type VALUE 'SOUP',
388        sort_down              TYPE wctpf_fcode_type VALUE 'SODN',
389        numbering              TYPE wctpf_fcode_type VALUE 'NUM',
390        select_all             TYPE wctpf_fcode_type VALUE 'SEA',
391        deselect_all           TYPE wctpf_fcode_type VALUE 'DSEA',
392        block_select           TYPE wctpf_fcode_type VALUE 'BLSE',
393        tick                   TYPE wctpf_fcode_type VALUE 'TICK',
394        toggle_display_change  TYPE wctpf_fcode_type VALUE 'V-A',
395        toggle_active_inactive TYPE wctpf_fcode_type VALUE 'I-A',
396        toggle_output          TYPE wctpf_fcode_type VALUE 'ONE-TWO',
397        navigate               TYPE wctpf_fcode_type VALUE 'NAV',
398        toggle_up_down         TYPE wctpf_fcode_type VALUE 'UP-DN',
399        refresh                TYPE wctpf_fcode_type VALUE 'REFR',
400        propose                TYPE wctpf_fcode_type VALUE 'PROP',
401        adjust                 TYPE wctpf_fcode_type VALUE 'ADJUST',
402        hierarchy              TYPE wctpf_fcode_type VALUE 'TREE',
403        history                TYPE wctpf_fcode_type VALUE 'HISTORY',
404        step                   TYPE wctpf_fcode_type VALUE 'STEP',
405        BEGIN OF object,
406          order                TYPE wctpf_fcode_type VALUE 'LIST_OR',
407          wap                  TYPE wctpf_fcode_type VALUE 'LIST_WW',
408          wapi                 TYPE wctpf_fcode_type VALUE 'LIST_WA',
409          wcd                  TYPE wctpf_fcode_type VALUE 'LIST_WD',
410        END   OF object,
411        dummy                  TYPE wctpf_fcode_type VALUE 'DUMMY',
412      END   OF wctpf_list.
413    * DATA AREA
414    CONSTANTS:
415      BEGIN OF wctpf_data_area,
416        expand   TYPE wctpf_fcode_type VALUE 'EXPAND',
417        collapse TYPE wctpf_fcode_type VALUE 'COLLAPSE',
418        toggle   TYPE wctpf_fcode_type VALUE 'EXPAND-COLLAPSE',
419      END   OF wctpf_data_area.
420    * FUNCTIONs FOR FILTERs
421    CONSTANTS:
422      BEGIN OF wctpf_filter,
423        undo          TYPE wctpf_fcode_type VALUE 'FLTR_UNDO',
424        dialog        TYPE wctpf_fcode_type VALUE 'FLTR',
425        reset         TYPE wctpf_fcode_type VALUE 'DEL',
426        BEGIN OF comparison,
427          delete      TYPE wctpf_fcode_type VALUE 'FLTR_DEL',
428          insert      TYPE wctpf_fcode_type VALUE 'FLTR_INS',
429          BEGIN OF update,
430            equal     TYPE wctpf_fcode_type VALUE 'FLTR_EQ',
431            not_equal TYPE wctpf_fcode_type VALUE 'FLTR_NE',
432          END   OF update,
433        END   OF comparison,
434        BEGIN OF object,
435          order       TYPE wctpf_fcode_type VALUE 'FLTR_OR',
436          wap         TYPE wctpf_fcode_type VALUE 'FLTR_WW',
437          wapi        TYPE wctpf_fcode_type VALUE 'FLTR_WA',
438          wcd         TYPE wctpf_fcode_type VALUE 'FLTR_WD',
439        END   OF object,
440      END   OF wctpf_filter.
441    * LIST COMPARISON
442    CONSTANTS:
443      BEGIN OF wctpf_compare,
444        with_copy_model TYPE wctpf_fcode_type VALUE 'CMP_CM',
445        with_wcd        TYPE wctpf_fcode_type VALUE 'CMP_WCD',
446      END   OF wctpf_compare.
447    * HIERARCHY
448    CONSTANTS:
449      BEGIN OF wctpf_hierarchy,
450        expand_sub_tree   TYPE wctpf_fcode_type VALUE 'TREP',
451        collapse_sub_tree TYPE wctpf_fcode_type VALUE 'TRCM',
452        position_cursor   TYPE wctpf_fcode_type VALUE 'TRTO',
453        color_legend      TYPE wctpf_fcode_type VALUE 'TRCL',
454        toggle_layout     TYPE wctpf_fcode_type VALUE 'TRLY',
455        hotspot           TYPE wctpf_fcode_type VALUE 'TRZM',
456        pick              TYPE wctpf_fcode_type VALUE 'TRPI',
457      END   OF wctpf_hierarchy.
458    * ALV
459    CONSTANTS:
460      BEGIN OF wctpf_alv,
461        continue     TYPE wctpf_fcode_type VALUE '&ONT',
462        cancel       TYPE wctpf_fcode_type VALUE '&AC1',
463        find         TYPE wctpf_fcode_type VALUE '%SC',
464        find_next    TYPE wctpf_fcode_type VALUE '%SC+',
465        select_all   TYPE wctpf_fcode_type VALUE '&ALL',
466        deselect_all TYPE wctpf_fcode_type VALUE '&SAL',
467        pick         TYPE wctpf_fcode_type VALUE '&IC1',
468        details      TYPE wctpf_fcode_type VALUE '&ETA',
469        sort_up      TYPE wctpf_fcode_type VALUE '&OUP',
470        sort_down    TYPE wctpf_fcode_type VALUE '&ODN',
471        filter       TYPE wctpf_fcode_type VALUE '&ILT',
472        print        TYPE wctpf_fcode_type VALUE '&RNT',
473      END   OF wctpf_alv.
474    * CONFLICT
475    CONSTANTS:
476      BEGIN OF wctpf_conflict,
477        wcdoc TYPE wctpf_fcode_type VALUE 'CONF',
478        item  TYPE wctpf_fcode_type VALUE 'CONI',
479        tag1  TYPE wctpf_fcode_type VALUE 'TAG1',
480        tag2  TYPE wctpf_fcode_type VALUE 'TAG2',
481        msg   TYPE wctpf_fcode_type VALUE 'MSG',
482        error TYPE wctpf_fcode_type VALUE 'ERR',
483      END   OF wctpf_conflict.
484    * PAGING
485    CONSTANTS:
486      BEGIN OF wctpf_page,
487        top      TYPE wctpf_fcode_type VALUE 'P--',
488        up       TYPE wctpf_fcode_type VALUE 'P-',
489        down     TYPE wctpf_fcode_type VALUE 'P+',
490        bottom   TYPE wctpf_fcode_type VALUE 'P++',
491        new_item TYPE wctpf_fcode_type VALUE 'NEW',
492      END   OF wctpf_page.
493    * CLIPBOARD FUNCTIONs
494    CONSTANTS:
495      BEGIN OF wctpf_clipboard,
496        cut    TYPE wctpf_fcode_type VALUE 'CUT',
497        copy   TYPE wctpf_fcode_type VALUE 'COPY',
498        append TYPE wctpf_fcode_type VALUE 'APND',
499        paste  TYPE wctpf_fcode_type VALUE 'PAST',
500        edit   TYPE wctpf_fcode_type VALUE 'EDIT',
501        import TYPE wctpf_fcode_type VALUE 'IMP',
502      END   OF wctpf_clipboard.
503    * PRINT TYPEs
504    CONSTANTS:
505      BEGIN OF wctpf_print,
506        header        TYPE wctpf_fcode_type VALUE 'PRI',
507        permit        TYPE wctpf_fcode_type VALUE 'PRI0',
508        tglst         TYPE wctpf_fcode_type VALUE 'PRI1',
509        untglst       TYPE wctpf_fcode_type VALUE 'PRI2',
510        copy_tag      TYPE wctpf_fcode_type VALUE 'PRI3',
511        copy_test_tag TYPE wctpf_fcode_type VALUE 'PRI4',
512        preprint_tag  TYPE wctpf_fcode_type VALUE 'PRI5',
513      END   OF wctpf_print.
514    * WORK PERMIT
515    CONSTANTS:
516      BEGIN OF wctpf_permit,
517        hand_out TYPE wctpf_fcode_type VALUE 'HOWP',
518        return   TYPE wctpf_fcode_type VALUE 'RWP',
519      END   OF wctpf_permit.
520    * FUNCTIONs FOR MOBILE WCM
521    CONSTANTS:
522      BEGIN OF wctpf_export,
523        tglst   TYPE wctpf_fcode_type VALUE 'EXP1',
524        untglst TYPE wctpf_fcode_type VALUE 'EXP2',
525        wkpt    TYPE wctpf_fcode_type VALUE 'EXP3',
526        display TYPE wctpf_fcode_type VALUE 'EXP_DISP',
527      END   OF wctpf_export.
528    * CATALOGUEs
529    CONSTANTS:
530      BEGIN OF wctpf_catalog,
531        typ1 TYPE wctpf_fcode_type VALUE 'CAT1',
532        typ2 TYPE wctpf_fcode_type VALUE 'CAT2',
533      END   OF wctpf_catalog.
534    * ANSWERs
535    CONSTANTS:
536      BEGIN OF wctpf_answer,
537        yes TYPE wctpf_fcode_type VALUE 'YES',
538        no  TYPE wctpf_fcode_type VALUE 'NO',
539      END   OF wctpf_answer.
540    * STATUS
541    CONSTANTS:
542      BEGIN OF wctpf_status,
543        detail              TYPE wctpf_fcode_type VALUE 'STAT',
544        detail_item         TYPE wctpf_fcode_type VALUE 'STAI',
545        header              TYPE wctpf_fcode_type VALUE 'STAT_HDR',
546        step                TYPE wctpf_fcode_type VALUE 'STAT_STEP',
547        item                TYPE wctpf_fcode_type VALUE 'STAT_ITM',
548        pa_set              TYPE wctpf_fcode_type VALUE 'PAS',
549        pa_reset            TYPE wctpf_fcode_type VALUE 'PAR',
550        delflg_set          TYPE wctpf_fcode_type VALUE 'DFLS',
551        delflg_reset        TYPE wctpf_fcode_type VALUE 'DFLR',
552        active              TYPE wctpf_fcode_type VALUE 'ACTS',
553        inactive            TYPE wctpf_fcode_type VALUE 'ACTR',
554        deactivated         TYPE wctpf_fcode_type VALUE 'DACT',
555        prepared            TYPE wctpf_fcode_type VALUE 'PREP',
556        prepared_reset      TYPE wctpf_fcode_type VALUE 'HPRP',
557        rejected            TYPE wctpf_fcode_type VALUE 'REJC',
558        closed              TYPE wctpf_fcode_type VALUE 'CLSD',
559        temp_entry_set      TYPE wctpf_fcode_type VALUE 'TEYS',
560        temp_entry_reset    TYPE wctpf_fcode_type VALUE 'TEYR',
561        to_be_tagged        TYPE wctpf_fcode_type VALUE 'BTG',
562        tag_printed         TYPE wctpf_fcode_type VALUE 'PTAG',
563        tagged              TYPE wctpf_fcode_type VALUE 'ETG',
564        to_be_untagged      TYPE wctpf_fcode_type VALUE 'BUG',
565        untagged            TYPE wctpf_fcode_type VALUE 'EUG',
566        to_be_temp_untagged TYPE wctpf_fcode_type VALUE 'BTUG',
567        test_tag_printed    TYPE wctpf_fcode_type VALUE 'PTST',
568        temp_untagged       TYPE wctpf_fcode_type VALUE 'ETUG',
569        processing          TYPE wctpf_fcode_type VALUE 'PROC',
570      END   OF wctpf_status.
571    * USER STATUS
572    CONSTANTS:
573      BEGIN OF wctpf_usrstat,
574        set   TYPE wctpf_fcode_type VALUE 'USRST_SET',
575        reset TYPE wctpf_fcode_type VALUE 'USRST_RESET',
576      END   OF wctpf_usrstat.
577    * MENU ENHANCEMENTs
578    CONSTANTS:
579      BEGIN OF wctpf_enhancements,
580        first   TYPE wctpf_fcode_type VALUE '+USR1',
581        second  TYPE wctpf_fcode_type VALUE '+USR2',
582        third   TYPE wctpf_fcode_type VALUE '+USR3',
583        fourth  TYPE wctpf_fcode_type VALUE '+USR4',
584        fifth   TYPE wctpf_fcode_type VALUE '+USR5',
585        sixth   TYPE wctpf_fcode_type VALUE '+USR6',
586        seventh TYPE wctpf_fcode_type VALUE '+USR7',
587        eight   TYPE wctpf_fcode_type VALUE '+USR8',
588        ninth   TYPE wctpf_fcode_type VALUE '+USR9',
589      END   OF wctpf_enhancements.
590    * MENU ENHANCEMENTs (SAP-INTERNALLY)
591    CONSTANTS:
592      BEGIN OF wctpf_enhancements_sap,
593        first  TYPE wctpf_fcode_type VALUE '+SAP1',
594        second TYPE wctpf_fcode_type VALUE '+SAP2',
595        third  TYPE wctpf_fcode_type VALUE '+SAP3',
596      END   OF wctpf_enhancements_sap.
597    * TEXT MAINTENANCE
598    CONSTANTS:
599      BEGIN OF wctpf_text_maint,
600        append  TYPE wctpf_fcode_type VALUE 'APND',
601        replace TYPE wctpf_fcode_type VALUE 'REPL',
602      END   OF wctpf_text_maint.
*--- End of %_CWCTPF - 602 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTPM                                  Level 1    Page 9
Object           ZRIWFWA01                                 Lines 652
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTPM
3      *-----------------------------------------------------------------------
4      *  Purpose: messages
5      ************************************************************************
6      TYPE-POOL wctpm.
7
8      * elementary types *****************************************************
9      TYPES: wctpm_msgtyp_type TYPE symsgty.
10
11     * structures types *****************************************************
12     * MESSAGE TYPES COUNTERs
13     TYPES:
14       BEGIN OF wctpm_msgcnt_type,
15         error   TYPE i,
16         warning TYPE i,
17         nothing TYPE i,
18       END   OF wctpm_msgcnt_type.
19     * MESSAGE TYPEs
20     CONSTANTS:
21       BEGIN OF wctpm_msgtyp,
22         termination  TYPE symsgty VALUE 'X',
23         abnormal_end TYPE symsgty VALUE 'A',
24         error        TYPE symsgty VALUE 'E',
25         warning      TYPE symsgty VALUE 'W',
26         info         TYPE symsgty VALUE 'I',
27         system       TYPE symsgty VALUE 'S',
28         nothing      TYPE symsgty VALUE 'N',
29         initial      TYPE symsgty VALUE space,
30       END   OF wctpm_msgtyp.
31     * MESSAGE IDs
32     CONSTANTS:
33       BEGIN OF wctpm_msgid,
34         00       TYPE symsgid VALUE '00',
35         01       TYPE symsgid VALUE '01',
36         26       TYPE symsgid VALUE '26',
37         1s       TYPE symsgid VALUE '1S',
38         ba       TYPE symsgid VALUE 'BA',
39         bs       TYPE symsgid VALUE 'BS',
40         cj       TYPE symsgid VALUE 'CJ',
41         csm      TYPE symsgid VALUE 'CSM',
42         dh       TYPE symsgid VALUE 'DH',
43         ds       TYPE symsgid VALUE 'DS',
44         i0       TYPE symsgid VALUE 'I0',
45         i4       TYPE symsgid VALUE 'I4',
46         ieq      TYPE symsgid VALUE 'IEQ',
47         ig       TYPE symsgid VALUE 'IG',
48         ih       TYPE symsgid VALUE 'IH',
49         il       TYPE symsgid VALUE 'IL',
50         im       TYPE symsgid VALUE 'IM',
51         io       TYPE symsgid VALUE 'IO',
52         is       TYPE symsgid VALUE 'IS',
53         ir       TYPE symsgid VALUE 'IR',
54         iu       TYPE symsgid VALUE 'IU',
55         iw       TYPE symsgid VALUE 'IW',
56         iwo_bapi TYPE symsgid VALUE 'IWO_BAPI',
57         td       TYPE symsgid VALUE 'TD',
58         mc       TYPE symsgid VALUE 'MC',
59         sy       TYPE symsgid VALUE 'SY',
60         st       TYPE symsgid VALUE 'ST',
61         se       TYPE symsgid VALUE 'SE',
62         spi_tool TYPE symsgid VALUE '/PLMB/SPI_TOOLS',
63       END   OF wctpm_msgid.
64
65     * tables types *********************************************************
66
67     * constants ************************************************************
68     * MESSAGE NUMBERs
69     CONSTANTS:
70       BEGIN OF wctpm_msgno,
71         101 TYPE symsgno VALUE '101', "Data for mode-dependent tagging was determined
72         102 TYPE symsgno VALUE '102', "Data for mode-dependent tagging has been deleted
73         103 TYPE symsgno VALUE '103', "In maintenance planning plant &1, overall condition &2 is not defined
74         104 TYPE symsgno VALUE '104', "Date & is in the past
75         105 TYPE symsgno VALUE '105', "Enter either functional location or equipment
76         106 TYPE symsgno VALUE '106', "Execute the function later
77         107 TYPE symsgno VALUE '107', "This entry has already been assigned
78         108 TYPE symsgno VALUE '108', "This entry has already been deleted
79         109 TYPE symsgno VALUE '109', "The assignment has not been made
80         110 TYPE symsgno VALUE '110', "No & are assigned
81         111 TYPE symsgno VALUE '111', "This is the wrong direction
82         112 TYPE symsgno VALUE '112', "You cannot assign &
83         113 TYPE symsgno VALUE '113', "Assignments already exist
84         114 TYPE symsgno VALUE '114', "Assignments do not exist
85         115 TYPE symsgno VALUE '115', "&1 &2 is before &3 &4
86         116 TYPE symsgno VALUE '116', "The &1 &2 with print format &3 was copied
87         117 TYPE symsgno VALUE '117', "The profile in maintenance planning plant &1 was adapted
88         118 TYPE symsgno VALUE '118', "Plant & does not exist
89         119 TYPE symsgno VALUE '119', "Maintenance planning plant & does not exist
90         120 TYPE symsgno VALUE '120', "Maintenance plant &1 does not support maintenance planner group &2
91         121 TYPE symsgno VALUE '121', "Plant &1 does not support location &2
92         122 TYPE symsgno VALUE '122', "Maintenance plant &1 does not support plant section &2
93         123 TYPE symsgno VALUE '123', "Check whether the data is valid for the new reference object
94         124 TYPE symsgno VALUE '124', "The reference object and object list cannot be copied
95         125 TYPE symsgno VALUE '125', "Perform Identification
96         126 TYPE symsgno VALUE '126', "Number & does not lie within external number range interval
97         127 TYPE symsgno VALUE '127', "&2 was created for maintenance planning plant &1
98         128 TYPE symsgno VALUE '128', "Functional location &1 belongs to maintenance planning plant &2
99         129 TYPE symsgno VALUE '129', "Equipment &1 belongs to maintenance planning plant &2
100        130 TYPE symsgno VALUE '130', "&1 &2 is flagged for deletion
101        131 TYPE symsgno VALUE '131', "&1 &2 is inactive
102        132 TYPE symsgno VALUE '132', "The maintenance planning plants are different
103        133 TYPE symsgno VALUE '133', "Long text was changed, you cannot cancel
104        134 TYPE symsgno VALUE '134', "Define a valid view
105        135 TYPE symsgno VALUE '135', "& already exists
106        136 TYPE symsgno VALUE '136', "Deselect work approval indicator
107        137 TYPE symsgno VALUE '137', "User & is locked
108        138 TYPE symsgno VALUE '138', "Operational list was created with the number &
109        139 TYPE symsgno VALUE '139', "Operational list was printed
110        140 TYPE symsgno VALUE '140', "&1 was printed
111        141 TYPE symsgno VALUE '141', "An item was selected
112        142 TYPE symsgno VALUE '142', "& items were selected
113        143 TYPE symsgno VALUE '143', "Approval group is already assigned
114        144 TYPE symsgno VALUE '144', "You cannot assign any more &
115        145 TYPE symsgno VALUE '145', "&1 &2 was closed
116        146 TYPE symsgno VALUE '146', "&1 &2 was rejected
117        147 TYPE symsgno VALUE '147', "Release for execution has been issued for order &
118        148 TYPE symsgno VALUE '148', "No entry available
119        149 TYPE symsgno VALUE '149', "Nearly all numbers are assigned for object & in internal number range
120        150 TYPE symsgno VALUE '150', "Last number was assigned for object & in internal number range
121        151 TYPE symsgno VALUE '151', "For & you need the internal number assignment
122        152 TYPE symsgno VALUE '152', "Release for execution has been issued for operation &
123        153 TYPE symsgno VALUE '153', "Date & lies too far in the future
124        154 TYPE symsgno VALUE '154', "One entry corresponded to the selection conditions
125        155 TYPE symsgno VALUE '155', "Enter a valid object
126        156 TYPE symsgno VALUE '156', "You can only assign &1 &2
127        157 TYPE symsgno VALUE '157', "&1 &2 were assigned
128        158 TYPE symsgno VALUE '158', "No & satisfy the selection criteria
129        159 TYPE symsgno VALUE '159', "Invalid selection
130        160 TYPE symsgno VALUE '160', "Invalid cursor position
131        161 TYPE symsgno VALUE '161', "Nothing was changed
132        162 TYPE symsgno VALUE '162', "You can only assign one &
133        163 TYPE symsgno VALUE '163', "You cannot reset date and time (&1 &2)
134        164 TYPE symsgno VALUE '164', "Enter an approval group
135        165 TYPE symsgno VALUE '165', "Data cannot be copied
136        166 TYPE symsgno VALUE '166', "Enter a reference object
137        167 TYPE symsgno VALUE '167', "You cannot create the WCM object (&) directly
138        168 TYPE symsgno VALUE '168', "You cannot change the WCM object (&) directly
139        169 TYPE symsgno VALUE '169', "You cannot use the &1 &2 as a template
140        170 TYPE symsgno VALUE '170', "& assignments were deleted
141        171 TYPE symsgno VALUE '171', "Not all subordinate approvals are issued
142        172 TYPE symsgno VALUE '172', "Work for order & has been completed
143        173 TYPE symsgno VALUE '173', "Work for operation & has been completed
144        174 TYPE symsgno VALUE '174', "Work for operation & has not been completed
145        175 TYPE symsgno VALUE '175', "Release for execution for operation & has not been issued
146        176 TYPE symsgno VALUE '176', "Incorrect master data for mode-dependent tagging
147        177 TYPE symsgno VALUE '177', "Incomplete master data for mode-dependent tagging
148        178 TYPE symsgno VALUE '178', "Maximum number of parameters permitted is 10
149        179 TYPE symsgno VALUE '179', "Feature of authorization or calling up AUTHORITY CHECK is incorrect
150        180 TYPE symsgno VALUE '180', "You cannot delete approval &
151        181 TYPE symsgno VALUE '181', "You have no authorization for &1 (&2)
152        182 TYPE symsgno VALUE '182', "Approval & must be issued to enable switching
153        183 TYPE symsgno VALUE '183', "You cannot deactivate the item
154        184 TYPE symsgno VALUE '184', "The changes have been saved
155        185 TYPE symsgno VALUE '185', "Enter a technical object, which is not of type &
156        186 TYPE symsgno VALUE '186', "Enter a reason for rejecting the WCM object
157        187 TYPE symsgno VALUE '187', "First end the lockout/tagout
158        188 TYPE symsgno VALUE '188', "Maintain the obligatory roles for the assigned partner profile
159        189 TYPE symsgno VALUE '189', "Select one valid entry only
160        190 TYPE symsgno VALUE '190', "Enter the time
161        191 TYPE symsgno VALUE '191', "Enter the unit
162        192 TYPE symsgno VALUE '192', "Enter the operational group
163        193 TYPE symsgno VALUE '193', "Enter the tagging condition
164        194 TYPE symsgno VALUE '194', "Clipboard is empty
165        195 TYPE symsgno VALUE '195', "& items have been inserted
166        196 TYPE symsgno VALUE '196', "One item has been inserted
167        197 TYPE symsgno VALUE '197', "Data has been saved
168        198 TYPE symsgno VALUE '198', "Select a maximum of one entry
169        199 TYPE symsgno VALUE '199', "Approvals were issued/revoked automatically
170        200 TYPE symsgno VALUE '200', "&1 &2 does not exist
171        201 TYPE symsgno VALUE '201', "& items were adjusted
172        202 TYPE symsgno VALUE '202', "& does not exist
173        203 TYPE symsgno VALUE '203', "&1 &2 was assigned
174        204 TYPE symsgno VALUE '204', "&1 &2 already exists
175        205 TYPE symsgno VALUE '205', "One item was adjusted
176        206 TYPE symsgno VALUE '206', "&1 is not a &2
177        207 TYPE symsgno VALUE '207', "&1 was saved with number &2
178        208 TYPE symsgno VALUE '208', "Check the item
179        209 TYPE symsgno VALUE '209', "Enter the type of technical object
180        210 TYPE symsgno VALUE '210', "Enter the technical object
181        211 TYPE symsgno VALUE '211', "Data was saved
182        212 TYPE symsgno VALUE '212', "Enter the tag print format
183        213 TYPE symsgno VALUE '213', "Select two valid entries
184        214 TYPE symsgno VALUE '214', "Select a second valid entry
185        215 TYPE symsgno VALUE '215', "In op. group &1, op. condition &2 is not allowed for &3 &4
186        216 TYPE symsgno VALUE '216', "One item was added to the clipboard
187        217 TYPE symsgno VALUE '217', "One item was copied to the clipboard
188        218 TYPE symsgno VALUE '218', "& items were added to the clipboard
189        219 TYPE symsgno VALUE '219', "& items were copied to the clipboard
190        220 TYPE symsgno VALUE '220', "The function is not permitted
191        221 TYPE symsgno VALUE '221', "Clipboard is deleted
192        222 TYPE symsgno VALUE '222', "Select field: Tag required
193        223 TYPE symsgno VALUE '223', "Type & is not permitted
194        224 TYPE symsgno VALUE '224', "&1 are the same
195        225 TYPE symsgno VALUE '225', "No required approvals found
196        226 TYPE symsgno VALUE '226', "& parameter is blank
197        227 TYPE symsgno VALUE '227', "& approval is assigned to the WCM object
198        228 TYPE symsgno VALUE '228', "&4 are not the same
199        229 TYPE symsgno VALUE '229', "&4 was changed
200        230 TYPE symsgno VALUE '230', "Function is not available
201        231 TYPE symsgno VALUE '231', "Select at least one valid entry
202        232 TYPE symsgno VALUE '232', "Before issueing the approval, set the status & (&)
203        233 TYPE symsgno VALUE '233', "Check completed successfully
204        234 TYPE symsgno VALUE '234', "Combination of print format &1 and print category &2 is not permitted
205        235 TYPE symsgno VALUE '235', "&1 was not changed
206        236 TYPE symsgno VALUE '236', "This entry is not allowed
207        237 TYPE symsgno VALUE '237', "WCM has not been released
208        238 TYPE symsgno VALUE '238', "You cannot assign any approvals
209        239 TYPE symsgno VALUE '239', "WCM object doesn't exist in this maintenance planning plant &
210        240 TYPE symsgno VALUE '240', "This is not a transaction for &
211        241 TYPE symsgno VALUE '241', "Deletion indicator was saved in the database
212        242 TYPE symsgno VALUE '242', "Reorganization run completed successfully
213        243 TYPE symsgno VALUE '243', "Errors occurred during reorganization run
214        244 TYPE symsgno VALUE '244', "No changes were made to database
215        245 TYPE symsgno VALUE '245', "Navigation not permitted
216        246 TYPE symsgno VALUE '246', "Maintenance planning plant & not permitted
217        247 TYPE symsgno VALUE '247', "External number assignment not permitted
218        248 TYPE symsgno VALUE '248', "You can only change WCM object (&) directly
219        249 TYPE symsgno VALUE '249', "You can only create WCM object (&) directly
220        250 TYPE symsgno VALUE '250', "You cannot select a &
221        251 TYPE symsgno VALUE '251', "Data has been changed
222        252 TYPE symsgno VALUE '252', "Data was deleted
223        253 TYPE symsgno VALUE '253', "You cannot delete type &
224        254 TYPE symsgno VALUE '254', "No more applications possible in the standard model
225        255 TYPE symsgno VALUE '255', "Type & already exists
226        256 TYPE symsgno VALUE '256', "Type & does not exist
227        257 TYPE symsgno VALUE '257', "Entry &1 &2 &3  could not be locked.
228        258 TYPE symsgno VALUE '258', "No processing for entry &1 &2 &3
229        259 TYPE symsgno VALUE '259', "Error in BAdI implementation
230        260 TYPE symsgno VALUE '260', "No further overall conditions exist
231        261 TYPE symsgno VALUE '261', "No further operational conditions exist
232        262 TYPE symsgno VALUE '262', "No further operational types exist
233        263 TYPE symsgno VALUE '263', "Entries that are flagged for deletion cannot be changed
234        264 TYPE symsgno VALUE '264', "Data could not be saved
235        265 TYPE symsgno VALUE '265', "No protected area exists
236        266 TYPE symsgno VALUE '266', "You have planned too few checks
237        267 TYPE symsgno VALUE '267', "Enter a reason for your rejection of the lineup
238        268 TYPE symsgno VALUE '268', "Select an entry
239        269 TYPE symsgno VALUE '269', "Enter a reason for your rejection of the verification list
240        270 TYPE symsgno VALUE '270', "Enter the planned number of checks
241        271 TYPE symsgno VALUE '271', "& items confirmed
242        272 TYPE symsgno VALUE '272', "One item confirmed
243        273 TYPE symsgno VALUE '273', "Enter Notes on Subject
244        274 TYPE symsgno VALUE '274', "Enter Operational Condition
245        275 TYPE symsgno VALUE '275', "Enter Operational Type
246        276 TYPE symsgno VALUE '276', "Enter Tagging Type
247        277 TYPE symsgno VALUE '277', "Operational condition &1 is not permitted
248        278 TYPE symsgno VALUE '278', "Operational type &1 is not permitted
249        279 TYPE symsgno VALUE '279', "Operational group &1 is not permitted
250        280 TYPE symsgno VALUE '280', "Status &1 (&2) was set
251        281 TYPE symsgno VALUE '281', "Status &1 (&2) was revoked
252        282 TYPE symsgno VALUE '282', "You must assign operational steps to each item
253        283 TYPE symsgno VALUE '283', "Operational step &1 is not allowed for tagging
254        284 TYPE symsgno VALUE '284', "Operational step &1 is not allowed for untagging
255        285 TYPE symsgno VALUE '285', "Operational steps were created automatically
256        286 TYPE symsgno VALUE '286', "Operational step &1 is no longer allowed for tagging
257        287 TYPE symsgno VALUE '287', "Operational step &1 is no longer allowed for untagging
258        288 TYPE symsgno VALUE '288', "Release for execution for WCM-relevant operation &1 is already assigned
259        289 TYPE symsgno VALUE '289', "WCM-relevant operation &1 is already assigned to an approval group
260        290 TYPE symsgno VALUE '290', "WCM-relevant operation &1 is already assigned to one &2
261        291 TYPE symsgno VALUE '291', "WCM-relevant operation &1 is already assigned to an operational step
262        292 TYPE symsgno VALUE '292', "WCM-relevant operation &1 is not assigned to an approval group
263        293 TYPE symsgno VALUE '293', "WCM-relevant operation &1 is not assigned to any &2
264        294 TYPE symsgno VALUE '294', "WCM-relevant operation &1 is not assigned to an operational step
265        295 TYPE symsgno VALUE '295', "Approval group &1 is already assigned to WCM-relevant operation &2
266        296 TYPE symsgno VALUE '296', "&1 &2 is already assigned to WCM-relevant operation &3
267        297 TYPE symsgno VALUE '297', "Operational step &1 (&2 &3) is already assigned to WCM-relevant oper. &4
268        298 TYPE symsgno VALUE '298', "Status of operational step &1 prevents revoking of the assignment
269        299 TYPE symsgno VALUE '299', "Status of &1 &2 prevents revoking of the assignment
270        300 TYPE symsgno VALUE '300', "Status of &1 &2 prevents assignment
271        301 TYPE symsgno VALUE '301', "Status of operational step &1 prevents assignment
272        302 TYPE symsgno VALUE '302', "An approval was assigned automatically
273        303 TYPE symsgno VALUE '303', "&1 approvals were assigned automatically
274        304 TYPE symsgno VALUE '304', "Tag &1 has been deleted
275        305 TYPE symsgno VALUE '305', "Test tag &1 has been deleted
276        306 TYPE symsgno VALUE '306', "Tagging steps cannot be processed simultaneously
277        307 TYPE symsgno VALUE '307', "Untagging steps cannot be processed simultaneously
278        308 TYPE symsgno VALUE '308', "Operational step &1 for tagging was not executed
279        309 TYPE symsgno VALUE '309', "Operational step &1 for untagging was not executed
280        310 TYPE symsgno VALUE '310', "The sequence of operational steps is not allowed
281        311 TYPE symsgno VALUE '311', "The simultaneous processing of operational steps is not allowed
282        312 TYPE symsgno VALUE '312', "No operational step found for this selection
283        313 TYPE symsgno VALUE '313', "No item found for this selection
284        314 TYPE symsgno VALUE '314', "Assignments have been revoked automatically
285        315 TYPE symsgno VALUE '315', "The data of the reference object was deleted
286        316 TYPE symsgno VALUE '316', "Asynchronous operational steps are not allowed
287        317 TYPE symsgno VALUE '317', "Filters for &1 are not allowed
288        318 TYPE symsgno VALUE '318', "The order is not WCM relevant
289        319 TYPE symsgno VALUE '319', "Assignment is not allowed
290        320 TYPE symsgno VALUE '320', "Activity category is not allowed
291        321 TYPE symsgno VALUE '321', "Architecture is not allowed
292        322 TYPE symsgno VALUE '322', "A status prevents assignment
293        323 TYPE symsgno VALUE '323', "&1 &2 activated
294        324 TYPE symsgno VALUE '324', "&1 &2 was deactivated
295        325 TYPE symsgno VALUE '325', "&1 &2 has been flagged for deletion
296        326 TYPE symsgno VALUE '326', "Deletion flag for &1 &2 revoked
297        327 TYPE symsgno VALUE '327', "&1 &2 was prepared
298        328 TYPE symsgno VALUE '328', "Preparation for &1 &2 revoked
299        329 TYPE symsgno VALUE '329', "The maintenance of tab pages is only possible for tab
300        330 TYPE symsgno VALUE '330', "No tabs (for example, &1) can be arranged on tab pages
301        331 TYPE symsgno VALUE '331', "The function was performed for &1 of &2 entries
302        332 TYPE symsgno VALUE '332', "The function was performed for all &1 entries
303        333 TYPE symsgno VALUE '333', "The function was not performed for any entries
304        334 TYPE symsgno VALUE '334', "The validity was extended by &1 hours
305        335 TYPE symsgno VALUE '335', "The validity was extended by one hour
306        336 TYPE symsgno VALUE '336', "Check the data for the new usage
307        337 TYPE symsgno VALUE '337', "The function was performed for one entry
308        338 TYPE symsgno VALUE '338', "All &1 entries were changed
309        339 TYPE symsgno VALUE '339', "No entries were changed
310        340 TYPE symsgno VALUE '340', "One entry was changed
311        341 TYPE symsgno VALUE '341', "One of &1 entries was changed
312        342 TYPE symsgno VALUE '342', "&1 of &2 entries were changed
313        343 TYPE symsgno VALUE '343', "No &1 is assigned
314        344 TYPE symsgno VALUE '344', "&1 is locked
315        345 TYPE symsgno VALUE '345', "Log entry for tag &1 deleted
316        346 TYPE symsgno VALUE '346', "Log entry for test tag &1 deleted
317        347 TYPE symsgno VALUE '347', "The WCM object is not yet valid
318        348 TYPE symsgno VALUE '348', "The validity period has already expired
319        349 TYPE symsgno VALUE '349', "Select an operation
320        350 TYPE symsgno VALUE '350', "Date and time (&1 &2) are in the past
321        351 TYPE symsgno VALUE '351', "Date and time (&1 &2) are too far in the future
322        352 TYPE symsgno VALUE '352', "Approval &1 was issued
323        353 TYPE symsgno VALUE '353', "Approval &1 was revoked
324        354 TYPE symsgno VALUE '354', "Approval &1 was deleted
325        355 TYPE symsgno VALUE '355', "One entry was deleted
326        356 TYPE symsgno VALUE '356', "Default value &1 for operational steps was used
327        357 TYPE symsgno VALUE '357', "Operational step &1 for tagging was enhanced
328        358 TYPE symsgno VALUE '358', "Operational step &1 for untagging was enhanced
329        359 TYPE symsgno VALUE '359', "Function &1 is active
330        360 TYPE symsgno VALUE '360', "Function &1 is possible
331        361 TYPE symsgno VALUE '361', "&1 entries were deleted
332        362 TYPE symsgno VALUE '362', "No entry was deleted
333        363 TYPE symsgno VALUE '363', "Table &1 has been changed
334        364 TYPE symsgno VALUE '364', "Table &1 has not been changed
335        365 TYPE symsgno VALUE '365', "Work clearance management for the operation is active
336        366 TYPE symsgno VALUE '366', "The settings for work permits have been defined
337        367 TYPE symsgno VALUE '367', "Graphical WCM planning is active
338        368 TYPE symsgno VALUE '368', "Mobile processing is active
339        369 TYPE symsgno VALUE '369', "Mode-dependent tagging is active
340        370 TYPE symsgno VALUE '370', "Stepwise tagging is active
341        371 TYPE symsgno VALUE '371', "Digital signature is active
342        372 TYPE symsgno VALUE '372', "Multiple use of operational tags is active
343        373 TYPE symsgno VALUE '373', "Valuation is active
344        374 TYPE symsgno VALUE '374', "When specifying an extension, you must specify the maximum extension
345        375 TYPE symsgno VALUE '375', "When specifying the maximum extension, you must specify the extension
346        376 TYPE symsgno VALUE '376', "The maximum extension must be the extension multiplied by n (n>0)
347        377 TYPE symsgno VALUE '377', "If you use an icon, the title can have up to 25 characters
348        378 TYPE symsgno VALUE '378', "No assignment was copied
349        379 TYPE symsgno VALUE '379', "Not all assignments were copied
350        380 TYPE symsgno VALUE '380', "Approval status for &1 &2 prevents the revoking of the assignment
351        381 TYPE symsgno VALUE '381', "Approval status for &1 &2 prevents the assignment
352        382 TYPE symsgno VALUE '382', "&1 &2 cannot be locked
353        383 TYPE symsgno VALUE '383', "&1 &2 is already assigned
354        384 TYPE symsgno VALUE '384', "Enhancement prevents the assignment of &1 &2
355        385 TYPE symsgno VALUE '385', "The maximum number of assignments has already been reached for &1 &2
356        386 TYPE symsgno VALUE '386', "The previous validity has been restored
357        387 TYPE symsgno VALUE '387', "A new validity has been determined
358        388 TYPE symsgno VALUE '388', "Position number &1 is already assigned
359        389 TYPE symsgno VALUE '389', "Tabstrips do not support frames
360        390 TYPE symsgno VALUE '390', "Subscreen &1 does not support (additional) frames
361        391 TYPE symsgno VALUE '391', "Subscreen &1 does not support arrangement in the right half of the screen
362        392 TYPE symsgno VALUE '392', "When arranging horizontally, use a frame
363        393 TYPE symsgno VALUE '393', "Subscreen &1 does not exist
364        394 TYPE symsgno VALUE '394', "You can select only operations to an order
365        395 TYPE symsgno VALUE '395', "Operational step &1 for tagging is in process
366        396 TYPE symsgno VALUE '396', "Operational step &1 for untagging is in process
367        397 TYPE symsgno VALUE '397', "The WCM object must be created manually
368        398 TYPE symsgno VALUE '398', "&1 &2 is locked by user &3
369        399 TYPE symsgno VALUE '399', "1 &2 can no longer be changed due to its status
370        400 TYPE symsgno VALUE '400', "The proposal was adopted
371        401 TYPE symsgno VALUE '401', "The proposal was revoked
372        402 TYPE symsgno VALUE '402', "&1 of &2 entries were selected
373        403 TYPE symsgno VALUE '403', "One entry of &2 entries was selected
374        404 TYPE symsgno VALUE '404', "No entries were selected
375        405 TYPE symsgno VALUE '405', "All &1 entries were selected
376        406 TYPE symsgno VALUE '406', "One entry was selected
377        407 TYPE symsgno VALUE '407', "&1 was extended (validity)
378        408 TYPE symsgno VALUE '408', "&1 &2 created
379        409 TYPE symsgno VALUE '409', "&1 &2 created
380        410 TYPE symsgno VALUE '410', "One proposal was adopted
381        411 TYPE symsgno VALUE '411', "&1 proposals were adopted
382        412 TYPE symsgno VALUE '412', "One proposal was determined
383        413 TYPE symsgno VALUE '413', "&1 proposals were determined
384        414 TYPE symsgno VALUE '414', "One entry was displayed
385        415 TYPE symsgno VALUE '415', "&1 entries were displayed
386        416 TYPE symsgno VALUE '416', "&1 &2 selected
387        417 TYPE symsgno VALUE '417', "&1 &2 selected
388        418 TYPE symsgno VALUE '418', "No proposals could be determined
389        419 TYPE symsgno VALUE '419', "Further information is available
390        420 TYPE symsgno VALUE '420', "Approval &1 does not exist
391        421 TYPE symsgno VALUE '421', "Approval &1 is already assigned
392        422 TYPE symsgno VALUE '422', "An assignment was deleted
393        423 TYPE symsgno VALUE '423', "Work permit was handed out
394        424 TYPE symsgno VALUE '424', "Work permit was returned
395        425 TYPE symsgno VALUE '425', "PDF document of safety plan could not be created
396        426 TYPE symsgno VALUE '426', "PDF document of safety plan could not be appended
397        427 TYPE symsgno VALUE '427', "Overriding of internal number range requires dedicated usage type
398        428 TYPE symsgno VALUE '428', "Overriding of external number range requires dedicated usage type
399        429 TYPE symsgno VALUE '429', "Overriding of view profile requires dedicated usage type
400        430 TYPE symsgno VALUE '430', "Specification of usage for automatic generation only applies to templates
401        431 TYPE symsgno VALUE '431', "Dedicated usage types must be specified consistently (plant &1)
402        432 TYPE symsgno VALUE '432', "View profile &1; maximum width of screen &2
403        433 TYPE symsgno VALUE '433', "Planning plant &1; usage &2; usage type &3
404        434 TYPE symsgno VALUE '434', "Direction &1: Database &2; add &3; delete &4
405        435 TYPE symsgno VALUE '435', "View profile &1: screen width reduced; check screen area arrangement
406        436 TYPE symsgno VALUE '436', "Not all items were copied
407        437 TYPE symsgno VALUE '437', "Subscreen &1 exceeds maximum allowable width of screen (&2 > &3)
408        438 TYPE symsgno VALUE '438', "In maintenance planning plant &1, train &2 is not defined
409        439 TYPE symsgno VALUE '439', "In maintenance planning plant &1, revision phase &2 is not defined
410        440 TYPE symsgno VALUE '440', "Enter the maintenance planning plant
411        441 TYPE symsgno VALUE '441', "The maintenance planning plant (&1) can no longer be changed
412        442 TYPE symsgno VALUE '442', "Enter the usage
413        443 TYPE symsgno VALUE '443', "The usage (&1) can no longer be changed
414        444 TYPE symsgno VALUE '444', "The current status of &1 &2 prevents the requested change
415        445 TYPE symsgno VALUE '445', "Automatic copying not possible; select the assignments.
416        446 TYPE symsgno VALUE '446', "Automatic copying not possible; assignments were not copied.
417        447 TYPE symsgno VALUE '447', "&1 &2 is not yet assigned
418        448 TYPE symsgno VALUE '448', "Enhancement prevents deletion of the assignment for &1 &2
419        449 TYPE symsgno VALUE '449', "Assignment of &1 &2 was deleted
420        450 TYPE symsgno VALUE '450', "Issuing of approval &1 is blocked across WCM objects
421        451 TYPE symsgno VALUE '451', "Stopwatch was started
422        452 TYPE symsgno VALUE '452', "Stopwatch was stopped. &2 seconds
423        453 TYPE symsgno VALUE '453', "Stopwatch was again started
424        454 TYPE symsgno VALUE '454', "Round &1: &2 seconds
425        455 TYPE symsgno VALUE '455', "Stopwatch was deleted
426        456 TYPE symsgno VALUE '456', "Locked text lines cannot be changed anymore
427        457 TYPE symsgno VALUE '457', "In operational group &1, operational condition &2 is not allowed
428        458 TYPE symsgno VALUE '458', "Item &1 cannot be changed
429        459 TYPE symsgno VALUE '459', "Item &1 cannot be deleted
430        460 TYPE symsgno VALUE '460', "Insertion of items is not possible
431        461 TYPE symsgno VALUE '461', "Change of items is not possible
432        462 TYPE symsgno VALUE '462', "Deletion of items is not possible
433        463 TYPE symsgno VALUE '463', "Usage &1 has invalid type (&2)
434        464 TYPE symsgno VALUE '464', "Approval &1 is not permitted
435        465 TYPE symsgno VALUE '465', "&1 could not be printed (error code &2)
436        466 TYPE symsgno VALUE '466', "Items were renumbered
437        467 TYPE symsgno VALUE '467', "Items were resorted
438        468 TYPE symsgno VALUE '468', "Function is not available due to current status (&1)
439        469 TYPE symsgno VALUE '469', "Existing operational protection prevents execution of function
440        470 TYPE symsgno VALUE '470', "Status of &1 prevents execution of function
441        471 TYPE symsgno VALUE '471', "Item &1: Error (time frame) due to item &2/&3
442        472 TYPE symsgno VALUE '472', "Item &1: &4 (conflict) due to item &2/&3
443        473 TYPE symsgno VALUE '473', "Item &1: Potential conflict against item &2
444        474 TYPE symsgno VALUE '474', "Status &1 (&2) was set for &3 items
445        475 TYPE symsgno VALUE '475', "Status &1 (&2) was set for one item
446        476 TYPE symsgno VALUE '476', "&1 were printed for &2 items
447        477 TYPE symsgno VALUE '477', "&1 was printed for one item
448        478 TYPE symsgno VALUE '478', "Reference object cannot be deleted due to maintained object list
449        479 TYPE symsgno VALUE '479', "Tab page "&1" has too many lines; scrollbar must be displayed
450        480 TYPE symsgno VALUE '480', "Assignment to order &1 was just deleted
451        481 TYPE symsgno VALUE '481', "Assignment to order &1 was just created
452        482 TYPE symsgno VALUE '482', "Assignment to operation &1 of order &2 was just deleted
453        483 TYPE symsgno VALUE '483', "At least one operation assignment isn't valid anymore
454        484 TYPE symsgno VALUE '484', "Assignment to operation &1 of order &2 cannot be deleted
455        485 TYPE symsgno VALUE '485', "Dynamic Operation Determination Excludes Physical Assignments
456        486 TYPE symsgno VALUE '486', "System only considers the text (of type &1) in the logon language
457        487 TYPE symsgno VALUE '487', "&1 &2 could not be saved
458        488 TYPE symsgno VALUE '488', "Work permit was created with the number &
459        489 TYPE symsgno VALUE '489', "Data segment "&1" of &2 &3 must not be changed
460        490 TYPE symsgno VALUE '490', "At first complete the following action: Create &1
461        491 TYPE symsgno VALUE '491', "At first refresh the list of assigned &1
462        492 TYPE symsgno VALUE '492', "Data for item &1 is not complete/correct
463        493 TYPE symsgno VALUE '493', "Criterion "&1" only allows (unmasked) search for identity
464        494 TYPE symsgno VALUE '494', "Multiple values for search criterion "&1" are not permitted
465        495 TYPE symsgno VALUE '495', "
466        496 TYPE symsgno VALUE '496', "
467        497 TYPE symsgno VALUE '497', "
468        498 TYPE symsgno VALUE '498', "
469        499 TYPE symsgno VALUE '499', "
470        601 TYPE symsgno VALUE '601', "Archiving object &1 is not available
471        603 TYPE symsgno VALUE '603', "Choose at least one activity
472        604 TYPE symsgno VALUE '604', "Select at least one status as condition
473        611 TYPE symsgno VALUE '611', "RFC Server: Problems with basic RFC functions
474        612 TYPE symsgno VALUE '612', "RFC Server: Error importing data from SAP
475        613 TYPE symsgno VALUE '613', "RFC Server: Error interpreting data from SAP
476        614 TYPE symsgno VALUE '614', "RFC Server: Error exporting data to SAP
477        615 TYPE symsgno VALUE '615', "RFC Server: Termination
478        616 TYPE symsgno VALUE '616', "& could not be started
479        617 TYPE symsgno VALUE '617', "& is busy
480        618 TYPE symsgno VALUE '618', "& canceled
481        619 TYPE symsgno VALUE '619', "Unspecified error calling up graphic planning
482        621 TYPE symsgno VALUE '621', "GUI status &1 was defined, activity category: &2
483        622 TYPE symsgno VALUE '622', "Label &1 was set
484        623 TYPE symsgno VALUE '623', "GUI status &1 and GUI title &2 were defined, activity category: &3
485        624 TYPE symsgno VALUE '624', "Question: &1; answer: &2
486        625 TYPE symsgno VALUE '625', "The update of the update function modules was successful
487        626 TYPE symsgno VALUE '626', "Call screen &1
488        627 TYPE symsgno VALUE '627', "Exit screen sequence: call screen &1
489        628 TYPE symsgno VALUE '628', "All change requests for current SAP LUW were stored
490        629 TYPE symsgno VALUE '629', "Exit program &1
491        630 TYPE symsgno VALUE '630', "Call transaction &1, display screen, new internal session
492        631 TYPE symsgno VALUE '631', "Exit current call sequence: call transaction &1
493        632 TYPE symsgno VALUE '632', "Data was written to ABAP memory under the ID &1
494        633 TYPE symsgno VALUE '633', "Data with the ID &1 found, and contents transferred
495        634 TYPE symsgno VALUE '634', "SET/GET parameter &1 has the value &2
496        635 TYPE symsgno VALUE '635', "Value &2 was set for SET/GET parameter &1
497        636 TYPE symsgno VALUE '636', "Dialog box &1 was displayed
498        637 TYPE symsgno VALUE '637', "Return value &1
499        638 TYPE symsgno VALUE '638', "Execute update function module &1 in dialog mode
500        639 TYPE symsgno VALUE '639', "Register update function module &1, execution is scheduled
501        640 TYPE symsgno VALUE '640', "Register subroutine &1, execution is scheduled
502        641 TYPE symsgno VALUE '641', "Call program &1, new internal session
503        642 TYPE symsgno VALUE '642', "Call program &1, internal session replaced
504        643 TYPE symsgno VALUE '643', "Screen sequence control was listed
505        644 TYPE symsgno VALUE '644', "Process current screen &1 in background, execute function code &2
506        645 TYPE symsgno VALUE '645', "Data records unlocked, lock object &1 (&2)
507        646 TYPE symsgno VALUE '646', "Lock data records, lock object &1 (&2)
508        647 TYPE symsgno VALUE '647', "Call transaction &1, do not display screen, new internal session
509        648 TYPE symsgno VALUE '648', "Execute function code &1
510        649 TYPE symsgno VALUE '649', "Function code &1 was executed
511        650 TYPE symsgno VALUE '650', "GUI title &1 was defined, activity category: &2
512        651 TYPE symsgno VALUE '651', "& & & &
513        652 TYPE symsgno VALUE '652', "Output simple list (one-line or multiline): &1 entries
514        653 TYPE symsgno VALUE '653', "Output hierarchical, sequential list: &1 header data, &2 items
515        654 TYPE symsgno VALUE '654', "List contains no data
516        655 TYPE symsgno VALUE '655', "No exception for function module call &1
517        656 TYPE symsgno VALUE '656', "Function is not available
518        657 TYPE symsgno VALUE '657', "Indicator &1 was set
519        658 TYPE symsgno VALUE '658', "Indicator &1 was revoked
520        659 TYPE symsgno VALUE '659', "Indicator &1 is set
521        660 TYPE symsgno VALUE '660', "Indicator &1 is not set
522        661 TYPE symsgno VALUE '661', "Result: &1 errors, &2 warnings, and &3 information messages
523        662 TYPE symsgno VALUE '662', "Execute data change in dialog mode
524        663 TYPE symsgno VALUE '663', "Table &1: create &2, delete &3, and change &4
525        664 TYPE symsgno VALUE '664', "Table &1: &2 created, &3 deleted, and &4 changed
526        665 TYPE symsgno VALUE '665', "Table &1 has one entry
527        666 TYPE symsgno VALUE '666', "Table &1 has no entries
528        667 TYPE symsgno VALUE '667', "Table &1 has &2 entries
529        668 TYPE symsgno VALUE '668', "Variable &1 has the value &2
530        669 TYPE symsgno VALUE '669', "Value of variable &1 changed from &2 to &3
531        670 TYPE symsgno VALUE '670', "Variable &1 was initialized
532        671 TYPE symsgno VALUE '671', "Value of variable &1 was set to &2
533        672 TYPE symsgno VALUE '672', "Variable &1 is initial
534        673 TYPE symsgno VALUE '673', "Label &1 was completed: processing duration &2
535        674 TYPE symsgno VALUE '674', "BAdI &1, method &2: return value &3
536        675 TYPE symsgno VALUE '675', "Function module &1: return value &2
537        676 TYPE symsgno VALUE '676', "& items were deleted
538        677 TYPE symsgno VALUE '677', "One item has been inserted
539        678 TYPE symsgno VALUE '678', "Table &1: no lines were transferred
540        679 TYPE symsgno VALUE '679', "Table &1: one line was transferred
541        680 TYPE symsgno VALUE '680', "Table &1: &2 lines were transferred
542        681 TYPE symsgno VALUE '681', "View &1: no lines were transferred
543        682 TYPE symsgno VALUE '682', "View &1: one line was transferred
544        683 TYPE symsgno VALUE '683', "View &1: &2 lines were transferred
545        684 TYPE symsgno VALUE '684', "One item was deleted
546        685 TYPE symsgno VALUE '685', "No view profile has been assigned
547        686 TYPE symsgno VALUE '686', "Call subroutine (&2) of program (&1)
548        687 TYPE symsgno VALUE '687', "Program &1, subroutine &2: return value &3
549        688 TYPE symsgno VALUE '688', "
550        689 TYPE symsgno VALUE '689', "
551        690 TYPE symsgno VALUE '690', "
552        691 TYPE symsgno VALUE '691', "
553        692 TYPE symsgno VALUE '692', "
554        693 TYPE symsgno VALUE '693', "
555        694 TYPE symsgno VALUE '694', "
556        695 TYPE symsgno VALUE '695', "
557        696 TYPE symsgno VALUE '696', "
558        697 TYPE symsgno VALUE '697', "
559        698 TYPE symsgno VALUE '698', "
560        699 TYPE symsgno VALUE '699', "
561        700 TYPE symsgno VALUE '700', "
562        701 TYPE symsgno VALUE '701', "Wrong transfer parameter(s)
563        702 TYPE symsgno VALUE '702', "No entry/entries in the table (&)
564        703 TYPE symsgno VALUE '703', "Task (&) is not defined
565        704 TYPE symsgno VALUE '704', "Object type (&) is not defined
566        705 TYPE symsgno VALUE '705', "Entry already exists
567        706 TYPE symsgno VALUE '706', "Entry does not exist
568        707 TYPE symsgno VALUE '707', "Activity category (&) is not defined
569        708 TYPE symsgno VALUE '708', "Print type (&) is not defined
570        709 TYPE symsgno VALUE '709', "Value (&) is not defined
571        710 TYPE symsgno VALUE '710', "Object number (&) is not defined
572        711 TYPE symsgno VALUE '711', "Error (&) occurred executing function module (&)
573        712 TYPE symsgno VALUE '712', "Entry (&) not found in table (&)
574        713 TYPE symsgno VALUE '713', "Transaction code (&) is not defined
575        714 TYPE symsgno VALUE '714', "Direction (&) is not defined
576        715 TYPE symsgno VALUE '715', "Message category (&) is not defined
577        716 TYPE symsgno VALUE '716', "Assignments are already available
578        717 TYPE symsgno VALUE '717', "Table (&) has (&) entry/entries
579        718 TYPE symsgno VALUE '718', "Program errors
580        719 TYPE symsgno VALUE '719', "Object type (&) is not defined
581        720 TYPE symsgno VALUE '720', "Subprogram (&1) or program (&2) is not available
582        721 TYPE symsgno VALUE '721', "Error when importing data (&)
583        722 TYPE symsgno VALUE '722', "Invalid entry in database table (&)
584        723 TYPE symsgno VALUE '723', "Invalid entry in internal table (&)
585        724 TYPE symsgno VALUE '724', "Function code (&) is not defined
586        725 TYPE symsgno VALUE '725', "Instruction (&1) provides exception (&2)
587        726 TYPE symsgno VALUE '726', "Memory ID (&) is not defined
588        727 TYPE symsgno VALUE '727', "Category (&) is not defined
589        728 TYPE symsgno VALUE '728', "Impermissible Customizing (&)
590        729 TYPE symsgno VALUE '729', "Return value (&) is not defined
591        730 TYPE symsgno VALUE '730', "Incorrect call (&)
592        731 TYPE symsgno VALUE '731', "Function cannot be active
593        732 TYPE symsgno VALUE '732', "Transaction (&) is not defined
594        733 TYPE symsgno VALUE '733', "Status (&) is not defined
595        734 TYPE symsgno VALUE '734', "Subscreen (&1) is not defined
596        735 TYPE symsgno VALUE '735', "Screen (&) is not defined
597        736 TYPE symsgno VALUE '736', "Item category (&) is not defined
598        737 TYPE symsgno VALUE '737', "Approval status (&) is not defined
599        738 TYPE symsgno VALUE '738', "List editing (&) is not defined
600        739 TYPE symsgno VALUE '739', "Model (&) is not defined
601        740 TYPE symsgno VALUE '740', "The generic object services are not available
602        741 TYPE symsgno VALUE '741', "Unspecified error when processing the object (&)
603        742 TYPE symsgno VALUE '742', "Usage (&1) is not defined
604        743 TYPE symsgno VALUE '743', "View profile (&1) is not defined
605        744 TYPE symsgno VALUE '744', "&1 (&2) is not defined
606        745 TYPE symsgno VALUE '745', "Error (&) in item data to be processed
607        746 TYPE symsgno VALUE '746', "Missing lock for &1 &2
608        747 TYPE symsgno VALUE '747', "Mode (&1) for data update is not defined
609        748 TYPE symsgno VALUE '748', "Wrong mode (&1) for data update; required mode: &2
610        749 TYPE symsgno VALUE '749', "Application context (&1) is not defined
611        750 TYPE symsgno VALUE '750', "Wrong application context (&1); required context: &2
612        751 TYPE symsgno VALUE '751', "
613        752 TYPE symsgno VALUE '752', "
614        753 TYPE symsgno VALUE '753', "
615        754 TYPE symsgno VALUE '754', "
616        755 TYPE symsgno VALUE '755', "
617        756 TYPE symsgno VALUE '756', "
618        757 TYPE symsgno VALUE '757', "
619        758 TYPE symsgno VALUE '758', "
620        759 TYPE symsgno VALUE '759', "
621        760 TYPE symsgno VALUE '760', "
622        801 TYPE symsgno VALUE '801', "Error when inserting in database table (&)
623        802 TYPE symsgno VALUE '802', "Error when deleting from database table (&)
624        803 TYPE symsgno VALUE '803', "Error during loop using the internal table (&)
625        804 TYPE symsgno VALUE '804', "Error when executing function module (&)
626        805 TYPE symsgno VALUE '805', "Error when deleting from internal table (&)
627        806 TYPE symsgno VALUE '806', "Error when reading the internal table (&)
628        807 TYPE symsgno VALUE '807', "Error during change to internal table (&)
629        808 TYPE symsgno VALUE '808', "Error during change to database table (&)
630        809 TYPE symsgno VALUE '809', "Error when inserting in internal table (&)
631        810 TYPE symsgno VALUE '810', "Error when reading line (&)
632        811 TYPE symsgno VALUE '811', "Error linking field (&1) to component (&2)
633        812 TYPE symsgno VALUE '812', "Update could not be completed successfully
634        813 TYPE symsgno VALUE '813', "Error when reading database table (&)
635        814 TYPE symsgno VALUE '814', "Could not import data objects
636        815 TYPE symsgno VALUE '815', "Error (&2) when executing method (&1)
637        816 TYPE symsgno VALUE '816', "Error when assigning memory area (&1) to field symbol (&2)
638        817 TYPE symsgno VALUE '817', "Error when converting date (&1) and time (&2)
639        818 TYPE symsgno VALUE '818', "Error (&1) when replacing by pattern
640        819 TYPE symsgno VALUE '819', "
641        820 TYPE symsgno VALUE '820', "
642        821 TYPE symsgno VALUE '821', "
643        822 TYPE symsgno VALUE '822', "
644        823 TYPE symsgno VALUE '823', "
645        824 TYPE symsgno VALUE '824', "
646        825 TYPE symsgno VALUE '825', "
647        826 TYPE symsgno VALUE '826', "
648        827 TYPE symsgno VALUE '827', "
649        828 TYPE symsgno VALUE '828', "
650        829 TYPE symsgno VALUE '829', "
651        830 TYPE symsgno VALUE '830', "
652      END   OF wctpm_msgno.
*--- End of %_CWCTPM - 652 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CWCTPZ                                  Level 1    Page 10
Object           ZRIWFWA01                                 Lines 660
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Type-Pool  WCTPZ
3      *-----------------------------------------------------------------------
4      *  Purpose: ABAP/4 LIST VIEWER (ALV)
5      ************************************************************************
6      TYPE-POOL wctpz.
7
8      * elementary types *****************************************************
9      TYPES: wctpz_display_variants_type(1) TYPE c.
10     TYPES: wctpz_handle_type(4)           TYPE c.
11     TYPES: wctpz_checkbox_type(1)         TYPE c.
12     TYPES: wctpz_key_word_type(1)         TYPE c.
13     TYPES: wctpz_alignment_type(1)        TYPE c.
14     TYPES: wctpz_group_type(4)            TYPE c.
15
16     * structures types *****************************************************
17     * SUBROUTINEs
18     TYPES:
19       BEGIN OF wctpz_form_type,
20         listtab_create TYPE formname,
21         listtab_update TYPE formname,
22         listtab_output TYPE formname,
23         listtab_read   TYPE formname,
24         worktab_update TYPE formname,
25         refresh        TYPE formname,
26       END   OF wctpz_form_type.
27     * PROGRAM CONTROL
28     TYPES:
29       BEGIN OF wctpz_prgctrl_type,
30         program TYPE programm,
31         form    TYPE wctpz_form_type,
32       END   OF wctpz_prgctrl_type.
33     * NUMBERs
34     TYPES:
35       BEGIN OF wctpz_number_type,
36         open_unmarked   TYPE sytabix,
37         open_marked     TYPE sytabix,
38         closed_unmarked TYPE sytabix,
39         closed_marked   TYPE sytabix,
40         no_output       TYPE sytabix,
41       END   OF wctpz_number_type.
42
43     * tables types *********************************************************
44     * LIST CONTROL
45     TYPES:
46       BEGIN OF wctpz_lstctrl_type,
47         current     TYPE wcelsttyp,
48         alternative TYPE wcelsttyp,
49         BEGIN OF body,
50           objart  TYPE wceobjart,
51           display TYPE wceboolean,
52           select  TYPE wceboolean,
53           text    TYPE itex132,
54         END   OF body,
55       END   OF wctpz_lstctrl_type.
56
57     * constants ************************************************************
58     * PATTERN FOR ICON_SPACE
59     CONSTANTS: wctpz_pattern(2) TYPE c VALUE '5F'.
60     * DISPLAY VARIANTs
61     CONSTANTS:
62       BEGIN OF wctpz_display_variants,
63         unused          TYPE wctpz_display_variants_type VALUE space,
64         user            TYPE wctpz_display_variants_type VALUE 'U',
65         global          TYPE wctpz_display_variants_type VALUE 'X',
66         user_and_global TYPE wctpz_display_variants_type VALUE 'A',
67       END   OF wctpz_display_variants.
68     * MGT. ID FOR REPEATED CALLS FROM THE SAME PROGRAM
69     CONSTANTS:
70       BEGIN OF wctpz_handle,
71         d5100 TYPE wctpz_handle_type VALUE '5100',
72         d5200 TYPE wctpz_handle_type VALUE '5200',
73         d5300 TYPE wctpz_handle_type VALUE '5300',
74         d5400 TYPE wctpz_handle_type VALUE '5400',
75         d5500 TYPE wctpz_handle_type VALUE '5500',
76       END   OF wctpz_handle.
77     * KEY WORD
78     CONSTANTS:
79       BEGIN OF wctpz_key_word,
80         long   TYPE wctpz_key_word_type VALUE 'L',
81         middle TYPE wctpz_key_word_type VALUE 'M',
82         short  TYPE wctpz_key_word_type VALUE 'S',
83       END   OF wctpz_key_word.
84     * ALIGNMENT
85     CONSTANTS:
86       BEGIN OF wctpz_alignment,
87         left     TYPE wctpz_alignment_type VALUE 'L',
88         centered TYPE wctpz_alignment_type VALUE 'C',
89         right    TYPE wctpz_alignment_type VALUE 'R',
90       END   OF wctpz_alignment.
91     * OUTPUT LENGTH
92     CONSTANTS:
93       BEGIN OF wctpz_output_length,
94         icon TYPE outputlen VALUE 10,
95       END   OF wctpz_output_length.
96     * CHECKBOX
97     CONSTANTS:
98       BEGIN OF wctpz_checkbox,
99         open_unmarked   TYPE wctpz_checkbox_type VALUE space,
100        open_marked     TYPE wctpz_checkbox_type VALUE 'X',
101        closed_unmarked TYPE wctpz_checkbox_type VALUE '0',
102        closed_marked   TYPE wctpz_checkbox_type VALUE '1',
103        no_output       TYPE wctpz_checkbox_type VALUE '-',
104      END   OF wctpz_checkbox.
105    * CONTROL BREAK
106    CONSTANTS:
107      BEGIN OF wctpz_control_break,
108        page_feed TYPE slis_ctrls VALUE '*',
109        underline TYPE slis_ctrls VALUE 'UL',
110      END   OF wctpz_control_break.
111    * FIELD GROUPs
112    CONSTANTS:
113      BEGIN OF wctpz_group,
114        BEGIN OF order,
115          general_data        TYPE wctpz_group_type VALUE 'A1',
116          location_account    TYPE wctpz_group_type VALUE 'A2',
117          address             TYPE wctpz_group_type VALUE 'A3',
118          schedule_dates      TYPE wctpz_group_type VALUE 'A4',
119          costs_revenues      TYPE wctpz_group_type VALUE 'A5',
120          service_data        TYPE wctpz_group_type VALUE 'A6',
121        END   OF order,
122        BEGIN OF wcmobj,
123          general_data        TYPE wctpz_group_type VALUE 'B1',
124          reference_object    TYPE wctpz_group_type VALUE 'B2',
125          responsibilities    TYPE wctpz_group_type VALUE 'B3',
126          administration_data TYPE wctpz_group_type VALUE 'B4',
127          planning_data       TYPE wctpz_group_type VALUE 'B5',
128          additional_data     TYPE wctpz_group_type VALUE 'B6',
129          works               TYPE wctpz_group_type VALUE 'B7',
130          needs               TYPE wctpz_group_type VALUE 'B8',
131        END   OF wcmobj,
132        BEGIN OF wcditm,
133          general_data        TYPE wctpz_group_type VALUE 'C1',
134          data_for_tagging    TYPE wctpz_group_type VALUE 'C2',
135          data_for_untagging  TYPE wctpz_group_type VALUE 'C3',
136          additional_data     TYPE wctpz_group_type VALUE 'C4',
137          administration_data TYPE wctpz_group_type VALUE 'C5',
138          operational_data    TYPE wctpz_group_type VALUE 'C6',
139        END   OF wcditm,
140        BEGIN OF oplst,
141          general_data        TYPE wctpz_group_type VALUE 'D1',
142          administration_data TYPE wctpz_group_type VALUE 'D2',
143          operational_data    TYPE wctpz_group_type VALUE 'D3',
144        END   OF oplst,
145        BEGIN OF verlst,
146          general_data        TYPE wctpz_group_type VALUE 'E1',
147          administration_data TYPE wctpz_group_type VALUE 'E2',
148          additional_data     TYPE wctpz_group_type VALUE 'E3',
149        END   OF verlst,
150        BEGIN OF object,
151          order               TYPE wctpz_group_type VALUE 'F1',
152          wap                 TYPE wctpz_group_type VALUE 'F2',
153          wapi                TYPE wctpz_group_type VALUE 'F3',
154          wcd                 TYPE wctpz_group_type VALUE 'F4',
155        END   OF object,
156      END OF wctpz_group.
157    * TABLE NAMEs
158    CONSTANTS:
159      BEGIN OF wctpz_table,
160        header TYPE slis_tabname VALUE 'HEADER',
161        body   TYPE slis_tabname VALUE 'BODY',
162      END   OF wctpz_table.
163    * LIST TYPEs
164    CONSTANTS:
165      BEGIN OF wctpz_lsttyp,
166        header      TYPE wcelsttyp VALUE '1',
167        body        TYPE wcelsttyp VALUE '2',
168        header_body TYPE wcelsttyp VALUE '3',
169      END   OF wctpz_lsttyp.
170    * CHECK BOXEs
171    CONSTANTS:
172      BEGIN OF wctpz_chkbox,
173        header TYPE wcecheckbox VALUE 'H',
174        body   TYPE wcecheckbox VALUE 'B',
175      END   OF wctpz_chkbox.
176    * TOOLBAR BUTTON TYPE (ALV GRID CONTROL)
177    CONSTANTS:
178      BEGIN OF wctpz_tb_buttontyp,
179        normal           TYPE tb_btype VALUE 0,
180        menu_and_default TYPE tb_btype VALUE 1,
181        menu             TYPE tb_btype VALUE 2,
182        separator        TYPE tb_btype VALUE 3,
183        radio            TYPE tb_btype VALUE 4,
184        checkbox         TYPE tb_btype VALUE 5,
185        menu_entry       TYPE tb_btype VALUE 6,
186      END   OF wctpz_tb_buttontyp.
187    * FIELDs
188    CONSTANTS:
189      BEGIN OF wctpz_field,
190        BEGIN OF wcm,
191    *     technical fields
192          button      TYPE fieldname VALUE 'BUTTON',
193          coltab      TYPE fieldname VALUE 'COLTAB',
194          tabname     TYPE fieldname VALUE 'TABNAME',
195    *     general data
196          aufnr       TYPE fieldname VALUE 'AUFNR',
197          wapnr       TYPE fieldname VALUE 'WAPNR',
198          wapinr      TYPE fieldname VALUE 'WAPINR',
199          wcnr        TYPE fieldname VALUE 'WCNR',
200          objnr       TYPE fieldname VALUE 'OBJNR',
201          wapityp     TYPE fieldname VALUE 'WAPITYP',
202          wctyp       TYPE fieldname VALUE 'WCTYP',
203          wapuse      TYPE fieldname VALUE 'WAPUSE',
204          wapiuse     TYPE fieldname VALUE 'WAPIUSE',
205          wcuse       TYPE fieldname VALUE 'WCUSE',
206          stxt        TYPE fieldname VALUE 'STXT',
207          sysst       TYPE fieldname VALUE 'SYSST',
208          usrst       TYPE fieldname VALUE 'USRST',
209          validicon   TYPE fieldname VALUE 'VALIDICON',
210          datefr      TYPE fieldname VALUE 'DATEFR',
211          timefr      TYPE fieldname VALUE 'TIMEFR',
212          dateto      TYPE fieldname VALUE 'DATETO',
213          timeto      TYPE fieldname VALUE 'TIMETO',
214          extperiod   TYPE fieldname VALUE 'EXTPERIOD',
215          priok       TYPE fieldname VALUE 'PRIOK',
216          anlzu       TYPE fieldname VALUE 'ANLZU',
217          etape       TYPE fieldname VALUE 'ETAPE',
218          rctime      TYPE fieldname VALUE 'RCTIME',
219          rcunit      TYPE fieldname VALUE 'RCUNIT',
220          refkey      TYPE fieldname VALUE 'REFKEY',
221          wkptid      TYPE fieldname VALUE 'WKPTID',
222    *     reference object
223          tplnr       TYPE fieldname VALUE 'TPLNR',
224          strno       TYPE fieldname VALUE 'STRNO',
225          tptxt       TYPE fieldname VALUE 'TPTXT',
226          equnr       TYPE fieldname VALUE 'EQUNR',
227          eqtxt       TYPE fieldname VALUE 'EQTXT',
228          train       TYPE fieldname VALUE 'TRAIN',
229    *     areas of responsibility
230          ingrp       TYPE fieldname VALUE 'INGRP',
231          iwerk       TYPE fieldname VALUE 'IWERK',
232          wkcr        TYPE fieldname VALUE 'WKCR',
233          plant       TYPE fieldname VALUE 'PLANT',
234          begru       TYPE fieldname VALUE 'BEGRU',
235    *     administration data
236          crname      TYPE fieldname VALUE 'CRNAME',
237          crdate      TYPE fieldname VALUE 'CRDATE',
238          crtime      TYPE fieldname VALUE 'CRTIME',
239          chname      TYPE fieldname VALUE 'CHNAME',
240          chdate      TYPE fieldname VALUE 'CHDATE',
241          chtime      TYPE fieldname VALUE 'CHTIME',
242    *     planning data
243          bdate       TYPE fieldname VALUE 'BDATE',
244          btime       TYPE fieldname VALUE 'BTIME',
245          edate       TYPE fieldname VALUE 'EDATE',
246          etime       TYPE fieldname VALUE 'ETIME',
247          tsdate      TYPE fieldname VALUE 'TSDATE',
248          tstime      TYPE fieldname VALUE 'TSTIME',
249          tfdate      TYPE fieldname VALUE 'TFDATE',
250          tftime      TYPE fieldname VALUE 'TFTIME',
251          asdate      TYPE fieldname VALUE 'ASDATE',
252          astime      TYPE fieldname VALUE 'ASTIME',
253          afdate      TYPE fieldname VALUE 'AFDATE',
254          aftime      TYPE fieldname VALUE 'AFTIME',
255    *     works
256          wk01        TYPE fieldname VALUE 'WK01',
257          wk02        TYPE fieldname VALUE 'WK02',
258          wk03        TYPE fieldname VALUE 'WK03',
259          wk04        TYPE fieldname VALUE 'WK04',
260          wk05        TYPE fieldname VALUE 'WK05',
261          wk06        TYPE fieldname VALUE 'WK06',
262          wk07        TYPE fieldname VALUE 'WK07',
263          wk08        TYPE fieldname VALUE 'WK08',
264          wk09        TYPE fieldname VALUE 'WK09',
265          wk10        TYPE fieldname VALUE 'WK10',
266          wk11        TYPE fieldname VALUE 'WK11',
267          wk12        TYPE fieldname VALUE 'WK12',
268          wk13        TYPE fieldname VALUE 'WK13',
269          wk14        TYPE fieldname VALUE 'WK14',
270          wk15        TYPE fieldname VALUE 'WK15',
271          wk16        TYPE fieldname VALUE 'WK16',
272          wk17        TYPE fieldname VALUE 'WK17',
273          wk18        TYPE fieldname VALUE 'WK18',
274          wk19        TYPE fieldname VALUE 'WK19',
275          wk20        TYPE fieldname VALUE 'WK20',
276          wk21        TYPE fieldname VALUE 'WK21',
277          wk22        TYPE fieldname VALUE 'WK22',
278          wk23        TYPE fieldname VALUE 'WK23',
279          wk24        TYPE fieldname VALUE 'WK24',
280          wk25        TYPE fieldname VALUE 'WK25',
281          wk26        TYPE fieldname VALUE 'WK26',
282          wk27        TYPE fieldname VALUE 'WK27',
283          wk28        TYPE fieldname VALUE 'WK28',
284    *     needs
285          need01      TYPE fieldname VALUE 'NEED01',
286          need02      TYPE fieldname VALUE 'NEED02',
287          need03      TYPE fieldname VALUE 'NEED03',
288          need04      TYPE fieldname VALUE 'NEED04',
289          need05      TYPE fieldname VALUE 'NEED05',
290          need06      TYPE fieldname VALUE 'NEED06',
291          need07      TYPE fieldname VALUE 'NEED07',
292          need08      TYPE fieldname VALUE 'NEED08',
293          need09      TYPE fieldname VALUE 'NEED09',
294          need10      TYPE fieldname VALUE 'NEED10',
295          need11      TYPE fieldname VALUE 'NEED11',
296          need12      TYPE fieldname VALUE 'NEED12',
297          need13      TYPE fieldname VALUE 'NEED13',
298          need14      TYPE fieldname VALUE 'NEED14',
299          need15      TYPE fieldname VALUE 'NEED15',
300          need16      TYPE fieldname VALUE 'NEED16',
301          need17      TYPE fieldname VALUE 'NEED17',
302          need18      TYPE fieldname VALUE 'NEED18',
303          need19      TYPE fieldname VALUE 'NEED19',
304          need20      TYPE fieldname VALUE 'NEED20',
305          need21      TYPE fieldname VALUE 'NEED21',
306          need22      TYPE fieldname VALUE 'NEED22',
307          need23      TYPE fieldname VALUE 'NEED23',
308          need24      TYPE fieldname VALUE 'NEED24',
309          need25      TYPE fieldname VALUE 'NEED25',
310          need26      TYPE fieldname VALUE 'NEED26',
311          need27      TYPE fieldname VALUE 'NEED27',
312          need28      TYPE fieldname VALUE 'NEED28',
313    *     additional data
314          phase       TYPE fieldname VALUE 'PHASE',
315          phaseicon   TYPE fieldname VALUE 'PHASEICON',
316          aprvicon    TYPE fieldname VALUE 'APRVICON',
317          docmgnicon  TYPE fieldname VALUE 'DOCMGNICON',
318          objlsticon  TYPE fieldname VALUE 'OBJLSTICON',
319          partnericon TYPE fieldname VALUE 'PARTNERICON',
320          dialogicon  TYPE fieldname VALUE 'DIALOGICON',
321          processicon TYPE fieldname VALUE 'PROCESSICON',
322          ltxticon    TYPE fieldname VALUE 'LTXTICON',
323          tgtxticon   TYPE fieldname VALUE 'TGTXTICON',
324          untgtxticon TYPE fieldname VALUE 'UNTGTXTICON',
325          reqtxticon  TYPE fieldname VALUE 'REQTXTICON',
326          cattxt1     TYPE fieldname VALUE 'CATTXT1',
327          cattxt2     TYPE fieldname VALUE 'CATTXT2',
328          caticon1    TYPE fieldname VALUE 'CATICON1',
329          caticon2    TYPE fieldname VALUE 'CATICON2',
330          upasgnicon  TYPE fieldname VALUE 'UPASGNICON',
331          dnasgnicon  TYPE fieldname VALUE 'DNASGNICON',
332          oplsticon   TYPE fieldname VALUE 'OPLSTICON',
333          opstepicon  TYPE fieldname VALUE 'OPSTEPICON',
334        END   OF wcm,
335        BEGIN OF order,
336    *     general data
337          mandt      TYPE fieldname VALUE 'MANDT',
338          iphas      TYPE fieldname VALUE 'IPHAS',
339          aufnr      TYPE fieldname VALUE 'AUFNR',
340          auart      TYPE fieldname VALUE 'AUART',
341          autyp      TYPE fieldname VALUE 'AUTYP',
342          ktext      TYPE fieldname VALUE 'KTEXT',
343          ltext      TYPE fieldname VALUE 'LTEXT',
344          equnr      TYPE fieldname VALUE 'EQUNR',
345          eqktx      TYPE fieldname VALUE 'EQKTX',
346          tplnr      TYPE fieldname VALUE 'TPLNR',
347          pltxt      TYPE fieldname VALUE 'PLTXT',
348          qmnum      TYPE fieldname VALUE 'QMNUM',
349          iwerk      TYPE fieldname VALUE 'IWERK',
350          priok      TYPE fieldname VALUE 'PRIOK',
351          priokx     TYPE fieldname VALUE 'PRIOKX',
352          artpr      TYPE fieldname VALUE 'ARTPR',
353          ernam      TYPE fieldname VALUE 'ERNAM',
354          erdat      TYPE fieldname VALUE 'ERDAT',
355          ustxt      TYPE fieldname VALUE 'USTXT',
356          sttxt      TYPE fieldname VALUE 'STTXT',
357          aenam      TYPE fieldname VALUE 'AENAM',
358          aedat      TYPE fieldname VALUE 'AEDAT',
359          warpl      TYPE fieldname VALUE 'WARPL',
360          wapos      TYPE fieldname VALUE 'WAPOS',
361          revnr      TYPE fieldname VALUE 'REVNR',
362          plnnr      TYPE fieldname VALUE 'PLNNR',
363          plnal      TYPE fieldname VALUE 'PLNAL',
364          plknz      TYPE fieldname VALUE 'PLKNZ',
365          bautl      TYPE fieldname VALUE 'BAUTL',
366          gewrk      TYPE fieldname VALUE 'GEWRK',
367          loekz      TYPE fieldname VALUE 'LOEKZ',
368          fevor      TYPE fieldname VALUE 'FEVOR',
369          aning      TYPE fieldname VALUE 'ANING',
370          egauzt     TYPE fieldname VALUE 'EGAUZT',
371          kalsm      TYPE fieldname VALUE 'KALSM',
372          zschl      TYPE fieldname VALUE 'ZSCHL',
373          awerk      TYPE fieldname VALUE 'AWERK',
374          rkeobjnr   TYPE fieldname VALUE 'RKEOBJNR',
375          objnr      TYPE fieldname VALUE 'OBJNR',
376          lead_aufnr TYPE fieldname VALUE 'LEAD_AUFNR',
377          maufnr     TYPE fieldname VALUE 'MAUFNR',
378          bemot      TYPE fieldname VALUE 'BEMOT',
379          kostv      TYPE fieldname VALUE 'KOSTV',
380          sermat     TYPE fieldname VALUE 'SERMAT',
381          serialnr   TYPE fieldname VALUE 'SERIALNR',
382          deviceid   TYPE fieldname VALUE 'DEVICEID',
383          vkorg      TYPE fieldname VALUE 'VKORG',
384          vtweg      TYPE fieldname VALUE 'VTWEG',
385          spart      TYPE fieldname VALUE 'SPART',
386          vkbur      TYPE fieldname VALUE 'VKBUR',
387          vkgrp      TYPE fieldname VALUE 'VKGRP',
388          maktx      TYPE fieldname VALUE 'MAKTX',
389          bautlx     TYPE fieldname VALUE 'BAUTLX',
390          pagestat   TYPE fieldname VALUE 'PAGESTAT',
391          pspel      TYPE fieldname VALUE 'PSPEL',
392          audisp     TYPE fieldname VALUE 'AUDISP',
393          plgrp      TYPE fieldname VALUE 'PLGRP',
394          obknr      TYPE fieldname VALUE 'OBKNR',
395    *     location data
396          kokrs      TYPE fieldname VALUE 'KOKRS',
397          swerk      TYPE fieldname VALUE 'SWERK',
398          ilart      TYPE fieldname VALUE 'ILART',
399          arbpl      TYPE fieldname VALUE 'ARBPL',
400          kostl      TYPE fieldname VALUE 'KOSTL',
401          proid      TYPE fieldname VALUE 'PROID',
402          aufnt      TYPE fieldname VALUE 'AUFNT',
403          vorue      TYPE fieldname VALUE 'VORUE',
404          kdauf      TYPE fieldname VALUE 'KDAUF',
405          kdpos      TYPE fieldname VALUE 'KDPOS',
406          gsber      TYPE fieldname VALUE 'GSBER',
407          bukrs      TYPE fieldname VALUE 'BUKRS',
408          werks      TYPE fieldname VALUE 'WERKS',
409          anlnr      TYPE fieldname VALUE 'ANLNR',
410          anlun      TYPE fieldname VALUE 'ANLUN',
411          anlzu      TYPE fieldname VALUE 'ANLZU',
412          beber      TYPE fieldname VALUE 'BEBER',
413          stort      TYPE fieldname VALUE 'STORT',
414          eqfnr      TYPE fieldname VALUE 'EQFNR',
415          abckz      TYPE fieldname VALUE 'ABCKZ',
416          ingpr      TYPE fieldname VALUE 'INGPR',
417          msgrp      TYPE fieldname VALUE 'MSGRP',
418          aufpl      TYPE fieldname VALUE 'AUFPL',
419          apgrp      TYPE fieldname VALUE 'APGRP',
420          kunum      TYPE fieldname VALUE 'KUNUM',
421          prctr      TYPE fieldname VALUE 'PRCTR',
422    *     address data
423          adrnra     TYPE fieldname VALUE 'ADRNRA',
424          name_list  TYPE fieldname VALUE 'NAME_LIST',
425          tel_number TYPE fieldname VALUE 'TEL_NUMBER',
426          post_code1 TYPE fieldname VALUE 'POST_CODE1',
427          city1      TYPE fieldname VALUE 'CITY1',
428          city2      TYPE fieldname VALUE 'CITY2',
429          country    TYPE fieldname VALUE 'COUNTRY',
430          region     TYPE fieldname VALUE 'REGION',
431          street     TYPE fieldname VALUE 'STREET',
432    *     schedule dates
433          addat      TYPE fieldname VALUE 'ADDAT',
434          aduhr      TYPE fieldname VALUE 'ADUHR',
435          gltrp      TYPE fieldname VALUE 'GLTRP',
436          gstrp      TYPE fieldname VALUE 'GSTRP',
437          gltrs      TYPE fieldname VALUE 'GLTRS',
438          gstrs      TYPE fieldname VALUE 'GSTRS',
439          gstri      TYPE fieldname VALUE 'GSTRI',
440          getri      TYPE fieldname VALUE 'GETRI',
441          ftrmi      TYPE fieldname VALUE 'FTRMI',
442          hisda      TYPE fieldname VALUE 'HISDA',
443          geuzi      TYPE fieldname VALUE 'GEUZI',
444          gsuzi      TYPE fieldname VALUE 'GSUZI',
445          gluzs      TYPE fieldname VALUE 'GLUZS',
446          gsuzs      TYPE fieldname VALUE 'GSUZS',
447          gluzp      TYPE fieldname VALUE 'GLUZP',
448          gsuzp      TYPE fieldname VALUE 'GSUZP',
449          anlbd      TYPE fieldname VALUE 'ANLBD',
450          anlvd      TYPE fieldname VALUE 'ANLVD',
451          anlbz      TYPE fieldname VALUE 'ANLBZ',
452          anlvz      TYPE fieldname VALUE 'ANLVZ',
453    *     costs/revenues
454          gksti      TYPE fieldname VALUE 'GKSTI',
455          gkstp      TYPE fieldname VALUE 'GKSTP',
456          gksta      TYPE fieldname VALUE 'GKSTA',
457          gerti      TYPE fieldname VALUE 'GERTI',
458          gertp      TYPE fieldname VALUE 'GERTP',
459          gesist     TYPE fieldname VALUE 'GESIST',
460          gespln     TYPE fieldname VALUE 'GESPLN',
461          user4      TYPE fieldname VALUE 'USER4',
462          waers      TYPE fieldname VALUE 'WAERS',
463    *     service data
464          bstkd      TYPE fieldname VALUE 'BSTKD',
465          bstdk      TYPE fieldname VALUE 'BSTDK',
466          serv_matnr TYPE fieldname VALUE 'SERV_MATNR',
467          serv_maktx TYPE fieldname VALUE 'SERV_MAKTX',
468          menge      TYPE fieldname VALUE 'MENGE',
469          meins      TYPE fieldname VALUE 'MEINS',
470          faktf      TYPE fieldname VALUE 'FAKTF',
471    *     others
472          vornr      TYPE fieldname VALUE 'VORNR',
473        END   OF order,
474        BEGIN OF conflog,
475    *     technical fields
476          coltab    TYPE fieldname VALUE 'COLTAB',
477    *     general data
478          cnt       TYPE fieldname VALUE 'CNT',
479          iwerk     TYPE fieldname VALUE 'IWERK',
480          wcnr      TYPE fieldname VALUE 'WCNR',
481          seq       TYPE fieldname VALUE 'SEQ',
482          itmtyp    TYPE fieldname VALUE 'ITMTYP',
483          ccobj     TYPE fieldname VALUE 'CCOBJ',
484          cctyp     TYPE fieldname VALUE 'CCTYP',
485          stxt      TYPE fieldname VALUE 'STXT',
486          tggrp     TYPE fieldname VALUE 'TGGRP',
487          control   TYPE fieldname VALUE 'CONTROL',
488          location  TYPE fieldname VALUE 'LOCATION',
489    *     current operational data
490          stattxt04 TYPE fieldname VALUE 'STATTXT04',
491          bname     TYPE fieldname VALUE 'BNAME',
492          bdate     TYPE fieldname VALUE 'BDATE',
493          btime     TYPE fieldname VALUE 'BTIME',
494          actstep   TYPE fieldname VALUE 'ACTSTEP',
495          actproc   TYPE fieldname VALUE 'ACTPROC',
496          acttyp    TYPE fieldname VALUE 'ACTTYP',
497    *     data for the tagging
498          tgstep    TYPE fieldname VALUE 'TGSTEP',
499          tgproc    TYPE fieldname VALUE 'TGPROC',
500          tgtyp     TYPE fieldname VALUE 'TGTYP',
501          tgseq     TYPE fieldname VALUE 'TGSEQ',
502          tgtxt     TYPE fieldname VALUE 'TGTXT',
503    *     data for the untagging
504          unstep    TYPE fieldname VALUE 'UNSTEP',
505          unproc    TYPE fieldname VALUE 'UNPROC',
506          untyp     TYPE fieldname VALUE 'UNTYP',
507          unseq     TYPE fieldname VALUE 'UNSEQ',
508          untxt     TYPE fieldname VALUE 'UNTXT',
509    *     data for physical blocking
510          phblflg   TYPE fieldname VALUE 'PHBLFLG',
511          phbltyp   TYPE fieldname VALUE 'PHBLTYP',
512          phblnr    TYPE fieldname VALUE 'PHBLNR',
513    *     print
514          tgflg     TYPE fieldname VALUE 'TGFLG',
515          tgnr      TYPE fieldname VALUE 'TGNR',
516          tgform    TYPE fieldname VALUE 'TGFORM',
517          unnr      TYPE fieldname VALUE 'UNNR',
518          unform    TYPE fieldname VALUE 'UNFORM',
519    *     additional data
520          usable    TYPE fieldname VALUE 'USABLE',
521          lflg      TYPE fieldname VALUE 'LFLG',
522          docflg    TYPE fieldname VALUE 'DOCFLG',
523    *     administration data
524          crname    TYPE fieldname VALUE 'CRNAME',
525          crdate    TYPE fieldname VALUE 'CRDATE',
526          crtime    TYPE fieldname VALUE 'CRTIME',
527          chname    TYPE fieldname VALUE 'CHNAME',
528          chdate    TYPE fieldname VALUE 'CHDATE',
529          chtime    TYPE fieldname VALUE 'CHTIME',
530        END   OF conflog,
531        BEGIN OF lineup,
532          lunr      TYPE fieldname VALUE 'LUNR',
533          lutyp     TYPE fieldname VALUE 'LUTYP',
534          luuse     TYPE fieldname VALUE 'LUUSE',
535          lupverlvl TYPE fieldname VALUE 'LUPVERLVL',
536          lucverlvl TYPE fieldname VALUE 'LUCVERLVL',
537          reflunr   TYPE fieldname VALUE 'REFLUNR',
538        END   OF lineup,
539        BEGIN OF verlst,
540          vernr    TYPE fieldname VALUE 'VERNR',
541          refvernr TYPE fieldname VALUE 'REFVERNR',
542        END   OF verlst,
543        BEGIN OF catalog,
544          sfield   TYPE fieldname VALUE 'SFIELD',
545          codegrpx TYPE fieldname VALUE 'CODEGRPX',
546          codex    TYPE fieldname VALUE 'CODEX',
547          chkbox   TYPE fieldname VALUE 'CHKBOX',
548          sign     TYPE fieldname VALUE 'SIGN',
549        END   OF catalog,
550        BEGIN OF other,
551          order_objnr   TYPE fieldname VALUE 'ORDER_OBJNR',
552          fatherobj     TYPE fieldname VALUE 'FATHEROBJ',
553          childobj      TYPE fieldname VALUE 'CHILDOBJ',
554          link          TYPE fieldname VALUE 'LINK',
555          text          TYPE fieldname VALUE 'TEXT',
556          feedback      TYPE fieldname VALUE 'FEEDBACK',
557          pmsog         TYPE fieldname VALUE 'PMSOG',
558          msgtyp        TYPE fieldname VALUE 'MSGTYP',
559          msgtypx       TYPE fieldname VALUE 'MSGTYPX',
560          msgicon       TYPE fieldname VALUE 'MSGICON',
561          tgproc1       TYPE fieldname VALUE 'TGPROC1',
562          tgtyp1        TYPE fieldname VALUE 'TGTYP1',
563          tgproc2       TYPE fieldname VALUE 'TGPROC2',
564          tgtyp2        TYPE fieldname VALUE 'TGTYP2',
565          tgicon        TYPE fieldname VALUE 'TGICON',
566          unicon        TYPE fieldname VALUE 'UNICON',
567          paicon        TYPE fieldname VALUE 'PAICON',
568          filtericon    TYPE fieldname VALUE 'FILTERICON',
569          taskicon      TYPE fieldname VALUE 'TASKICON',
570          valicon       TYPE fieldname VALUE 'VALICON',
571          asgnicon      TYPE fieldname VALUE 'ASGNICON',
572          updflg        TYPE fieldname VALUE 'UPDFLG',
573          crflg         TYPE fieldname VALUE 'CRFLG',
574          delflg        TYPE fieldname VALUE 'DELFLG',
575          tgclass       TYPE fieldname VALUE 'TGCLASS',
576          lstid         TYPE fieldname VALUE 'LSTID',
577          stepicon      TYPE fieldname VALUE 'STEPICON',
578          staticon      TYPE fieldname VALUE 'STATICON',
579          clsdicon      TYPE fieldname VALUE 'CLSDICON',
580          objart        TYPE fieldname VALUE 'OBJART',
581          objtyp        TYPE fieldname VALUE 'OBJTYP',
582          objtxt        TYPE fieldname VALUE 'OBJTXT',
583          objkey        TYPE fieldname VALUE 'OBJKEY',
584          refobjtxt     TYPE fieldname VALUE 'REFOBJTXT',
585          refobjkey     TYPE fieldname VALUE 'REFOBJKEY',
586          dbflg         TYPE fieldname VALUE 'DBFLG',
587          crtcode       TYPE fieldname VALUE 'CRTCODE',
588          chtcode       TYPE fieldname VALUE 'CHTCODE',
589          dptcode       TYPE fieldname VALUE 'DPTCODE',
590          setcode       TYPE fieldname VALUE 'SETCODE',
591          crobjflg      TYPE fieldname VALUE 'CROBJFLG',
592          chobjflg      TYPE fieldname VALUE 'CHOBJFLG',
593          seobjflg      TYPE fieldname VALUE 'SEOBJFLG',
594          asgnflg       TYPE fieldname VALUE 'ASGNFLG',
595          direction     TYPE fieldname VALUE 'DIRECTION',
596          nr_object     TYPE fieldname VALUE 'NR_OBJECT',
597          int_range     TYPE fieldname VALUE 'INT_RANGE',
598          ext_range     TYPE fieldname VALUE 'EXT_RANGE',
599          priotyp       TYPE fieldname VALUE 'PRIOTYP',
600          pargr         TYPE fieldname VALUE 'PARGR',
601          stsma         TYPE fieldname VALUE 'STSMA',
602          bor_objtyp    TYPE fieldname VALUE 'BOR_OBJTYP',
603          objart1       TYPE fieldname VALUE 'OBJART1',
604          objtyp1       TYPE fieldname VALUE 'OBJTYP1',
605          objart2       TYPE fieldname VALUE 'OBJART2',
606          objtyp2       TYPE fieldname VALUE 'OBJTYP2',
607          reftcode      TYPE fieldname VALUE 'REFTCODE',
608          objlnkcnt     TYPE fieldname VALUE 'OBJLNKCNT',
609          aprvgrp       TYPE fieldname VALUE 'APRVGRP',
610          aprvicon      TYPE fieldname VALUE 'APRVICON',
611          gntxt         TYPE fieldname VALUE 'GNTXT',
612          sign          TYPE fieldname VALUE 'SIGN',
613          icon_val      TYPE fieldname VALUE 'ICON_VAL',
614          icon_task     TYPE fieldname VALUE 'ICON_TASK',
615          icon_k_genehm TYPE fieldname VALUE 'ICON_K_GENEHM',
616          pb_text       TYPE fieldname VALUE 'PB_TEXT',
617          updltxtflg    TYPE fieldname VALUE 'UPDLTXTFLG',
618          rejcflg       TYPE fieldname VALUE 'REJCFLG',
619          updrejcflg    TYPE fieldname VALUE 'UPDREJCFLG',
620          reftxt        TYPE fieldname VALUE 'REFTXT',
621          refobj        TYPE fieldname VALUE 'REFOBJ',
622          reftyp        TYPE fieldname VALUE 'REFTYP',
623          wkcrtyp       TYPE fieldname VALUE 'WKCRTYP',
624          wkcrid        TYPE fieldname VALUE 'WKCRID',
625          step          TYPE fieldname VALUE 'STEP',
626          stepx         TYPE fieldname VALUE 'STEPX',
627          requalflg     TYPE fieldname VALUE 'REQUALFLG',
628          catflg1       TYPE fieldname VALUE 'CATFLG1',
629          catflg2       TYPE fieldname VALUE 'CATFLG2',
630          lnkflg        TYPE fieldname VALUE 'LNKFLG',
631          parflg        TYPE fieldname VALUE 'PARFLG',
632          low           TYPE fieldname VALUE 'LOW',
633          txt4wap       TYPE fieldname VALUE 'TXT4WAP',
634          txt4wapi      TYPE fieldname VALUE 'TXT4WAPI',
635          txt4wcd       TYPE fieldname VALUE 'TXT4WCD',
636          reftxt4wap    TYPE fieldname VALUE 'REFTXT4WAP',
637          reftxt4wapi   TYPE fieldname VALUE 'REFTXT4WAPI',
638          reftxt4wcd    TYPE fieldname VALUE 'REFTXT4WCD',
639          refkey4wap    TYPE fieldname VALUE 'REFKEY4WAP',
640          refkey4wapi   TYPE fieldname VALUE 'REFKEY4WAPI',
641          refkey4wcd    TYPE fieldname VALUE 'REFKEY4WCD',
642          propkey4wcd   TYPE fieldname VALUE 'PROPKEY4WCD',
643          taskicon4wap  TYPE fieldname VALUE 'TASKICON4WAP',
644          taskicon4wapi TYPE fieldname VALUE 'TASKICON4WAPI',
645          taskicon4wcd  TYPE fieldname VALUE 'TASKICON4WCD',
646          pbpropconf    TYPE fieldname VALUE 'PBPROPCONF',
647          message       TYPE fieldname VALUE 'MESSAGE',
648          or            TYPE fieldname VALUE 'OR',
649          ww            TYPE fieldname VALUE 'WW',
650          wa            TYPE fieldname VALUE 'WA',
651          wd            TYPE fieldname VALUE 'WD',
652          prttyp        TYPE fieldname VALUE 'PRTTYP',
653          wcitm         TYPE fieldname VALUE 'WCITM',
654          completed     TYPE fieldname VALUE 'COMPLETED',
655          status        TYPE fieldname VALUE 'STATUS',
656        END   OF other,
657      END OF wctpz_field.
658    * FORMAT
659    CONSTANTS: wctpz_on  TYPE i VALUE 1.
660    CONSTANTS: wctpz_off TYPE i VALUE 0.
*--- End of %_CWCTPZ - 660 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CNTN01>                                  Level 1    Page 11
Object           ZRIWFWA01                                 Lines 613
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      * BITTE NEUE INCLUDES <CNTN02>, <CNTL03> benutzen!!!
3      ************************************************************************
4      * Dieses Include führt bei der Nutzung innerhalb eines CLASS-POOLS zu
5      * einer Vielzahl von Warnungen. Um dieses zu vermeiden, bitte das oben
6      * genannte Include in den lokalen Implementierungsteil einer gloabeln
7      * Klasse inkludieren.
8      ************************************************************************
9
10     *************************** Macros *************************************
11     * Types
12     TYPES:
13       swc_object LIKE obj_record.
14
15     * DATA Container
16     DEFINE swc_container.
17       DATA BEGIN OF &1 OCCURS 0.
18       INCLUDE STRUCTURE swcont.
19       DATA END OF &1.
20     END-OF-DEFINITION.
21
22     *************************** Data Declaration ***************************
23     DATA BEGIN OF swo_%return.
24     INCLUDE STRUCTURE swotreturn.
25     DATA END OF swo_%return.
26     DATA swo_%objid LIKE swotobjid.
27     DATA swo_%verb LIKE swotlv-verb.
28     DATA swo_%key_version TYPE as4vers.
29     DATA swo_%objkey TYPE swo_typeid.
30     DATA swo_%runtime_exception TYPE REF TO cx_swo_runtime_error.
31     swc_container swo_%container.
32
33     ************************* Error Handling   *****************************
34     * set system error codes from structure SWOTRETURN
35     * P1    Returncode of structure SWOTRETURN
36     DEFINE swc_%sys_error_set.
37       IF &1-code NE 0.
38         sy-msgid = &1-workarea.
39         sy-msgno = &1-message.
40         sy-msgty = 'E'.
41         sy-msgv1 = &1-variable1.
42         sy-msgv2 = &1-variable2.
43         sy-msgv3 = &1-variable3.
44         sy-msgv4 = &1-variable4.
45       ENDIF.
46       sy-subrc = &1-code.
47     END-OF-DEFINITION.
48
49     ************************* Container Macros *****************************
50     *** for documentation see Online Documentation: Workflow Container
51     * Create Container
52     DEFINE swc_create_container.
53       CLEAR &1.
54       REFRESH &1.
55     END-OF-DEFINITION.
56
57     * Release Container
58     DEFINE swc_release_container.
59       CLEAR &1.
60       REFRESH &1.
61     END-OF-DEFINITION.
62
63     * Clear Container
64     DEFINE swc_clear_container.
65       REFRESH &1.
66       CLEAR &1.
67     END-OF-DEFINITION.
68
69     * Container Create Element
70     DEFINE swc_create_element.
71       CALL FUNCTION 'SWC_ELEMENT_CREATE'  ##FM_SUBRC_OK
72            EXPORTING
73                 element   = &2
74            TABLES
75                 container = &1
76            EXCEPTIONS already_exists = 4
77                       OTHERS = 1.
78     END-OF-DEFINITION.
79
80     * Container Set Element
81     DEFINE swc_set_element.
82       CALL FUNCTION 'SWC_ELEMENT_SET' ##FM_SUBRC_OK
83            EXPORTING
84                 element       = &2
85                 field         = &3
86            TABLES
87                 container     = &1
88            EXCEPTIONS OTHERS = 1.
89     END-OF-DEFINITION.
90
91     * Container Set Table
92     DEFINE swc_set_table.
93       CALL FUNCTION 'SWC_TABLE_SET' ##FM_SUBRC_OK
94            EXPORTING
95                 element       = &2
96            TABLES
97                 container     = &1
98                 table         = &3
99            EXCEPTIONS OTHERS = 1.
100    END-OF-DEFINITION.
101
102    * Container Get Element
103    DEFINE swc_get_element.
104      CALL FUNCTION 'SWC_ELEMENT_GET'  ##FM_SUBRC_OK
105           EXPORTING
106                element       = &2
107           IMPORTING
108                field         = &3
109           TABLES
110                container     = &1
111           EXCEPTIONS not_found = 8
112                      is_null   = 4
113                      OTHERS = 1.
114    END-OF-DEFINITION.
115
116    * Container Get Table
117    DEFINE swc_get_table.
118      CALL FUNCTION 'SWC_TABLE_GET'  ##FM_SUBRC_OK
119           EXPORTING
120                element       = &2
121           TABLES
122                container     = &1
123                table         = &3
124           EXCEPTIONS not_found = 8
125                      is_null   = 4
126                      OTHERS = 1.
127    END-OF-DEFINITION.
128
129    * Container Löschen Element
130    DEFINE swc_delete_element.
131      CALL FUNCTION 'SWC_ELEMENT_DELETE'  ##FM_SUBRC_OK
132           EXPORTING
133                element   = &2
134           TABLES
135                container = &1
136           EXCEPTIONS OTHERS = 1.
137    END-OF-DEFINITION.
138
139    * Kopieren Container1/Element1 -> Container2/Element2
140    * Parameters:  P1  Quellcontainer
141    *              P2  Quellelement
142    *              P3  Zielcontainer
143    *              P4  Zielelement
144    DEFINE swc_copy_element.
145      CALL FUNCTION 'SWC_ELEMENT_COPY'  ##FM_SUBRC_OK
146           EXPORTING
147                source_element   = &2
148                target_element   = &4
149           TABLES
150                source_container = &1
151                target_container = &3
152           EXCEPTIONS
153                not_found        = 1
154                is_null          = 2
155                OTHERS           = 3.
156    END-OF-DEFINITION.
157
158
159    *************** Container Object Macros ********************************
160
161    * Create Object Reference, the key has the current version
162    * Parameters: P1   Object Reference to be created,  Output
163    *             P2   Type of the Object, Input
164    *             P3   Key of the Object, Input
165    *             P4   Object Location (logical system), Input
166    DEFINE swc_create_remote_object.
167      swo_%objid-objtype = &2.
168      swo_%objid-objkey  = &3.
169      swo_%objid-logsys  = &4.
170      &1-header = 'OBJH'.
171      &1-type   = 'SWO '.
172      CALL FUNCTION 'SWO_CREATE'
173           EXPORTING
174                objtype = swo_%objid-objtype
175                objkey  = swo_%objid-objkey
176                logical_system = swo_%objid-logsys
177           IMPORTING
178                object  = &1-handle
179                return  = swo_%return
180           EXCEPTIONS
181                no_remote_objects = 1
182                others            = 2  ##FM_SUBRC_OK.
183      IF swo_%return-code NE 0.
184        &1-handle = 0.
185      ENDIF.
186      swc_%sys_error_set swo_%return.
187    END-OF-DEFINITION.
188
189    * Create Object Reference via Dialog RFC destination if available, the key has the current version
190    * Parameters: P1   Object Reference to be created,  Output
191    *             P2   Type of the Object, Input
192    *             P3   Key of the Object, Input
193    *             P4   Object Location (logical system), Input
194    DEFINE swc_create_remote_dialg_object.
195      swo_%objid-objtype = &2.
196      swo_%objid-objkey  = &3.
197      swo_%objid-logsys  = &4.
198      &1-header          = 'OBJH'.
199      &1-type            = 'SWO '.
200      CALL FUNCTION 'SWO_CREATE'
201           EXPORTING
202                objtype        = swo_%objid-objtype
203                objkey         = swo_%objid-objkey
204                logical_system = swo_%objid-logsys
205                use_dialog_rfc = 'X'
206           IMPORTING
207                object         = &1-handle
208                return         = swo_%return
209           EXCEPTIONS
210                no_remote_objects = 1
211                others            = 2  ##FM_SUBRC_OK.
212      IF swo_%return-code NE 0.
213        &1-handle = 0.
214      ENDIF.
215      swc_%sys_error_set swo_%return.
216    END-OF-DEFINITION.
217
218    * Create Object Reference, the version is defined in the key
219    * Parameters: P1   Object Reference to be created,  Output
220    *             P2   Type of the Object, Input
221    *             P3   Key of the Object, Input
222    *             P4   Object Location (logical system), Input
223    *             P5   'X' <=> Use dialog RFC if possible
224    DEFINE swc_create_remote_legacy_obj.
225      swo_%objid-objtype = &2.
226      swo_%objid-objkey  = &3.
227      swo_%objid-logsys  = &4.
228      &1-header          = 'OBJH'.
229      &1-type            = 'SWO '.
230      CALL FUNCTION 'SWO_CREATE'
231           EXPORTING
232                objtype        = swo_%objid-objtype
233                objkey         = swo_%objid-objkey
234                logical_system = swo_%objid-logsys
235                set_current_key_version = abap_false
236                use_dialog_rfc          = &5
237           IMPORTING
238                object         = &1-handle
239                return         = swo_%return
240           EXCEPTIONS
241                no_remote_objects = 1
242                others            = 2  ##FM_SUBRC_OK.
243      IF swo_%return-code NE 0.
244        &1-handle = 0.
245      ENDIF.
246      swc_%sys_error_set swo_%return.
247    END-OF-DEFINITION.
248
249    * Create Object Reference, the version is defined explicitely
250    * Parameters: P1   Object Reference to be created,  Output
251    *             P2   Type of the Object, Input
252    *             P3   Key of the Object, Input
253    *             P4   Version of the key
254    *             P5   Object Location (logical system), Input
255    *             P6   'X' <=> Use dialog RFC if possible
256    DEFINE swc_create_remote_obj_w_vers.
257      swo_%objid-objtype    = &2.
258      swo_%objid-objkey     = &3.
259      swo_%objid-logsys     = &5.
260      &1-header             = 'OBJH'.
261      &1-type               = 'SWO '.
262      CALL FUNCTION 'SWO_CREATE'
263           EXPORTING
264                objtype                 = swo_%objid-objtype
265                objkey                  = swo_%objid-objkey
266                logical_system          = swo_%objid-logsys
267                set_current_key_version = abap_false
268                set_key_version         = &4
269                use_dialog_rfc          = &6
270           IMPORTING
271                object         = &1-handle
272                return         = swo_%return
273           EXCEPTIONS
274                no_remote_objects = 1
275                others            = 2  ##FM_SUBRC_OK.
276      IF swo_%return-code NE 0.
277        &1-handle = 0.
278      ENDIF.
279      swc_%sys_error_set swo_%return.
280    END-OF-DEFINITION.
281
282    * Create Object Reference, the key is passed as a structure
283    * Parameters: P1   Object Reference to be created,  Output
284    *             P2   Type of the Object, Input
285    *             P3   Key structure of the Object, Input
286    *             P4   Version of the key
287    *             P5   Object Location (logical system), Input
288    *             P6   'X' <=> Use dialog RFC if possible
289    DEFINE swc_create_remote_obj_from_key.
290      TRY.
291        cl_swo_key_handling=>get_instance( )->get_object_key(
292          EXPORTING
293            i_logsys      = &5
294            i_object_type = &2
295            i_logical_key = &3
296            i_key_version = &4
297          RECEIVING
298            r_object_key  = swo_%objkey ).
299
300          swo_%objid-objtype    = &2.
301          swo_%objid-objkey     = swo_%objkey.
302          swo_%objid-logsys     = &5.
303          &1-header             = 'OBJH'.
304          &1-type               = 'SWO '.
305          CALL FUNCTION 'SWO_CREATE'
306               EXPORTING
307                    objtype                 = swo_%objid-objtype
308                    objkey                  = swo_%objid-objkey
309                    logical_system          = swo_%objid-logsys
310                    set_current_key_version = abap_false
311                    set_caller_version      = &4
312                    use_dialog_rfc          = &6
313               IMPORTING
314                    object         = &1-handle
315                    return         = swo_%return
316               EXCEPTIONS
317                    no_remote_objects = 1
318                    others            = 2  ##FM_SUBRC_OK.
319          IF swo_%return-code NE 0.
320            &1-handle = 0.
321          ENDIF.
322          swc_%sys_error_set swo_%return.
323
324        CATCH cx_swo_runtime_error INTO swo_%runtime_exception.
325          &1-handle = 0.
326          swo_%return = swo_%runtime_exception->get_system_error( ).
327          swc_%sys_error_set swo_%return.
328      ENDTRY.
329
330    END-OF-DEFINITION.
331
332    * Create Object Reference, the key has the current version
333    * Parameters: P1   Object Reference to be created,  Output
334    *             P2   Type of the Object, Input
335    *             P3   Key of the Object, Input
336    DEFINE swc_create_object.
337
338      swc_create_remote_object &1 &2 &3 space.
339
340    END-OF-DEFINITION.
341
342    * Create Object Reference, the version is defined in the key
343    * Parameters: P1   Object Reference to be created,  Output
344    *             P2   Type of the Object, Input
345    *             P3   Key of the Object, Input
346    DEFINE swc_create_legacy_object.
347
348      swc_create_remote_legacy_obj &1 &2 &3 space space.
349
350    END-OF-DEFINITION.
351
352    * Create Object Reference, the key is passed as a structure
353    * Parameters: P1   Object Reference to be created,  Output
354    *             P2   Type of the Object, Input
355    *             P3   Key structure of the Object, Input
356    DEFINE swc_create_object_from_key.
357
358      swo_%key_version = cl_swo_key_handling=>get_instance( )->get_current_key_version( &2 ).
359
360      swc_create_remote_obj_from_key &1 &2 &3 swo_%key_version space space.
361
362    END-OF-DEFINITION.
363
364
365    * Free Object Reference
366    * Parameters: P1   Object Reference to be freed,  Input
367    DEFINE swc_free_object.
368      CALL FUNCTION 'SWO_FREE'
369           EXPORTING
370                object  = &1-handle
371           IMPORTING
372                return  = swo_%return.
373      swc_%sys_error_set swo_%return.
374    END-OF-DEFINITION.
375
376    * Get Object Type
377    * Parameters: P1   Object Reference , Input
378    *             P2   Name of the Objecttype, Output
379    DEFINE swc_get_object_type.
380      CALL FUNCTION 'SWO_OBJECT_ID_GET'
381           EXPORTING
382                object  = &1-handle
383           IMPORTING
384                return  = swo_%return
385                objid   = swo_%objid.
386      swc_%sys_error_set swo_%return.
387      &2 = swo_%objid-objtype.
388    END-OF-DEFINITION.
389
390    * Get Object Key
391    * Parameters: P1   Object Reference,  Input
392    *             P2   Object Key without key version information, Output
393    DEFINE swc_get_object_key.
394      CALL FUNCTION 'SWO_OBJECT_ID_GET'
395           EXPORTING
396                object  = &1-handle
397           IMPORTING
398                return  = swo_%return
399                objid   = swo_%objid.
400      swc_%sys_error_set swo_%return.
401      &2 = swo_%objid-objkey.
402    END-OF-DEFINITION.
403
404    * Get Object Key
405    * Parameters: P1   Object Reference,  Input
406    *             P2   Object Key with key version information (if available), Output
407    DEFINE swc_get_object_key_w_version.
408      CALL FUNCTION 'SWO_OBJECT_ID_GET'
409        EXPORTING
410          object = &1-handle
411          keep_object_version_info = abap_true
412        IMPORTING
413          return = swo_%return
414          objid  = swo_%objid.
415      swc_%sys_error_set swo_%return.
416      &2 = swo_%objid-objkey.
417    END-OF-DEFINITION.
418
419    * Get Property
420    * Parameters: P1   Object Reference,  Input
421    *             P2   Attribute Name, Input
422    *             P3   Value of the attribute, Output
423    DEFINE swc_get_property.
424      swc_create_container swo_%container.
425      CALL FUNCTION 'SWO_INVOKE'
426           EXPORTING
427                access     = 'G'
428                object     = &1-handle
429                verb       = &2
430                persistent = ' '
431           IMPORTING
432                return     = swo_%return
433                verb       = swo_%verb
434           TABLES
435                container  = swo_%container.
436      swc_%sys_error_set swo_%return.
437      IF sy-subrc = 0.
438        swc_get_element swo_%container swo_%verb &3.
439      ENDIF.
440    END-OF-DEFINITION.
441
442    * Get Table Property
443    * Parameters: P1   Object Reference,  Input
444    *             P2   Table Attribute Name, Input
445    *             P3   Value of the table attribute, Output
446    DEFINE swc_get_table_property.
447      swc_create_container swo_%container.
448      CALL FUNCTION 'SWO_INVOKE'
449           EXPORTING
450                access     = 'G'
451                object     = &1-handle
452                verb       = &2
453                persistent = ' '
454           IMPORTING
455                return     = swo_%return
456                verb       = swo_%verb
457           TABLES
458                container  = swo_%container.
459      swc_%sys_error_set swo_%return.
460      IF sy-subrc = 0.
461        swc_get_table swo_%container swo_%verb &3.
462      ENDIF.
463    END-OF-DEFINITION.
464
465    * Invoke Method
466    * Parameters: P1   Object Reference,  Input
467    *             P2   Method Name, Input
468    *             P3   Container with Import and Export parameters, In/Out
469    DEFINE swc_call_method.
470      CALL FUNCTION 'SWO_INVOKE'
471           EXPORTING
472                access     = 'C'
473                object     = &1-handle
474                verb       = &2
475                persistent = ' '
476           IMPORTING
477                return     = swo_%return
478           TABLES
479                container  = &3.
480      swc_%sys_error_set swo_%return.
481    END-OF-DEFINITION.
482
483    * Invoke Method asynchronously
484    * Parameters: P1   Object Reference,  Input
485    *             P2   Method Name, Input
486    *             P3   Container with Import and Export parameters, In/Out
487    DEFINE swc_call_method_async.
488      CALL FUNCTION 'SWO_INVOKE'
489           EXPORTING
490                access     = 'C'
491                object     = &1-handle
492                verb       = &2
493                persistent = ' '
494                synchron   = ' '
495                no_arfc    = 'X'
496           IMPORTING
497                return     = swo_%return
498           TABLES
499                container  = &3.
500      swc_%sys_error_set swo_%return.
501    END-OF-DEFINITION.
502
503    * Refresh Object Properties
504    * Parameters: P1   Object Reference,  Input
505    DEFINE swc_refresh_object.
506      CALL FUNCTION 'SWO_OBJECT_REFRESH'
507           EXPORTING
508                object       = &1
509           EXCEPTIONS
510                error_create = 02.
511    END-OF-DEFINITION.
512    ***************** Events ***********************************************
513    * Raise Event
514    * Parameters: P1   Objectreference, Input
515    *             P2   Event Name, Input
516    *             P3   Event container with export parameters, Input
517    DEFINE swc_raise_event.
518      IF &1-handle > 0.
519        swc_create_container swo_%container.
520        LOOP AT &3.
521          swo_%container = &3.
522          APPEND swo_%container.
523        ENDLOOP.
524    *   Make container a persistent
525        CALL FUNCTION 'SWC_CONT_PERSISTENT_CONVERT'
526           EXPORTING
527                from_persistent = ' '
528                to_persistent   = 'X'
529           IMPORTING
530                return          = swo_%return
531           TABLES
532                container       = swo_%container
533           EXCEPTIONS
534                OTHERS          = 1.
535        IF swo_%return-code = 0.
536    *     Raise event
537          swc_get_object_type &1 swo_%objid-objtype.
538          swc_get_object_key &1 swo_%objid-objkey.
539          CALL FUNCTION 'SWE_EVENT_CREATE'
540             EXPORTING
541                  objtype              = swo_%objid-objtype
542                  objkey               = swo_%objid-objkey
543                  event                = &2
544             TABLES
545                  event_container      = swo_%container
546             EXCEPTIONS
547                  objtype_not_found    = 1
548                  OTHERS               = 2.
549        ELSE.
550          swc_%sys_error_set swo_%return.
551        ENDIF.
552      ELSE.
553        sy-subrc = 4.
554      ENDIF.
555    END-OF-DEFINITION.
556
557    ************ Converting containers *************************************
558    * Convert persistent container to runtime format
559    * Parameters: P1   Container, In/Out
560    *             P2   from persistent,  In
561    *             P3   to persistent,    In
562    DEFINE swc_container_convert.
563      CALL FUNCTION 'SWC_CONT_PERSISTENT_CONVERT'
564         EXPORTING
565              from_persistent = &2
566              to_persistent   = &3
567         IMPORTING
568              return          = swo_%return
569         TABLES
570              container       = &1
571         EXCEPTIONS
572              OTHERS          = 1.
573      swc_%sys_error_set swo_%return.
574    END-OF-DEFINITION.
575    * Convert persistent container to runtime format
576    * Parameters: P1   Container, In/Out
577    DEFINE swc_container_to_runtime.
578      swc_container_convert &1 'X' ' '.
579    END-OF-DEFINITION.
580    * Make container persistent
581    * Parameters: P1   Container, In/Out
582    DEFINE swc_container_to_persistent.
583      swc_container_convert &1 ' ' 'X'.
584    END-OF-DEFINITION.
585
586    * Convert handle to persistent object reference
587    * Parameters:   P1   object handle,   In
588    *               P2   persistent object reference (SWOTOBJID),   Out
589    DEFINE swc_object_to_persistent.
590      CALL FUNCTION 'SWO_OBJECT_ID_GET'
591           EXPORTING
592                object  = &1-handle
593           IMPORTING
594                return  = swo_%return
595                objid   = swo_%objid.
596      swc_%sys_error_set swo_%return.
597      &2 = swo_%objid.
598    END-OF-DEFINITION.
599
600    * Convert persistent object reference to runtime handle
601    * Parameters:   P1   persistent object reference (SWOTOBJID),   Out
602    *               P2   object handle,   In
603    DEFINE swc_object_from_persistent.
604      swc_create_legacy_object &2 &1-objtype &1-objkey.
605    END-OF-DEFINITION.
606
607    * Compress container
608    * Parameters:   P   container,     Changing
609    DEFINE swc_container_compress.
610      CALL FUNCTION 'SWC_CONT_COMPRESS'
611        TABLES
612          container       = &1.
613    END-OF-DEFINITION.
*--- End of <CNTN01> - 613 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <OBJECT>                                  Level 1    Page 12
Object           ZRIWFWA01                                 Lines 339
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      program object.
2      * Include Container-Macros
3      *include <cntain>.
4      include <cntn01>.
5      * OLE 2.0 INCLUDE
6      include ole2incl.
7      ******************** Class  Data ***************************************
8      define begin_data_class.
9        data begin of &1.
10     end-of-definition.
11     define end_data_class.
12       data end of &1.
13     end-of-definition.
14     ******************** Object Data ***************************************
15     data self  type swc_object.
16     data super type swc_object.
17     data swo_%status_check(30) value 'STATUS_CHECK'.
18     * Begin Object
19     define begin_data.
20       data begin of &1 occurs 0.
21       data _handle like swotinvoke-object.
22       data _objecttypename like swotinvoke-objtype.
23       data _remote_auth_check_required type abap_bool.
24     end-of-definition.
25     field-symbols <object>.
26     * End Object
27     define end_data.
28       data end of &1.
29       data swo_%tabix like sy-tabix.
30       form swo_%invoke using invoke structure swotinvoke remote_auth_check_required type abap_bool.
31         invoke-invoked = 'X'.
32         self-header  = 'OBJH'.
33         self-type   = 'SWO '.
34         self-handle = invoke-object.
35         if object-_handle ne invoke-object.
36           if swo_%tabix ne 0.
37             if object-_handle ne 0.
38               modify object index swo_%tabix.
39             else.
40               delete object index swo_%tabix.
41             endif.
42           endif.
43           read table object with key invoke-object.
44           if sy-subrc = 0.
45             swo_%tabix = sy-tabix.
46           else.
47             clear object.
48             object-_handle = invoke-object.
49             object-_objecttypename = invoke-objtype.
50             object-key = invoke-objkey.
51             append object.
52             describe table object lines swo_%tabix.
53           endif.
54         endif.
55         data key like object-key.
56         key = invoke-objkey. " ´remove key version
57         if invoke-refresh ne space or object-key ne key.
58           clear object.
59           object-_objecttypename = invoke-objtype.
60           object-_handle = invoke-object.
61           object-key = invoke-objkey.
62         endif.
63         if remote_auth_check_required <> abap_undefined.
64           object-_remote_auth_check_required = remote_auth_check_required.
65         endif.
66       endform.
67
68       form swo_%refresh_instance using handle like swotrtime-object.
69         data temp_object like object.
70         temp_object = object.
71         read table object with key _handle = handle.
72         if sy-subrc = 0.
73           delete object index sy-tabix.
74           if temp_object-_handle = handle.
75             clear object.
76             clear swo_%tabix.
77           else.
78             object = temp_object.
79           endif.
80         endif.
81       endform.
82
83       form swo_%refresh using object like swotrtime-object.
84
85       endform.
86
87       form swo_%refresh_all.
88         refresh object. clear object.
89       endform.
90     end-of-definition.
91
92     ***************** Result ***********************************************
93     data result(32) value '_RESULT'.
94
95     ***************** Return ***********************************************
96     * datatype for exception
97     types: begin of swc_exception,
98              exception_occured(1),
99              returncode           like swotinvoke-code,
100             variable1            like swotinvoke-variable1,
101             variable2            like swotinvoke-variable2,
102             variable3            like swotinvoke-variable3,
103             variable4            like swotinvoke-variable4,
104           end of swc_exception.
105    constants:
106      swc_no_exception(1)   value ' ',
107      swc_exception_occured value 'X'.
108
109    * Initialize exception
110    define swc_exception_init.
111      clear &1.
112      &1-exception_occured = swc_no_exception.
113    end-of-definition.
114
115    * Set exception data
116    define swc_exception_set.
117      clear &1.
118      &1-exception_occured  = swc_exception_occured.
119      &1-returncode         = &2.
120      &1-variable1          = &3.
121      &1-variable2          = &4.
122      &1-variable3          = &5.
123      &1-variable4          = &6.
124    end-of-definition.
125
126    * Exit using exception data
127    define exit_with_exception.
128      exit_return &1-returncode
129                  &1-variable1
130                  &1-variable2
131                  &1-variable3
132                  &1-variable4.
133    end-of-definition.
134
135    * Exit using runtime exception
136    define exit_with_runtime_exception.
137      swo_%return = &1->get_system_error( ).
138      exit_return swo_%return-code
139                  swo_%return-variable1
140                  swo_%return-variable2
141                  swo_%return-variable3
142                  swo_%return-variable4.
143    end-of-definition.
144
145    * Exit if exception has occured
146    define exit_if_exception.
147      if &1-exception_occured = swc_exception_occured.
148        exit_with_exception &1.
149      endif.
150    end-of-definition.
151
152    * Exit with Returncode  (only within methods)
153    define exit_return.
154      swo_%invoke-code = &1.
155      swo_%invoke-variable1 = &2.
156      swo_%invoke-variable2 = &3.
157      swo_%invoke-variable3 = &4.
158      swo_%invoke-variable4 = &5.
159      exit.
160    end-of-definition.
161
162    * Exit if Object not found  (only within methods and getproperty)
163    define exit_object_not_found.
164      swo_%invoke-code = 8026.
165      swo_%invoke-variable1 = object-key.
166      swo_%invoke-variable2 = object-_objecttypename.
167      exit.
168    end-of-definition.
169
170    * Exit if User cancels     (only within methods)
171    define exit_cancelled.
172      swo_%invoke-code = 8017.
173      exit.
174    end-of-definition.
175
176    * Exit if method is not yet implemented
177    define exit_not_implemented.
178      set extended check off.
179      swo_%invoke-code = 8048.
180      swo_%invoke-variable1 = &1.   "method name
181      set extended check on.
182      exit.
183    end-of-definition.
184
185    * Exit if obligate Parameter is missed (only within methods)
186    define exit_parameter_not_found.
187      set extended check off.
188      swo_%invoke-code = 8013.
189      swo_%invoke-variable1 = &1.                " Parameter Name
190      swo_%invoke-variable2 = swo_%invoke-verb.  " Method Name
191      set extended check on.
192      exit.
193    end-of-definition.
194
195    * Exit if Property is not defined (only within getproperty)
196    define exit_property_not_found.
197      swo_%invoke-code = 8013.
198      swo_%invoke-variable1 = swo_%invoke-verb.
199      exit.
200    end-of-definition.
201
202    ***************** PROPERTYs ******************************************
203    * Virtuell PROPERTY
204    define get_property.
205      form _get_&1 tables &3 structure swcont
206                    &2    swo_%invoke structure swotinvoke remote_auth_check_required..
207      data swo_%object type swc_object.
208      data swo_%objnr(22).
209      perform swo_%invoke using swo_%invoke remote_auth_check_required..
210      if swo_%invoke-debug ne space.
211      break-point '%_VERIFICATION-MESSAGE'.                    "#EC NOBREAK
212      endif.
213    end-of-definition.
214
215    * Table  PROPERTY
216    define get_table_property.
217      form _gettable_&1 tables container structure swcont
218        changing  swo_%invoke structure swotinvoke remote_auth_check_required..
219      data swo_%object type swc_object.
220      data swo_%objnr(22).
221      perform swo_%invoke using swo_%invoke remote_auth_check_required..
222      if swo_%invoke-debug ne space.
223      break-point '%_VERIFICATION-MESSAGE'.                    "#EC NOBREAK
224      endif.
225    end-of-definition.
226
227    * End PROPERTY
228    field-symbols <swo_%field> type any.
229    define end_property.
230      if swo_%invoke-dbfield ne space.
231        assign (swo_%invoke-dbfield) to <swo_%field>.
232        if sy-subrc <> 0.
233          exit_return 8015 swo_%invoke-dbfield sy-repid
234                          space space.
235        endif.
236        if swo_%invoke-istat ne space.
237          swo_%objnr = <swo_%field>.
238        elseif swo_%invoke-reftype = 'O'.
239          swc_create_object
240               swo_%object swo_%invoke-refobjtype  <swo_%field>.
241          swc_set_element container swo_%invoke-verb swo_%object.
242        else.
243          swc_set_element container swo_%invoke-verb <swo_%field>.
244        endif.
245      endif.
246      if swo_%invoke-istat ne space.
247        if swo_%invoke-dbfield = space.
248          swc_get_element container 'STATUSOBJNUMBER' swo_%objnr.
249        endif.
250        call function swo_%status_check
251             exporting
252                  bypass_buffer     = 'X'
253                  client            = sy-mandt
254                  objnr             = swo_%objnr
255                  status            = swo_%invoke-istat
256             exceptions
257                  object_not_found  = 01
258                  status_not_active = 02.
259        case sy-subrc.
260          when 0.  swc_set_element container swo_%invoke-verb 'X'.
261          when 1.  exit_return 8023 swo_%objnr
262                                    swo_%invoke-verb
263                                    swo_%invoke-objtype  space.
264          when 2.  swc_set_element container swo_%invoke-verb ' '.
265        endcase.
266      endif.
267    endform.
268    end-of-definition.
269    ***************** Method ***********************************************
270    * Begin Method
271    define begin_method.
272      form &1 tables &3 structure swcont
273                    &2    swo_%invoke structure swotinvoke remote_auth_check_required type abap_bool.
274      perform swo_%invoke using swo_%invoke remote_auth_check_required.
275      if swo_%invoke-debug ne space.
276      break-point '%_VERIFICATION-MESSAGE'.                    "#EC NOBREAK
277      endif.
278    end-of-definition.
279
280    * End Method
281    define end_method.
282      swo_%invoke-objkey = object-key.
283      cl_swo_key_handling=>get_instance( )->set_current_version( exporting i_object_type = object-_objecttypename changing c_key = swo_%invoke-objkey ).
284    endform.
285    end-of-definition.
286
287    **************Set Object Key********************************************
288    data: swo_%invoke_stack like swotinvoke occurs 0 with header line.
289    data: swo_%invoke_stack_ptr type i.
290    data: swo_%invoke_id(30) value 'SWO_INVOKE_INTERNAL'.
291    data: swo_%invoke_objkey like swotrtime-objkey.
292
293    define swc_set_objectkey.
294      swo_%invoke_objkey = &1.
295      cl_swo_key_handling=>get_instance( )->set_current_version( exporting i_object_type = object-_objecttypename changing c_key = swo_%invoke_objkey ).
296
297      import invoke_stack to swo_%invoke_stack
298             invoke_stack_ptr to swo_%invoke_stack_ptr
299             from memory id swo_%invoke_id.
300      read table swo_%invoke_stack with key object = self-handle.
301      if sy-subrc = 0.
302        swo_%invoke_stack-objkey = swo_%invoke_objkey.
303        modify swo_%invoke_stack index sy-tabix.
304        export invoke_stack from swo_%invoke_stack
305               invoke_stack_ptr from swo_%invoke_stack_ptr
306               to memory id swo_%invoke_id.
307      endif.
308
309      object-key         = &1.
310      call function 'SWO_OBJECT_ID_SET'
311           exporting
312                object    = self-handle
313                objectkey = swo_%invoke_objkey
314           importing
315                return    = swo_%return
316           exceptions
317                others    = 1.
318    end-of-definition.
319
320    *Declare logical_key
321    * Parameters:   P1   dictionary structure of logical key
322    define swc_key.
323      data: key_computed type abap_bool,
324            key          type &1.
325    end-of-definition.
326
327    *Initialize logical key
328    *
329    define swc_access_key.
330      if object-private-key_computed eq abap_false.
331        cl_swo_key_handling=>get_instance( )->get_logical_key(
332          exporting
333            i_object_type = object-_objecttypename
334            i_key         = object-key
335          importing
336            e_logical_key = object-private-key ).
337        object-private-key_computed = abap_true.
338      endif.
339    end-of-definition.
*--- End of <OBJECT> - 339 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <SYSINI>                                  Level 1    Page 13
Object           ZRIWFWA01                                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
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
Generated incl.  OLE2INCL                                  Level 1    Page 14
Object           ZRIWFWA01                                 Lines 2
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:36
----------------------------------------------------------------------------------------------------
1      ***INCLUDE OLE2INCL.
2      TYPE-POOLS OLE2 .
*--- End of OLE2INCL - 2 lines ---
