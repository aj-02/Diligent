*--- MAIN PROGRAM: FZMM_IMSCDC ---*
FORM CD_CALL_ZMM_IMS.
  IF   ( UPD_ZMM_IMS NE SPACE )
    OR ( UPD_ICDTXT_ZMM_IMS NE SPACE )
  .
    CALL FUNCTION 'ZMM_IMS_WRITE_DOCUMENT' IN UPDATE TASK
        EXPORTING
          OBJECTID                = OBJECTID
          TCODE                   = TCODE
          UTIME                   = UTIME
          UDATE                   = UDATE
          USERNAME                = USERNAME
          PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
          OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
          PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
          NO_CHANGE_POINTERS      = CDOC_NO_CHANGE_POINTERS
* workarea_old of ZMM_IMS
          O_ZMM_IMS
                      = *ZMM_IMS
* workarea_new of ZMM_IMS
          N_ZMM_IMS
                      = ZMM_IMS
* updateflag of ZMM_IMS
          UPD_ZMM_IMS
                      = UPD_ZMM_IMS
          UPD_ICDTXT_ZMM_IMS
                      = UPD_ICDTXT_ZMM_IMS
        TABLES
          ICDTXT_ZMM_IMS
                      = ICDTXT_ZMM_IMS
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
