----------------------------------------------------------------------------------------------------
Main program     ZRCCWFL01                                 Level 0    Page 1
Object           ZRCCWFL01                                 Lines 364
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:31
----------------------------------------------------------------------------------------------------
1      include <object>.
2
3      BEGIN_DATA OBJECT. " Do not change.. DATA is generated
4      * only private members may be inserted into structure private
5      DATA:
6      " begin of private,
7      "   to declare private attributes remove comments and
8      "   insert private attributes here ...
9      " end of private,
10       BEGIN OF KEY,
11           CHANGENUMBER LIKE AENR-AENNR,
12       END OF KEY,
13           CHANGENOTYPE_ORGUNIT TYPE SWC_OBJECT,
14           ECO_REFERENCES TYPE SWC_OBJECT OCCURS 0,
15           STATUSOBJNUMBER LIKE ONR00-OBJNR,
16           STATUSOBJTYPE LIKE TJ03-OBTYP,
17           STATUS_CHECK_REQUEST,
18           STATUS_ALLOBJCHECKED,
19           STATUS_CHECKED,
20           STATUS_APPROVED,
21           STATUS_REJECTED,
22           STATUS_TO_BE_PROC,
23           STATUS_LOCKED_BY_SYS,
24           STATUS_LOCKED_BY_USE,
25           STATUS_INCOMPLETE,
26           STATUS_COMPLETE,
27           STATUS_CONFIRMATED,
28           STATUS_COMPLETED,
29           STATUS_CHGOBJINCORRE,
30           STATUS_ALLOBJRELEASD,
31           STATUS_RELEASED,
32           _AENR LIKE AENR.
33     END_DATA OBJECT. " Do not change.. DATA is generated
34
35
36     *- ATTRIBUTE ---------------------------------------------------------
37     * Database Attributes Table AENR
38     tables: aenr, aeoi.
39     * Get Attribute AENR
40     get_table_property aenr .
41     data subrc like sy-subrc.
42     perform get_table_aenr using subrc.
43     if subrc ne 0.
44     *      EXIT_RETURN RetuncCode Param1 Param2 Param3 Param4.
45     endif.
46     end_property.
47
48
49     get_property eco_references changing container.
50     data: l_aeoi_ref type swc_object.
51     data: l_aeoi_refs type swc_object occurs 0 with header line.
52     data: begin of l_aeoi_key ,
53             aennr like aeoi-aennr,
54             aetyp like aeoi-aetyp,
55             objkt like aeoi-objkt,
56           end of l_aeoi_key.
57     refresh l_aeoi_refs.
58     select * from  aeoi
59              where aennr = object-key-changenumber.
60       move-corresponding aeoi to l_aeoi_key.
61       swc_create_object l_aeoi_ref 'ECO' l_aeoi_key.
62       append l_aeoi_ref to l_aeoi_refs.
63     endselect.
64
65     "   SWC_SET_TABLE CONTAINER 'ECO_references' OBJECT-ECO_REFERENCES.
66     swc_set_table container 'ECO_references' l_aeoi_refs.
67     end_property.
68
69
70     get_property changenotype_orgunit changing container.
71     data: l_object type swc_object.
72     select single * from aenr client specified
73            where mandt = sy-mandt
74            and   aennr = object-key-changenumber.
75     swc_create_object l_object 'TCC11     ' aenr-ccart.
76     swc_set_element container 'ChangeNoType_OrgUnit'  l_object.
77     end_property.
78     *----------------------------------------------------------- ATTRIBUTE
79
80     * Get Table AENR
81     * ID to be filled with Object-ID
82     form get_table_aenr using subrc.
83     * with note 488573 buffer removed
84
85     * Form new designed with note 552406
86
87        if object-_aenr-mandt is initial
88        and object-_aenr-aennr is initial.
89          select single * from aenr client specified
90              where mandt = sy-mandt
91              and aennr = object-key-changenumber.
92          subrc = sy-subrc.
93          if subrc eq 0.
94             object-_aenr = aenr.
95          else.
96             exit.
97          endif.
98        else.
99          subrc = 0.
100         aenr = object-_aenr.
101       endif.
102
103    endform.
104
105    begin_method edit changing container.
106
107    data : flg_wf like csdata-xfeld value 'X'.
108
109    export flg_wf to memory id 'WFECM'.
110    set parameter id 'AEN' field object-key-changenumber.
111    call transaction 'CC32' and skip first screen.
112    .
113    end_method .
114
115    begin_method display changing container.
116
117    data : flg_wf like csdata-xfeld value 'X'.
118
119    export flg_wf to memory id 'WFECM'.
120    set parameter id 'AEN' field object-key-changenumber.
121    call transaction 'CC33' and skip first screen.
122
123    end_method.
124
125
126
127
128    begin_method statusreport changing container.
129
130    submit rcc00400 with pm_aennr = object-key-changenumber
131                                                   and return.
132    end_method.
133
134    begin_method edit_synchron changing container.
135
136    data : flg_wf like csdata-xfeld value 'X'.
137
138    export flg_wf to memory id 'WFECM'.
139    set parameter id 'AEN' field object-key-changenumber.
140    call transaction 'CC32' and skip first screen.
141
142    end_method.
143
144    begin_method create changing container.
145
146    data : flg_wf like csdata-xfeld value 'X'.
147
148    export flg_wf to memory id 'WFECM'.
149    call transaction 'CC31'.
150    .
151    end_method.
152
153
154    get_property statusobjtype changing container.
155    object-statusobjtype = 'CDM'.
156    swc_set_element container 'StatusObjType' object-statusobjtype.
157    end_property.
158
159    get_property statusobjnumber changing container.
160    data subrc like sy-subrc.
161    * Fill TABLES AENR to enable Object Manager Access to Table Properties
162    perform get_table_aenr using subrc.
163    if subrc ne 0.
164      exit_object_not_found.
165    endif.
166    *- Statusobjektschlüssel aufbauen
167    object-statusobjnumber = 'CD'.
168    object-statusobjnumber+2 = aenr-aennr.
169
170    swc_set_element container 'StatusObjNumber' object-statusobjnumber.
171    end_property.
172
173
174    * Calculate Deadline (Latest_End)
175    * Termin (spätestes Ende zum Bearbeiten der folg. WI)
176    * wird aus Benutzerabfrage berechnet
177    begin_method deadline_determinate changing container.
178    data:
179          deadline_new like syst-datum,
180          deadline     like syst-index.
181    swc_get_element container 'Deadline' deadline.
182
183    * Calculate
184    call function 'END_TIME_DETERMINE'
185        exporting
186             duration                   = deadline
187    *          unit                       =
188    *          factory_calendar           =
189        importing
190             end_date                   = deadline_new
191    *          end_time                   =
192        changing
193             start_date                 = sy-datum
194             start_time                 = sy-uzeit
195        exceptions
196             factory_calendar_not_found = 1
197             date_out_of_calendar_range = 2
198             date_not_valid             = 3
199             unit_conversion_error      = 4
200             si_unit_missing            = 5
201             parameters_no_valid        = 6
202             others                     = 7.
203
204    if sy-subrc <> 0.
205    endif.
206
207    swc_set_element container 'Deadline_new' deadline_new.
208
209    end_method.
210
211
212
213
214
215
216    BEGIN_METHOD ZECM_SENDMAIL CHANGING CONTAINER.
217    DATA:
218          ORGDESC LIKE HRP1000-MC_SHORT,
219          CHANGENUMBER LIKE AENR-AENNR,
220          USER LIKE WFSYST-INITIATOR,
221          EVENT LIKE HRS1212-EVENT,
222          POSITION LIKE HRP1000-MC_SHORT,
223          CHANGETYPE LIKE AENR-CCART.
224      SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
225      SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
226      SWC_GET_ELEMENT CONTAINER 'User' USER.
227      SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
228      SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
229      SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
230      CALL FUNCTION 'ZLDM_ECM_SENDMAIL'
231        EXPORTING
232          CHANGETYPE = CHANGETYPE
233          POSITION = POSITION
234          EVENT = EVENT
235          USER = USER
236          CHANGENUMBER = CHANGENUMBER
237          ORG_DESC = ORGDESC
238        EXCEPTIONS
239          OTHERS = 01.
240      CASE SY-SUBRC.
241        WHEN 0.            " OK
242        WHEN OTHERS.       " to be implemented
243      ENDCASE.
244    END_METHOD.
245
246    BEGIN_METHOD ZECMSENDMAILCHECKED CHANGING CONTAINER.
247    DATA:
248          ORGDESC LIKE HRP1000-MC_SHORT,
249          CHANGENUMBER LIKE AENR-AENNR,
250          USER LIKE WFSYST-INITIATOR,
251          EVENT LIKE HRS1212-EVENT,
252          POSITION LIKE HRP1000-MC_SHORT,
253          CHANGETYPE LIKE AENR-CCART.
254      SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
255      SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
256      SWC_GET_ELEMENT CONTAINER 'User' USER.
257      SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
258      SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
259      SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
260      CALL FUNCTION 'ZLDM_ECM_SENDMAIL_CHECKED'
261        EXPORTING
262          CHANGETYPE = CHANGETYPE
263          POSITION = POSITION
264          EVENT = EVENT
265          USER = USER
266          CHANGENUMBER = CHANGENUMBER
267          ORG_DESC = ORGDESC
268        EXCEPTIONS
269          OTHERS = 01.
270      CASE SY-SUBRC.
271        WHEN 0.            " OK
272        WHEN OTHERS.       " to be implemented
273      ENDCASE.
274    END_METHOD.
275
276    BEGIN_METHOD ZECMSENDMAILREJECTED CHANGING CONTAINER.
277    DATA:
278          ORGDESC LIKE HRP1000-MC_SHORT,
279          CHANGENUMBER LIKE AENR-AENNR,
280          USER LIKE WFSYST-INITIATOR,
281          EVENT LIKE HRS1212-EVENT,
282          POSITION LIKE HRP1000-MC_SHORT,
283          CHANGETYPE LIKE AENR-CCART.
284      SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
285      SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
286      SWC_GET_ELEMENT CONTAINER 'User' USER.
287      SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
288      SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
289      SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
290      CALL FUNCTION 'ZLDM_ECM_SENDMAIL_REJECTED'
291        EXPORTING
292          CHANGETYPE = CHANGETYPE
293          POSITION = POSITION
294          EVENT = EVENT
295          USER = USER
296          CHANGENUMBER = CHANGENUMBER
297          ORG_DESC = ORGDESC
298        EXCEPTIONS
299          OTHERS = 01.
300      CASE SY-SUBRC.
301        WHEN 0.            " OK
302        WHEN OTHERS.       " to be implemented
303      ENDCASE.
304    END_METHOD.
305
306    BEGIN_METHOD ZECMSENDMAILAPPROVED CHANGING CONTAINER.
307    DATA:
308          ORGDESC LIKE HRP1000-MC_SHORT,
309          CHANGENUMBER LIKE AENR-AENNR,
310          USER LIKE WFSYST-INITIATOR,
311          EVENT LIKE HRS1212-EVENT,
312          POSITION LIKE HRP1000-MC_SHORT,
313          CHANGETYPE LIKE AENR-CCART.
314      SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
315      SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
316      SWC_GET_ELEMENT CONTAINER 'User' USER.
317      SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
318      SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
319      SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
320      CALL FUNCTION 'ZLDM_ECM_SENDMAIL_APPROVED'
321        EXPORTING
322          CHANGETYPE = CHANGETYPE
323          POSITION = POSITION
324          EVENT = EVENT
325          USER = USER
326          CHANGENUMBER = CHANGENUMBER
327          ORG_DESC = ORGDESC
328        EXCEPTIONS
329          OTHERS = 01.
330      CASE SY-SUBRC.
331        WHEN 0.            " OK
332        WHEN OTHERS.       " to be implemented
333      ENDCASE.
334    END_METHOD.
335
336    BEGIN_METHOD ZECMSENDMAILRELEASED CHANGING CONTAINER.
337    DATA:
338          ORGDESC LIKE HRP1000-MC_SHORT,
339          CHANGENUMBER LIKE AENR-AENNR,
340          USER LIKE WFSYST-INITIATOR,
341          EVENT LIKE HRS1212-EVENT,
342          POSITION LIKE HRP1000-MC_SHORT,
343          CHANGETYPE LIKE AENR-CCART.
344      SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
345      SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
346      SWC_GET_ELEMENT CONTAINER 'User' USER.
347      SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
348      SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
349      SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
350      CALL FUNCTION 'ZLDM_ECM_SENDMAIL_RELEASED'
351        EXPORTING
352          CHANGETYPE = CHANGETYPE
353          POSITION = POSITION
354          EVENT = EVENT
355          USER = USER
356          CHANGENUMBER = CHANGENUMBER
357          ORG_DESC = ORGDESC
358        EXCEPTIONS
359          OTHERS = 01.
360      CASE SY-SUBRC.
361        WHEN 0.            " OK
362        WHEN OTHERS.       " to be implemented
363      ENDCASE.
364    END_METHOD.
*--- End of ZRCCWFL01 - 364 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 2
Object           ZRCCWFL01                                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:31
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
Generated incl.  <CNTN01>                                  Level 1    Page 3
Object           ZRCCWFL01                                 Lines 613
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:31
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
Generated incl.  <OBJECT>                                  Level 1    Page 4
Object           ZRCCWFL01                                 Lines 339
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:31
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
Generated incl.  <SYSINI>                                  Level 1    Page 5
Object           ZRCCWFL01                                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:31
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
Generated incl.  OLE2INCL                                  Level 1    Page 6
Object           ZRCCWFL01                                 Lines 2
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:31
----------------------------------------------------------------------------------------------------
1      ***INCLUDE OLE2INCL.
2      TYPE-POOLS OLE2 .
*--- End of OLE2INCL - 2 lines ---
