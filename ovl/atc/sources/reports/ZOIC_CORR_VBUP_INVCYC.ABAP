----------------------------------------------------------------------------------------------------
Main program     ZOIC_CORR_VBUP_INVCYC                     Level 0    Page 1
Object           ZOIC_CORR_VBUP_INVCYC                     Lines 132
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:15
----------------------------------------------------------------------------------------------------
1      REPORT zoic_corr_vbup_invcyc .
2
3      ************************************************************************
4      * This program is to correct the billing status and invoice status in  *
5      * delivery, when the SET status doe not get updated propery after      *
6      * invoice CANCELLATION. This is specific to IS-OIL.                    *
7      *                                                                      *
8      ******************************** C A U T I O N *************************
9      *                                                                      *
10     * Its recommended that this program should be executed ONLY if the note*
11     * no. 587965 and 642372 are already applied.                           *
12     *                                                                      *
13     ************************************************************************
14     FIELD-SYMBOLS <invcyc>.
15
16     DATA: BEGIN OF l_inv_cycle,
17             fix(20) VALUE 'L_ITAB_VBUP-OIINVCST',
18             nr      LIKE komv-oiinvcyc,
19           END OF l_inv_cycle.
20
21     * Declare local variables
22     DATA : l_delivery    LIKE likp,
23            l_no_of_tries TYPE i,
24            l_simul,
25            last_deliv    LIKE vbup-vbeln,
26            last_posnr    LIKE vbup-posnr.
27
28     * Declare log type data
29     DATA : BEGIN OF log_type,
30              vbeln        LIKE vbup-vbeln,
31              posnr        LIKE vbup-posnr,
32              invcy        LIKE toia10-oiinvcyc,
33              old_value    LIKE vbup-oiinvcst1,
34              new_value    LIKE vbup-oiinvcst1,
35              updated      TYPE c,
36              message(255) TYPE c,
37            END OF log_type.
38
39     * Declare internal tables
40     DATA : l_itab_log  LIKE STANDARD TABLE OF log_type WITH HEADER LINE,
41            l_itab_vbup LIKE STANDARD TABLE OF vbup WITH HEADER LINE.
42
43     SELECT-OPTIONS l_del_no FOR l_delivery-vbeln.
44     SELECT-OPTIONS simul FOR l_simul DEFAULT 'X'.
45
46     CHECK NOT l_del_no-low IS INITIAL.
47     * Read data from VBUP tables
48     SELECT * FROM v_vbup_s4  WHERE vbeln IN @l_del_no
49       AND ( besta EQ 'C' OR fksaa EQ 'C' OR gbsta EQ 'C'
50       OR lfgsa EQ 'C' OR rfgsa EQ 'C' OR uvall EQ 'C'
51       OR uvvlk EQ 'C' OR uvfak EQ 'C' OR uvprs EQ 'C' ) INTO
52      CORRESPONDING FIELDS OF TABLE
53     @l_itab_vbup .
54
55     IF NOT sy-subrc IS INITIAL.
56       WRITE : / 'No valid selection' .
57       ULINE.
58       EXIT.
59     ENDIF.
60     * Loop through VBUP entries
61     LOOP AT l_itab_vbup.
62     * Process only deliveries that have not been billed completely
63     * but have incorrect status for invoice cycles
64       CHECK l_itab_vbup-fksta EQ 'A'.
65       CLEAR l_itab_log.
66
67       DO 9 TIMES.
68         l_inv_cycle-nr      = sy-index.
69         ASSIGN (l_inv_cycle) TO <invcyc>.
70         IF NOT <invcyc> IS INITIAL.
71           CLEAR l_itab_log.
72           IF last_deliv IS INITIAL OR
73              last_deliv NE l_itab_vbup-vbeln.
74             last_deliv =  l_itab_vbup-vbeln.
75             l_itab_log-vbeln = l_itab_vbup-vbeln.
76           ENDIF.
77           l_itab_log-posnr = l_itab_vbup-posnr.
78           l_itab_log-invcy = l_inv_cycle-nr.
79           l_itab_log-old_value = <invcyc>.
80           CLEAR <invcyc>.
81           l_itab_log-new_value = <invcyc>.
82           APPEND l_itab_log.
83         ENDIF.
84       ENDDO.
85
86       IF simul IS INITIAL.
87     *    UPDATE vbup FROM l_itab_vbup.
88         IF sy-subrc IS INITIAL.
89           l_itab_log-updated = 'Y'.
90           l_itab_log-message = 'Invoice cycle status updated successfully.'.
91           l_no_of_tries = l_no_of_tries + 1.
92         ELSE.
93           l_itab_log-updated = 'N'.
94           CONCATENATE 'Error updating database table. '
95                       'Could not update invoice cycle status in VBUP table.'
96                       INTO l_itab_log-message SEPARATED BY ' '.
97         ENDIF.
98       ENDIF.
99       MODIFY l_itab_log INDEX sy-tabix.
100    ENDLOOP.
101
102    * Write log table entries.
103    WRITE : /1   'VBELN',
104             11  'POSNR',
105             20  'INVCYCLE',
106             30  'OLD VALUE',
107             40  'NEW VALUE',
108             50  'UPDATED',
109             59  'MESSAGE'.
110    LOOP AT l_itab_log.
111      IF NOT l_itab_log-vbeln IS INITIAL.
112        ULINE.
113        CLEAR last_posnr.
114      ENDIF.
115      IF last_posnr IS INITIAL.
116        last_posnr = l_itab_log-posnr.
117      ELSE.
118        IF last_posnr NE l_itab_log-posnr.
119          WRITE : /.
120          last_posnr = l_itab_log-posnr.
121        ENDIF.
122      ENDIF.
123      WRITE : /1   l_itab_log-vbeln,
124               11  l_itab_log-posnr,
125               20  l_itab_log-invcy,
126               30  l_itab_log-old_value,
127               40  l_itab_log-new_value,
128               50  l_itab_log-updated,
129               59  l_itab_log-message.
130    ENDLOOP.
131    ULINE.
132    WRITE : / 'Total no of records updated :', l_no_of_tries.
*--- End of ZOIC_CORR_VBUP_INVCYC - 132 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZOIC_CORR_VBUP_INVCYC                     Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:15
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
Object           ZOIC_CORR_VBUP_INVCYC                     Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:15
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
Object           ZOIC_CORR_VBUP_INVCYC                     Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:15
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
Object           ZOIC_CORR_VBUP_INVCYC                     Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:15
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
