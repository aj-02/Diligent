include <object>.

BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      CHANGENUMBER LIKE AENR-AENNR,
  END OF KEY,
      CHANGENOTYPE_ORGUNIT TYPE SWC_OBJECT,
      ECO_REFERENCES TYPE SWC_OBJECT OCCURS 0,
      STATUSOBJNUMBER LIKE ONR00-OBJNR,
      STATUSOBJTYPE LIKE TJ03-OBTYP,
      STATUS_CHECK_REQUEST,
      STATUS_ALLOBJCHECKED,
      STATUS_CHECKED,
      STATUS_APPROVED,
      STATUS_REJECTED,
      STATUS_TO_BE_PROC,
      STATUS_LOCKED_BY_SYS,
      STATUS_LOCKED_BY_USE,
      STATUS_INCOMPLETE,
      STATUS_COMPLETE,
      STATUS_CONFIRMATED,
      STATUS_COMPLETED,
      STATUS_CHGOBJINCORRE,
      STATUS_ALLOBJRELEASD,
      STATUS_RELEASED,
      _AENR LIKE AENR.
END_DATA OBJECT. " Do not change.. DATA is generated


*- ATTRIBUTE ---------------------------------------------------------
* Database Attributes Table AENR
tables: aenr, aeoi.
* Get Attribute AENR
get_table_property aenr .
data subrc like sy-subrc.
perform get_table_aenr using subrc.
if subrc ne 0.
*      EXIT_RETURN RetuncCode Param1 Param2 Param3 Param4.
endif.
end_property.


get_property eco_references changing container.
data: l_aeoi_ref type swc_object.
data: l_aeoi_refs type swc_object occurs 0 with header line.
data: begin of l_aeoi_key ,
        aennr like aeoi-aennr,
        aetyp like aeoi-aetyp,
        objkt like aeoi-objkt,
      end of l_aeoi_key.
refresh l_aeoi_refs.
select * from  aeoi
         where aennr = object-key-changenumber.
  move-corresponding aeoi to l_aeoi_key.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  swc_create_object l_aeoi_ref 'ECO' l_aeoi_key.  "#EC CI_FLDEXT_OK
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  append l_aeoi_ref to l_aeoi_refs.
endselect.

"   SWC_SET_TABLE CONTAINER 'ECO_references' OBJECT-ECO_REFERENCES.
swc_set_table container 'ECO_references' l_aeoi_refs.
end_property.


get_property changenotype_orgunit changing container.
data: l_object type swc_object.
select single * from aenr client specified
       where mandt = sy-mandt
       and   aennr = object-key-changenumber.
swc_create_object l_object 'TCC11     ' aenr-ccart.
swc_set_element container 'ChangeNoType_OrgUnit'  l_object.
end_property.
*----------------------------------------------------------- ATTRIBUTE

* Get Table AENR
* ID to be filled with Object-ID
form get_table_aenr using subrc.
* with note 488573 buffer removed

* Form new designed with note 552406

   if object-_aenr-mandt is initial
   and object-_aenr-aennr is initial.
     select single * from aenr client specified
         where mandt = sy-mandt
         and aennr = object-key-changenumber.
     subrc = sy-subrc.
     if subrc eq 0.
        object-_aenr = aenr.
     else.
        exit.
     endif.
   else.
     subrc = 0.
     aenr = object-_aenr.
   endif.

endform.

begin_method edit changing container.

data : flg_wf like csdata-xfeld value 'X'.

export flg_wf to memory id 'WFECM'.
set parameter id 'AEN' field object-key-changenumber.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
call transaction 'CC32' and skip first screen.  "#EC CI_USAGE_OK[2267918]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
.
end_method .

begin_method display changing container.

data : flg_wf like csdata-xfeld value 'X'.

export flg_wf to memory id 'WFECM'.
set parameter id 'AEN' field object-key-changenumber.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
call transaction 'CC33' and skip first screen.  "#EC CI_USAGE_OK[2267918]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

end_method.




begin_method statusreport changing container.

submit rcc00400 with pm_aennr = object-key-changenumber
                                               and return.
end_method.

begin_method edit_synchron changing container.

data : flg_wf like csdata-xfeld value 'X'.

export flg_wf to memory id 'WFECM'.
set parameter id 'AEN' field object-key-changenumber.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
call transaction 'CC32' and skip first screen.  "#EC CI_USAGE_OK[2267918]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

end_method.

begin_method create changing container.

data : flg_wf like csdata-xfeld value 'X'.

export flg_wf to memory id 'WFECM'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
call transaction 'CC31'.  "#EC CI_USAGE_OK[2267918]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
.
end_method.


get_property statusobjtype changing container.
object-statusobjtype = 'CDM'.
swc_set_element container 'StatusObjType' object-statusobjtype.
end_property.

get_property statusobjnumber changing container.
data subrc like sy-subrc.
* Fill TABLES AENR to enable Object Manager Access to Table Properties
perform get_table_aenr using subrc.
if subrc ne 0.
  exit_object_not_found.
endif.
*- Statusobjektschlüssel aufbauen
object-statusobjnumber = 'CD'.
object-statusobjnumber+2 = aenr-aennr.

swc_set_element container 'StatusObjNumber' object-statusobjnumber.
end_property.


* Calculate Deadline (Latest_End)
* Termin (spätestes Ende zum Bearbeiten der folg. WI)
* wird aus Benutzerabfrage berechnet
begin_method deadline_determinate changing container.
data:
      deadline_new like syst-datum,
      deadline     like syst-index.
swc_get_element container 'Deadline' deadline.

* Calculate
call function 'END_TIME_DETERMINE'
    exporting
         duration                   = deadline
*          unit                       =
*          factory_calendar           =
    importing
         end_date                   = deadline_new
*          end_time                   =
    changing
         start_date                 = sy-datum
         start_time                 = sy-uzeit
    exceptions
         factory_calendar_not_found = 1
         date_out_of_calendar_range = 2
         date_not_valid             = 3
         unit_conversion_error      = 4
         si_unit_missing            = 5
         parameters_no_valid        = 6
         others                     = 7.

if sy-subrc <> 0.
endif.

swc_set_element container 'Deadline_new' deadline_new.

end_method.






BEGIN_METHOD ZECM_SENDMAIL CHANGING CONTAINER.
DATA:
      ORGDESC LIKE HRP1000-MC_SHORT,
      CHANGENUMBER LIKE AENR-AENNR,
      USER LIKE WFSYST-INITIATOR,
      EVENT LIKE HRS1212-EVENT,
      POSITION LIKE HRP1000-MC_SHORT,
      CHANGETYPE LIKE AENR-CCART.
  SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
  SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
  SWC_GET_ELEMENT CONTAINER 'User' USER.
  SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
  SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
  SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
  CALL FUNCTION 'ZLDM_ECM_SENDMAIL'
    EXPORTING
      CHANGETYPE = CHANGETYPE
      POSITION = POSITION
      EVENT = EVENT
      USER = USER
      CHANGENUMBER = CHANGENUMBER
      ORG_DESC = ORGDESC
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
END_METHOD.

BEGIN_METHOD ZECMSENDMAILCHECKED CHANGING CONTAINER.
DATA:
      ORGDESC LIKE HRP1000-MC_SHORT,
      CHANGENUMBER LIKE AENR-AENNR,
      USER LIKE WFSYST-INITIATOR,
      EVENT LIKE HRS1212-EVENT,
      POSITION LIKE HRP1000-MC_SHORT,
      CHANGETYPE LIKE AENR-CCART.
  SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
  SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
  SWC_GET_ELEMENT CONTAINER 'User' USER.
  SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
  SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
  SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
  CALL FUNCTION 'ZLDM_ECM_SENDMAIL_CHECKED'
    EXPORTING
      CHANGETYPE = CHANGETYPE
      POSITION = POSITION
      EVENT = EVENT
      USER = USER
      CHANGENUMBER = CHANGENUMBER
      ORG_DESC = ORGDESC
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
END_METHOD.

BEGIN_METHOD ZECMSENDMAILREJECTED CHANGING CONTAINER.
DATA:
      ORGDESC LIKE HRP1000-MC_SHORT,
      CHANGENUMBER LIKE AENR-AENNR,
      USER LIKE WFSYST-INITIATOR,
      EVENT LIKE HRS1212-EVENT,
      POSITION LIKE HRP1000-MC_SHORT,
      CHANGETYPE LIKE AENR-CCART.
  SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
  SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
  SWC_GET_ELEMENT CONTAINER 'User' USER.
  SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
  SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
  SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
  CALL FUNCTION 'ZLDM_ECM_SENDMAIL_REJECTED'
    EXPORTING
      CHANGETYPE = CHANGETYPE
      POSITION = POSITION
      EVENT = EVENT
      USER = USER
      CHANGENUMBER = CHANGENUMBER
      ORG_DESC = ORGDESC
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
END_METHOD.

BEGIN_METHOD ZECMSENDMAILAPPROVED CHANGING CONTAINER.
DATA:
      ORGDESC LIKE HRP1000-MC_SHORT,
      CHANGENUMBER LIKE AENR-AENNR,
      USER LIKE WFSYST-INITIATOR,
      EVENT LIKE HRS1212-EVENT,
      POSITION LIKE HRP1000-MC_SHORT,
      CHANGETYPE LIKE AENR-CCART.
  SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
  SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
  SWC_GET_ELEMENT CONTAINER 'User' USER.
  SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
  SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
  SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
  CALL FUNCTION 'ZLDM_ECM_SENDMAIL_APPROVED'
    EXPORTING
      CHANGETYPE = CHANGETYPE
      POSITION = POSITION
      EVENT = EVENT
      USER = USER
      CHANGENUMBER = CHANGENUMBER
      ORG_DESC = ORGDESC
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
END_METHOD.

BEGIN_METHOD ZECMSENDMAILRELEASED CHANGING CONTAINER.
DATA:
      ORGDESC LIKE HRP1000-MC_SHORT,
      CHANGENUMBER LIKE AENR-AENNR,
      USER LIKE WFSYST-INITIATOR,
      EVENT LIKE HRS1212-EVENT,
      POSITION LIKE HRP1000-MC_SHORT,
      CHANGETYPE LIKE AENR-CCART.
  SWC_GET_ELEMENT CONTAINER 'OrgDesc' ORGDESC.
  SWC_GET_ELEMENT CONTAINER 'Changenumber' CHANGENUMBER.
  SWC_GET_ELEMENT CONTAINER 'User' USER.
  SWC_GET_ELEMENT CONTAINER 'Event' EVENT.
  SWC_GET_ELEMENT CONTAINER 'Position' POSITION.
  SWC_GET_ELEMENT CONTAINER 'Changetype' CHANGETYPE.
  CALL FUNCTION 'ZLDM_ECM_SENDMAIL_RELEASED'
    EXPORTING
      CHANGETYPE = CHANGETYPE
      POSITION = POSITION
      EVENT = EVENT
      USER = USER
      CHANGENUMBER = CHANGENUMBER
      ORG_DESC = ORGDESC
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
END_METHOD.
