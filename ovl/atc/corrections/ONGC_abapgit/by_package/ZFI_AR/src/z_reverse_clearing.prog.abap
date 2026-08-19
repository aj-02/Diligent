 REPORT Z_REVERSE_CLEARING.
* This report can be used to reverse big clearing documents
* for G/L accounts, vendor or customer accounts if
* transaction FBRA fails.
* The clearing information is deleted in BSEG and the
* index tables are actualized.

     tables: bsis, bsas,
             bsik, bsak,
             bsid, bsad,
             bkpf,
             bseg.

     selection-screen begin of block 001 with frame title text-001.
     parameters: p_bukrs like bseg-bukrs obligatory,
                 p_accnt like bseg-hkont obligatory,
                 p_augdt like bseg-augdt obligatory,
                 p_augbl like bseg-augbl obligatory,
                 p_umsks like bseg-umsks,
                 p_umskz like bseg-umskz.
     selection-screen end of block 001.

     selection-screen begin of block 002 with frame title text-002.
     parameters: gl_doc radiobutton group 0001,
                 ap_doc radiobutton group 0001,
                 ar_doc radiobutton group 0001.
     selection-screen end of block 002.


     data: i_bsas  like bsas occurs 40000 with header line,
           i_bsak  like bsak occurs 40000 with header line,
           i_bsad  like bsad occurs 40000 with header line,
           wa_bsis like bsis,
           wa_bsik like bsik,
           wa_bsid like bsid,
           wa_bseg like bseg.

     data: commit_counter type i,
           n type i.

     constants threashold type i value 100.

* define initial variables to initialize clearing information
     data: init_augcp like bseg-augcp,
           init_augdt like bseg-augdt,
           init_augbl like bseg-augbl.



*---------------------------------------------------------------------*
*       main                                                          *
*---------------------------------------------------------------------*
     if gl_doc = 'X'.  perform gl_reverse.  endif.
     if ap_doc = 'X'.  perform ap_reverse.  endif.
     if ar_doc = 'X'.  perform ar_reverse.  endif.





*---------------------------------------------------------------------*
*       FORM gl_reverse                                               *
*---------------------------------------------------------------------*
     form gl_reverse.
* copy all cleared line items into internal table I_BSAS
       select * from bsas into table i_bsas where bukrs = p_bukrs
                                            and   hkont = p_accnt
                                            and   augdt = p_augdt
                                            and   augbl = p_augbl.

       commit_counter = 0.
       loop at i_bsas.
         add 1 to commit_counter.
* reset clearing information in BSEG line item
         update bseg set augcp = init_augcp
                         augdt = init_augdt
                         augbl = init_augbl
                   where bukrs = i_bsas-bukrs
                   and   belnr = i_bsas-belnr
                   and   gjahr = i_bsas-gjahr
                   and   buzei = i_bsas-buzei.
         perform check_result_gl using sy-subrc i_bsas 1.
* insert a new open item line into BSIS
         wa_bsis = i_bsas.
         wa_bsis-augbl = init_augbl.
         wa_bsis-augdt = init_augdt.
*         insert bsis from wa_bsis.
         perform check_result_gl using sy-subrc i_bsas 2.
* delete the cleared item line out of BSAS
*         delete bsas from i_bsas.
         perform check_result_gl using sy-subrc i_bsas 3.
* perform a commit beyond a given threashold
         n = commit_counter mod threashold.
         if n = 0.
           CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                EXPORTING
                     TEXT = commit_counter.
           call function 'DB_COMMIT'.
         endif.
       endloop.
     endform.                               "G/L reverse


*---------------------------------------------------------------------*
*       FORM check_result_gl                                          *
*---------------------------------------------------------------------*
* describes the reaction for a failed UPDATE, INSERT or DELETE
* for G/L clearings
     form check_result_gl using subrc key like bsas msg type i.
       if subrc ne 0.
         write: / 'Data base action failed with', key-bukrs,
                                                  key-belnr,
                                                  key-gjahr,
                                                  key-buzei.
         case msg.
           when 1.  message a005(FI) with 'BSEG' key-belnr. "#EC MG_PAR_CNT.
           when 2.  message a004(FI) with 'BSIS' key-belnr. "#EC MG_PAR_CNT
           when 3.  message a006(FI) with 'BSAS' key-belnr. "#EC MG_PAR_CNT
         endcase.
       endif.
     endform.


*---------------------------------------------------------------------*
*       FORM ap_reverse                                               *
*---------------------------------------------------------------------*
     form ap_reverse.
* copy all cleared line items into internal table I_BSAK
       select * from bsak into table i_bsak where bukrs = p_bukrs
                                            and   lifnr = p_accnt
                                            and   augdt = p_augdt
                                            and   augbl = p_augbl
                                            and   umsks = p_umsks
                                            and   umskz = p_umskz.
       commit_counter = 0.
       loop at i_bsak.
         add 1 to commit_counter.


* check, if reconciliation account is single item managed
*   first read document line item information
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
         select single * from bseg into wa_bseg where
                               bukrs = i_bsak-bukrs and
                               belnr = i_bsak-belnr and
                               gjahr = i_bsak-gjahr and
                               buzei = i_bsak-buzei.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
         perform check_result_ap using sy-subrc i_bsak 1.
         If wa_bseg-xhres = 'X'.
*     read BSAS entry regarding to vendor line item
           select single * from bsas into i_bsas where
                           bukrs = wa_bseg-bukrs and
                           hkont = wa_bseg-hkont and
                           augdt = wa_bseg-augdt and
                           augbl = wa_bseg-augbl and
                           zuonr = wa_bseg-hzuon and
                           gjahr = wa_bseg-gjahr and
                           belnr = wa_bseg-belnr and
                           buzei = wa_bseg-buzei.
           perform check_result_ap using sy-subrc i_bsak 1.
*     create a new BSIS entry
           move i_bsas to wa_bsis.
           wa_bsis-augbl = init_augbl.
           wa_bsis-augdt = init_augdt.
*           insert bsis from wa_bsis.
           perform check_result_gl using sy-subrc i_bsas 2.
*     delete the BSAS entry
*           delete bsas from i_bsas .
           perform check_result_gl using sy-subrc i_bsas 3.
         endif.

* check, if the cleared document was posted net
* if so, reset clearing information in SKV line items and
* restore BSIS / delete BSAS
         if ( i_bsak-xnetb = 'X' ) or ( i_bsak-augbl = i_bsak-belnr ).
           perform reverse_skv_ap using i_bsak.
         endif.

* handle vendor line item
* reset clearing information in BSEG line item
         wa_bseg-augcp = init_augcp.
         wa_bseg-augdt = init_augdt.
         wa_bseg-augbl = init_augbl.
         update bseg from wa_bseg.
         perform check_result_ap using sy-subrc i_bsak 1.
* insert a new open item line into BSIK
         wa_bsik = i_bsak.
         wa_bsik-augbl = init_augbl.
         wa_bsik-augdt = init_augdt.
*         insert bsik from wa_bsik.
         perform check_result_ap using sy-subrc i_bsak 2.
* delete the cleared item line out of BSAK
*         delete bsak from i_bsak.
         perform check_result_ap using sy-subrc i_bsak 3.
* perform a commit beyond a given threashold
         n = commit_counter mod threashold.
         if n = 0.
           CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                EXPORTING
                     TEXT = commit_counter.
           call function 'DB_COMMIT'.
         endif.
       endloop.
     endform.                               "AP reverse


*---------------------------------------------------------------------*
*       FORM reverse_skv_ap                                           *
*---------------------------------------------------------------------*
* reset clearing information in SKV document line items and
* restore BSIS / delete BSAS
     form reverse_skv_ap using key like bsak.
       data: iwa_bsis like bsis,
             iwa_bsas like bsas.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
       select * from bseg where bukrs = key-bukrs
                          and   belnr = key-belnr
                          and   gjahr = key-gjahr
                          and   ktosl = 'SKV' ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*   read BSAS entry
         select single * from bsas into iwa_bsas
                                            where bukrs = bseg-bukrs
                                            and   hkont = bseg-hkont
                                            and   augdt = bseg-augdt
                                            and   augbl = bseg-augbl
                                            and   zuonr = bseg-zuonr
                                            and   gjahr = bseg-gjahr
                                            and   belnr = bseg-belnr
                                            and   buzei = bseg-buzei.
         perform check_result_ap using sy-subrc key 1.
*   create a new BSIS entry
         move iwa_bsas to iwa_bsis.
         iwa_bsis-augbl = init_augbl.
         iwa_bsis-augdt = init_augdt.
*         insert bsis from iwa_bsis.
         perform check_result_gl using sy-subrc iwa_bsas 2.
*   delete the BSAS entry
*         delete bsas from iwa_bsas.
         perform check_result_gl using sy-subrc iwa_bsas 3.
*   reset clearing information in BSEG
         bseg-augcp = init_augcp.
         bseg-augdt = init_augdt.
         bseg-augbl = init_augbl.
         update bseg.
         perform check_result_ap using sy-subrc key 1.
       endselect.
     endform.                               "reverse_SKV_AP




*---------------------------------------------------------------------*
*       FORM check_result_ap                                          *
*---------------------------------------------------------------------*
* describes the reaction for a failed UPDATE, INSERT or DELETE
* for AP clearings
     form check_result_ap using subrc key like bsak msg type i.

       if subrc ne 0.
         write: / 'Data base action failed with', key-bukrs,
                                                  key-belnr,
                                                  key-gjahr,
                                                  key-buzei.
         case msg.
           when 1.  message a005(FI) with 'BSEG' key-belnr. "#EC MG_PAR_CNT
           when 2.  message a004(FI) with 'BSIK' key-belnr. "#EC MG_PAR_CNT
           when 3.  message a006(FI) with 'BSAK' key-belnr. "#EC MG_PAR_CNT
         endcase.
       endif.
     endform.


*---------------------------------------------------------------------*
*       FORM ar_reverse                                               *
*---------------------------------------------------------------------*
     form ar_reverse.
* copy all cleared line items into internal table I_BSAD
       select * from bsad into table i_bsad where bukrs = p_bukrs
                                            and   kunnr = p_accnt
                                            and   augdt = p_augdt
                                            and   augbl = p_augbl
                                            and   umsks = p_umsks
                                            and   umskz = p_umskz.

       commit_counter = 0.
       loop at i_bsad.
         add 1 to commit_counter.

* check, if reconciliation account is single item managed
*   first read document line item information
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
         select single * from bseg into wa_bseg where
                               bukrs = i_bsad-bukrs and
                               belnr = i_bsad-belnr and
                               gjahr = i_bsad-gjahr and
                               buzei = i_bsad-buzei.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
         perform check_result_ar using sy-subrc i_bsad 1.
         If wa_bseg-xhres = 'X'.
*     read BSAS entry regarding to customer line item
           select single * from bsas into i_bsas where
                             bukrs = wa_bseg-bukrs and
                             hkont = wa_bseg-hkont and
                             augdt = wa_bseg-augdt and
                             augbl = wa_bseg-augbl and
                             zuonr = wa_bseg-hzuon and
                             gjahr = wa_bseg-gjahr and
                             belnr = wa_bseg-belnr and
                             buzei = wa_bseg-buzei.
           perform check_result_ar using sy-subrc i_bsad 1.
*     create a new BSIS entry
           move i_bsas to wa_bsis.
           wa_bsis-augbl = init_augbl.
           wa_bsis-augdt = init_augdt.
*           insert bsis from wa_bsis.

           perform check_result_gl using sy-subrc i_bsas 2.
*     delete the BSAS entry
*           delete bsas from i_bsas .
           perform check_result_gl using sy-subrc i_bsas 3.
         endif.

* check, if the cleared document was posted net
* if so, reset clearing information in SKV line items and
* restore BSIS / delete BSAS
         if ( i_bsad-xnetb = 'X' ) or ( i_bsad-augbl = i_bsad-belnr ).
           perform reverse_skv_ar using i_bsad.
         endif.

* handle customer line item
* reset clearing information in BSEG line item
         wa_bseg-augcp = init_augcp.
         wa_bseg-augdt = init_augdt.
         wa_bseg-augbl = init_augbl.
         update bseg from wa_bseg.
         perform check_result_ar using sy-subrc i_bsad 1.
* insert a new open item line into bsid
         wa_bsid = i_bsad.
         wa_bsid-augbl = init_augbl.
         wa_bsid-augdt = init_augdt.
*         insert bsid from wa_bsid.
         perform check_result_ar using sy-subrc i_bsad 2.
* delete the cleared item line out of bsad
*         delete bsad from i_bsad.
         perform check_result_ar using sy-subrc i_bsad 3.
* perform a commit beyond a given threashold
         n = commit_counter mod threashold.
         if n = 0.
           CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                EXPORTING
                     TEXT = commit_counter.
           call function 'DB_COMMIT'.
         endif.

       endloop.
     endform.                               "AR reverse



*---------------------------------------------------------------------*
*       FORM reverse_skv_ar                                           *
*---------------------------------------------------------------------*
* reset clearing information in SKV document line items and
* restore BSIS / delete BSAS
     form reverse_skv_ar using key like bsad.
       data: iwa_bsis like bsis,
             iwa_bsas like bsas.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
       select * from bseg where bukrs = key-bukrs
                          and   belnr = key-belnr
                          and   gjahr = key-gjahr
                          and   ktosl = 'SKV' ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*   read BSAS entry
         select single * from bsas into iwa_bsas
                                            where bukrs = bseg-bukrs
                                            and   hkont = bseg-hkont
                                            and   augdt = bseg-augdt
                                            and   augbl = bseg-augbl
                                            and   zuonr = bseg-zuonr
                                            and   gjahr = bseg-gjahr
                                            and   belnr = bseg-belnr
                                            and   buzei = bseg-buzei.
         perform check_result_ar using sy-subrc key 1.
*   create a new BSIS entry
         move iwa_bsas to iwa_bsis.
         iwa_bsis-augbl = init_augbl.
         iwa_bsis-augdt = init_augdt.
*         insert bsis from iwa_bsis.
         perform check_result_gl using sy-subrc iwa_bsas 2.
*   delete the BSAS entry
*         delete bsas from iwa_bsas.
         perform check_result_gl using sy-subrc iwa_bsas 3.
*   reset clearing information in BSEG
         bseg-augcp = init_augcp.
         bseg-augdt = init_augdt.
         bseg-augbl = init_augbl.
         update bseg.
         perform check_result_ar using sy-subrc key 1.
       endselect.
     endform.                               "reverse_SKV_AR



*---------------------------------------------------------------------*
*       FORM check_result_ar                                          *
*---------------------------------------------------------------------*
* describes the reaction for a failed UPDATE, INSERT or DELETE
* for AR clearings
     form check_result_ar using subrc key like bsad msg type i.
       if subrc ne 0.
         write: / 'Data base action failed with', key-bukrs,
                                                  key-belnr,
                                                  key-gjahr,
                                                  key-buzei.
         case msg.
           when 1.  message a005(FI) with 'BSEG' key-belnr. "#EC MG_PAR_CNT
           when 2.  message a004(FI) with 'BSID' key-belnr. "#EC MG_PAR_CNT
           when 3.  message a006(FI) with 'BSAD' key-belnr. "#EC MG_PAR_CNT
         endcase.
       endif.
     endform.
