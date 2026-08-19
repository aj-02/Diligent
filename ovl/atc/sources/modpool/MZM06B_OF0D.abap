*--- MAIN PROGRAM: MZM06B_OF0D ---*
*eject
***********************************************************************
*  Form-Routinen   Bestellanforderungsabwicklung  MM06BF0D
*  Alphabetisch geordnet; hier beginnend mit 'D'
***********************************************************************
* 70368 11.06.1997 3.1H GT :ME52 Planungsvormerkung nach Lö. nicht ange.

  INCLUDE MM06BF0D_DISPODATEN_MERKEN .  " DISPODATEN_MERKEN

  INCLUDE MM06BF0D_NEUE_POS_DIEN .  " NEUE_POS_DIEN

  INCLUDE MM06BF0D_DISPLAY_LAST_PO .  " DISPLAY_LAST_PO

  INCLUDE MM06BF0D_TC_VARIANTE .  " TC_VARIANTE

  INCLUDE MM06BF0D_DEFAULT_ITEM_CATEGORY .  " DEFAULT_ITEM_CATEGORY


  INCLUDE MM06BF0D_DOKUMENTENUEBERSICHT .  " DOKUMENTENUEBERSICHT



  INCLUDE MM06BF0D_DOKUMENTE_BELEGNR_CHA .  " DOKUMENTE_BELEGNR_CHANGE
  form dispobereich_Me51.

*   check fc_vorga ne cva_en.          "in MEPO nicht erforderlich
    if bsn-update eq 'U'.
      check bsn-matnr ne yeban-matnr or
            bsn-werks ne yeban-werks or
            bsn-lgort ne yeban-lgort or
            bsn-emlif ne yeban-emlif or
            bsn-lblkz ne yeban-lblkz or
            bsn-sobkz ne yeban-sobkz.
    endif.
    clear bsn-berid.
    data: lf_lbear type eban-emlif.
    data: ls_mdlv type mdlv.
    if bsn-lblkz ne space.
      lf_lbear = bsn-emlif.
    endif.
    CALL FUNCTION 'MD_MRP_AREA_GET'
         EXPORTING
              I_MATNR          = bsn-matnr
              I_WERKS          = bsn-werks
              I_LGORT          = bsn-lgort
              I_LBEAR          = lf_lbear
              I_SOBKZ          = bsn-sobkz
*             I_DBSKZ          =
*             I_VRPLA          =
         IMPORTING
              E_DB_MDLV        = ls_mdlv
         EXCEPTIONS
              others           = 1.
    IF SY-SUBRC eq 0.
      if ls_mdlv-berid ne bsn-berid.
        bsn-berid = ls_mdlv-berid.
      endif.
    ENDIF.

  endform.
