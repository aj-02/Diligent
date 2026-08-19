----------------------------------------------------------------------------------------------------
Main program     ZF_CORR_PSWSL                             Level 0    Page 1
Object           ZF_CORR_PSWSL                             Lines 241
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:56
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZF_CORR_PSWSL                                               *
3      *&                                                                     *
4      *&---------------------------------------------------------------------*
5      *&                                                                     *
6      *&                                                                     *
7      *&---------------------------------------------------------------------*
8
9      REPORT  zf_corr_pswsl line-size 150   .
10
11     ************************************************************************
12     * This program is not intended to run DIRECTLY. This program is used
13     * to clear entries in FI related tables.
14     * DO NOT EXECUTE THIS PROGRAM.
15     ************************************************************************
16     *Change History
17     ***********************************************************************
18     *  Date        Transport    USERID       Description                  *
19     * 03/09/2008   RD1K960036   SAB_SRIDHAR  To resolved the Obsolete Stmt*
20     *                                        Error added SAPCE            *
21     ***********************************************************************
22
23     TABLES: bkpf, bseg, bsis, bsas, t001, skb1.
24
25     TYPES: BEGIN OF header,
26            bukrs TYPE bkpf-bukrs,
27            belnr TYPE bkpf-belnr,
28            gjahr TYPE bkpf-gjahr,
29            monat TYPE bkpf-monat,
30            END OF header.
31
32     TYPES: BEGIN OF accounts,
33            bukrs TYPE skb1-bukrs,
34            saknr TYPE skb1-saknr,
35            xsalh TYPE skb1-xsalh,
36            END OF accounts.
37
38     TYPES: BEGIN OF items,
39            bukrs TYPE bseg-bukrs,
40            belnr TYPE bseg-belnr,
41            gjahr TYPE bseg-gjahr,
42            buzei TYPE bseg-buzei,
43            augdt TYPE bseg-augdt,
44            augbl TYPE bseg-augbl,
45            dmbtr TYPE bseg-dmbtr,
46            wrbtr TYPE bseg-wrbtr,
47            pswbt TYPE bseg-pswbt,
48            pswsl TYPE bseg-pswsl,
49            hkont TYPE bseg-hkont,
50            new_pswbt TYPE bseg-pswbt,
51            new_pswsl TYPE bseg-pswsl,
52            END OF items.
53
54     DATA: wa_bkpf TYPE header,
55           it_bkpf TYPE TABLE OF header,
56           wa_skb1 TYPE accounts,
57           it_skb1 TYPE TABLE OF accounts,
58           wa_items TYPE items,
59           it_items TYPE TABLE OF items.
60
61     DATA: cnt TYPE i,
62           x_waers TYPE t001-waers.
63
64     SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
65     SELECT-OPTIONS: so_hkont FOR bseg-hkont OBLIGATORY.
66     PARAMETERS:     p_bukrs TYPE bkpf-bukrs OBLIGATORY.
67     SELECT-OPTIONS: so_belnr FOR bkpf-belnr,
68                     so_gjahr FOR bkpf-gjahr,
69                     so_monat FOR bkpf-monat.
70     SELECTION-SCREEN SKIP.
71     PARAMETERS: p_update AS CHECKBOX.
72     SELECTION-SCREEN END OF BLOCK 001.
73
74     START-OF-SELECTION.
75
76     *** determine local currency of the company code
77       SELECT SINGLE waers FROM t001 INTO x_waers
78         WHERE bukrs = p_bukrs.
79       IF sy-subrc <> 0.
80         FORMAT COLOR 6.
81         WRITE:/ 'Company code', p_bukrs, 'does not exist.'.
82         FORMAT COLOR OFF.
83         EXIT.
84       ENDIF.
85
86     *** G/L account master data
87       SELECT bukrs saknr xsalh FROM skb1 INTO wa_skb1
88         WHERE bukrs = p_bukrs
89           AND saknr IN so_hkont.
90         APPEND wa_skb1 TO it_skb1.
91       ENDSELECT.
92
93     *** select affected line items
94       SELECT
95       bukrs belnr gjahr
96       FROM bkpf INTO TABLE it_bkpf
97         WHERE bukrs = p_bukrs
98           AND belnr IN so_belnr
99           AND gjahr IN so_gjahr
100          AND monat IN so_monat.
101
102      LOOP AT it_bkpf INTO wa_bkpf.
103        SELECT
104        bukrs belnr gjahr buzei augdt augbl dmbtr wrbtr pswbt pswsl hkont
105        FROM bseg INTO wa_items
106          WHERE bukrs = wa_bkpf-bukrs
107            AND belnr = wa_bkpf-belnr
108            AND gjahr = wa_bkpf-gjahr
109            AND hkont IN so_hkont
110            AND pswsl NE x_waers ORDER BY PRIMARY KEY.
111          IF sy-subrc = 0.
112            APPEND wa_items TO it_items.
113            ADD 1 TO cnt.
114          ENDIF.
115        ENDSELECT.
116      ENDLOOP.
117
118    *** output
119      IF cnt > 0.
120
121        FORMAT COLOR COL_TOTAL.
122        ULINE AT /0(116).
123        WRITE:/ sy-vline NO-GAP, 'Affected line items:'.
124        WRITE: 116 sy-vline NO-GAP.
125        FORMAT COLOR OFF.
126        ULINE AT /0(116).
127        FORMAT COLOR COL_HEADING.
128        WRITE:/ sy-vline NO-GAP,
129                (5) 'BUKRS', sy-vline NO-GAP,
130               (10) 'BELNR', sy-vline NO-GAP,
131                (5) 'GJAHR', sy-vline NO-GAP,
132                (5) 'BUZEI', sy-vline NO-GAP,
133               (15) 'PSWBT', sy-vline NO-GAP,
134                (5) 'PSWSL', sy-vline NO-GAP,
135               (10) 'HKONT', sy-vline NO-GAP,
136               (15) 'new PSWBT', sy-vline NO-GAP,
137                (5) 'new PSWSL', sy-vline NO-GAP,
138    *Begin of <RD1K960036>
139    *           (20)'Updated:', sy-vline NO-GAP.
140               (20) 'Updated:', sy-vline NO-GAP.
141    *End of <RD1K960036>
142        ULINE AT /0(116).
143        FORMAT COLOR OFF.
144
145        SORT it_items BY hkont belnr buzei.
146        LOOP AT it_items INTO wa_items.
147          WRITE:/ sy-vline NO-GAP,
148                  (5) wa_items-bukrs, sy-vline NO-GAP,
149                 (10) wa_items-belnr, sy-vline NO-GAP,
150                  (5) wa_items-gjahr, sy-vline NO-GAP,
151                  (5) wa_items-buzei, sy-vline NO-GAP,
152                 (15) wa_items-pswbt, sy-vline NO-GAP,  "#EC CI_FLDEXT_OK[2610650]
153                  (5) wa_items-pswsl, sy-vline NO-GAP,
154                 (10) wa_items-hkont, sy-vline NO-GAP.  "#EC CI_FLDEXT_OK[2610650]
155    *** PSWSL has to be eq T001-waers (XSALH = 'X')
156          READ TABLE it_skb1 WITH KEY
157          bukrs = wa_items-bukrs
158          saknr = wa_items-hkont
159          INTO wa_skb1.
160
161          IF wa_skb1-xsalh = 'X'.
162            wa_items-new_pswbt = wa_items-dmbtr.
163            wa_items-new_pswsl = x_waers.
164            WRITE: (15) wa_items-new_pswbt, sy-vline NO-GAP,   "#EC CI_FLDEXT_OK[2610650]
165                    (5) wa_items-new_pswsl, sy-vline NO-GAP.  "#EC CI_FLDEXT_OK[2610650]
166            IF p_update = 'X'.
167              PERFORM update_item.
168            ENDIF.
169          ELSE.
170            WRITE: 'no XSALH' COLOR 3.
171          ENDIF.
172          WRITE: 116 sy-vline NO-GAP.
173        ENDLOOP.
174        ULINE AT /0(116).
175      ELSE.
176        FORMAT COLOR 3.
177        WRITE:/ 'No affetced line item found in company code', p_bukrs.
178        FORMAT COLOR OFF.
179      ENDIF.
180
181
182
183    *&---------------------------------------------------------------------*
184    *&      Form  update_item
185    *&---------------------------------------------------------------------*
186    *       text
187    *----------------------------------------------------------------------*
188    *  -->  p1        text
189    *  <--  p2        text
190    *----------------------------------------------------------------------*
191    FORM update_item.
192
193    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
194    * S/4: PSWSL/PSWBT (amount and update currency) cannot be changed on a posted document in S/4HANA (Note 3484729).
195    *  UPDATE bseg
196    *  SET pswsl   = wa_items-new_pswsl
197    *      pswbt   = wa_items-new_pswbt
198    *  WHERE bukrs = wa_items-bukrs
199    *    AND belnr = wa_items-belnr
200    *    AND gjahr = wa_items-gjahr
201    *    AND buzei = wa_items-buzei.
202      MESSAGE 'Document not updated. Amount/currency (PSWSL/PSWBT) cannot be changed on posted document - reverse and repost. Refer SAP Note 3484729' TYPE 'E'.
203    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
204      IF sy-subrc = 0.
205        WRITE: 'BSEG' COLOR 5.
206      ENDIF.
207    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
208
209    *  IF wa_items-augbl IS INITIAL.
210    *    UPDATE bsis
211    *    SET pswsl   = wa_items-new_pswsl
212    *        pswbt   = wa_items-new_pswbt
213    *    WHERE bukrs = wa_items-bukrs
214    *      AND hkont = wa_items-hkont
215    *      AND gjahr = wa_items-gjahr
216    *      AND belnr = wa_items-belnr
217    *      AND buzei = wa_items-buzei.
218    *    IF sy-subrc = 0.
219    *      WRITE: 'BSIS' COLOR 5.
220    *    ELSE.
221    *      WRITE: 'no BSIS found' COLOR 6.
222    *    ENDIF.
223    *  ELSE.
224    *    UPDATE bsas
225    *    SET pswsl   = wa_items-new_pswsl
226    *        pswbt   = wa_items-new_pswbt
227    *    WHERE bukrs = wa_items-bukrs
228    *      AND hkont = wa_items-hkont
229    *      AND augdt = wa_items-augdt
230    *      AND augbl = wa_items-augbl
231    *      AND gjahr = wa_items-gjahr
232    *      AND belnr = wa_items-belnr
233    *      AND buzei = wa_items-buzei.
234    *    IF sy-subrc = 0.
235    *      WRITE: 'BSAS' COLOR 5.
236    *    ELSE.
237    *      WRITE: 'no BSAS found' COLOR 6.
238    *    ENDIF.
239    *  ENDIF.
240    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
241    ENDFORM.                    " update_item
*--- End of ZF_CORR_PSWSL - 241 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZF_CORR_PSWSL                             Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:56
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
Object           ZF_CORR_PSWSL                             Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:56
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
Object           ZF_CORR_PSWSL                             Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:56
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
Object           ZF_CORR_PSWSL                             Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:56
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           ZF_CORR_PSWSL                             Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:56
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
