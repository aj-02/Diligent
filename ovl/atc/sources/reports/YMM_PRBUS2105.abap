*--- MAIN PROGRAM: YMM_PRBUS2105 ---*
*****           Implementation of object type BUS2105              *****
INCLUDE <object>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      NUMBER LIKE EBAN-BANFN,
      RELEASECODE LIKE ZMM_PR_RELCODE-FRGCO,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated
TABLES eban.


begin_method change changing container.
DATA:
      requisitionitemsold LIKE bapiebanv OCCURS 0,
      requisitionitemsnew LIKE bapiebanv OCCURS 0,
      requisitionaccountol LIKE bapiebknv OCCURS 0,
      requisitionaccountne LIKE bapiebknv OCCURS 0,
      requisitiontextold LIKE bapiebantx OCCURS 0,
      requisitiontextnew LIKE bapiebantx OCCURS 0,
      return LIKE bapireturn OCCURS 0.
swc_get_table container 'RequisitionItemsOld' requisitionitemsold.
swc_get_table container 'RequisitionItemsNew' requisitionitemsnew.
swc_get_table container 'RequisitionAccountOl' requisitionaccountol.
swc_get_table container 'RequisitionAccountNe' requisitionaccountne.
swc_get_table container 'RequisitionTextOld' requisitiontextold.
swc_get_table container 'RequisitionTextNew' requisitiontextnew.
swc_get_table container 'Return' return.
CALL FUNCTION 'BAPI_REQUISITION_CHANGE'
  EXPORTING
    number                  = object-key-number
  TABLES
    return                  = return
    requisition_text_new    = requisitiontextnew
    requisition_text_old    = requisitiontextold
    requisition_account_new = requisitionaccountne
    requisition_account_old = requisitionaccountol
    requisition_items_new   = requisitionitemsnew
    requisition_items_old   = requisitionitemsold
  EXCEPTIONS
    OTHERS                  = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container 'RequisitionItemsOld' requisitionitemsold.
swc_set_table container 'RequisitionItemsNew' requisitionitemsnew.
swc_set_table container 'RequisitionAccountOl' requisitionaccountol.
swc_set_table container 'RequisitionAccountNe' requisitionaccountne.
swc_set_table container 'RequisitionTextOld' requisitiontextold.
swc_set_table container 'RequisitionTextNew' requisitiontextnew.
swc_set_table container 'Return' return.
end_method.


begin_method getitemsforrelease changing container.
DATA:
      relgroup LIKE bapimmpara-rel_group,
      relcode LIKE bapimmpara-rel_code,
      itemsforrelease LIKE bapimmpara-selection,
      requisitionitems LIKE bapiebanc OCCURS 0,
      return LIKE bapireturn OCCURS 0.
swc_get_element container 'RelGroup' relgroup.
swc_get_element container 'RelCode' relcode.
swc_get_element container 'ItemsForRelease' itemsforrelease.
IF sy-subrc <> 0.
  MOVE 'X' TO itemsforrelease.
ENDIF.
swc_get_table container 'RequisitionItems' requisitionitems. "#EC CI_FLDEXT_OK
swc_get_table container 'Return' return.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
CALL FUNCTION 'BAPI_REQUISITION_GETITEMSREL'"#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
  EXPORTING
    items_for_release = itemsforrelease
    rel_code          = relcode
    rel_group         = relgroup
  TABLES
    requisition_items = requisitionitems
    return            = return
  EXCEPTIONS
    OTHERS            = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container 'RequisitionItems' requisitionitems. "#EC CI_FLDEXT_OK
swc_set_table container 'Return' return.
end_method.

begin_method delete changing container.
DATA:
      requisitionitemstode LIKE bapieband OCCURS 0,
      return LIKE bapireturn OCCURS 0.
swc_get_table container 'RequisitionItemsToDe' requisitionitemstode.
swc_get_table container 'Return' return.
CALL FUNCTION 'BAPI_REQUISITION_DELETE'
  EXPORTING
    number                      = object-key-number
  TABLES
    requisition_items_to_delete = requisitionitemstode
    return                      = return
  EXCEPTIONS
    OTHERS                      = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container 'RequisitionItemsToDe' requisitionitemstode.
swc_set_table container 'Return' return.
end_method.

begin_method getdetail changing container.
DATA:
      accountassignment LIKE bapimmpara-selection,
      itemtexts LIKE bapimmpara-selection,
      services LIKE bapimmpara-selection,
      servicetexts LIKE bapimmpara-selection,
      requisitionitems LIKE bapieban OCCURS 0,
      requisitionaccountas LIKE bapiebkn OCCURS 0,
      requisitiontext LIKE bapiebantx OCCURS 0,
      requisitionlimits LIKE bapiesuh OCCURS 0,
      requisitioncontractl LIKE bapiesuc OCCURS 0,
      requisitionservices LIKE bapiesll OCCURS 0,
      requisitionsrvtexts LIKE bapieslltx OCCURS 0,
      requisitionsrvaccass LIKE bapieskl OCCURS 0,
      return LIKE bapireturn OCCURS 0.
swc_get_element container 'AccountAssignment' accountassignment.
IF sy-subrc <> 0.
  MOVE space TO accountassignment.
ENDIF.
swc_get_element container 'ItemTexts' itemtexts.
IF sy-subrc <> 0.
  MOVE space TO itemtexts.
ENDIF.
swc_get_element container 'Services' services.
IF sy-subrc <> 0.
  MOVE space TO services.
ENDIF.
swc_get_element container 'ServiceTexts' servicetexts.
IF sy-subrc <> 0.
  MOVE space TO servicetexts.
ENDIF.

swc_get_table container 'RequisitionItems' requisitionitems.  "#EC CI_FLDEXT_OK
swc_get_table container 'RequisitionAccountAs' requisitionaccountas.
swc_get_table container 'RequisitionText' requisitiontext.
swc_get_table container 'RequisitionLimits' requisitionlimits.
swc_get_table container 'RequisitionContractL' requisitioncontractl.
swc_get_table container 'RequisitionServices' requisitionservices.
swc_get_table container 'RequisitionSrvTexts' requisitionsrvtexts.
swc_get_table container 'RequisitionSrvAccass' requisitionsrvaccass.
swc_get_table container 'Return' return.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
CALL FUNCTION 'BAPI_REQUISITION_GETDETAIL'"#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
  EXPORTING
    services                       = services
    service_texts                  = servicetexts
    item_texts                     = itemtexts
    account_assignment             = accountassignment
    number                         = object-key-number
  TABLES
    requisition_contract_limits    = requisitioncontractl
    requisition_services           = requisitionservices
    requisition_services_texts     = requisitionsrvtexts
    requisition_srv_accass_values  = requisitionsrvaccass
    return                         = return
    requisition_limits             = requisitionlimits
    requisition_text               = requisitiontext
    requisition_account_assignment = requisitionaccountas
    requisition_items              = requisitionitems
  EXCEPTIONS
    OTHERS                         = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container 'RequisitionItems' requisitionitems.  "#EC CI_FLDEXT_OK
swc_set_table container 'RequisitionAccountAs' requisitionaccountas.
swc_set_table container 'RequisitionText' requisitiontext.
swc_set_table container 'RequisitionLimits' requisitionlimits.
swc_set_table container 'RequisitionContractL' requisitioncontractl.
swc_set_table container 'RequisitionServices' requisitionservices.
swc_set_table container 'RequisitionSrvTexts' requisitionsrvtexts.
swc_set_table container 'RequisitionSrvAccass' requisitionsrvaccass.
swc_set_table container 'Return' return.
end_method.

begin_method getreleaseinfo changing container.
DATA:
      item LIKE bapirlgnrq-preq_item,
      relcode LIKE bapirlgnrq-rel_code,
      generalreleaseinfo LIKE bapirlgnrq OCCURS 0,
      releaseprerequisites LIKE bapirlcorq OCCURS 0,
      releasealreadyposted LIKE bapirlcorq OCCURS 0,
      releasefinal LIKE bapirlcorq OCCURS 0,
      return LIKE bapireturn OCCURS 0.
swc_get_element container 'Item' item.
swc_get_element container 'RelCode' relcode.
swc_get_table container 'GeneralReleaseInfo' generalreleaseinfo.
swc_get_table container 'ReleasePrerequisites' releaseprerequisites.
swc_get_table container 'ReleaseAlreadyPosted' releasealreadyposted.
swc_get_table container 'ReleaseFinal' releasefinal.
swc_get_table container 'Return' return.
CALL FUNCTION 'BAPI_REQUISITION_GETRELINFO'
  EXPORTING
    rel_code               = relcode
    item                   = item
    number                 = object-key-number
  TABLES
    return                 = return
    release_final          = releasefinal
    release_already_posted = releasealreadyposted
    release_prerequisites  = releaseprerequisites
    general_release_info   = generalreleaseinfo
  EXCEPTIONS
    OTHERS                 = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container 'GeneralReleaseInfo' generalreleaseinfo.
swc_set_table container 'ReleasePrerequisites' releaseprerequisites.
swc_set_table container 'ReleaseAlreadyPosted' releasealreadyposted.
swc_set_table container 'ReleaseFinal' releasefinal.
swc_set_table container 'Return' return.
end_method.

begin_method display changing container.
CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
  EXPORTING
    im_banfn = object-key-number
  EXCEPTIONS
    OTHERS   = 1.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
end_method.

begin_method existencecheck changing container.
DATA: lv_banfn LIKE object-key-number.

SELECT banfn FROM eban INTO lv_banfn
                       WHERE banfn EQ object-key-number.
ENDSELECT.
IF sy-subrc NE 0.                                           "154883
  exit_object_not_found.                                    "154883
ENDIF.                                                      "154883
end_method.

begin_method singlerelease changing container.
DATA: purchaserequisition LIKE eban-banfn,
      releasecode LIKE rm06b-frgab,
      call_updkz.

swc_get_element container 'ReleaseCode' releasecode.
purchaserequisition = object-key-number.

CALL FUNCTION 'ME_RELEASE_REQUISITION'
  EXPORTING
    im_banfn = purchaserequisition
    im_frgco = releasecode
    im_wf    = 'X'
  IMPORTING
    ex_updkz = call_updkz
  EXCEPTIONS
    OTHERS   = 0.

IF call_updkz NE space.
  IF call_updkz EQ 'N'.
    CLEAR call_updkz.
  ENDIF.
  swc_set_element container result call_updkz.
ELSE.
  exit_cancelled.
ENDIF.

end_method.

begin_method inforeleasereset changing container.
DATA:
   releasecode LIKE rm06b-frgab.
swc_get_element container 'ReleaseCode' releasecode.

end_method.

begin_method inforeleaserejected changing container.
CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
  EXPORTING
    im_banfn  = object-key-number
    im_change = 'X'
  EXCEPTIONS
    OTHERS    = 1.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
end_method.

begin_method inforeleaseeffected changing container.

DATA:
    releasecode LIKE rm06b-frgab.
swc_get_element container 'ReleaseCode' releasecode.

end_method.

begin_method release changing container.
DATA:
      relcode LIKE bapimmpara-rel_code,
      relstatusnew LIKE bapimmpara-rel_status,
      relindicatornew LIKE bapimmpara-rel_ind,
      return LIKE bapireturn OCCURS 0,
      nocommitwork TYPE bapiflag-bapiflag.
swc_get_element container 'RelCode' relcode.
swc_get_table container 'Return' return.
swc_get_element container 'NoCommitWork' nocommitwork.
CALL FUNCTION 'BAPI_REQUISITION_RELEASE_GEN'
  EXPORTING
    number            = object-key-number
    rel_code          = relcode
    no_commit_work    = nocommitwork
  IMPORTING
    rel_indicator_new = relindicatornew
    rel_status_new    = relstatusnew
  TABLES
    return            = return
  EXCEPTIONS
    OTHERS            = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'RelStatusNew' relstatusnew.
swc_set_element container 'RelIndicatorNew' relindicatornew.
swc_set_table container 'Return' return.
end_method.

begin_method resetrelease changing container.
DATA:
      relcode LIKE bapimmpara-rel_code,
      relstatusnew LIKE bapimmpara-rel_status,
      relindicatornew LIKE bapimmpara-rel_ind,
      return LIKE bapireturn OCCURS 0.
swc_get_element container 'RelCode' relcode.
swc_get_table container 'Return' return.
CALL FUNCTION 'BAPI_REQUISITION_RESET_REL_GEN'
  EXPORTING
    number            = object-key-number
    rel_code          = relcode
  IMPORTING
    rel_indicator_new = relindicatornew
    rel_status_new    = relstatusnew
  TABLES
    return            = return
  EXCEPTIONS
    OTHERS            = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'RelStatusNew' relstatusnew.
swc_set_element container 'RelIndicatorNew' relindicatornew.
swc_set_table container 'Return' return.
end_method.


begin_method edit changing container.
CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
  EXPORTING
    im_banfn  = object-key-number
    im_change = 'X'
  EXCEPTIONS
    OTHERS    = 1.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
end_method.

begin_method createfromdata changing container.
DATA:
      requisitionitems LIKE bapiebanc OCCURS 0,
      requisitionaccountas LIKE bapiebkn OCCURS 0,
      requisitionitemtext LIKE bapiebantx OCCURS 0,
      requisitionlimits LIKE bapiesuhc OCCURS 0,
      requisitioncontractl LIKE bapiesucc OCCURS 0,
      requisitionservices LIKE bapiesllc OCCURS 0,
      requisitionsrvtext LIKE bapieslltx OCCURS 0,
      requisitionsrvaccass LIKE bapiesklc OCCURS 0,
      return LIKE bapireturn OCCURS 0,
      extensionin LIKE bapiparex OCCURS 0,
      skipitemswitherror LIKE bapimmpara-selection.
swc_get_table container 'RequisitionItems' requisitionitems.  "#EC CI_FLDEXT_OK
swc_get_table container 'RequisitionAccountAs' requisitionaccountas.
swc_get_table container 'RequisitionItemText' requisitionitemtext.
swc_get_table container 'RequisitionLimits' requisitionlimits.
swc_get_table container 'RequisitionContractL' requisitioncontractl.
swc_get_table container 'RequisitionServices' requisitionservices.
swc_get_table container 'RequisitionSrvText' requisitionsrvtext.
swc_get_table container 'RequisitionSrvAccass' requisitionsrvaccass.
swc_get_table container 'ExtensionIn' extensionin.
swc_get_element container 'SkipItemsWithError' skipitemswitherror.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*CALL FUNCTION 'BAPI_REQUISITION_CREATE'   "#EC CI_USAGE_OK[2438131]
*  EXPORTING
*    skip_items_with_error          = skipitemswitherror
*  IMPORTING
*    number                         = object-key-number
*  TABLES
*    requisition_services           = requisitionservices
*    requisition_srv_accass_values  = requisitionsrvaccass
*    return                         = return
*    requisition_services_text      = requisitionsrvtext
*    extensionin                    = extensionin
*    requisition_items              = requisitionitems
*    requisition_account_assignment = requisitionaccountas
*    requisition_item_text          = requisitionitemtext
*    requisition_limits             = requisitionlimits
*    requisition_contract_limits    = requisitioncontractl
*  EXCEPTIONS
*    OTHERS                         = 01.
CALL FUNCTION 'BAPI_PR_CREATE'   "#EC CI_USAGE_OK[2438131]
  EXPORTING
    skip_items_with_error          = skipitemswitherror
  IMPORTING
    number                         = object-key-number
  TABLES
    requisition_items              = requisitionitems
    requisition_account_assignment = requisitionaccountas
    requisition_item_text          = requisitionitemtext
    requisition_limits             = requisitionlimits
    requisition_contract_limits    = requisitioncontractl
    requisition_services           = requisitionservices
    requisition_srv_accass_values  = requisitionsrvaccass
    requisition_services_text      = requisitionsrvtext
    extensionin                    = extensionin
    return                         = return.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container 'RequisitionItems' requisitionitems.  "#EC CI_FLDEXT_OK
swc_set_table container 'RequisitionAccountAs' requisitionaccountas.
swc_set_table container 'RequisitionItemText' requisitionitemtext.
swc_set_table container 'RequisitionLimits' requisitionlimits.
swc_set_table container 'RequisitionContractL' requisitioncontractl.
swc_set_table container 'RequisitionServices' requisitionservices.
swc_set_table container 'RequisitionSrvAccass' requisitionsrvaccass.
swc_set_table container 'Return' return.
end_method.

begin_method editasync changing container.
CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
  EXPORTING
    im_banfn  = object-key-number
    im_change = 'X'
  EXCEPTIONS
    OTHERS    = 1.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
end_method.

BEGIN_METHOD CREATEFROMDATA1 CHANGING CONTAINER.
DATA:
      PRHEADER LIKE BAPIMEREQHEADER,
      PRHEADERX LIKE BAPIMEREQHEADERX,
      TESTRUN TYPE BAPIFLAG-BAPIFLAG,
      PRNUMBER TYPE BAPIMEREQHEADER-PREQ_NO,
      PRHEADEREXP LIKE BAPIMEREQHEADER,
      RETURN LIKE BAPIRET2 OCCURS 0,
      PRITEM LIKE BAPIMEREQITEMIMP OCCURS 0,
      PRITEMX LIKE BAPIMEREQITEMX OCCURS 0,
      PRITEMEXP LIKE BAPIMEREQITEM OCCURS 0,
      PRITEMSOURCE LIKE BAPIMEREQSOURCE OCCURS 0,
      PRACCOUNT LIKE BAPIMEREQACCOUNT OCCURS 0,
      PRACCOUNTPROITSEGMENT LIKE BAPIMEREQACCOUNTPROFITSEG OCCURS 0,
      PRACCOUNTX LIKE BAPIMEREQACCOUNTX OCCURS 0,
      PRADDRDELIVERY LIKE BAPIMERQADDRDELIVERY OCCURS 0,
      PRITEMTEXT LIKE BAPIMEREQITEMTEXT OCCURS 0,
      PRHEADERTEXT LIKE BAPIMEREQHEADTEXT OCCURS 0,
      PRVERSION LIKE BAPIMEREQDCM OCCURS 0,
      PRVERSIONX LIKE BAPIMEREQDCMX OCCURS 0,
      EXTENSIONIN LIKE BAPIPAREX OCCURS 0,
      EXTENSIONOUT LIKE BAPIPAREX OCCURS 0,
      ALLVERSIONS LIKE BAPIMEDCM_ALLVERSIONS OCCURS 0.
  SWC_GET_ELEMENT CONTAINER 'PrHeader' PRHEADER.
  SWC_GET_ELEMENT CONTAINER 'PrHeaderX' PRHEADERX.
  SWC_GET_ELEMENT CONTAINER 'PrVersion' PRVERSION.
  SWC_GET_ELEMENT CONTAINER 'PrVersionX' PRVERSIONX.
  SWC_GET_ELEMENT CONTAINER 'Testrun' TESTRUN.
  SWC_GET_TABLE CONTAINER 'PrItem' PRITEM. "#EC CI_FLDEXT_OK
  SWC_GET_TABLE CONTAINER 'PrItemX' PRITEMX.
  SWC_GET_TABLE CONTAINER 'PrAccount' PRACCOUNT.
  SWC_GET_TABLE CONTAINER 'PrAccountProitSegment' PRACCOUNTPROITSEGMENT.
  SWC_GET_TABLE CONTAINER 'PrAccountX' PRACCOUNTX.
  SWC_GET_TABLE CONTAINER 'PrAddrDelivery' PRADDRDELIVERY.
  SWC_GET_TABLE CONTAINER 'PrItemText' PRITEMTEXT.
  SWC_GET_TABLE CONTAINER 'PrHeaderText' PRHEADERTEXT.
  SWC_GET_TABLE CONTAINER 'Extensionin' EXTENSIONIN.
  SWC_GET_TABLE CONTAINER 'Allversions' ALLVERSIONS.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
  CALL FUNCTION 'BAPI_PR_CREATE'"#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
    EXPORTING
      PRHEADER = PRHEADER
      PRHEADERX = PRHEADERX
      TESTRUN = TESTRUN
    IMPORTING
      NUMBER = OBJECT-KEY-NUMBER
      PRHEADEREXP = PRHEADEREXP
    TABLES
      PRHEADERTEXT = PRHEADERTEXT
      EXTENSIONIN = EXTENSIONIN
      EXTENSIONOUT = EXTENSIONOUT
      ALLVERSIONS = ALLVERSIONS
      PRITEMTEXT = PRITEMTEXT
      PRADDRDELIVERY = PRADDRDELIVERY
      PRACCOUNTX = PRACCOUNTX
      PRACCOUNTPROITSEGMENT = PRACCOUNTPROITSEGMENT
      PRACCOUNT = PRACCOUNT
      PRITEMSOURCE = PRITEMSOURCE
      PRITEMEXP = PRITEMEXP
      PRITEMX = PRITEMX
      PRITEM = PRITEM
      PRVERSION = PRVERSION
      PRVERSIONX = PRVERSIONX
      RETURN = RETURN
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
  SWC_SET_ELEMENT CONTAINER 'Number' PRNUMBER.
  SWC_SET_ELEMENT CONTAINER 'PrHeaderExp' PRHEADEREXP.
  SWC_SET_TABLE CONTAINER 'Return' RETURN.
  SWC_SET_TABLE CONTAINER 'PrItemExp' PRITEMEXP. "#EC CI_FLDEXT_OK
  SWC_SET_TABLE CONTAINER 'PrItemSource' PRITEMSOURCE.
  SWC_SET_TABLE CONTAINER 'PrAccount' PRACCOUNT.
  SWC_SET_TABLE CONTAINER 'PrAccountProitSegment' PRACCOUNTPROITSEGMENT.
  SWC_SET_TABLE CONTAINER 'PrAddrDelivery' PRADDRDELIVERY.
  SWC_SET_TABLE CONTAINER 'PrItemText' PRITEMTEXT.
  SWC_SET_TABLE CONTAINER 'PrHeaderText' PRHEADERTEXT.
  SWC_SET_TABLE CONTAINER 'Extensionin' EXTENSIONIN.
  SWC_SET_TABLE CONTAINER 'Extensionout' EXTENSIONOUT.
  SWC_SET_TABLE CONTAINER 'Allversions' ALLVERSIONS.
END_METHOD.

BEGIN_METHOD CHANGE1 CHANGING CONTAINER.
DATA:
      PRHEADER LIKE BAPIMEREQHEADER,
      PRHEADERX LIKE BAPIMEREQHEADERX,
      PRHEADEREXP LIKE BAPIMEREQHEADER,
      TESTRUN TYPE BAPIFLAG-BAPIFLAG,
      RETURN LIKE BAPIRET2 OCCURS 0,
      PRITEM LIKE BAPIMEREQITEMIMP OCCURS 0,
      PRITEMX LIKE BAPIMEREQITEMX OCCURS 0,
      PRITEMEXP LIKE BAPIMEREQITEM OCCURS 0,
      PRITEMSOURCE LIKE BAPIMEREQSOURCE OCCURS 0,
      PRACCOUNT LIKE BAPIMEREQACCOUNT OCCURS 0,
      PRACCOUNTPROITSEGMENT LIKE BAPIMEREQACCOUNTPROFITSEG OCCURS 0,
      PRACCOUNTX LIKE BAPIMEREQACCOUNTX OCCURS 0,
      PRADDRDELIVERY LIKE BAPIMERQADDRDELIVERY OCCURS 0,
      PRITEMTEXT LIKE BAPIMEREQITEMTEXT OCCURS 0,
      PRHEADERTEXT LIKE BAPIMEREQHEADTEXT OCCURS 0,
      EXTENSIONIN LIKE BAPIPAREX OCCURS 0,
      EXTENSIONOUT LIKE BAPIPAREX OCCURS 0,
      PRVERSION LIKE BAPIMEREQDCM OCCURS 0,
      PRVERSIONX LIKE BAPIMEREQDCMX OCCURS 0,
      ALLVERSIONS LIKE BAPIMEDCM_ALLVERSIONS OCCURS 0.
  SWC_GET_ELEMENT CONTAINER 'PrHeader' PRHEADER.
  SWC_GET_ELEMENT CONTAINER 'PrHeaderX' PRHEADERX.
  SWC_GET_ELEMENT CONTAINER 'PrVersion' PRVERSION.
  SWC_GET_ELEMENT CONTAINER 'PrVersionX' PRVERSIONX.
  SWC_GET_ELEMENT CONTAINER 'Testrun' TESTRUN.
  SWC_GET_TABLE CONTAINER 'PrItem' PRITEM.  "#EC CI_FLDEXT_OK
  SWC_GET_TABLE CONTAINER 'PrItemX' PRITEMX.
  SWC_GET_TABLE CONTAINER 'PrAccount' PRACCOUNT.
  SWC_GET_TABLE CONTAINER 'PrAccountProitSegment' PRACCOUNTPROITSEGMENT.
  SWC_GET_TABLE CONTAINER 'PrAccountX' PRACCOUNTX.
  SWC_GET_TABLE CONTAINER 'PrAddrDelivery' PRADDRDELIVERY.
  SWC_GET_TABLE CONTAINER 'PrItemText' PRITEMTEXT.
  SWC_GET_TABLE CONTAINER 'PrHeaderText' PRHEADERTEXT.
  SWC_GET_TABLE CONTAINER 'Extensionin' EXTENSIONIN.
  SWC_GET_TABLE CONTAINER 'AllVersions' ALLVERSIONS.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
  CALL FUNCTION 'BAPI_PR_CHANGE'"#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
    EXPORTING
      NUMBER = OBJECT-KEY-NUMBER
      PRHEADER = PRHEADER
      PRHEADERX = PRHEADERX
      TESTRUN = TESTRUN
    IMPORTING
      PRHEADEREXP = PRHEADEREXP
    TABLES
      PRHEADERTEXT = PRHEADERTEXT
      EXTENSIONIN = EXTENSIONIN
      EXTENSIONOUT = EXTENSIONOUT
      ALLVERSIONS = ALLVERSIONS
      PRITEMTEXT = PRITEMTEXT
      PRADDRDELIVERY = PRADDRDELIVERY
      PRACCOUNTX = PRACCOUNTX
      PRACCOUNTPROITSEGMENT = PRACCOUNTPROITSEGMENT
      PRACCOUNT = PRACCOUNT
      PRITEMSOURCE = PRITEMSOURCE
      PRITEMEXP = PRITEMEXP
      PRITEMX = PRITEMX
      PRITEM = PRITEM
      PRVERSION = PRVERSION
      PRVERSIONX = PRVERSIONX
      RETURN = RETURN
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
  SWC_SET_ELEMENT CONTAINER 'PrHeaderExp' PRHEADEREXP.
  SWC_SET_TABLE CONTAINER 'Return' RETURN.
  SWC_SET_TABLE CONTAINER 'PrItemExp' PRITEMEXP. "#EC CI_FLDEXT_OK
  SWC_SET_TABLE CONTAINER 'PrItemSource' PRITEMSOURCE.
  SWC_SET_TABLE CONTAINER 'PrAccount' PRACCOUNT.
  SWC_SET_TABLE CONTAINER 'PrAddrDelivery' PRADDRDELIVERY.
  SWC_SET_TABLE CONTAINER 'PrItemText' PRITEMTEXT.
  SWC_SET_TABLE CONTAINER 'PrHeaderText' PRHEADERTEXT.
  SWC_SET_TABLE CONTAINER 'Extensionout' EXTENSIONOUT.
  SWC_SET_TABLE CONTAINER 'AllVersions' ALLVERSIONS.
END_METHOD.

BEGIN_METHOD GETDETAIL1 CHANGING CONTAINER.
DATA:
      ACCOUNTASSIGNMENT TYPE BAPIMMPARA-SELECTION,
      ITEMTEXT TYPE BAPIMMPARA-SELECTION,
      HEADERTEXT TYPE BAPIMMPARA-SELECTION,
      VERSION TYPE BAPIMMPARA-SELECTION,
      DELIVERYADDRESS TYPE BAPIMMPARA-SELECTION,
      RETURN LIKE BAPIRET2 OCCURS 0,
      PRITEM LIKE BAPIMEREQITEM OCCURS 0,
      PRACCOUNT LIKE BAPIMEREQACCOUNT OCCURS 0,
      PRADDRDELIVERY LIKE BAPIMERQADDRDELIVERY OCCURS 0,
      PRITEMTEXT LIKE BAPIMEREQITEMTEXT OCCURS 0,
      PRHEADERTEXT LIKE BAPIMEREQHEADTEXT OCCURS 0,
      EXTENSIONOUT LIKE BAPIPAREX OCCURS 0,
      ALLVERSIONS LIKE BAPIMEDCM_ALLVERSIONS OCCURS 0,
      PRHEADER LIKE BAPIMEREQHEADER.
  SWC_GET_ELEMENT CONTAINER 'AccountAssignment' ACCOUNTASSIGNMENT.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO ACCOUNTASSIGNMENT.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'ItemText' ITEMTEXT.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO ITEMTEXT.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'HeaderText' HEADERTEXT.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO HEADERTEXT.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'Version' VERSION.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO VERSION.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'DeliveryAddress' DELIVERYADDRESS.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO DELIVERYADDRESS.
  ENDIF.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
  CALL FUNCTION 'BAPI_PR_GETDETAIL'"#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
    EXPORTING
      NUMBER = OBJECT-KEY-NUMBER
      ACCOUNT_ASSIGNMENT = ACCOUNTASSIGNMENT
      ITEM_TEXT = ITEMTEXT
      HEADER_TEXT = HEADERTEXT
      DELIVERY_ADDRESS = DELIVERYADDRESS
      VERSION = VERSION
    IMPORTING
      PRHEADER = PRHEADER
    TABLES
      ALLVERSIONS = ALLVERSIONS
      EXTENSIONOUT = EXTENSIONOUT
      PRHEADERTEXT = PRHEADERTEXT
      PRITEMTEXT = PRITEMTEXT
      PRADDRDELIVERY = PRADDRDELIVERY
      PRACCOUNT = PRACCOUNT
      PRITEM = PRITEM
      RETURN = RETURN
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
  SWC_SET_TABLE CONTAINER 'Return' RETURN.
  SWC_SET_TABLE CONTAINER 'PrItem' PRITEM.  "#EC CI_FLDEXT_OK
  SWC_SET_TABLE CONTAINER 'PrAccount' PRACCOUNT.
  SWC_SET_TABLE CONTAINER 'PrAddrDelivery' PRADDRDELIVERY.
  SWC_SET_TABLE CONTAINER 'PrItemText' PRITEMTEXT.
  SWC_SET_TABLE CONTAINER 'PrHeaderText' PRHEADERTEXT.
  SWC_SET_TABLE CONTAINER 'Extensionout' EXTENSIONOUT.
  SWC_SET_TABLE CONTAINER 'AllVersions' ALLVERSIONS.
  SWC_SET_ELEMENT CONTAINER 'PrHeader' PRHEADER.
END_METHOD.

BEGIN_METHOD CONFIRM CHANGING CONTAINER.
DATA: lv_banfn like object-key-number,
      CONFIRM(255).
  SWC_SET_ELEMENT CONTAINER RESULT CONFIRM.

  select banfn from eban into lv_banfn
                         where banfn eq object-key-number.
  endselect.
  if sy-subrc ne 0.
    exit_object_not_found.
  endif.
END_METHOD.

BEGIN_METHOD GETITEMS CHANGING CONTAINER.
DATA:
      PREQNO TYPE BAPIEBAN-PREQ_NO,
      PURGROUP TYPE BAPIEBAN-PUR_GROUP,
      PREQNAME TYPE BAPIEBAN-PREQ_NAME,
      PREQDATE TYPE BAPIEBAN-PREQ_DATE,
      MATERIAL TYPE BAPIEBAN-MATERIAL,
      MATGRP TYPE BAPIEBAN-MAT_GRP,
      TRACKINGNO TYPE BAPIEBAN-TRACKINGNO,
      PLANT TYPE BAPIEBAN-PLANT,
      DOCTYPE TYPE BAPIEBAN-DOC_TYPE,
      DELIVDATE TYPE BAPIEBAN-DELIV_DATE,
      RELDATE TYPE BAPIEBAN-REL_DATE,
      SHORTTEXT TYPE BAPIEBAN-SHORT_TEXT,
      ASSIGNEDITEMS TYPE BAPIMMPARA-SELECTION,
      CLOSEDITEMS TYPE BAPIMMPARA-SELECTION,
      DELETEDITEMS TYPE BAPIMMPARA-SELECTION,
      PARTIALLYORDEREDITEMS TYPE BAPIMMPARA-SELECTION,
      ONLYNONMATERIALITEMS TYPE BAPIMMPARA-SELECTION,
      OPENITEMS TYPE BAPIMMPARA-SELECTION,
      REQUISITIONITEMS LIKE BAPIEBANC OCCURS 0,
      RETURN LIKE BAPIRETURN OCCURS 0,
      MATERIALEVG LIKE BAPIMGVMATNR.
  SWC_GET_ELEMENT CONTAINER 'PreqNo' PREQNO.
  SWC_GET_ELEMENT CONTAINER 'PurGroup' PURGROUP.
  SWC_GET_ELEMENT CONTAINER 'PreqName' PREQNAME.
  SWC_GET_ELEMENT CONTAINER 'PreqDate' PREQDATE.
  SWC_GET_ELEMENT CONTAINER 'Material' MATERIAL.  "#EC CI_FLDEXT_OK
  SWC_GET_ELEMENT CONTAINER 'MatGrp' MATGRP.
  SWC_GET_ELEMENT CONTAINER 'Trackingno' TRACKINGNO.
  SWC_GET_ELEMENT CONTAINER 'Plant' PLANT.
  SWC_GET_ELEMENT CONTAINER 'DocType' DOCTYPE.
  SWC_GET_ELEMENT CONTAINER 'DelivDate' DELIVDATE.
  SWC_GET_ELEMENT CONTAINER 'RelDate' RELDATE.
  SWC_GET_ELEMENT CONTAINER 'ShortText' SHORTTEXT.
  SWC_GET_ELEMENT CONTAINER 'AssignedItems' ASSIGNEDITEMS.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO ASSIGNEDITEMS.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'ClosedItems' CLOSEDITEMS.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO CLOSEDITEMS.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'DeletedItems' DELETEDITEMS.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO DELETEDITEMS.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'PartiallyOrderedItems'
       PARTIALLYORDEREDITEMS.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO PARTIALLYORDEREDITEMS.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'OnlyNonMaterialItems' ONLYNONMATERIALITEMS.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO ONLYNONMATERIALITEMS.
  ENDIF.
  SWC_GET_ELEMENT CONTAINER 'OpenItems' OPENITEMS.
  IF SY-SUBRC <> 0.
    MOVE 'X' TO OPENITEMS.
  ENDIF.
  SWC_GET_TABLE CONTAINER 'RequisitionItems' REQUISITIONITEMS. "#EC CI_FLDEXT_OK
  SWC_GET_ELEMENT CONTAINER 'materialEVG' MATERIALEVG.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
  CALL FUNCTION 'BAPI_REQUISITION_GETITEMS'"#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
    EXPORTING
      MATERIAL_EVG = MATERIALEVG
      OPEN_ITEMS = OPENITEMS
      ONLY_NON_MATERIAL_ITEMS = ONLYNONMATERIALITEMS
      PARTIALLY_ORDERED_ITEMS = PARTIALLYORDEREDITEMS
      DELETED_ITEMS = DELETEDITEMS
      CLOSED_ITEMS = CLOSEDITEMS
      ASSIGNED_ITEMS = ASSIGNEDITEMS
      SHORT_TEXT = SHORTTEXT
      REL_DATE = RELDATE
      DELIV_DATE = DELIVDATE
      DOC_TYPE = DOCTYPE
      PLANT = PLANT
      TRACKINGNO = TRACKINGNO
      MAT_GRP = MATGRP
      MATERIAL = MATERIAL
      PREQ_DATE = PREQDATE
      PREQ_NAME = PREQNAME
      PUR_GROUP = PURGROUP
      PREQ_NO = PREQNO
    TABLES
      REQUISITION_ITEMS = REQUISITIONITEMS
      RETURN = RETURN
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
  SWC_SET_TABLE CONTAINER 'RequisitionItems' REQUISITIONITEMS.  "#EC CI_FLDEXT_OK
  SWC_SET_TABLE CONTAINER 'Return' RETURN.
END_METHOD.


BEGIN_METHOD SONEWDOCUMENTATTSENDAPI1 CHANGING CONTAINER.
DATA:
      DOCUMENTDATA LIKE SODOCCHGI1,
      PUTINOUTBOX TYPE SONV-FLAG,
      COMMITWORK TYPE SONV-FLAG,
      SENTTOALL TYPE SONV-FLAG,
      NEWOBJECTID TYPE SOFOLENTI1-OBJECT_ID,
      PACKINGLIST LIKE SOPCKLSTI1 OCCURS 0 WITH HEADER LINE,
      OBJECTHEADER LIKE SOLISTI1 OCCURS 0,
      CONTENTSBIN LIKE SOLISTI1 OCCURS 0,
      CONTENTSTXT LIKE SOLISTI1 OCCURS 0 with header line,
      CONTENTSHEX LIKE SOLIX OCCURS 0,
      OBJECTPARA LIKE SOPARAI1 OCCURS 0,
      OBJECTPARB LIKE SOPARBI1 OCCURS 0,
      RECEIVERS LIKE SOMLRECI1 OCCURS 0 with header line,
      mail_id like zbapi_agent occurs 0 with header line.

  SWC_GET_TABLE CONTAINER 'Mail_id' Mail_id.
  loop at mail_id.
    move:  mail_id-UNAME to receivers-RECEIVER,
           'B'            to receivers-REC_TYPE.
    append receivers.
  endloop.

  CONTENTSTXT-LINE = 'Rea is approved'.
  append CONTENTSTXT.

  PACKINGLIST-transf_bin = SPACE.
   PACKINGLIST-head_start = 1.
    PACKINGLIST-head_num = 0.
     PACKINGLIST-body_start = 1.
      PACKINGLIST-body_num = 1.
       PACKINGLIST-doc_type = 'RAW'.
   APPEND PACKINGLIST.

  DOCUMENTDATA-doc_size = 1.
  DOCUMENTDATA-obj_langu = sy-langu.
  DOCUMENTDATA-obj_name  = 'SAPRPT'.
  DOCUMENTDATA-obj_descr = 'Purchase Requisition workflow'.


  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA = DOCUMENTDATA
      PUT_IN_OUTBOX = 'X'
      COMMIT_WORK = 'X'
    IMPORTING
      SENT_TO_ALL = SENTTOALL
      NEW_OBJECT_ID = NEWOBJECTID
    TABLES
      RECEIVERS = RECEIVERS
      OBJECT_PARB = OBJECTPARB
      OBJECT_PARA = OBJECTPARA
      CONTENTS_HEX = CONTENTSHEX
      CONTENTS_TXT = CONTENTSTXT
      CONTENTS_BIN = CONTENTSBIN
      OBJECT_HEADER = OBJECTHEADER
      PACKING_LIST = PACKINGLIST.
  CASE SY-SUBRC.
  ENDCASE.
  SWC_SET_ELEMENT CONTAINER 'SentToAll' SENTTOALL.
  SWC_SET_ELEMENT CONTAINER 'NewObjectId' NEWOBJECTID.
  SWC_SET_TABLE CONTAINER 'PackingList' PACKINGLIST.
  SWC_SET_TABLE CONTAINER 'ObjectHeader' OBJECTHEADER.
  SWC_SET_TABLE CONTAINER 'ContentsBin' CONTENTSBIN.
  SWC_SET_TABLE CONTAINER 'ContentsTxt' CONTENTSTXT.
  SWC_SET_TABLE CONTAINER 'ContentsHex' CONTENTSHEX.
  SWC_SET_TABLE CONTAINER 'ObjectPara' OBJECTPARA.
  SWC_SET_TABLE CONTAINER 'ObjectParb' OBJECTPARB.
  SWC_SET_TABLE CONTAINER 'Receivers' RECEIVERS.

   data: g_OBJTYPE  like   SWETYPECOU-OBJTYPE value 'YBUS2105',
         g_OBJKEY   like         SWEINSTCOU-OBJKEY,
         g_EVENT    like   SWETYPECOU-EVENT VALUE 'MAIL_SENT'.
   MOVE OBJECT-KEY-NUMBER TO g_OBJKEY.
  call function 'SWE_EVENT_CREATE'
    exporting
      objtype                       = g_OBJTYPE
      objkey                        = g_OBJKEY
      event                         =  g_EVENT
*     CREATOR                       = ' '
*     TAKE_WORKITEM_REQUESTER       = ' '
*     START_WITH_DELAY              = ' '
*     START_RECFB_SYNCHRON          = ' '
*     NO_COMMIT_FOR_QUEUE           = ' '
*     DEBUG_FLAG                    = ' '
*     NO_LOGGING                    = ' '
*     IDENT                         =
*   IMPORTING
*     EVENT_ID                      =
*     RECEIVER_COUNT                =
*   TABLES
*     EVENT_CONTAINER               =
    EXCEPTIONS
     OBJTYPE_NOT_FOUND             = 1
      OTHERS                        = 2
            .
  if sy-subrc EQ 0.
    COMMIT WORK.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

END_METHOD.

BEGIN_METHOD ZMMPRUSERFETCH CHANGING CONTAINER.
DATA:
      RELCODE TYPE BAPIMMPARA-REL_CODE,
      NUMBER TYPE BAPI2009OB-PREQ_NO,
      NOCOMMITWORK TYPE BAPIFLAG-BAPIFLAG,
      RETURN LIKE BAPIRETURN OCCURS 0,
      LTAGENT LIKE ZBAPI_AGENT OCCURS 0.
  SWC_GET_ELEMENT CONTAINER 'RelCode' RELCODE.
  SWC_GET_ELEMENT CONTAINER 'Number' NUMBER.
  SWC_GET_ELEMENT CONTAINER 'NoCommitWork' NOCOMMITWORK.
  IF SY-SUBRC <> 0.
    MOVE SPACE TO NOCOMMITWORK.
  ENDIF.
* if RELCODE eq '01'.
*   relcode = '02'.
*relcode = '02'.
*case RELCODE.
*   when '02'.
*  when 'c3'.
* when 'l3'.
* endcase.


  SWC_GET_TABLE CONTAINER 'Return' RETURN.
  SWC_GET_TABLE CONTAINER 'LtAgent' LTAGENT.
  CALL FUNCTION 'ZMM_PR_USER_FETCH'
    EXPORTING
      REL_CODE = RELCODE
      NUMBER = NUMBER
      NO_COMMIT_WORK = NOCOMMITWORK
    TABLES
      RETURN = RETURN
      LT_AGENT = LTAGENT
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
  SWC_SET_TABLE CONTAINER 'Return' RETURN.
  SWC_SET_TABLE CONTAINER 'LtAgent' LTAGENT.
END_METHOD.

BEGIN_METHOD CHANGE_ME5N CHANGING CONTAINER.
DATA:
      RELCODE TYPE BAPIMMPARA-REL_CODE,
      NUMBER TYPE BAPI2009OB-PREQ_NO.


  SWC_GET_ELEMENT CONTAINER 'Relcode' Relcode.
  SWC_GET_ELEMENT CONTAINER 'Number' NUMBER.
  SET PARAMETER ID 'BAN' FIELD NUMBER.
  SET PARAMETER ID 'FAB' FIELD RELCODE.
  CALL TRANSACTION 'ME54N' AND SKIP FIRST SCREEN.
END_METHOD.

*--- INCLUDE: %_CABAP ---*
type-pool ABAP .


************************************************************************
* WARNING!!!!! DO NOT CHANGE ANY OF THE FOLLOWING TYPES! WARNING !!!!! *
* !!!!!!!! All types have to synchronized with ABAP kernel types !!!!! *
************************************************************************

************************************************************************
* NAMES WITH PREFIX "ABAP_" DECLARED IN THE DDIC
* MUST NOT BE REDEFINED HERE!
************************************************************************
* abap_encod
* abap_endia
* abap_repl

************************************************************************
**** GENERAL ***********************************************************
types:
  ABAP_BOOL type C length 1.
* constants for abap_bool
constants:
  ABAP_TRUE      type ABAP_BOOL value 'X',
  ABAP_FALSE     type ABAP_BOOL value ' ',
  ABAP_UNDEFINED type ABAP_BOOL value '-',
  ABAP_ON        type ABAP_BOOL value 'X',
  ABAP_OFF       type ABAP_BOOL value ' '.


************************************************************************
**** DESCRIBE   ********************************************************
constants:
  ABAP_MAX_ABS_TYPE_NAME_LN   type I value        200,
  ABAP_MAX_CLASS_NAME_LN      type I value         30,
  ABAP_MAX_INTF_NAME_LN       type I value         30,
  ABAP_MAX_COMP_NAME_LN       type I value         30,
  ABAP_MAX_KEY_NAME_LN        type I value        255,
  ABAP_MAX_CLASS_COMP_NAME_LN type I value         61,
  ABAP_MAX_EDIT_MASK_LN       type I value          7,
  ABAP_MAX_HELP_ID_LN         type I value         62,
  ABAP_MAX_DB_STRING_LN       type I value  536870912,
  ABAP_MAX_DB_RAWSTRING_LN    type I value 1073741824.



types:
* type kinds
  ABAP_TYPEKIND     type C length 1, " check CL_ABAP_TYPEDESCR for values
  ABAP_TYPECATEGORY type C length 1, " check CL_ABAP_TYPEDESCR for values
  ABAP_TYPEPROPKIND type C length 1,
  ABAP_STRUCTKIND   type C length 1,
  ABAP_TABLEKIND    type C length 1,
  ABAP_KEYDEFKIND   type C length 1,
  ABAP_CLASSKIND    type C length 1,
  ABAP_INTFKIND     type C length 1,
  ABAP_PARMKIND     type C length 1,
* misc
  ABAP_EDITMASK     type C length ABAP_MAX_EDIT_MASK_LN,
  ABAP_HELPID       type C length ABAP_MAX_HELP_ID_LN,
  ABAP_VISIBILITY   type C length 1,
* name types
  ABAP_TYPENAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_ABSTYPENAME  type C length ABAP_MAX_ABS_TYPE_NAME_LN,
  ABAP_COMPNAME     type C length ABAP_MAX_COMP_NAME_LN,
  ABAP_KEYNAME      type C length ABAP_MAX_KEY_NAME_LN,
  ABAP_KEYCOMPNAME  type          ABAP_KEYNAME,
  ABAP_CLASSNAME    type C length ABAP_MAX_CLASS_NAME_LN,
  ABAP_INTFNAME     type C length ABAP_MAX_INTF_NAME_LN,
  ABAP_ATTRNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_METHNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_EVNTNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_PARMNAME     type C length ABAP_MAX_COMP_NAME_LN,
  ABAP_EXCPNAME     type C length ABAP_MAX_COMP_NAME_LN,
* structure component description
  begin of ABAP_COMPDESCR,
    LENGTH    type I,
    DECIMALS  type I,
    TYPE_KIND type ABAP_TYPEKIND,
    NAME      type ABAP_COMPNAME,
  end of ABAP_COMPDESCR,
  ABAP_COMPDESCR_TAB type standard table of ABAP_COMPDESCR
                     with key NAME,
  begin of ABAP_COMPONENTDESCR,
    NAME       type STRING,
    TYPE       type ref to CL_ABAP_DATADESCR,
    AS_INCLUDE type ABAP_BOOL,
    SUFFIX     type STRING,
  end of ABAP_COMPONENTDESCR,
  ABAP_COMPONENT_TAB type standard table of ABAP_COMPONENTDESCR
                     with key NAME,
  begin of ABAP_SIMPLE_COMPONENTDESCR,
    NAME type STRING,
    TYPE type ref to CL_ABAP_DATADESCR,
  end of ABAP_SIMPLE_COMPONENTDESCR,
  ABAP_COMPONENT_SYMBOL_TAB type hashed table of ABAP_SIMPLE_COMPONENTDESCR
                            with unique key NAME,
  ABAP_COMPONENT_VIEW_TAB   type standard table of ABAP_SIMPLE_COMPONENTDESCR
                          with key NAME,
* key description of tables
  begin of ABAP_KEYDESCR,
    NAME type ABAP_KEYNAME,
  end of ABAP_KEYDESCR,
  ABAP_KEYDESCR_TAB type standard table of ABAP_KEYDESCR
                    with key NAME,
* description of all secondary keys and primary key of tables
  begin of ABAP_TABLE_KEYCOMPDESCR,
    NAME type ABAP_KEYCOMPNAME,
  end of ABAP_TABLE_KEYCOMPDESCR,
  begin of ABAP_TABLE_KEYDESCR,
    COMPONENTS  type standard table of ABAP_TABLE_KEYCOMPDESCR
                         with non-unique default key
                         initial size 4,
    NAME        type ABAP_COMPNAME,
    IS_PRIMARY  type ABAP_BOOL,
    ACCESS_KIND type ABAP_TABLEKIND,
    IS_UNIQUE   type ABAP_BOOL,
    KEY_KIND    type ABAP_KEYDEFKIND,
  end of ABAP_TABLE_KEYDESCR,
  ABAP_TABLE_KEYDESCR_TAB type standard table of ABAP_TABLE_KEYDESCR
                          with non-unique key NAME
                          initial size 2,
* map for mapping table key names to table key aliases
  begin of ABAP_KEY_ALIAS_PAIR,
    NAME  type ABAP_COMPNAME,
    ALIAS type ABAP_COMPNAME,
  end of ABAP_KEY_ALIAS_PAIR,
  ABAP_KEY_ALIAS_MAP type sorted table of ABAP_KEY_ALIAS_PAIR
                          with non-unique key NAME
                          with unique sorted key KEY_ALIAS components ALIAS
                          initial size 2,
* parameter description (methods and event)
  begin of ABAP_PARMDESCR,
    LENGTH      type I,
    DECIMALS    type I,
    TYPE_KIND   type ABAP_TYPEKIND,
    NAME        type ABAP_PARMNAME,
    PARM_KIND   type ABAP_PARMKIND,
    BY_VALUE    type ABAP_BOOL,
    IS_OPTIONAL type ABAP_BOOL,
  end of ABAP_PARMDESCR,
  ABAP_PARMDESCR_TAB type standard table of ABAP_PARMDESCR
                     with key NAME,
* exception description (method and event)
  begin of ABAP_EXCPDESCR,
    NAME         type ABAP_EXCPNAME,
    IS_RESUMABLE type ABAP_BOOL, "abap_false for old exceptions,
    "abap_true or abap_false for class based exceptions
  end of ABAP_EXCPDESCR,
  ABAP_EXCPDESCR_TAB type standard table of ABAP_EXCPDESCR
                     with key NAME,
* exposed and access friend description
  begin of ABAP_FRNDDESCR,
    NAME type ABAP_CLASSNAME,
  end of ABAP_FRNDDESCR,
  ABAP_FRNDDESCR_TAB type standard table of ABAP_FRNDDESCR
                     with key NAME,
* included interfaces / interface implementation description
  begin of ABAP_INTFDESCR,
    NAME         type ABAP_INTFNAME,
    IS_INHERITED type ABAP_BOOL,
  end of ABAP_INTFDESCR,
  ABAP_INTFDESCR_TAB type standard table of ABAP_INTFDESCR
                     with key NAME,
* type definition inside class / interface
  begin of ABAP_TYPEDEF,
    NAME         type ABAP_TYPENAME,
    ALIAS_FOR    type ABAP_TYPENAME,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
  end of ABAP_TYPEDEF,
  ABAP_TYPEDEF_TAB type standard table of ABAP_TYPEDEF
                     with key NAME,
* attribute description
  begin of ABAP_ATTRDESCR,
    LENGTH       type I,
    DECIMALS     type I,
    NAME         type ABAP_ATTRNAME,
    TYPE_KIND    type ABAP_TYPEKIND,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
    IS_CLASS     type ABAP_BOOL,
    IS_CONSTANT  type ABAP_BOOL,
    IS_VIRTUAL   type ABAP_BOOL,
    IS_READ_ONLY type ABAP_BOOL,
    ALIAS_FOR    type ABAP_ATTRNAME,
  end of ABAP_ATTRDESCR,
  ABAP_ATTRDESCR_TAB type standard table of ABAP_ATTRDESCR
                     with key NAME,
* method description
  begin of ABAP_METHDESCR,
    PARAMETERS       type ABAP_PARMDESCR_TAB,
    EXCEPTIONS       type ABAP_EXCPDESCR_TAB,
    NAME             type ABAP_METHNAME,
    FOR_EVENT        type ABAP_EVNTNAME,
    OF_CLASS         type ABAP_CLASSNAME,
    VISIBILITY       type ABAP_VISIBILITY,
    IS_INTERFACE     type ABAP_BOOL,
    IS_INHERITED     type ABAP_BOOL,
    IS_REDEFINED     type ABAP_BOOL,
    IS_ABSTRACT      type ABAP_BOOL,
    IS_FINAL         type ABAP_BOOL,
    IS_CLASS         type ABAP_BOOL,
    ALIAS_FOR        type ABAP_METHNAME,
    IS_RAISING_EXCPS type ABAP_BOOL, "abap_true if method declaration has a raising clause
    "abap_false otherwise
  end of ABAP_METHDESCR,
  ABAP_METHDESCR_TAB type standard table of ABAP_METHDESCR
                     with key NAME,
* event description
  begin of ABAP_EVNTDESCR,
    PARAMETERS   type ABAP_PARMDESCR_TAB,
    NAME         type ABAP_EVNTNAME,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
    IS_CLASS     type ABAP_BOOL,
    ALIAS_FOR    type ABAP_EVNTNAME,
  end of ABAP_EVNTDESCR,
  ABAP_EVNTDESCR_TAB type standard table of ABAP_EVNTDESCR
                     with key NAME,

* table for get_friend_types
  ABAP_FRNDTYPES_TAB type standard table of ref to CL_ABAP_TYPEDESCR
                     with key TABLE_LINE.


************************************************************************
************* DYNAMIC CALL FUNCTION ************************************
types:
* CALL FUNCTION ... PARAMETER-TABLE
  begin of ABAP_FUNC_PARMBIND,
    VALUE     type ref to DATA,
    TABLES_WA type ref to DATA,
    KIND      type I,
    NAME      type ABAP_PARMNAME,
  end of ABAP_FUNC_PARMBIND,
  ABAP_FUNC_PARMBIND_TAB type sorted table of ABAP_FUNC_PARMBIND
                         with unique key KIND NAME,
* CALL FUNCTION ... EXCEPTION-TABLE
  begin of ABAP_FUNC_EXCPBIND,
    MESSAGE type ref to DATA,
    VALUE   type I,
    NAME    type ABAP_EXCPNAME,
  end of ABAP_FUNC_EXCPBIND,
  ABAP_FUNC_EXCPBIND_TAB type hashed table of ABAP_FUNC_EXCPBIND
                         with unique key NAME.

constants:
  ABAP_FUNC_EXPORTING type ABAP_FUNC_PARMBIND-KIND value 10,
  ABAP_FUNC_IMPORTING type ABAP_FUNC_PARMBIND-KIND value 20,
  ABAP_FUNC_TABLES    type ABAP_FUNC_PARMBIND-KIND value 30,
  ABAP_FUNC_CHANGING  type ABAP_FUNC_PARMBIND-KIND value 40.

************************************************************************
************* DYNAMIC INVOKE *******************************************
types:
* PARAMETER-TABLE
  begin of ABAP_PARMBIND,
    NAME  type ABAP_PARMNAME,
    KIND  type ABAP_PARMKIND,
    VALUE type ref to DATA,
  end of ABAP_PARMBIND,
  ABAP_PARMBIND_TAB type hashed table of ABAP_PARMBIND
                    with unique key NAME,
* EXCEPTION-TABLE
  begin of ABAP_EXCPBIND,
    NAME  type ABAP_EXCPNAME,
    VALUE type I,
  end of ABAP_EXCPBIND,
  ABAP_EXCPBIND_TAB type hashed table of ABAP_EXCPBIND
                    with unique key NAME.


************************************************************************
**** Types for CL_ABAP_CHAR_UTILITIES **********************************
types:
  ABAP_CHAR1(1)           type C,
  ABAP_CR_LF(2)           type C,
  ABAP_BYTE_ORDER_MARK(2) type X,
  ABAP_BYTE_ORDER_UTF8(3) type X.


************************************************************************
**** CONVERSION ********************************************************
types:
  ABAP_ENCODING type ABAP_ENCOD,
  ABAP_ENDIAN   type ABAP_ENDIA.

************************************************************************
**** CALL TRANSFORMATION ***********************************************

* PARAMETER TABLE
types:
  ABAP_TRANS_PARMNAME  type STRING,
  ABAP_TRANS_PARMVALUE type STRING,
  ABAP_TRANS_PARMREF   type ref to DATA.

types:
  begin of ABAP_TRANS_PARMBIND,
    NAME  type ABAP_TRANS_PARMNAME,
    VALUE type ABAP_TRANS_PARMVALUE,
  end of ABAP_TRANS_PARMBIND,
  begin of ABAP_TRANS_PARM_OBJ_BIND,
    NAME  type ABAP_TRANS_PARMNAME,
    VALUE type ABAP_TRANS_PARMREF,
  end of ABAP_TRANS_PARM_OBJ_BIND.

types:
  ABAP_TRANS_PARMBIND_TAB
      type standard table of ABAP_TRANS_PARMBIND with key NAME,
  ABAP_TRANS_PARM_OBJ_BIND_TAB
      type sorted table of ABAP_TRANS_PARM_OBJ_BIND with unique key NAME.

* OBJECT TABLE
types:
  ABAP_TRANS_OBJNAME type STRING.

types:
  begin of ABAP_TRANS_OBJBIND,
    NAME  type ABAP_TRANS_OBJNAME,
    VALUE type ref to OBJECT,
  end of ABAP_TRANS_OBJBIND.

types:
  ABAP_TRANS_OBJBIND_TAB
      type standard table of ABAP_TRANS_OBJBIND with key NAME.

* SOURCE TABLE
types:
  ABAP_TRANS_SRCNAME type STRING.

types:
  begin of ABAP_TRANS_SRCBIND,
    NAME  type ABAP_TRANS_SRCNAME,
    VALUE type ref to DATA,
  end of ABAP_TRANS_SRCBIND.

types:
  ABAP_TRANS_SRCBIND_TAB
       type standard table of ABAP_TRANS_SRCBIND with key NAME,
  ABAP_TRANS_SRCBIND_TAB_SORTED
       type sorted table of ABAP_TRANS_SRCBIND with unique key NAME.

* RESULT TABLE
types:
  ABAP_TRANS_RESNAME type STRING.

types:
  begin of ABAP_TRANS_RESBIND,
    NAME  type ABAP_TRANS_RESNAME,
    VALUE type ref to DATA,
  end of ABAP_TRANS_RESBIND.

types:
  ABAP_TRANS_RESBIND_TAB
       type standard table of ABAP_TRANS_RESBIND with key NAME,
  ABAP_TRANS_RESBIND_TAB_SORTED
       type sorted table of ABAP_TRANS_RESBIND with unique key NAME.

*--- INCLUDE: CL_ABAP_DATADESCR=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_DATADESCR and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_ABAP_TYPEDESCR=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_TYPEDESCR and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_SWO_KEY_HANDLING===========CU ---*
class CL_SWO_KEY_HANDLING definition
  public
  final
  create public .

public section.

  class-methods GET_INSTANCE
    returning
      value(RESULT) type ref to IF_SWO_KEY_HANDLING .

*--- INCLUDE: CX_ROOT=======================CU ---*
class cx_root definition
  public
  abstract
  create public.

  public section.
    interfaces if_message.
    interfaces if_serializable_object.

    aliases get_longtext
      for if_message~get_longtext.
    aliases get_text
      for if_message~get_text.

    constants cx_root type sotr_conc value '16AA9A3937A9BB56E10000000A11447B'. "#EC NOTEXT
    data textid type sotr_conc read-only.
    data previous type ref to cx_root read-only.
    data kernel_errid type s380errid read-only.
    data is_resumable type abap_bool read-only.

    methods constructor
      importing
        !textid like textid optional
        !previous like previous optional.

    methods get_source_position
      exporting
        !program_name type syrepid
        !include_name type syrepid
        !source_line type i.


*--- INCLUDE: CX_STATIC_CHECK===============CU ---*
class CX_STATIC_CHECK definition
  public
  inheriting from CX_ROOT
  abstract
  create public .

*"* public components of class CX_STATIC_CHECK
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_SWO_APPLICATION_ERROR======CU ---*
class CX_SWO_APPLICATION_ERROR definition
  public
  inheriting from CX_SWO_RUNTIME_ERROR
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !VERSION type AS4VERS optional
      !ERROR_TYPE type SWO_ERRTYP default CO_ERROR_TYPE-SYSTEM_ERROR
      !EXCEPTION type SWOTRETURN optional
      !RFC_ERROR_V1 type CHAR50 optional
      !RFC_ERROR_V2 type CHAR50 optional
      !RFC_ERROR_V3 type CHAR50 optional
      !RFC_ERROR_V4 type CHAR50 optional .

  methods GET_SYSTEM_ERROR
    redefinition .

*--- INCLUDE: CX_SWO_RUNTIME_ERROR==========CU ---*
class CX_SWO_RUNTIME_ERROR definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of key_version_not_supported,
        msgid type symsgid value 'OL',
        msgno type symsgno value '865',
        attr1 type scx_attrname value 'VERSION',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of key_version_not_supported .
  constants:
    begin of invalid_key,
        msgid type symsgid value 'OL',
        msgno type symsgno value '866',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of invalid_key .
  constants:
    begin of rfc_system_error,
        msgid type symsgid value 'OL',
        msgno type symsgno value '802',
        attr1 type scx_attrname value 'RFC_ERROR_V1',
        attr2 type scx_attrname value 'RFC_ERROR_V2',
        attr3 type scx_attrname value 'RFC_ERROR_V3',
        attr4 type scx_attrname value 'RFC_ERROR_V4',
      end of rfc_system_error .
  constants:
    begin of rfc_communication_error,
        msgid type symsgid value 'OL',
        msgno type symsgno value '812',
        attr1 type scx_attrname value 'RFC_ERROR_V1',
        attr2 type scx_attrname value 'RFC_ERROR_V2',
        attr3 type scx_attrname value 'RFC_ERROR_V3',
        attr4 type scx_attrname value 'RFC_ERROR_V4',
      end of rfc_communication_error .
  constants:
    begin of rfc_resource_error,
        msgid type symsgid value 'OL',
        msgno type symsgno value '857',
        attr1 type scx_attrname value 'RFC_ERROR_V1',
        attr2 type scx_attrname value 'RFC_ERROR_V2',
        attr3 type scx_attrname value 'RFC_ERROR_V3',
        attr4 type scx_attrname value 'RFC_ERROR_V4',
      end of rfc_resource_error .
  constants:
    begin of logical_keys_not_supported,
        msgid type symsgid value 'OL',
        msgno type symsgno value '867',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of logical_keys_not_supported .
  constants:
    begin of NOT_AUTHORIZED_FOR_LOGSYS,
      msgid type symsgid value 'OL',
      msgno type symsgno value '868',
      attr1 type scx_attrname value 'USER',
      attr2 type scx_attrname value 'OBJECT_TYPE',
      attr3 type scx_attrname value 'LOGSYS',
      attr4 type scx_attrname value '',
    end of NOT_AUTHORIZED_FOR_LOGSYS .
  constants:
    begin of NOT_AUTHORIZED_FOR_RFC,
      msgid type symsgid value 'OL',
      msgno type symsgno value '869',
      attr1 type scx_attrname value 'USER',
      attr2 type scx_attrname value 'OBJECT_TYPE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOT_AUTHORIZED_FOR_RFC .
  constants:
    begin of co_error_type,
        temporary_error   type swo_errtyp value '0',
        application_error type swo_errtyp value '1',
        system_error      type swo_errtyp value '2',
      end of co_error_type .
  data VERSION type AS4VERS .
  data ERROR_TYPE type SWO_ERRTYP value CO_ERROR_TYPE-SYSTEM_ERROR ##NO_TEXT.
  data EXCEPTION type SWOTRETURN .
  data RFC_ERROR_V1 type CHAR50 .
  data RFC_ERROR_V2 type CHAR50 .
  data RFC_ERROR_V3 type CHAR50 .
  data RFC_ERROR_V4 type CHAR50 .
  data OBJECT_TYPE type TOJTB-NAME .
  data LOGSYS type LOGSYS .
  data USER type SYUNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !VERSION type AS4VERS optional
      !ERROR_TYPE type SWO_ERRTYP default CO_ERROR_TYPE-SYSTEM_ERROR
      !EXCEPTION type SWOTRETURN optional
      !RFC_ERROR_V1 type CHAR50 optional
      !RFC_ERROR_V2 type CHAR50 optional
      !RFC_ERROR_V3 type CHAR50 optional
      !RFC_ERROR_V4 type CHAR50 optional
      !OBJECT_TYPE type TOJTB-NAME optional
      !LOGSYS type LOGSYS optional
      !USER type SYUNAME optional .
  methods GET_SYSTEM_ERROR
    returning
      value(RESULT) type SWOTRETURN .
  class-methods RAISE_EXCEPTION
    importing
      !I_RETURN_VALUE type SWOTRETURN
    raising
      CX_SWO_RUNTIME_ERROR .

*--- INCLUDE: IF_MESSAGE====================IU ---*
*"* components of interface IF_MESSAGE
interface IF_MESSAGE
  public .


  methods GET_TEXT
    returning
      value(RESULT) type STRING .
  methods GET_LONGTEXT
    importing
      value(PRESERVE_NEWLINES) type ABAP_BOOL optional
    returning
      value(RESULT) type STRING .
endinterface.

*--- INCLUDE: IF_SERIALIZABLE_OBJECT========IU ---*
*"* components of interface IF_SERIALIZABLE_OBJECT
interface IF_SERIALIZABLE_OBJECT
  public .

endinterface.

*--- INCLUDE: IF_SWO_KEY_CONVERTER==========IU ---*
interface if_swo_key_converter
  public .

  constants:
     "! Specify that version of an object key or a container is the currently implemented version
     co_current_key_version   type swo_key_vers value '9999',

     "! Specify that the version of an object key is not explicitly given
     co_not_specified         type swo_key_vers value if_swo_key_handling=>co_not_specified, "'9998'

     "! Specify that the format of a container adheres to the version of the object key
     co_version_of_object_key type swo_key_vers value '9997'.

  types: ty_container type standard table of swcont with default key.

  methods:
    "! Convert a key into the current version
    "!
    "! @parameter i_old_key_version      | Version of the key to be converted
    "! @parameter i_old_key              | Key to be converted
    "! @parameter r_current_key          | Representation of the key in the current key version
    "! @raising cx_swo_application_error | Is raised if key cannot be converted
    convert_key
      importing
                !i_old_key_version   type as4vers
                !i_old_key           type swo_shortkey
      returning
                value(r_current_key) type swo_shortkey
      raising   cx_swo_application_error,

    "! Compute a key field value out of BAPI parameters. If the length of a (logical) key field
    "! is extended, BAPIs that have the key as parameters get an additional parameter that is
    "! mapped to the new key field. Callers can either use the old parameter that was used for the
    "! original key field, or the new parameter that corresponds to the current key field.
    "! This method shall compute the correct value of the key field based on the passed parameter
    "! values.
    "!
    "! @parameter i_key_field           | Name of the key field
    "! @parameter i_old_key_field_value | Value from the BAPI parameter for the old value
    "! @parameter i_new_key_field_value | Value from the BAPI parameter for the new value
    "! @parameter r_current_value       | Value of the key field in the current (logical) key
    "! @raising cx_swo_application_error | Is raised if key cannot be converted
    get_key_field_from_parameters
      importing
                !i_key_field               type swotrk-keyfield
                !i_old_key_field_value     type clike
                !i_new_key_field_value     type clike
      returning
                value(r_current_value) type swo_typeid_long
      raising   cx_swo_application_error,

    "! Convert a current key into an older version
    "!
    "! @parameter i_current_key          | Key with current version
    "! @parameter i_old_key_version      | Version into which the key shall be converted
    "! @parameter r_old_key              | Converted key
    "! @raising cx_swo_application_error | Is raised if key cannot be converted
    downgrade_key
      importing
                !i_current_key     type swo_shortkey
                !i_old_key_version type as4vers
      returning
                value(r_old_key)   type swo_shortkey
      raising   cx_swo_application_error,

    "! Convert a logical key into an older version
    "!
    "! @parameter i_source_key           | Logical key to be converted
    "! @parameter i_source_key_version   | Version of key to be converted
    "! @parameter i_dest_key_version     | Requested key version
    "! @parameter r_dest_key             | Converted key
    "! @raising cx_swo_application_error | Is raised if key cannot be converted
    downgrade_logical_key
      importing
                !i_source_key         type swo_typeid_long
                !i_source_key_version type swo_key_vers
                !i_dest_key_version   type swo_key_vers
      returning
                value(r_dest_key)     type swo_typeid_long
      raising   cx_swo_application_error,

    "! Convert a technical key (GUID) into a logical key
    "!
    "! @parameter i_key                  | Technical key (GUID)
    "! @parameter e_logical_key          | Logical key (the type is a structure, the name of the structure is returned by method get_logical_key_structure )
    "! @raising cx_swo_application_error | Is raised if key cannot be converted
    get_logical_key
      importing
                !i_key         type swo_shortkey
      exporting
                !e_logical_key type any
      raising   cx_swo_application_error,

    "! Convert a logical key into a technical key (GUID)
    "!
    "! @parameter i_logical_key          | Logical key (the type is a structure, the name of the structure is returned by method get_logical_key_structure)
    "! @parameter i_key_version          | Version of the logical key
    "! @parameter r_object_key           | Technical key (GUID)
    "! @raising cx_swo_application_error | Is raised if key cannot be converted
    get_object_key
      importing
                !i_logical_key      type any
                !i_key_version      type as4vers default co_current_key_version
      returning
                value(r_object_key) type swo_shortkey
      raising   cx_swo_application_error,

    "! Get the version number which is currently implemented
    "!
    "! @parameter result | Version number
    get_current_key_version
      returning
        value(result) type as4vers,

    "! Get the name of the structure which is used to deal with logical keys
    "!
    "! @parameter result | Structure name
    get_logical_key_structure
      importing i_key_version type swo_key_vers default if_swo_key_converter=>co_current_key_version
      returning value(result) type tabname,

    "! Convert a container to a different object type version
    "!
    "! @parameter i_verb                 | Name of the method for which the container is used.
    "! @parameter i_source_version       | Current version of the container
    "! @parameter i_dest_version         | Required version of the container
    "! @parameter c_container            | Container to be converted
    "! @raising cx_swo_application_error | Is raised if the container cannot be converted
    convert_container
      importing
        i_verb             type swo_verb
        i_source_version   type as4vers
        i_dest_version     type as4vers
      changing
        c_container        type ty_container
      raising   cx_swo_application_error.


endinterface.

*--- INCLUDE: IF_SWO_KEY_HANDLING===========IU ---*
interface if_swo_key_handling
  public .

  types:
    ty_fieldlist                 type table of swotrk,
    ty_keylist                   type swo_typeid_list,
    ty_object_key_representation type c length 1,
    ty_container                 type standard table of swcont with default key.


  constants:
    co_not_specified type as4vers value '9998',

    "! Representations of keys that are received
    begin of co_inbound_key_representation,
      key_with_version  type ty_object_key_representation value 'V',
      current_version   type ty_object_key_representation value 'C',
      specified_version type ty_object_key_representation value 'S',
    end of co_inbound_key_representation,

    "! Representations of keys that are sent
    begin of co_outbound_key_representation,
      current_version_wo_vers_info   type ty_object_key_representation value 'O',
      current_version_with_vers_info type ty_object_key_representation value 'W',
      specified_version              type ty_object_key_representation value 'S',
      lowest_version                 type ty_object_key_representation value 'L',
    end of co_outbound_key_representation.

  "! Convert a key into the current key version
  "!
  "! @parameter i_destination               | Destination to the system in which the object type is defined.
  "! @parameter i_object_type               | Technical representation of the object type
  "! @parameter i_key                       | Object key
  "! @parameter i_set_current_version       | abap_true : The key is already a current key; abap_false: The key contains the version.
  "! @parameter i_set_key_version           | optional: Can be used to set an explicit key version of the source key, must not be used
  "!                                          in connection with  i_set_current_version.
  "! @parameter e_effective_key             | The converted key with the current version.
  "! @parameter e_effective_key_version     | The version of the converted key.
  "! @parameter e_current_key_version       | The version of the source key.
  "! @raising cx_swo_runtime_error          | Is raised if the conversion could not be executed.
  methods get_effective_key
    importing
      !i_destination                 type rfcdest optional
      !i_object_type                 type swo_objtyp
      !i_key                         type swo_typeid
      value(i_set_current_version)   type abap_bool
      value(i_set_key_version)       type as4vers default co_not_specified
      value(i_set_caller_version)    type as4vers default if_swo_key_converter=>co_current_key_version
    exporting
      value(e_effective_key)         type swo_typeid
      value(e_effective_key_version) type as4vers
      value(e_current_key_version)   type as4vers
      value(e_caller_version)        type as4vers
    raising
      cx_swo_runtime_error .

  "! Removes the key version information from a key
  "!
  "! @parameter i_object_type               | Technical representation of the object type
  "! @parameter c_key                       | Object key: If the object type supports key versioning, the last four characters are cleared
  methods strip_key_version
    importing
      !i_object_type type swo_objtyp
    changing
      !c_key         type swo_typeid .

  "! Convert an object key into its normalized version. The method removes the version information in case of local keys.
  "! @parameter i_object_type | Technical representation of the object type
  "! @parameter i_logsys      | Logical system for which the object key is valid
  "! @parameter i_key         | Key to be normalized
  "! @parameter result        | Normalized key
  methods get_normalized_key
    importing
              !i_object_type  type swo_objtyp
              value(i_logsys) type swotrtime-logsys optional
              !i_key          type swo_typeid
    returning value(result)   type swo_typeid.

  "! Convert a normalized key into a key with version information.
  "! @parameter i_object_type | Technical representation of the object type
  "! @parameter i_logsys      | Logical system for which the object key is valid
  "! @parameter i_key         | Normalized
  "! @parameter result        | Key with key version
  methods get_runtime_key_frm_normalized
    importing
              !i_object_type  type swo_objtyp
              value(i_logsys) type swotrtime-logsys optional
              !i_key          type swo_typeid
    returning value(result)   type swo_typeid.

  "! Normalize all object keys in a container
  "! @parameter c_container   | Container to be processed
  methods normalize_container
    changing c_container type ty_container.

  "! Convert an object key from one representation into another.
  "! @parameter i_object_type              | Technical representation of the object type
  "! @parameter i_key                      | Key to be converted
  "! @parameter i_key_representation       | Representation of input key
  "! @parameter i_requested_representation | Representation of result
  "! @parameter result                     | Converted key
  methods change_key_representation
    importing
              !i_object_type              type swo_objtyp
              !i_key                      type swo_typeid
              !i_key_representation       type ty_object_key_representation
              !i_key_version              type as4vers optional
              !i_requested_representation type ty_object_key_representation
              !i_requested_version        type as4vers optional
    returning value(result)               type swo_typeid
    raising
              cx_swo_runtime_error .

  "! Compute a vector with all versions of an object key
  "!
  "! @parameter i_destination               | Destination to the system in which the object type is defined.
  "! @parameter i_object_type               | Technical representation of the object type
  "! @parameter i_key                       | Object key
  "! @parameter i_set_current_version       | abap_true : The key is already a current key; abap_false: The key contains the version.
  "! @parameter e_object_keys               | Object keys in all supported versions.
  "! @parameter e_key_with_lowest_version   | The object key with the lowest version
  "! @raising cx_swo_runtime_error          | Is raised if the conversion could not be executed.
  methods get_object_keys
    importing
      !i_destination             type rfcdest optional
      !i_object_type             type swo_objtyp
      value(i_key)               type swo_typeid
      !i_set_current_version     type abap_bool
    exporting
      !e_object_keys             type ty_keylist
      !e_key_with_lowest_version type swo_typeid
    raising
      cx_swo_runtime_error .

  "! Convert a GUID into a logical key
  "!
  "! @parameter i_object_type      | Technical representation of the object type
  "! @parameter i_key              | GUID-key
  "! @parameter e_logical_key      | Logical key
  "! @raising cx_swo_runtime_error | Is raised if the conversion could not be executed.
  methods get_logical_key
    importing
      !i_object_type type swo_objtyp
      !i_key         type any
    exporting
      !e_logical_key type any
    raising
      cx_swo_runtime_error .

  "! Convert a logical key into a GUID
  "!
  "! @parameter i_destination      | Destination to the system in which the object type is defined.
  "! @parameter i_object_type      | Technical representation of the object type
  "! @parameter i_logical_key      | Logical key
  "! @parameter i_key_version      | Version of the logical key
  "! @parameter r_object_key       | GUID-key
  "! @raising cx_swo_runtime_error | Is raised if the conversion could not be executed.
  methods get_object_key
    importing
      !i_destination      type rfcdest optional
      value(i_logsys)     type swotrtime-logsys optional
      !i_object_type      type swo_objtyp
      !i_logical_key      type any
      !i_key_version      type as4vers default if_swo_key_converter=>co_current_key_version
    returning
      value(r_object_key) type swo_typeid
    raising
      cx_swo_runtime_error .

  "! Enter the current key version into an object key
  "!
  "! @parameter i_object_type | Technical representation of the object type
  "! @parameter c_key         | Object key, the last four characters are overwritten by the current key version
  methods set_current_version
    importing
      !i_object_type type swo_objtyp
    changing
      !c_key         type swo_typeid .

  "! Get the currently implemented key version
  "!
  "! @parameter i_object_type | Technical representation of the object type
  "! @parameter result        | Key version
  methods get_current_key_version
    importing
      !i_object_type type swo_objtyp
    returning
      value(result)  type as4vers .

  "! Get the name of the key converter class
  "!
  "! @parameter i_object_type | Technical representation of the object type
  "! @parameter result | Class name
  methods get_key_converter
    importing
      !i_object_type type swo_objtyp
    returning
      value(result)  type swo_key_converter.

  "! Get a of fields which make up the logical key
  "!
  "! @parameter i_object_type      | Technical representation of the object type
  "! @parameter i_object_key       | Object key in current format
  "! @parameter e_fields           | Field list with values. The values are populated with the logical representation of the object key
  "! @parameter e_logical_key      | Logical representation of the object key
  "! @raising cx_swo_runtime_error | Is raised if the conversion could not be executed.
  methods get_logical_keyfields
    importing
      !i_object_type type swo_objtyp
      !i_object_key  type swo_typeid optional
    exporting
      !e_fields      type ty_fieldlist
      !e_logical_key type any
    raising
      cx_swo_runtime_error .

  "! Check is a logical key structure is defined for the object type
  "!
  "! @parameter i_object_type       | Technical representation of the object type
  "! @parameter r_has_technical_key | abap_true iff the object type has a technical key (GUID)
  methods has_technical_key
    importing
              !i_object_type             type swo_objtyp
    returning value(r_has_technical_key) type abap_bool.

  "! Get the version of a key
  "!
  "! @parameter i_object_type         | Technical representation of the object type
  "! @parameter i_key                 | Object key
  "! @parameter i_set_current_version | abap_true : The key is already a current key; abap_false: The key contains the version.
  "! @parameter r_key_version         | Version of the key
  methods get_key_version
    importing
      !i_object_type         type swo_objtyp
      !i_key                 type swo_typeid
      !i_set_current_version type abap_bool
    returning
      value(r_key_version)   type as4vers .

  "! Convert a container
  "!
  "! @parameter i_object_type          | Technical representation of the object type
  "! @parameter i_verb                 | Name of a method
  "! @parameter i_source_version       | Container version
  "! @parameter i_dest_version         | Required version
  "! @parameter c_container            | Container
  "! @raising cx_swo_application_error | Is raised if the conversion could not be executed.
  methods convert_container
    importing
              i_object_type    type swo_objtyp
              i_verb           type swo_verb
              i_source_version type as4vers
              i_dest_version   type as4vers
    changing
              c_container      type if_swo_key_converter=>ty_container
    raising   cx_swo_application_error.


  "! Compute the version of a container
  "!
  "! @parameter i_object_type          | Technical representation of the object type
  "! @parameter i_container_version    | Intended container version: Allowed values are
  "!                                        if_swo_key_converter~co_version_of_object_key: The version of the container
  "!                                            adheres to the object type version
  "!                                        if_swo_key_converter~co_current_key_version: The version of the container
  "!                                            adheres to the object type version implemented in the system
  "!                                        other values specify the container version explicitly
  "! @parameter i_caller_version       | Version of the object key that was passed during the instantiation
  "! @parameter result                 | Resulting container version
  methods get_effective_container_vers
    importing
              i_object_type       type swo_objtyp
              i_container_version type swo_key_vers
              i_caller_version    type swo_key_vers
    returning value(result)       type swo_key_vers.


  "! Compute a key field value out of BAPI parameters. If the length of a (logical) key field
  "! is extended, BAPIs that have the key as parameters get an additional parameter that is
  "! mapped to the new key field. Callers can either use the old parameter that was used for the
  "! original key field, or the new parameter that corresponds to the current key field.
  "! This method shall compute the correct value of the key field based on the passed parameter
  "! values.
  "!
  "! @parameter i_object_type          | Technical representation of the object type
  "! @parameter i_key_field            | Name of the key field
  "! @parameter i_old_key_field_value  | Value from the BAPI parameter for the old value
  "! @parameter i_new_key_field_value  | Value from the BAPI parameter for the new value
  "! @parameter r_current_value        | Value of the key field in the current (logical) key
  "! @raising cx_swo_application_error | Is raised if key cannot be converted
  methods get_key_field_from_parameters
    importing
              i_object_type          type swo_objtyp
              i_key_field            type swotrk-keyfield
              i_old_key_field_value  type clike
              i_new_key_field_value  type clike
    returning
              value(r_current_value) type swo_typeid_long
    raising   cx_swo_application_error.


endinterface.

*--- INCLUDE: IF_T100_DYN_MSG===============IU ---*
interface IF_T100_DYN_MSG
  public .


  interfaces IF_MESSAGE .
  interfaces IF_T100_MESSAGE .

  data MSGV1 type SYMSGV .
  data MSGV2 type SYMSGV .
  data MSGV3 type SYMSGV .
  data MSGV4 type SYMSGV .
  data MSGTY type SYMSGTY .
endinterface.

*--- INCLUDE: IF_T100_MESSAGE===============IU ---*
*"* components of interface IF_T100_MESSAGE
interface IF_T100_MESSAGE
  public .


  interfaces IF_MESSAGE .

  constants:
    begin of default_textid,
      msgid type symsgid value 'SY',
      msgno type symsgno value '530',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of default_textid.

  data T100KEY type SCX_T100KEY .
endinterface.

*--- INCLUDE: OLE2INCL ---*
***INCLUDE OLE2INCL.
TYPE-POOLS OLE2 .
