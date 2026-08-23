@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Excel Download - Action Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #S,
  dataClass:      #MASTER
}

define root view entity ZPRA_I_DPR_EXCEL_DL
  as select from I_BusinessUser as BU
{
  key BU.UserID         as RequestId,
      BU.PersonFullName as RequestedBy
}
where BU.UserID = $session.user
