----------------------------------------------------------------------------------------------------
Main program     ZFI_UPDATE_SECO                           Level 0    Page 1
Object           ZFI_UPDATE_SECO                           Lines 79
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:44
----------------------------------------------------------------------------------------------------
1      REPORT zfi_update_seco .
2      *-----  PROGRAM FOR Updating section codes in  the wrong documents ****
3      ***********************************************************************
4      * Program    :                                                        *
5      *                                                                     *
6      *                                                                     *
7      * Author     : S.R.Sudha                     Date : 8.11.2007
8      *
9      *                                                                     *
10     * Login Id   : CAB_SUDHA                                              *
11     *                                                                      *
12     * Description: ONE TIME EXERCISE FOR CHANGING SECCODE IN   A DOCUEMNT
13     *             CREATED FOR  passing the validation for section code
14     *             As per Mail from FI CORE Team .
15     *
16     *
17     *                                                                     *
18     *                                                                     *
19     ***********************************************************************
20
21
22     TABLES : bsik.
23
24
25
26     DATA : ist_bsik LIKE bsik.
27     DATA : ist_bseg LIKE bseg.
28
29
30     PARAMETERS:  p_belnr  LIKE bsik-belnr,
31                  p_year   LIKE bsik-gjahr,
32                  p_bukrs LIKE bsik-bukrs ,
33                  p_lifnr LIKE bsik-lifnr ,
34                  p_buzei LIKE bsik-buzei,
35                  p_secco LIKE bsik-secco.
36
37     *------------------------------------------------------*
38     START-OF-SELECTION.
39     *------------------------------------------------------*
40       SELECT SINGLE *   FROM bsik INTO  ist_bsik WHERE
41                    bukrs  =  p_bukrs
42                    AND lifnr  = p_lifnr
43                    AND gjahr = p_year
44                    AND belnr = p_belnr
45                    AND buzei =  p_buzei.
46
47       ist_bsik-secco = p_secco.
48       "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
49
50     *  MODIFY  bsik FROM ist_bsik.
51     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
52       IF sy-subrc = 0.
53         MESSAGE  i303(zfi).
54       ENDIF.
55
56
57       SELECT SINGLE *   FROM bseg INTO  ist_bseg WHERE
58                    bukrs  =  p_bukrs
59                    AND lifnr  = p_lifnr
60                    AND gjahr = p_year
61                    AND belnr = p_belnr
62                    AND buzei =  p_buzei.
63
64       ist_bseg-secco = p_secco.
65
66     " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
67     * S/4: BSEG SECCO via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
68     *  MODIFY  bseg FROM ist_bseg.
69       DATA: lt_acg TYPE STANDARD TABLE OF accchg, ls_acg TYPE accchg.
70       REFRESH lt_acg. CLEAR ls_acg.
71       ls_acg-fdname = 'SECCO'. ls_acg-newval = ist_bseg-secco.
72       APPEND ls_acg TO lt_acg.
73       CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = ist_bseg-bukrs i_belnr = ist_bseg-belnr
74            i_gjahr = ist_bseg-gjahr i_buzei = ist_bseg-buzei TABLES t_acchg = lt_acg EXCEPTIONS OTHERS = 0.
75       COMMIT WORK.
76     " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
77       IF sy-subrc = 0.
78         MESSAGE  i303(zfi).
79       ENDIF.
*--- End of ZFI_UPDATE_SECO - 79 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZFI_UPDATE_SECO                           Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:44
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
Object           ZFI_UPDATE_SECO                           Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:44
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
Object           ZFI_UPDATE_SECO                           Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:44
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
Object           ZFI_UPDATE_SECO                           Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:44
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
