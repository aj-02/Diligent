----------------------------------------------------------------------------------------------------
Main program     ZSD_CORRECT_RFBSK                         Level 0    Page 1
Object           ZSD_CORRECT_RFBSK                         Lines 88
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:04
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZSD_CORRECT_RFBSK
3      *&
4      *&---------------------------------------------------------------------*
5      *Change History
6      *
7      * Mod Date     Changed By     Description         Chng ID
8      * 13022009     Sudhir Sharma  Chn Dbl Acctg stat  <RD1K961813>
9      *
10     *&---------------------------------------------------------------------*
11
12     REPORT  ZSD_CORRECT_RFBSK    .
13
14     Tables :  VBRK ,
15               ENT6037,
16               ENT6038 ,
17               ENT6209  ,
18               ENT6210   ,
19               ENT6211    ,
20               ENT6216     ,
21               ENT6217      ,
22               ENT6218       ,
23               M_VMCFA        ,
24               VBRKUK          , "#EC CI_USAGE_OK[2198647]
25     *          V_BAM_VBRK      ,
26               WB2_V_VBRK_VBRL ,
27               WB2_V_VBRK_VBRL2,
28               WB2_V_VBRK_VBRP ,
29               WB2_V_VBRK_VBRP2.
30
31     data : ist_vbrk type table of vbrk,
32            wa_vbrk type vbrk.
33
34     SELECTION-SCREEN BEGIN OF BLOCK REPORT_SELECTION WITH FRAME TITLE
35     TEXT-001.
36     SELECT-OPTIONS: fakturen FOR vbrk-vbeln obligatory.
37     PARAMETERS    : RFBSK type vbrk-RFBSK  obligatory,
38                     test AS CHECKBOX DEFAULT 'X'.
39     SELECTION-SCREEN END OF BLOCK REPORT_SELECTION.
40
41     start-of-selection.
42
43     if test = 'X'.
44        select * from vbrk into table ist_vbrk where vbeln in fakturen.
45        if sy-subrc = 0.
46
47           uline (55).
48           loop at ist_vbrk into wa_vbrk.
49             write:/1 '|' no-gap,
50               2  wa_vbrk-vbeln,
51               19 '|' no-gap,
52               21 wa_vbrk-rfbsk,
53              24  '|' no-gap,
54              26  'Will be Changed to --->',
55              51  '|' no-gap,
56              53  rfbsk,
57              55  '|'.
58          new-line.
59          uline (55).
60     *        write : /2 wa_vbrk-vbeln , wa_vbrk-rfbsk.
61     *        write : /2 'Will be changed to ',19 rfbsk .
62           endloop.
63
64        endif.
65
66     else.
67        select * from vbrk into table ist_vbrk where vbeln in fakturen.
68        if sy-subrc = 0.
69           uline (55).
70           loop at ist_vbrk into wa_vbrk.
71
72             update vbrk set rfbsk = rfbsk
73                         where vbeln = wa_vbrk-vbeln.
74         write:/1 '|' no-gap,
75               2  wa_vbrk-vbeln, "#EC CI_NOORDER
76               19 '|' no-gap, "#EC CI_NOORDER
77               21 wa_vbrk-rfbsk, "#EC CI_NOORDER
78              24  '|' no-gap, "#EC CI_NOORDER
79              26  'Changed to --->', "#EC CI_NOORDER
80              51  '|' no-gap, "#EC CI_NOORDER
81              53  rfbsk, "#EC CI_NOORDER
82              55  '|'. "#EC CI_NOORDER
83          new-line.
84          uline (55).
85          endloop.
86        endif.
87
88     endif.
*--- End of ZSD_CORRECT_RFBSK - 88 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZSD_CORRECT_RFBSK                         Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:04
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
Object           ZSD_CORRECT_RFBSK                         Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:04
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
Object           ZSD_CORRECT_RFBSK                         Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:04
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
Object           ZSD_CORRECT_RFBSK                         Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:04
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
