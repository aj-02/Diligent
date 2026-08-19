----------------------------------------------------------------------------------------------------
Main program     ZFI_EMP_VEND_BANK_DETAIL                  Level 0    Page 1
Object           ZFI_EMP_VEND_BANK_DETAIL                  Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:05
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZHR_EMP_VEND_BANK_DETAIL
3      *&
4      *&---------------------------------------------------------------------*
5      *& Developed by : Manisha bh.
6      *&
7      *&---------------------------------------------------------------------*
8      REPORT zfi_emp_vend_bank_detail.
9
10     INCLUDE zfi_emp_vend_bank_detail_top.
11
12     INCLUDE zfi_emp_vend_bank_detail_pai.
13
14     INCLUDE zfi_emp_vend_bank_detail_pbo.
*--- End of ZFI_EMP_VEND_BANK_DETAIL - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_EMP_VEND_BANK_DETAIL_TOP              Level 1    Page 2
Object           ZFI_EMP_VEND_BANK_DETAIL                  Lines 88
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:05
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_EMP_VEND_BANK_DETAIL_TOP
3      *&---------------------------------------------------------------------*
4
5      TABLES : LFA1,LFBK,BNKA.
6
7      DATA : BEGIN OF I_BANKDATA_NEW OCCURS 0.
8              INCLUDE STRUCTURE LFBK.
9      DATA : END OF I_BANKDATA_NEW.
10
11     DATA : BEGIN OF I_BANKDATA_OLD OCCURS 0.
12             INCLUDE STRUCTURE LFBK.
13     DATA : END OF I_BANKDATA_OLD.
14
15     DATA : BEGIN OF I_BANKDATA OCCURS 0.
16             INCLUDE STRUCTURE LFBK.
17     DATA : END OF I_BANKDATA.
18
19     DATA : BEGIN OF T_MESSAGES OCCURS 0.
20             INCLUDE STRUCTURE EBPP_MESSAGES.
21     DATA : END OF T_MESSAGES.
22
23     DATA : BEGIN OF IT_EMP_BNK OCCURS 0.
24             INCLUDE STRUCTURE ZFI_EMP_BNK.
25     DATA : END OF IT_EMP_BNK.
26
27     TYPES : BEGIN OF GS_DATA,
28               LIFNR TYPE LIFNR,
29               NAME1 TYPE NAME1,
30               BANKS TYPE BANKS,
31               BANKL TYPE BANKL,
32               BANKN TYPE BANKN, "lfbk-bankn
33               BANKA TYPE BANKA, "BNKA-BANKA  Name of bank
34               PROVZ TYPE PROVZ, "BNKA-PROVZ  region
35               STRAS TYPE STRAS, "BNKA-STRAS  street
36               ORT01 TYPE ORT01, "BNKA-ORT01  city
37               BRNCH TYPE BRNCH, "BNKA-BRNCH  bank branch
38               BNKLZ TYPE BANKL,  "BNKA-BNKLZ  bank no.
39             END OF GS_DATA.
40
41     DATA : OK_CODE    TYPE SY-UCOMM,
42            OK_CODE1   TYPE SY-UCOMM,
43            LV_VLEN    TYPE I,
44            LV_FLAG(1) TYPE C,
45            LV_LIFNR   TYPE LIFNR,
46            LV_CPFNO   TYPE LIFNR,
47            LV_LIFNR1  TYPE LIFNR,  "Added by Manisha bh.Dt:18.09.2018
48            LV_BUKRS   TYPE BUKRS.  "Added by Manisha bh.Dt:18.09.2018
49
50     DATA : LO_SEND_REQUEST TYPE REF TO CL_BCS VALUE IS INITIAL.
51     DATA : LO_DOCUMENT     TYPE REF TO CL_DOCUMENT_BCS VALUE IS INITIAL. "document object
52     DATA : I_TEXT          TYPE BCSY_TEXT. "Table for body
53     DATA : W_TEXT          LIKE LINE OF I_TEXT. "work area for message body
54     DATA : LO_SENDER       TYPE REF TO IF_SENDER_BCS VALUE IS INITIAL. "sender
55     DATA : LO_RECIPIENT    TYPE REF TO IF_RECIPIENT_BCS VALUE IS INITIAL. "recipient
56
57     DATA : LV_STRING      TYPE STRING,
58            LV_DATA_STRING TYPE STRING,
59            LV_XSTRING     TYPE XSTRING.
60     DATA : LIT_BINARY_CONTENT TYPE SOLIX_TAB,
61            L_ATTSUBJECT       TYPE SOOD-OBJDES.
62
63     DATA : LV_LIFNRO TYPE LIFNR,
64            LV_BANKS  TYPE BANKS,
65            LV_BANKL  TYPE BANKL,
66            LV_BANKN  TYPE BANKN.
67
68     DATA : I_OTF       TYPE ITCOO OCCURS 0 WITH HEADER LINE,
69            I_TLINE     TYPE TABLE OF TLINE WITH HEADER LINE,
70            I_RECEIVERS TYPE TABLE OF SOMLRECI1 WITH HEADER LINE,
71            I_RECORD    LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE.
72
73     DATA : WA_OBJHEAD  TYPE SOLI_TAB,
74            WA_BNKA     TYPE BNKA,
75            WA_LFBK     TYPE LFBK,
76            W_CTRLOP    TYPE SSFCTRLOP,
77            W_COMPOP    TYPE SSFCOMPOP,
78            W_RETURN    TYPE SSFCRESCL,
79            WA_DOC_CHNG TYPE SODOCCHGI1,
80            W_DATA      TYPE SODOCCHGI1,
81            WA_BUFFER   TYPE STRING.
82
83     DATA : V_FORMNM    TYPE RS38L_FNAM,
84            V_LEN_IN    LIKE SOOD-OBJLEN,
85            V_LEN_OUT   LIKE SOOD-OBJLEN,
86            V_LEN_OUTN  TYPE I,
87            V_LINES_TXT TYPE I,
88            V_LINES_BIN TYPE I.
*--- End of ZFI_EMP_VEND_BANK_DETAIL_TOP - 88 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_EMP_VEND_BANK_DETAIL_PAI              Level 1    Page 3
Object           ZFI_EMP_VEND_BANK_DETAIL                  Lines 582
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:05
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_EMP_VEND_BANK_DETAIL_PAI
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  USER_COMMAND_0100  INPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE user_command_0100 INPUT.
10       ok_code = sy-ucomm.
11       CASE ok_code.
12         WHEN 'BACK'.
13           LEAVE TO SCREEN 0.
14         WHEN 'CANCEL'.
15           LEAVE TO SCREEN 0.
16         WHEN 'EXIT'.
17           LEAVE TO SCREEN 0.
18         WHEN 'ENTER'.
19           PERFORM get_bank_detail.
20     *------Validation Added by Manisha bh.Dt:18.09.2018------*
21           IF lfa1-lifnr IS NOT INITIAL.
22             SELECT SINGLE lifnr bukrs INTO (lv_lifnr1,lv_bukrs) FROM lfb1
23                    WHERE  lifnr = lfa1-lifnr
24               AND bukrs = 'OVL'.      """"------ADDED By Rahul Gupta Date 01-10-2018 -------""""
25             IF sy-subrc = 0.
26     *          commented by Rahul Gupta date 01-10-2018
27     *          IF LV_BUKRS NE 'OVL'.
28     *            MESSAGE 'Vendor is not created for company code OVL!!!' TYPE 'S' DISPLAY LIKE 'E'.
29     *            LEAVE TO LIST-PROCESSING.
30     *          ELSE.
31               CALL SCREEN '0110'.
32     *          ENDIF.
33     *            end of comment
34             ELSE.
35               MESSAGE 'Vendor is not created for company code OVL!!!' TYPE 'S' DISPLAY LIKE 'E'.
36               LEAVE TO LIST-PROCESSING.
37             ENDIF.
38           ENDIF.
39     *--------------------------------------------------------*
40     *    WHEN 'SAVE' OR 'SUBMIT'.
41     *      PERFORM save_data.
42     *      PERFORM send_mail_attach.
43     *      MESSAGE 'Employee Bank Details Updated' TYPE 'I'.
44     *      LEAVE TO SCREEN 0.
45       ENDCASE.
46     ENDMODULE.
47     *&---------------------------------------------------------------------*
48     *&      Module  CHECK_EMP_VEND_CODE  INPUT
49     *&---------------------------------------------------------------------*
50     *       text
51     *----------------------------------------------------------------------*
52     MODULE check_emp_vend_code INPUT.
53
54       lv_vlen  = strlen( lv_cpfno ).
55       lv_lifnr = lv_cpfno.  "lfbk-lifnr.
56       IF lv_vlen = 6.
57         CONCATENATE '7'  lv_lifnr INTO lfa1-lifnr.
58       ENDIF.
59       IF lv_vlen = 5.
60         CONCATENATE '70' lv_lifnr INTO lfa1-lifnr.
61       ENDIF.
62       IF lv_vlen = 4.
63         CONCATENATE '700' lv_lifnr INTO lfa1-lifnr.
64       ENDIF.
65       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
66         EXPORTING
67           input  = lfa1-lifnr
68         IMPORTING
69           output = lfa1-lifnr.
70
71       SELECT SINGLE name1 INTO lfa1-name1 FROM lfa1
72               WHERE lifnr = lfa1-lifnr.
73
74     ENDMODULE.
75     *&---------------------------------------------------------------------*
76     *&      Form  GET_BANK_DETAIL
77     *&---------------------------------------------------------------------*
78     *       text
79     *----------------------------------------------------------------------*
80     *  -->  p1        text
81     *  <--  p2        text
82     *----------------------------------------------------------------------*
83     FORM get_bank_detail .
84       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
85         EXPORTING
86           input  = lfa1-lifnr
87         IMPORTING
88           output = lfa1-lifnr.
89
90       SELECT BANKS BANKL BANKN INTO ( LV_BANKS , LV_BANKL , LV_BANKN )
91      FROM LFBK UP TO 1 ROWS WHERE LIFNR = LFA1-LIFNR
92      ORDER BY PRIMARY KEY .
93      ENDSELECT.
94       SELECT SINGLE banka INTO bnka-banka
95              FROM bnka
96              WHERE banks = lfbk-banks
97               AND  bankl = lfbk-bankl.
98
99       lfbk-banks = lv_banks.
100      lfbk-bankl = lv_bankl.
101      lfbk-bankn = lv_bankn.
102
103      i_bankdata_old-lifnr = lfa1-lifnr.
104      i_bankdata_old-banks = lfbk-banks.
105      i_bankdata_old-bankl = lfbk-bankl.
106      i_bankdata_old-bankn = lfbk-bankn.
107      i_bankdata_old-koinh = lfbk-koinh.
108    *
109      APPEND i_bankdata_old.
110
111    ENDFORM.
112    *&---------------------------------------------------------------------*
113    *&      Form  SAVE_DATA
114    *&---------------------------------------------------------------------*
115    *       text
116    *----------------------------------------------------------------------*
117    *  -->  p1        text
118    *  <--  p2        text
119    *----------------------------------------------------------------------*
120    FORM save_data .
121
122      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
123        EXPORTING
124          input  = lfa1-lifnr
125        IMPORTING
126          output = lfa1-lifnr.
127
128      i_bankdata_new-lifnr = lfa1-lifnr.
129      i_bankdata_new-banks = lfbk-banks.
130      i_bankdata_new-bankl = lfbk-bankl.
131      i_bankdata_new-bankn = lfbk-bankn.
132      i_bankdata_new-koinh = lfbk-koinh.
133
134      APPEND i_bankdata_new.
135
136      CALL FUNCTION 'FIN_AP_AR_CHANGE_BANK'
137        EXPORTING
138          i_koart        = 'K'
139          i_bankdata_new = i_bankdata_new
140          i_bankdata_old = i_bankdata_old
141    *     I_CONFIRM_CHANGES       = 'X'
142    *     I_CHECKMODUS   = ' '
143    * IMPORTING
144    *     E_RETURNCODE   =
145        TABLES
146          t_messages     = t_messages[].
147
148      COMMIT WORK AND WAIT.
149      CLEAR : it_emp_bnk,it_emp_bnk[].
150
151      it_emp_bnk-lifnr = lfa1-lifnr.
152      it_emp_bnk-name1 = lfa1-name1.
153      it_emp_bnk-bankl = lfbk-bankl.
154      it_emp_bnk-bankn = lfbk-bankn.
155    *  it_emp_bnk-koinh = lfbk-koinh.
156      APPEND it_emp_bnk.
157      IF lfbk-bankl CS 'SBI'.
158        UPDATE lfb1 SET zwels = '9'
159           WHERE lifnr = lfa1-lifnr.
160      ELSE.
161        UPDATE lfb1 SET zwels = '8'
162           WHERE lifnr = lfa1-lifnr.
163      ENDIF.
164
165      COMMIT WORK AND WAIT.
166
167    ENDFORM.
168    *&---------------------------------------------------------------------*
169    *&      Form  SEND_MAIL_ATTACH
170    *&---------------------------------------------------------------------*
171    *       text
172    *----------------------------------------------------------------------*
173    *  -->  p1        text
174    *  <--  p2        text
175    *----------------------------------------------------------------------*
176    FORM send_mail_attach .
177
178    *Prepare Mail Object
179      DATA : p_sub TYPE char50. "email subject
180      CLASS cl_bcs DEFINITION LOAD.
181      DATA : p_email TYPE adr6-smtp_addr.
182      DATA : BEGIN OF it_email OCCURS 0.
183              INCLUDE STRUCTURE zfi_email_add.
184      DATA : END OF it_email.
185      DATA : lv_handle   LIKE sy-tabix,
186             lv_spool_nr LIKE tsp01-rqident,
187             wa_usr21    LIKE usr21, "-persnumber,
188             wa_adr6     LIKE adr6,
189             wa_usr21cpf LIKE usr21, "-persnumber,
190             wa_adr6cpf  LIKE adr6,
191             wa_lfa1     LIKE lfa1,
192             wa_adr6lfa  LIKE adr6,
193             lv_rc       TYPE c,
194             lv_recm     TYPE i,
195             lv_err(100) TYPE c,
196             lv_text(70) TYPE c.
197
198      DATA : lv_filesize TYPE so_obj_len.
199
200    *--------------
201      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_email
202               FROM zfi_email_add.
203      DESCRIBE TABLE it_email LINES lv_recm.
204      SELECT SINGLE * INTO wa_usr21
205             FROM usr21 WHERE bname = sy-uname.
206
207      IF wa_usr21-persnumber NE ' '.
208        SELECT * INTO CORRESPONDING FIELDS OF WA_ADR6
209     FROM ADR6 UP TO 1 ROWS WHERE PERSNUMBER = WA_USR21-PERSNUMBER AND ADDRNUMBER = WA_USR21-ADDRNUMBER
210     ORDER BY PRIMARY KEY .
211     ENDSELECT.
212        IF sy-subrc = 0.
213          it_email-srno      = lv_recm + 1.
214          it_email-email_add = wa_adr6-smtp_addr.
215          APPEND it_email.
216        ENDIF.
217      ENDIF.
218    *------------Lv_cpfno Maill Address-----------*
219      SELECT SINGLE * INTO wa_usr21cpf
220             FROM usr21 WHERE bname = lv_cpfno.
221
222      IF wa_usr21cpf-persnumber NE ' '.
223        SELECT * INTO CORRESPONDING FIELDS OF WA_ADR6CPF
224     FROM ADR6 UP TO 1 ROWS WHERE PERSNUMBER = WA_USR21CPF-PERSNUMBER AND ADDRNUMBER = WA_USR21CPF-ADDRNUMBER
225     ORDER BY PRIMARY KEY .
226     ENDSELECT.
227        IF sy-subrc = 0.
228          it_email-srno      = lv_recm + 2.
229          it_email-email_add = wa_adr6cpf-smtp_addr.
230          APPEND it_email.
231        ENDIF.
232      ENDIF.
233
234    *---Added by Manisha bh.Dt:20.09.2018--LFA1-LIFNR Mail Address--------*
235      SELECT SINGLE * INTO wa_lfa1
236             FROM lfa1 WHERE lifnr = lfa1-lifnr.
237      IF sy-subrc = 0.
238        SELECT * INTO CORRESPONDING FIELDS OF WA_ADR6LFA
239     FROM ADR6 UP TO 1 ROWS WHERE ADDRNUMBER = WA_LFA1-ADRNR
240     ORDER BY PRIMARY KEY .
241     ENDSELECT.
242        IF sy-subrc = 0.
243          it_email-srno      = lv_recm + 3.
244          it_email-email_add = wa_adr6lfa-smtp_addr.
245          APPEND it_email.
246        ENDIF.
247      ENDIF.
248    *---------------------------------------------------------------------*
249
250    ***Attachment data
251      p_sub = 'Employee Bank Details'.
252      lo_send_request = cl_bcs=>create_persistent( ).
253    * Message body and subject
254    *Set body
255
256      w_text-line = 'Bank details are updated as per sheet attached for information and necessary action'.
257      APPEND w_text TO i_text.
258      CLEAR w_text.
259
260      w_text-line = ' '.
261      APPEND w_text TO i_text.
262      CLEAR w_text.
263
264      w_text-line = ' '.
265      APPEND w_text TO i_text.
266      CLEAR w_text.
267
268      w_text-line = 'Regards'.
269      APPEND w_text TO i_text.
270      CLEAR w_text.
271
272      lo_document = cl_document_bcs=>create_document( "create document
273      i_type = 'TXT' "Type of document HTM, TXT etc
274      i_text =  i_text "email body internal table
275      i_subject = p_sub ). "email subject here p_sub input parameter
276    * Pass the document to send request
277      lo_send_request->set_document( lo_document ).
278    ***Set attachment
279    *-------------------
280      PERFORM print_emp_pdf.
281      lv_data_string = i_record.
282      lv_filesize    = v_len_in.
283    *-------------------
284    **Convert string to xstring
285      CALL FUNCTION 'HR_KR_STRING_TO_XSTRING'
286        EXPORTING
287    *     codepage_to      = '8300'
288          unicode_string   = lv_data_string
289    *     OUT_LEN          =
290        IMPORTING
291          xstring_stream   = lv_xstring
292        EXCEPTIONS
293          invalid_codepage = 1
294          invalid_string   = 2
295          OTHERS           = 3.
296      IF sy-subrc <> 0.
297        IF sy-subrc = 1 .
298
299        ELSEIF sy-subrc = 2 .
300          WRITE:/ 'invalid string ' .
301        ENDIF.
302      ENDIF.
303
304    ***Xstring to binary
305      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
306        EXPORTING
307          buffer     = lv_xstring
308        TABLES
309          binary_tab = lit_binary_content.
310    **add attachment
311      CLEAR l_attsubject .
312      CONCATENATE 'Employee Bank Detail' sy-datum INTO l_attsubject.
313    * Create Attachment
314      TRY.
315          lo_document->add_attachment( EXPORTING
316                                          i_attachment_type = 'PDF' "'XLS'
317                                          i_attachment_size   = lv_filesize
318                                          i_attachment_subject = l_attsubject
319                                          i_att_content_text   = i_record[] ).
320    *                                      i_att_content_hex = lit_binary_content  ).
321    *          CATCH cx_document_bcs INTO lx_document_bcs.
322
323      ENDTRY.
324      TRY.
325          lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
326    * Set sender to send request
327          lo_send_request->set_sender(
328          EXPORTING
329          i_sender = lo_sender ).
330    *    CATCH CX_ADDRESS_BCS.
331    ****Catch exception here
332      ENDTRY.
333    **Set recipient
334
335      LOOP AT it_email.
336        p_email = it_email-email_add.
337        lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
338        TRY.
339            lo_send_request->add_recipient(
340                EXPORTING
341                i_recipient = lo_recipient
342                i_express = 'X' ).
343    *  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
344    **Catch exception here
345        ENDTRY.
346        CLEAR : p_email.
347      ENDLOOP.
348      TRY.
349          CALL METHOD lo_send_request->set_send_immediately
350            EXPORTING
351              i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
352    *    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
353    **Catch exception here
354      ENDTRY.
355      TRY.
356    ** Send email
357          lo_send_request->send(
358          EXPORTING
359          i_with_error_screen = 'X' ).
360          COMMIT WORK.
361          IF sy-subrc = 0. "mail sent successfully
362            WRITE :/ 'Mail sent successfully'.
363          ENDIF.
364    *    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
365    *catch exception here
366      ENDTRY.
367    ENDFORM.
368    *&---------------------------------------------------------------------*
369    *&      Module  USER_COMMAND_0110  INPUT
370    *&---------------------------------------------------------------------*
371    *       text
372    *----------------------------------------------------------------------*
373    MODULE user_command_0110 INPUT.
374      ok_code1 = sy-ucomm.
375      CASE ok_code1.
376        WHEN 'BACK'.
377          LEAVE TO SCREEN '0100'.
378        WHEN 'CANCEL'.
379          LEAVE TO SCREEN '0100'.
380        WHEN 'EXIT'.
381          LEAVE TO SCREEN 0.
382        WHEN 'ENTER'.
383          PERFORM bank_validation.
384          i_bankdata_new-lifnr = lfa1-lifnr.
385          i_bankdata_new-banks = lfbk-banks.
386          i_bankdata_new-bankl = lfbk-bankl.
387          i_bankdata_new-bankn = lfbk-bankn.
388          i_bankdata_new-koinh = lfbk-koinh.
389
390        WHEN 'SAVE' OR 'SUBMIT'.
391          PERFORM bank_validation.
392          IF lv_flag = 'X'.
393            PERFORM save_data.
394          ELSE.
395            PERFORM save_data_new_vend.
396          ENDIF.
397          PERFORM send_mail_attach.
398          IF t_messages[] IS INITIAL.
399            MESSAGE 'Employee Bank Details Updated' TYPE 'I'.
400          ELSE.
401            MESSAGE 'Please check employee Bank Details updated' TYPE 'I'.
402          ENDIF.
403          LEAVE PROGRAM.
404      ENDCASE.
405
406    ENDMODULE.
407    *&---------------------------------------------------------------------*
408    *&      Form  PRINT_EMP_PDF
409    *&---------------------------------------------------------------------*
410    *       text
411    *----------------------------------------------------------------------*
412    *  -->  p1        text
413    *  <--  p2        text
414    *----------------------------------------------------------------------*
415    FORM print_emp_pdf .
416      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
417        EXPORTING
418          formname = 'ZFI_EMP_BANK_DETAIL'
419    *     VARIANT  = ' '
420    *     DIRECT_CALL              = ' '
421        IMPORTING
422          fm_name  = v_formnm
423    *  EXCEPTIONS
424    *     NO_FORM  = 1
425    *     NO_FUNCTION_MODULE       = 2
426    *     OTHERS   = 3
427        .
428      IF sy-subrc <> 0.
429    * Implement suitable error handling here
430      ENDIF.
431
432      w_ctrlop-getotf    = 'X'.
433      w_ctrlop-no_dialog = 'X'.
434      w_ctrlop-preview   = space.
435      w_compop-tdnoprev  = 'X'.
436      w_compop-tddest    = 'LP01'.
437
438      CALL FUNCTION v_formnm  "'/1BCDWB/SF00000335'
439        EXPORTING
440    *     ARCHIVE_INDEX      =
441    *     ARCHIVE_INDEX_TAB  =
442    *     ARCHIVE_PARAMETERS =
443          control_parameters = w_ctrlop
444    *     MAIL_APPL_OBJ      =
445    *     MAIL_RECIPIENT     =
446    *     MAIL_SENDER        =
447          output_options     = w_compop
448          user_settings      = 'X'
449        IMPORTING
450    *     DOCUMENT_OUTPUT_INFO       =
451          job_output_info    = w_return
452    *     JOB_OUTPUT_OPTIONS =
453        TABLES
454          it_emp_bnk         = it_emp_bnk
455    * EXCEPTIONS
456    *     FORMATTING_ERROR   = 1
457    *     INTERNAL_ERROR     = 2
458    *     SEND_ERROR         = 3
459    *     USER_CANCELED      = 4
460    *     OTHERS             = 5
461        .
462      IF sy-subrc <> 0.
463    * Implement suitable error handling here
464      ENDIF.
465      i_otf[] = w_return-otfdata[].
466
467      CALL FUNCTION 'CONVERT_OTF'
468        EXPORTING
469          format        = 'PDF'  "'ASCII'
470          max_linewidth = 132
471    *     ARCHIVE_INDEX = ' '
472    *     COPYNUMBER    = 0
473    *     ASCII_BIDI_VIS2LOG          = ' '
474    *     PDF_DELETE_OTFTAB           = ' '
475    *     PDF_USERNAME  = ' '
476    *     PDF_PREVIEW   = ' '
477    *     USE_CASCADING = ' '
478    *     MODIFIED_PARAM_TABLE        =
479        IMPORTING
480          bin_filesize  = v_len_in
481    *     BIN_FILE      =
482        TABLES
483          otf           = i_otf
484          lines         = i_tline
485    *   EXCEPTIONS
486    *     ERR_MAX_LINEWIDTH           = 1
487    *     ERR_FORMAT    = 2
488    *     ERR_CONV_NOT_POSSIBLE       = 3
489    *     ERR_BAD_OTF   = 4
490    *     OTHERS        = 5
491        .
492      IF sy-subrc <> 0.
493    * Implement suitable error handling here
494      ENDIF.
495      LOOP AT i_tline.
496        TRANSLATE i_tline USING '~'.
497        CONCATENATE wa_buffer i_tline INTO wa_buffer.
498      ENDLOOP.
499      TRANSLATE wa_buffer USING '~'.
500      DO.
501        i_record = wa_buffer.
502        APPEND i_record.
503        SHIFT wa_buffer LEFT BY 255 PLACES.
504        IF wa_buffer IS INITIAL.
505          EXIT.
506        ENDIF.
507      ENDDO.
508
509    ENDFORM.
510    *&---------------------------------------------------------------------*
511    *&      Form  BANK_VALIDATION
512    *&---------------------------------------------------------------------*
513    *       text
514    *----------------------------------------------------------------------*
515    *  -->  p1        text
516    *  <--  p2        text
517    *----------------------------------------------------------------------*
518    FORM bank_validation .
519      SELECT SINGLE * FROM bnka
520                        INTO wa_bnka WHERE banks = lfbk-banks
521                                       AND bankl = lfbk-bankl.
522      IF sy-subrc NE 0.
523        MESSAGE e356(zfi) WITH lfbk-bankl.
524      ENDIF.
525      SELECT SINGLE * FROM lfbk INTO wa_lfbk WHERE lifnr = lfa1-lifnr.
526      IF sy-subrc = 0.
527        lv_flag = 'X'.
528      ENDIF.
529    ENDFORM.
530    *&---------------------------------------------------------------------*
531    *&      Form  SAVE_DATA_NEW_VEND
532    *&---------------------------------------------------------------------*
533    *       text
534    *----------------------------------------------------------------------*
535    *  -->  p1        text
536    *  <--  p2        text
537    *----------------------------------------------------------------------*
538    FORM save_data_new_vend .
539      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
540        EXPORTING
541          input  = lfa1-lifnr
542        IMPORTING
543          output = lfa1-lifnr.
544
545      i_bankdata-lifnr = lfa1-lifnr.
546      i_bankdata-banks = lfbk-banks.
547      i_bankdata-bankl = lfbk-bankl.
548      i_bankdata-bankn = lfbk-bankn.
549      i_bankdata-koinh = lfbk-koinh.
550
551
552      CALL FUNCTION 'FIN_AP_AR_ADD_BANK'
553        EXPORTING
554          i_koart    = 'K'
555          i_bankdata = i_bankdata
556    *     I_CONFIRM_CHANGES       = 'X'
557    *     I_CHECKMODUS            = ' '
558    * IMPORTING
559    *     E_RETURNCODE            =
560        TABLES
561          t_messages = t_messages[].
562
563      COMMIT WORK AND WAIT.
564      CLEAR : it_emp_bnk,it_emp_bnk[].
565
566      it_emp_bnk-lifnr = lfa1-lifnr.
567      it_emp_bnk-name1 = lfa1-name1.
568      it_emp_bnk-bankl = lfbk-bankl.
569      it_emp_bnk-bankn = lfbk-bankn.
570    *  it_emp_bnk-koinh = lfbk-koinh.
571      APPEND it_emp_bnk.
572      IF lfbk-bankl CS 'SBI'.
573        UPDATE lfb1 SET zwels = '9'
574           WHERE lifnr = lfa1-lifnr.
575      ELSE.
576        UPDATE lfb1 SET zwels = '8'
577           WHERE lifnr = lfa1-lifnr.
578      ENDIF.
579
580      COMMIT WORK AND WAIT.
581
582    ENDFORM.
*--- End of ZFI_EMP_VEND_BANK_DETAIL_PAI - 582 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_EMP_VEND_BANK_DETAIL_PBO              Level 1    Page 4
Object           ZFI_EMP_VEND_BANK_DETAIL                  Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:05
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_EMP_VEND_BANK_DETAIL_PBO
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  STATUS_0100  OUTPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE status_0100 OUTPUT.
10       SET PF-STATUS 'STATUS1'.
11       SET TITLEBAR 'TITLE'.
12     ENDMODULE.
13     *&---------------------------------------------------------------------*
14     *&      Module  STATUS_0110  OUTPUT
15     *&---------------------------------------------------------------------*
16     *       text
17     *----------------------------------------------------------------------*
18     MODULE status_0110 OUTPUT.
19       SET PF-STATUS 'STATUS1'.
20       SET TITLEBAR 'TITLE'.
21     ENDMODULE.
22     *&---------------------------------------------------------------------*
23     *&      Module  GET_EMP_DETAILS  OUTPUT
24     *&---------------------------------------------------------------------*
25     *       text
26     *----------------------------------------------------------------------*
27     MODULE get_emp_details OUTPUT.
28       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
29         EXPORTING
30           input  = lfa1-lifnr
31         IMPORTING
32           output = lfa1-lifnr.
33
34       SELECT BANKS BANKL BANKN INTO ( LV_BANKS , LV_BANKL , LV_BANKN )
35      FROM LFBK UP TO 1 ROWS WHERE LIFNR = LFA1-LIFNR
36      ORDER BY PRIMARY KEY .
37      ENDSELECT.
38       SELECT SINGLE banka INTO bnka-banka
39              FROM bnka
40              WHERE banks = lfbk-banks
41               AND  bankl = lfbk-bankl.
42
43     *  BREAK-POINT.
44
45       lfbk-banks = lv_banks.
46       lfbk-bankl = lv_bankl.
47       lfbk-bankn = lv_bankn.
48
49     ENDMODULE.
50     *&---------------------------------------------------------------------*
51     *&      Module  GET_DEFAULT_VALUE  OUTPUT
52     *&---------------------------------------------------------------------*
53     *       text
54     *----------------------------------------------------------------------*
55     MODULE get_default_value OUTPUT.
56       lv_cpfno = sy-uname.
57     ENDMODULE.
*--- End of ZFI_EMP_VEND_BANK_DETAIL_PBO - 57 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZFI_EMP_VEND_BANK_DETAIL                  Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:05
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
Generated incl.  <SYSINI>                                  Level 1    Page 6
Object           ZFI_EMP_VEND_BANK_DETAIL                  Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:05
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
