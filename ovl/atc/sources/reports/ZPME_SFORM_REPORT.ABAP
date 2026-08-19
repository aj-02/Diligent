----------------------------------------------------------------------------------------------------
Main program     ZPME_SFORM_REPORT                         Level 0    Page 1
Object           ZPME_SFORM_REPORT                         Lines 268
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:18
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZPME_SFORM_REPORT
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8
9      report  zpme_sform_report.
10     TABLES: ehs_perprosc, ehs_perprscd, ehs_pernr,
11             ehs00fbpersdat,t7ehs00_protexam,t7ehs00_examlab,t7ehs00_examphy,T7EHS00_srv_exa.
12     TYPES: t_ehs_pernr TYPE STANDARD TABLE OF ehs_pernr,
13            t_perprscd  TYPE STANDARD TABLE OF ehs_perprscd,
14            t_prott     TYPE STANDARD TABLE OF t7ehs00_prott.
15
16     TYPES: BEGIN OF ty_perprosc_t,
17             pernr        TYPE ehs_pernr-pernr,
18             sname        TYPE ehs_pernr-sname,
19             gbdat        TYPE ehs_pernr-gbdat,
20             perid        TYPE ehs_pernr-perid,
21             person_flag  TYPE ehs_pernr-person_flag,
22             pgroup       LIKE ehs_perprosc-pgroup,
23             pnumber      LIKE ehs_perprosc-pnumber,
24             pname(50),
25             prot_type     TYPE ehs_perprosc-prot_type,
26             prot_frtypnam TYPE t7ehs00_freqtypt-prot_frtypnam,
27             last_sched    TYPE ehs_perprosc-last_sched,
28             next_sched    TYPE ehs_perprosc-next_sched,
29             status_prot   TYPE ehs_perprosc-status_prot,
30     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
31     *         status_protnam TYPE ehs00_stat_prott,
32             status_protnam TYPE CHAR20,
33     " Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
34             byhand_flag  LIKE ehs_perprosc-byhand_flag,
35             byhand_txt(20),
36             begda        LIKE ehs_perprscd-begda,
37             endda        LIKE ehs_perprscd-endda,
38             uname        LIKE ehs_perprosc-uname,
39             aedtm        LIKE ehs_perprosc-aedtm,
40             person_id    LIKE ehs_pernr-person_id,
41             nachn        LIKE ehs_pernr-nachn,
42             vorna        LIKE ehs_pernr-vorna,
43             werks        TYPE persa,  " Personnel Area
44             name1        TYPE pbtxt,  " Personnel Area Text
45             orgeh        TYPE orgeh,  " Organizational Unit
46             orgtx        TYPE orgtx,  " Short Text of Organizational Unit
47             grade        TYPE zdesignation_rev-grade,
48             desig_text   TYPE zdesignation_rev-desig_text,
49
50         END OF ty_perprosc_t.
51
52     DATA:  o_perprosc  TYPE STANDARD TABLE OF ty_perprosc_t,
53            o_perprscd  TYPE t_perprscd,
54                   i_ehspernr  TYPE t_ehs_pernr.
55     DATA:  wa_perprosc    TYPE ty_perprosc_t.
56     DATA:  wa_perprscd TYPE ehs_perprscd.
57
58     data : fm_name type rs38l_fnam.
59     data : output_options type ssfcompop,
60            control type ssfctrlop.
61     data : it_prh type table of zpme_pa_prh,
62            wa_prh like line of it_prh.
63     data : it_hpe type table of zpme_pa_hpe,
64            wa_hpe like line of it_hpe.
65
66     data :  outop         TYPE ssfcompop,
67             cparam        TYPE ssfctrlop.
68     data: st_control_parameters type ssfctrlop,
69           st_output_options type ssfcompop,
70           st_document_output_info type ssfcrespd,
71           st_job_output_info type ssfcrescl,
72           st_job_output_options type ssfcresop,
73           v_e_devtype type rspoptype,
74           v_language type sflangu value 'E'.
75     data : lt_otfdata type table of itcoo.
76
77     parameters : lv_para type char10.
78     parameters : lv_doc type char10.
79     DATA lv_begda type T7EHS00_service-srv_opendate.
80
81     *GET ehs_pernr.
82     *  APPEND ehs_pernr TO i_ehspernr.
83     *
84     *GET ehs_perprosc.
85     *  MOVE-CORRESPONDING ehs_perprosc TO wa_perprosc.
86     *  APPEND wa_perprosc TO o_perprosc.
87     *
88     *GET ehs_perprscd.
89     *  APPEND ehs_perprscd TO o_perprscd.
90     ************************************
91     *  sort o_perprscd by begda descending.
92     *  READ TABLE o_perprscd INTO wa_perprscd index 1.
93     *  if sy-subrc = 0.
94     *    lv_begda = wa_perprscd-begda.
95     *  endif.
96     perform get_detail.
97
98     ***********************************
99
100
101    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
102      EXPORTING
103        formname           = 'ZPME_SFORM_REPORT'
104      IMPORTING
105        fm_name            = fm_name
106      EXCEPTIONS
107        no_form            = 1
108        no_function_module = 2
109        others             = 3.
110
111    if sy-subrc <> 0.
112      message id sy-msgid type sy-msgty number sy-msgno
113              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
114    endif.
115
116    outop-tdnoprev = 'X'.
117    outop-tdtitle = sy-title.
118    outop-tdnewid = 'X'.
119    outop-tdprinter = 'PDF1'.
120
121
122    cparam-no_dialog  = 'X' .
123    cparam-preview    = 'X'.
124    cparam-getotf     = 'X'.
125
126    *control-preview = 'X'.
127    *control-no_open = ' '.
128    *control-no_close = ' '.
129    *control-no_dialog = ''.
130    *control-getotf = ' '.
131    *control-device = 'PRINTER'.
132
133    *output_options-tddest = 'LOCL'.
134
135    call function fm_name
136      exporting
137                 control_parameters = cparam
138                 output_options     = outop
139    **   ARCHIVE_INDEX              =
140    **   ARCHIVE_INDEX_TAB          =
141    **   ARCHIVE_PARAMETERS         =
142    *   control_parameters         = control
143    **   MAIL_APPL_OBJ              =
144    **   MAIL_RECIPIENT             =
145    **   MAIL_SENDER                =
146    *   output_options             = output_options
147    *   USER_SETTINGS              = 'X'
148        lv_cpf_no                  = lv_para
149        lv_doc                     = lv_doc
150        lv_begda                   = lv_begda
151     IMPORTING
152        document_output_info = st_document_output_info
153        job_output_info      = st_job_output_info
154        job_output_options   = st_job_output_options
155    * Begin of Changes on 25-Jun-2013
156     EXCEPTIONS
157       FORMATTING_ERROR           = 1
158       INTERNAL_ERROR             = 2
159       SEND_ERROR                 = 3
160       USER_CANCELED              = 4
161       OTHERS                     = 5
162    * End of Changes on 25-Jun-2013
163              .
164    if sy-subrc <> 0.
165      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
166              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
167    endif.
168
169    refresh lt_otfdata.
170    lt_otfdata[] = st_job_output_info-otfdata[].
171
172    CALL FUNCTION 'FOPC_REPORT_SHOW_PDF'
173      EXPORTING
174        it_otfdata = lt_otfdata.
175
176
177    *&---------------------------------------------------------------------*
178    *&      Form  GET_DETAIL
179    *&---------------------------------------------------------------------*
180    *       text
181    *----------------------------------------------------------------------*
182    *  -->  p1        text
183    *  <--  p2        text
184    *----------------------------------------------------------------------*
185    form get_detail .
186      data : l_pernr type T7EHS00_MAPPERNR-intpernr.
187      data :l_srv_signoffdate type T7EHS00_SERVICE-srv_signoffdate,
188            l_srv_exam_date type T7EHS00_srv_exa-srv_exam_date,
189            wa_pme_pa_det type zpme_pa_det.
190
191      DATA : wa_T7EHS00_SRV_EXA TYPE T7EHS00_SRV_EXA,
192            ist_T7EHS00_SRV_EXA TYPE STANDARD TABLE OF T7EHS00_SRV_EXA.
193
194      data : wa_T7EHS00_PERPRscd type T7EHS00_PERPRscd.
195      select * from zpme_pa_prh into table it_prh where cpf_no = lv_para and docu_no = lv_doc.
196
197      clear : l_pernr.
198      SELECT INTPERNR FROM T7EHS00_MAPPERNR
199     INTO L_PERNR UP TO 1 ROWS WHERE PERSON_ID = LV_PARA
200     ORDER BY PRIMARY KEY .
201     ENDSELECT.
202
203      if sy-subrc = 0.
204        clear : wa_pme_pa_det.
205        select single * from zpme_pa_det
206          into wa_pme_pa_det
207          where cpf_no = lv_para
208          and docu_no = lv_doc.
209
210        if sy-subrc = 0.
211
212          SELECT SRV_EXAM_DATE
213     INTO L_SRV_EXAM_DATE FROM T7EHS00_SRV_EXA UP TO 1 ROWS WHERE SRV_NUMBER = WA_PME_PA_DET-SRV_NUMBER
214     ORDER BY PRIMARY KEY .
215     ENDSELECT.
216          if sy-subrc = 0.
217            lv_begda = l_srv_exam_date.
218          else.
219            clear : l_srv_signoffdate.
220
221            select single srv_signoffdate
222              from T7EHS00_SERVICE
223              into l_srv_signoffdate
224              where srv_number = wa_pme_pa_det-srv_number
225              and pernr = l_pernr.
226            if l_srv_signoffdate = '00000000'.
227              select single srv_opendate
228                  from T7EHS00_SERVICE
229                  into l_srv_signoffdate
230                  where srv_number = wa_pme_pa_det-srv_number
231                  and pernr = l_pernr.
232            endif.
233            lv_begda = l_srv_signoffdate.
234          endif.
235
236          CLEAR:ist_T7EHS00_SRV_EXA,WA_T7EHS00_SRV_EXA.
237          REFRESH ist_T7EHS00_SRV_EXA.
238
239          SELECT * FROM T7EHS00_SRV_EXA
240              INTO CORRESPONDING FIELDS OF TABLE ist_T7EHS00_SRV_EXA
241              WHERE SRV_NUMBER = wa_pme_pa_det-srv_number.
242          IF NOT ist_T7EHS00_SRV_EXA[] IS INITIAL.
243            SORT ist_T7EHS00_SRV_EXA BY SRV_EXAM_DATE ASCENDING.
244            READ TABLE ist_T7EHS00_SRV_EXA INTO wa_T7EHS00_SRV_EXA INDEX 1.
245            lv_begda = wa_T7EHS00_SRV_EXA-SRV_EXAM_DATE.
246          ENDIF.
247    *DATA :   ist_T7EHS00_PERPROSC TYPE STANDARD TABLE OF T7EHS00_PERPROSC  ,
248    *         WA_T7EHS00_PERPROSC
249    *SELECT * from T7EHS00_PERPROSC
250    *  into CORRESPONDING FIELDS OF TABLE ist_T7EHS00_PERPROSC
251    *  where pernr = l_pernr   .
252    *  SORT ist_T7EHS00_PERPROSC by number DESCENDING.
253    *  READ TABLE ist_T7EHS00_PERPROSC INTO WA_T7EHS00_PERPROSC INDEX 1.
254    *          lv_begda = WA_T7EHS00_PERPROSC-LAST_SCHED.
255    *    endif.
256    *    select single * from T7EHS00_PERPRscd
257    *      into wa_T7EHS00_PERPRscd
258    *      where pernr = l_pernr
259    *      and endda = '99991231'.
260    *    select single last_sched from T7EHS00_PERPRosc
261    *  into lv_begda
262    *  where pernr = l_pernr
263    *      and pgroup = wa_T7EHS00_PERPRscd-pgroup
264    *      and pnumber = wa_T7EHS00_PERPRscd-pnumber.
265    **      and endda = '99991231'.
266        endif.
267      ENDIF.
268    endform.                    " GET_DETAIL
*--- End of ZPME_SFORM_REPORT - 268 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZPME_SFORM_REPORT                         Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:18
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
Object           ZPME_SFORM_REPORT                         Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:18
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
Object           ZPME_SFORM_REPORT                         Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:18
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
Object           ZPME_SFORM_REPORT                         Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:18
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
