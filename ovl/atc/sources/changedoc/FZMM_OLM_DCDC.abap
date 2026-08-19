*--- MAIN PROGRAM: FZMM_OLM_DCDC ---*
FORM CD_CALL_ZMM_OLM_D.
  IF   ( UPD_ZOL_MFST_D NE SPACE )
    OR ( UPD_ZOL_MFST_H NE SPACE )
    OR ( UPD_ICDTXT_ZMM_OLM_D NE SPACE )
  .
    CALL FUNCTION 'ZMM_OLM_D_WRITE_DOCUMENT' IN UPDATE TASK
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
* workarea_old of ZOL_MFST_D
          O_ZOL_MFST_D
                      = *ZOL_MFST_D
* workarea_new of ZOL_MFST_D
          N_ZOL_MFST_D
                      = ZOL_MFST_D
* updateflag of ZOL_MFST_D
          UPD_ZOL_MFST_D
                      = UPD_ZOL_MFST_D
* workarea_old of ZOL_MFST_H
          O_ZOL_MFST_H
                      = *ZOL_MFST_H
* workarea_new of ZOL_MFST_H
          N_ZOL_MFST_H
                      = ZOL_MFST_H
* updateflag of ZOL_MFST_H
          UPD_ZOL_MFST_H
                      = UPD_ZOL_MFST_H
          UPD_ICDTXT_ZMM_OLM_D
                      = UPD_ICDTXT_ZMM_OLM_D
        TABLES
          ICDTXT_ZMM_OLM_D
                      = ICDTXT_ZMM_OLM_D
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
