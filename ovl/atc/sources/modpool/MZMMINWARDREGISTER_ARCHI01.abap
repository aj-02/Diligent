*--- MAIN PROGRAM: MZMMINWARDREGISTER_ARCHI01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMINWARDREGISTERI01                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*& To navigate screen(s) according to selection
*----------------------------------------------------------------------*
module user_command_9000 input.

  if g_ok_code = 'ENTER'  or
     g_ok_code = 'INW'    or
     sy-ucomm  = 'G_CREA' or
     sy-ucomm  = 'G_DISP' or
     sy-ucomm  = 'G_CHAN' or
     sy-ucomm  = 'G_DELE'.

    perform menu_navigate.

  endif.

endmodule.                 " USER_COMMAND_9000  INPUT

*&---------------------------------------------------------------------*
*&      Module  exit1  INPUT
*&---------------------------------------------------------------------*
*& To navigate to previous screen if Back or exit is pressed
*----------------------------------------------------------------------*
module exit1 input.
  g_ok_code = sy-ucomm .
  if g_ok_code = 'BACK'
  or g_ok_code = '%EX'
  or g_ok_code = 'RW'.
    if g_status = 'X' .

*leave to transaction 'ZMMPENDINGGR' .
      leave program .
    endif .
    refresh ist_inwarddt1.
    refresh ist_inwarddt.
    perform clear_data.

    if sy-dynnr = '9030'.          "Change screen
      if g_mode = 'Change' or g_mode = 'Delete'.
        perform unlock_record.
      endif.
      leave to screen 9020.
    elseif sy-dynnr = '9000'.
      leave program.

    else.
      leave to screen 9000.
    endif.

  endif.

endmodule.                 " exit1  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*& To save entries onto ZMM_INWARDHD & ZMM_INWARDDT tables
*----------------------------------------------------------------------*
module user_command_9010 input.
  if sy-ucomm = 'G_CREA' or
     sy-ucomm = 'G_DISP' or
     sy-ucomm = 'G_CHAN' or
     sy-ucomm = 'G_DELE'.

    perform menu_navigate.
  endif.

  if ( g_ok_code eq 'SAVE' or sy-ucomm = 'SAVE' )
     and not ist_inwarddt[] is initial.

    refresh ist_inwarddt1.

    perform get_serialno.

    perform lock_record.

    refresh ist_inwardhd1.

    move: zmm_inwardhd-inwno to ist_inwardhd1-inwno,
          sy-datum           to ist_inwardhd1-inwdt,
          zmm_inwardhd-ebeln to ist_inwardhd1-ebeln,
          zmm_inwardhd-rcnno to ist_inwardhd1-rcnno,
          zmm_inwardhd-cfloc to ist_inwardhd1-cfloc,
          sy-datum           to ist_inwardhd1-createdon,
          sy-uname           to ist_inwardhd1-createdby.
    if not zmm_inwardhd-rcnno is initial.
      move ZMM_CNFRCNHD-EBELN to ist_inwardhd1-ebeln.
    endif.
    perform set_timestamp using ist_inwardhd1-timestamp.
    append ist_inwardhd1.

    CALL FUNCTION 'Z_UPDATE_ZMM_INWARDHD' in update task
      EXPORTING
        l_mode     = '1'  "Create mode
      TABLES
        l_inwardhd = ist_inwardhd1.

    if sy-subrc ne 0.
      rollback work.
      perform unlock_record.
      message e076.
    endif.

    g_recid = 0.
    refresh ist_inwarddt1.

    loop at ist_inwarddt.

      g_recid = g_recid + 1.
      move: zmm_inwardhd-inwno     to ist_inwarddt1-inwno.
* Inserted on 10.07.2003 as suggested by Parjinder
      if zmm_inwardhd-ebeln is initial.
        move  ist_inwarddt-inwrd     to ist_inwarddt1-inwrd.
      else.
        move   g_recid               to ist_inwarddt1-inwrd.
      endif.
* End of Insertion.

      if ist_inwarddt-lrben is initial or
          ist_inwarddt-lrdat is initial or
          ist_inwarddt-docty is initial or
          ist_inwarddt-packr is initial or
          ist_inwarddt-packs is initial or
          ist_inwarddt-itemsrecd is initial.
*        data: l_line type i.
*               l_line = DISPREC-CURRENT_LINE.
*        get cursor field ist_inwarddt-lrben line l_line+1.
        loop at screen.
          if screen-group1 = 'IN1'  OR
             screen-name = 'IST_INWARDDT-LRBEN'     OR
             screen-name = 'IST_INWARDDT-LRDAT'     OR
             screen-name = 'IST_INWARDDT-DOCTY'     OR
             screen-name = 'IST_INWARDDT-PACKS'     OR
             screen-name = 'IST_INWARDDT-PACKS'     OR
             screen-name = 'IST_INWARDDT-ITEMSRECD'.
*            l_req = 'X'.
            screen-ACTIVE  = 1.
            screen-INPUT = 1.
*            screen-required = 1.

*            message s994(zmm). " commented by cab_dns
            modify screen.
          endif.
        endloop.

        message e994(zmm).
*         err = 'X'.


*        get cursor field ist_inwarddt-lrben line DISPREC-CURRENT_LINE.  set
*        message e994(zmm).
      endif.

      move : ist_inwarddt-ladno     to ist_inwarddt1-ladno,
             ist_inwarddt-laddt     to ist_inwarddt1-laddt,
             ist_inwarddt-ladamt    to ist_inwarddt1-ladamt,
             ist_inwarddt-ladcur    to ist_inwarddt1-ladcur,
             ist_inwarddt-lrben     to ist_inwarddt1-lrben,
             ist_inwarddt-lrdat     to ist_inwarddt1-lrdat,
             ist_inwarddt-docty     to ist_inwarddt1-docty,
             ist_inwarddt-ccncd     to ist_inwarddt1-ccncd,
             ist_inwarddt-caseno    to ist_inwarddt1-caseno,
             ist_inwarddt-packs     to ist_inwarddt1-packs,
             ist_inwarddt-itemsrecd to ist_inwarddt1-itemsrecd,
             ist_inwarddt-packr     to ist_inwarddt1-packr,
             ist_inwarddt-actwt     to ist_inwarddt1-actwt,
             ist_inwarddt-wtuom     to ist_inwarddt1-wtuom,
             ist_inwarddt-wtchr     to ist_inwarddt1-wtchr,
             ist_inwarddt-chwtuom   to ist_inwarddt1-chwtuom,
             ist_inwarddt-indelno   to ist_inwarddt1-indelno,
             ist_inwarddt-remarks   to ist_inwarddt1-remarks.
      append ist_inwarddt1.
    endloop.

    if not zmm_inwardhd-ebeln is initial.
      sort ist_inwarddt1 by inwrd.
      delete adjacent duplicates from ist_inwarddt1 comparing inwrd.
    endif.
                                    "11122013
      CALL FUNCTION 'Z_UPDATE_ZMM_INWARDDT' in update task
        EXPORTING
          l_mode     = '1'  "Create mode
          l_rcnno    = zmm_inwardhd-rcnno
        TABLES
          l_inwarddt = ist_inwarddt1.

      if sy-subrc ne 0.
        rollback work.
        perform unlock_record.
        message e010.
      endif.

      perform unlock_record.
      commit work.
      message i009 with zmm_inwardhd-inwno.

*--- To pass the inward no. as parameter id.
      set parameter id 'ZINWNO' field zmm_inwardhd-inwno.

      refresh ist_inwarddt1.
      refresh ist_inwarddt.
      perform clear_data.

  else.
    g_flg = 'N'.
    if ( g_ok_code eq 'SAVE' or sy-ucomm = 'SAVE' )
       and ist_inwarddt[] is initial.

      message s994(zmm).
    endif.
    clear sy-ucomm.
    clear g_ok_code.

  endif.

endmodule.                 " USER_COMMAND_9010  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_rcnno_ebeln  INPUT
*&---------------------------------------------------------------------*
*& To validate RCN No. & PO No. inputs
*----------------------------------------------------------------------*
module check_rcnno_ebeln input.

*  if l_ebeln_old ne ZMM_INWARDHD-EBELN.
*    refresh ist_inwarddt.
**    l_ebeln = ZMM_INWARDHD-EBELN.
*  endif.

********Start of change on 05.08.2003, by Subodh *********
*  IF NOT zmm_inwardhd-cfloc IS INITIAL.
*    SELECT SINGLE * FROM zmm_location WHERE loccd = zmm_inwardhd-cfloc.
  if not zmm_location-loccd is initial.
    select single * from zmm_location where loccd = zmm_location-loccd.
    if sy-subrc ne 0.
*      MESSAGE e021 WITH zmm_inwardhd-cfloc.
      message e021 with zmm_location-loccd.

*******End of change for 05.08.2003              *********
    else.
**Start of insertion on 07.08.2003               ********
      zmm_inwardhd-cfloc = zmm_location-loccd.
**End of insertion for  07.08.2003              **********
      zmm_location-locds = zmm_location-locds.
    endif.
  endif.

  if not zmm_inwardhd-rcnno is initial and
     not zmm_inwardhd-ebeln is initial.

    message e018.
  endif.

  if not zmm_inwardhd-rcnno is initial.
    select single * from zmm_cnfrcnhd where rcnno = zmm_inwardhd-rcnno.
    if sy-subrc ne 0.
      message e019 with zmm_inwardhd-rcnno.
    else.
      if zmm_cnfrcnhd-canflg  = 'C'.
        message e029 with zmm_inwardhd-rcnno.
      elseif zmm_cnfrcnhd-inwrflg = 'I'.
        message e028 with zmm_inwardhd-rcnno.
      endif.
      zmm_cnfrcnhd-ebeln = zmm_cnfrcnhd-ebeln.
      select single * from ekko where ebeln = zmm_cnfrcnhd-ebeln.
      if sy-subrc ne 0.
        ekko-aedat = ''.
        ekko-lifnr = ekko-lifnr.
        ekko-reswk = ekko-reswk.
        select single * from lfa1 where lifnr = ekko-lifnr.
        if sy-subrc eq 0.
          lfa1-name1 = lfa1-name1.
        endif.
        select single * from t001w where werks = ekko-reswk.
        if sy-subrc eq 0.
          t001w-name1 = t001w-name1.
        endif.
      endif.

    endif.

    select single * from zmm_cnfrcndt where rcnno = zmm_inwardhd-rcnno.
    if sy-subrc ne 0.
      message e019 with zmm_inwardhd-rcnno.
    else.
      zmm_cnfrcnhd-rcndt = zmm_cnfrcnhd-rcndt.

      select * from zmm_cnfrcndt
        into corresponding fields of table ist_inwarddt
        where rcnno = zmm_inwardhd-rcnno.

      loop at ist_inwarddt.
        select single * from zmm_cnfinwr
          where inwrd = ist_inwarddt-inwrd.
        if sy-subrc eq 0.
          move: zmm_cnfinwr-actwt   to ist_inwarddt-actwt,
* Inserted on 10.07.2003 as suggested by Parjinder.
                zmm_cnfinwr-indat   to ist_inwarddt-indat,
                zmm_cnfinwr-indelno to ist_inwarddt-indelno,
                zmm_cnfinwr-lrben   to ist_inwarddt-lrben,
                zmm_cnfinwr-lrdat   to ist_inwarddt-lrdat,
                zmm_cnfinwr-docty   to ist_inwarddt-docty,
                zmm_cnfinwr-ccncd   to ist_inwarddt-ccncd,
* End of Insertion.
                zmm_cnfinwr-wtchr   to ist_inwarddt-wtchr,
                zmm_cnfinwr-wtuom   to ist_inwarddt-wtuom,
                zmm_cnfinwr-chwtuom to ist_inwarddt-chwtuom,
                zmm_cnfinwr-packs   to ist_inwarddt-packs,
                zmm_cnfinwr-packr   to ist_inwarddt-packr.
          modify ist_inwarddt.
        endif.

      endloop.
    endif.
  elseif not zmm_inwardhd-ebeln is initial.
    select single * from ekko where ebeln = zmm_inwardhd-ebeln
*************Insertion of condition on 06.08.2003 by Subodh*************
        and bsart in ('MBPM','MEMI','MEPI','MICM','MIMM','MNBM','MPCM',
                      'MPOI','MPOM','MSDM','MSIM','MSUB').
*************End of insertion for 06.08.2003****************************
    if sy-subrc ne 0.
      message e012 with zmm_inwardhd-ebeln.
    else.
      ekko-aedat = ekko-aedat.
      ekko-lifnr = ekko-lifnr.
      ekko-reswk = ekko-reswk.

      select single * from lfa1 where lifnr = ekko-lifnr.
      if sy-subrc eq 0.
        lfa1-name1 = lfa1-name1.
      endif.
      select single * from t001w where werks = ekko-reswk.
      if sy-subrc eq 0.
        t001w-name1 = t001w-name1.
      endif.
    endif.
  endif.

* Begin of <> on 13112013
  if not ekko-lifnr is initial.
    select single * from kssk into wa_kssk where objek = ekko-lifnr and klart = 'ALV' and clint = '636'.
    if sy-subrc = 0.
      g_ksskflag = 'X'.
      MESSAGE s610(zmm).
    else.
      g_ksskflag = SPACE.
    endif.

  endif.
  select * from tcurc into corresponding fields of table ist_tcurc.
* End of <> on 13112013

endmodule.                 " check_rcnno_ebeln  INPUT

*&---------------------------------------------------------------------*
*&      Module  DISP_CFLOC  INPUT
*&---------------------------------------------------------------------*
*& To Display F4 help for CF Location(s).
*----------------------------------------------------------------------*
module disp_cfloc input.

*  PERFORM disp_cfloc.

endmodule.                 " DISP_CFLOC  INPUT

*&---------------------------------------------------------------------*
*&      Module  DISP_RCNNO  INPUT
*&---------------------------------------------------------------------*
*& To Display F4 help for RCN No(s).
*----------------------------------------------------------------------*
module disp_rcnno input.

  perform disp_rcnno.

endmodule.                 " DISP_RCNNO  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_9020  INPUT
*&---------------------------------------------------------------------*
*& To fetch data from ZMM_INWARDHD & ZMM_INWARDDT tables and display
*----------------------------------------------------------------------*
module user_command_9020 input.

  if sy-ucomm  = 'G_CREA' or
     sy-ucomm  = 'G_DISP' or
     sy-ucomm  = 'G_CHAN' or
     sy-ucomm  = 'G_DELE'.

    perform menu_navigate.
  endif.

  if g_ok_code eq 'ENTER' or sy-ucomm = 'ENTER'.

    refresh ist_inwarddt.

    select * from zmm_inwarddt
      into corresponding fields of table ist_inwarddt
      where inwno = zmm_inwardhd-inwno.
* Inserted on 10.07.2003 as suggested by Parjinder
    loop at ist_inwarddt.
      if sy-subrc = 0.
        clear ist_inwarddt-indat.
        select single * from zmm_cnfinwr where inwrd = ist_inwarddt-inwrd.
        ist_inwarddt-indat = zmm_cnfinwr-indat.
*Inserted on 14.07.2003 as suggested by Parjinder
        if not ist_inwarddt-indelno is initial.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ist_inwarddt-indelno
            IMPORTING
              output = ist_inwarddt-indelno.

          select single * from likp
            where vbeln = ist_inwarddt-indelno.
          if sy-subrc eq 0.
            move: likp-lfdat to ist_inwarddt-lfdat,
                  likp-traid to ist_inwarddt-traid.
          endif.
        endif.
*End of Insertion 14.07.2003

        modify ist_inwarddt.
      endif.
    endloop.
* End of insertion.
    if ist_inwarddt[] is initial.
      message e156 with zmm_inwardhd-inwno.
    endif.

    select single * from zmm_inwardhd where inwno = zmm_inwardhd-inwno.
    if sy-subrc ne 0.
      message e156 with zmm_inwardhd-inwno.
    else.
      if not zmm_inwardhd-cfloc is initial.

        select single * from zmm_location
          where loccd = zmm_inwardhd-cfloc.

        if sy-subrc ne 0.
          message e021 with zmm_inwardhd-cfloc.
        else.
          zmm_location-locds = zmm_location-locds.
        endif.
      endif.

      if not zmm_inwardhd-rcnno is initial.
        select single * from zmm_cnfrcndt
          where rcnno = zmm_inwardhd-rcnno.
        if sy-subrc ne 0.
          message e019 with zmm_inwardhd-rcnno.
        else.
          zmm_cnfrcnhd-rcndt = zmm_cnfrcnhd-rcndt.
****Start of insertion on 07.08.2003 by Subodh**************
          perform get-othdet.
****End of insertion for 07.08.2003*************************
        endif.
      elseif not zmm_inwardhd-ebeln is initial.

        select single * from ekko where ebeln = zmm_inwardhd-ebeln.
*****************************Archive data retrival MM_EKKO****************************************
          IF sy-subrc <> 0.
             PERFORM mm_ekko_ret .
          read table it_ekko_arch into wa_ekko_arch index 1.
          if sy-subrc = 0.
            ekko-aedat = wa_ekko_arch-aedat.
            ekko-lifnr = wa_ekko_arch-lifnr.
            ekko-reswk = wa_ekko_arch-reswk.
          endif.

          ENDIF.
*****************************Archive data retrival MM_EKKO****************************************

        if sy-subrc ne 0.
          message e012 with zmm_inwardhd-ebeln.
        else.
          ekko-aedat = ekko-aedat.
          ekko-lifnr = ekko-lifnr.
          ekko-reswk = ekko-reswk.
          select single * from lfa1 where lifnr = ekko-lifnr.
          if sy-subrc eq 0.
            lfa1-name1 = lfa1-name1.
          endif.
          select single * from t001w where werks = ekko-reswk.
          if sy-subrc eq 0.
            t001w-name1 = t001w-name1.
          endif.
        endif.
      endif.
    endif.
 SHIFT ist_inwarddt-indelno LEFT DELETING LEADING '0'.
    if g_mode ne 'Display'.
      perform lock_record.
    endif.

    if not ist_inwarddt[] is initial.
      call screen 9030.
    endif.

  endif.

endmodule.                 " user_command_9020  INPUT

*&---------------------------------------------------------------------*
*&      Module  disp_inwno  INPUT
*&---------------------------------------------------------------------*
*& To display F4 Help for Inward No.
*----------------------------------------------------------------------*
module disp_inwno input.

  perform disp_inwno.

endmodule.                 " disp_inwno  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_9030  INPUT
*&---------------------------------------------------------------------*
*& To upate/delete entries in ZMM_INWARDHD & ZMM_INWARDDT tables
*----------------------------------------------------------------------*
module user_command_9030 input.

  if sy-ucomm = 'G_CREA' or
     sy-ucomm = 'G_DISP' or
     sy-ucomm = 'G_CHAN' or
     sy-ucomm = 'G_DELE'.

    perform menu_navigate.
  endif.

  if g_mode = 'Change' and
    ( g_ok_code eq 'SAVE' or sy-ucomm = 'SAVE' ).
    refresh ist_inwardhd1.
    refresh ist_inwarddt1.
    move: sy-datum to zmm_inwardhd-changedon,
          sy-uname to zmm_inwardhd-changedby.
    perform set_timestamp using zmm_inwardhd-timestamp.

    CALL FUNCTION 'Z_UPDATE_ZMM_INWARDHD' in update task
      EXPORTING
        l_mode      = '2'  "Change mode
        l_unam      = sy-uname
        l_timestamp = zmm_inwardhd-timestamp
        l_inwno     = zmm_inwardhd-inwno
      TABLES
        l_inwardhd  = ist_inwardhd1.

    if sy-subrc ne 0.
      rollback work.
      perform unlock_record.
      message e026 with zmm_inwardhd-inwno.
    endif.

    perform unlock_record.

    loop at ist_inwarddt.
      move: ist_inwarddt-inwno     to ist_inwarddt1-inwno,
            ist_inwarddt-inwrd     to ist_inwarddt1-inwrd,
            ist_inwarddt-ladno     to ist_inwarddt1-ladno,
            ist_inwarddt-laddt     to ist_inwarddt1-laddt,
            ist_inwarddt-ladamt    to ist_inwarddt1-ladamt,
            ist_inwarddt-ladcur    to ist_inwarddt1-ladcur,
            ist_inwarddt-lrben     to ist_inwarddt1-lrben,
            ist_inwarddt-lrdat   to ist_inwarddt1-lrdat,
            ist_inwarddt-docty     to ist_inwarddt1-docty,
            ist_inwarddt-ccncd     to ist_inwarddt1-ccncd,
            ist_inwarddt-caseno    to ist_inwarddt1-caseno,
            ist_inwarddt-packs     to ist_inwarddt1-packs,
            ist_inwarddt-itemsrecd to ist_inwarddt1-itemsrecd,
            ist_inwarddt-packr     to ist_inwarddt1-packr,
            ist_inwarddt-actwt     to ist_inwarddt1-actwt,
            ist_inwarddt-wtuom     to ist_inwarddt1-wtuom,
            ist_inwarddt-wtchr     to ist_inwarddt1-wtchr,
            ist_inwarddt-chwtuom   to ist_inwarddt1-chwtuom,
            ist_inwarddt-indelno   to ist_inwarddt1-indelno,
            ist_inwarddt-remarks   to ist_inwarddt1-remarks.
      append ist_inwarddt1.
    endloop.

    CALL FUNCTION 'Z_UPDATE_ZMM_INWARDDT' in update task
      EXPORTING
        l_mode     = '2'  "Change mode
      TABLES
        l_inwarddt = ist_inwarddt1.

    if sy-subrc ne 0.
      rollback work.
      perform unlock_record.
      message e026 with zmm_inwardhd-inwno.
    endif.

    commit work.
    message i014 with zmm_inwardhd-inwno.
    refresh ist_inwarddt1.
    refresh ist_inwarddt.
    perform clear_data.
    call screen 9020.
  elseif sy-ucomm = 'DELETE' and g_mode = 'Delete'.
    perform delete_data.
    refresh ist_inwarddt1.
    refresh ist_inwarddt.
    perform clear_data.
    call screen 9020.
  elseif sy-ucomm = 'Display'.
    refresh ist_inwarddt1.
    refresh ist_inwarddt.
    perform clear_data.
    call screen 9020.
  endif.

endmodule.                 " user_command_9030  INPUT

*&---------------------------------------------------------------------*
*&      Module  modify_ist_inwarddt  INPUT
*&---------------------------------------------------------------------*
*& To move values from table control to internal table ist_inwarddt
*----------------------------------------------------------------------*
module modify_ist_inwarddt input.

  if not zmm_inwardhd-ebeln is initial.
* Begin of <> on 08112013
    if not IST_INWARDDT-INDELNO is initial.
      if DISPREC-CURRENT_LINE > 1 and not IST_INWARDDT is initial.
        read table IST_INWARDDT with key indelno = IST_INWARDDT-INDELNO.
        if sy-subrc = 0.
          message e993(zmm) with IST_INWARDDT-INDELNO.
        endif.
      endif.
* Begin of <> on 12112013
      if not GE_HEADER-ZZDOC_TYPE is initial.
        if ist_inwarddt-docty <> GE_HEADER-ZZDOC_TYPE.
          ist_inwarddt-docty = GE_HEADER-ZZDOC_TYPE.
        endif.
      endif.
      if not GE_HEADER-ZZREF_NO is initial.
        if ist_inwarddt-lrben <>  GE_HEADER-ZZREF_NO.
          ist_inwarddt-lrben =  GE_HEADER-ZZREF_NO.
        endif.
      endif.
      if not GE_HEADER-ZZREF_DATE is initial.
        if ist_inwarddt-lrdat <> GE_HEADER-ZZREF_DATE.
          ist_inwarddt-lrdat = GE_HEADER-ZZREF_DATE.
        endif.
      endif.
* End of <> on 12112013
    endif.
* Begin of <> on 13112013
*    break cab_sudhir.
    if not IST_INWARDDT-LADCUR is initial .
      read table ist_tcurc into wa_tcurc with key waers = IST_INWARDDT-LADCUR.
      if sy-subrc <> 0.
        message e043(zmm).
      endif.
    endif.


******commented by cab_dns********
*    if not IST_INWARDDT-LADNO is initial.
*      if IST_INWARDDT-LADDT is initial OR
*         IST_INWARDDT-LADCUR is initial OR
*         IST_INWARDDT-LADAMT is initial.
*        message e992(zmm).
*      endif.
**    else.
**      if not IST_INWARDDT-LADDT is initial OR
**         not IST_INWARDDT-LADCUR is initial OR
**         not IST_INWARDDT-LADAMT is initial.
**        message e992(zmm).
**      endif.
*    endif.

    if IST_INWARDDT-LADNO is initial or
       IST_INWARDDT-LADDT is initial OR
       IST_INWARDDT-LADCUR is initial OR
       IST_INWARDDT-LADAMT is initial.
      loop at screen.
        if screen-name = 'IST_INWARDDT-LADDT' OR
           screen-name = 'IST_INWARDDT-LADCUR' OR
           screen-name = 'IST_INWARDDT-LADAMT'.
          screen-required = 0.
          modify screen.
        endif.
      endloop.
    endif.

* End of <> on 13112013
* Commented on 01122013
*    if ist_inwarddt-lrben is initial or
*     ist_inwarddt-lrdat is initial or
*     ist_inwarddt-docty is initial or
*     ist_inwarddt-packr is initial or
*     ist_inwarddt-packs is initial or
*     ist_inwarddt-itemsrecd is initial.
*
**      get cursor field ist_inwarddt-lrben line DISPREC-CURRENT_LINE.   "01122013
**      set cursor FIELD ist_inwarddt-lrben line DISPREC-CURRENT_LINE.
*      loop at screen.
*        if screen-name = 'IST_INWARDDT-PACKS' OR
*           screen-name = 'IST_INWARDDT-PACKS' OR
*           screen-name = 'IST_INWARDDT-ITEMSRECD'.
*          screen-required = 1.
*          modify screen.
*        endif.
*      endloop.
*
*      message e994(zmm).
*    endif.
* End of Block commented

* End of <> on 08112013
    move: ist_inwarddt-inwrd     to ist_inwarddt1-inwrd,
          ist_inwarddt-ladno     to ist_inwarddt1-ladno,
          ist_inwarddt-laddt     to ist_inwarddt1-laddt,
          ist_inwarddt-ladamt    to ist_inwarddt1-ladamt,
          ist_inwarddt-ladcur    to ist_inwarddt1-ladcur,
          ist_inwarddt-lrben     to ist_inwarddt1-lrben,
          ist_inwarddt-lrdat     to ist_inwarddt1-lrdat,
          ist_inwarddt-docty     to ist_inwarddt1-docty,
          ist_inwarddt-ccncd     to ist_inwarddt1-ccncd,
          ist_inwarddt-caseno    to ist_inwarddt1-caseno,
          ist_inwarddt-packs     to ist_inwarddt1-packs,
          ist_inwarddt-itemsrecd to ist_inwarddt1-itemsrecd,
          ist_inwarddt-packr     to ist_inwarddt1-packr,
          ist_inwarddt-actwt     to ist_inwarddt1-actwt,
          ist_inwarddt-wtuom     to ist_inwarddt1-wtuom,
          ist_inwarddt-wtchr     to ist_inwarddt1-wtchr,
          ist_inwarddt-chwtuom   to ist_inwarddt1-chwtuom,
          ist_inwarddt-indelno   to ist_inwarddt1-indelno,
          ist_inwarddt-remarks   to ist_inwarddt1-remarks.
*******Start of change ( comment-perform ) on 06.08.03*****
**Inserted on 14.07.2003 as suggested by Parjinder
*
*    IF NOT ist_inwarddt-indelno IS INITIAL.
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*           EXPORTING
*                input  = ist_inwarddt-indelno
*           IMPORTING
*                output = ist_inwarddt-indelno.
*
*      SELECT SINGLE * FROM likp
*        WHERE vbeln = ist_inwarddt-indelno.
*      IF sy-subrc EQ 0.
*        MOVE: likp-lfdat TO ist_inwarddt-lfdat,
*              likp-traid TO ist_inwarddt-traid.
*
**********Inserted else part of sy-subrc on 05.08.2003 ****
*      ELSE.
*         message e030(zmm) with ist_inwarddt-indelno.
***********************************************************
*      ENDIF.
*    ENDIF.
**End of Insertion 14.07.2003
    perform indelno-para.
*******End of change (comment-perform) *********************
    read table ist_inwarddt index disprec-current_line.
    if sy-subrc eq 0.
      move: ist_inwarddt1-inwrd     to ist_inwarddt-inwrd,
            ist_inwarddt1-ladno     to ist_inwarddt-ladno,
            ist_inwarddt1-laddt     to ist_inwarddt-laddt,
            ist_inwarddt1-ladamt    to ist_inwarddt-ladamt,
            ist_inwarddt1-ladcur    to ist_inwarddt-ladcur,
            ist_inwarddt1-lrben     to ist_inwarddt-lrben,
            ist_inwarddt1-lrdat     to ist_inwarddt-lrdat,
            ist_inwarddt1-docty     to ist_inwarddt-docty,
            ist_inwarddt1-ccncd     to ist_inwarddt-ccncd,
            ist_inwarddt1-caseno    to ist_inwarddt-caseno,
            ist_inwarddt1-packs     to ist_inwarddt-packs,
            ist_inwarddt1-itemsrecd to ist_inwarddt-itemsrecd,
            ist_inwarddt1-packr     to ist_inwarddt-packr,
            ist_inwarddt1-actwt     to ist_inwarddt-actwt,
            ist_inwarddt1-wtuom     to ist_inwarddt-wtuom,
            ist_inwarddt1-wtchr     to ist_inwarddt-wtchr,
            ist_inwarddt1-chwtuom   to ist_inwarddt-chwtuom,
            ist_inwarddt1-indelno   to ist_inwarddt-indelno,
            ist_inwarddt1-remarks   to ist_inwarddt-remarks.
      modify ist_inwarddt index disprec-current_line.
    else.
      move: ist_inwarddt-inwrd     to ist_inwarddt-inwrd,
            ist_inwarddt-ladno     to ist_inwarddt-ladno,
            ist_inwarddt-laddt     to ist_inwarddt-laddt,
            ist_inwarddt-ladamt    to ist_inwarddt-ladamt,
            ist_inwarddt-ladcur    to ist_inwarddt-ladcur,
            ist_inwarddt-lrben     to ist_inwarddt-lrben,
            ist_inwarddt-lrdat     to ist_inwarddt-lrdat,
            ist_inwarddt-docty     to ist_inwarddt-docty,
            ist_inwarddt-ccncd     to ist_inwarddt-ccncd,
            ist_inwarddt-caseno    to ist_inwarddt-caseno,
            ist_inwarddt-packs     to ist_inwarddt-packs,
            ist_inwarddt-itemsrecd to ist_inwarddt-itemsrecd,
            ist_inwarddt-packr     to ist_inwarddt-packr,
            ist_inwarddt-actwt     to ist_inwarddt-actwt,
            ist_inwarddt-wtuom     to ist_inwarddt-wtuom,
            ist_inwarddt-wtchr     to ist_inwarddt-wtchr,
            ist_inwarddt-chwtuom   to ist_inwarddt-chwtuom,
            ist_inwarddt-indelno   to ist_inwarddt-indelno,
            ist_inwarddt-remarks   to ist_inwarddt-remarks.
      append ist_inwarddt.
    endif.
*     ENDIF.
*   ENDIF.
  else.
*   IF ist_inwarddt-inwrd IS INITIAL.
*      MESSAGE e050.
*   ENDIF.
*******Start of change ( comment-perform ) on 06.08.03*****
    perform indelno-para.
*******End of change (comment-perform) *********************
    modify ist_inwarddt index disprec-current_line.
  endif.
******************** added by cab_dns***************

  IF not l_ebeln_old is INITIAL .


    if l_ebeln_old ne ZMM_INWARDHD-EBELN AND ist_inwarddt is NOT INITIAL.
      refresh ist_inwarddt.
      CLEAR g_ksskflag.
      l_ebeln_old = ZMM_INWARDHD-EBELN..
    endif.

  ENDIF.

  l_ebeln_old = ZMM_INWARDHD-EBELN.
******************** added by cab_dns***************

  if not ist_inwarddt-lrben is initial
     and ist_inwarddt-docty is initial.
    message e045.
  endif.


*  IF ist_inwarddt-packr > ist_inwarddt-packs.
*    MESSAGE e055.
*  ENDIF.


endmodule.                 " modify_ist_inwarddt  INPUT

*&---------------------------------------------------------------------*
*&      Module  modify_ist_inwarddt1  INPUT
*&---------------------------------------------------------------------*
*& To move values from table control to internal table ist_inwarddt
*----------------------------------------------------------------------*
module modify_ist_inwarddt1 input.
*******Start of insertion  on 06.08.03 ***********************
  perform indelno-para.
*******End of insertion **************************************

  modify ist_inwarddt index disprec1-current_line.

endmodule.                 " modify_ist_inwarddt1  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_inwno  INPUT
*&---------------------------------------------------------------------*
*& To validate the Inward No. input
*----------------------------------------------------------------------*
module check_inwno input.

  select single * from zmm_inwardhd where inwno = zmm_inwardhd-inwno.
  if sy-subrc ne 0.
    message e084 with zmm_inwardhd-inwno.
  endif.

  if g_mode = 'Change' or g_mode = 'Delete'.
*    select single * from mkpf where bktxt = zmm_inwardhd-inwno.   "11122013
*    if sy-subrc eq 0.
*      message e025 with zmm_inwardhd-inwno.
*    endif.
  endif.

endmodule.                 " check_inwno  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_autho_rct_loc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module chk_autho_rct_loc input.

  authority-check object 'ZCFLOC'  id 'LOCCD' field zmm_location-loccd
                                   id 'ACTVT' dummy . "field '01-07'

  if sy-subrc ne 0 .
    message e113 with zmm_location-loccd.
  endif .

endmodule.                 " chk_autho_rct_loc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_docty  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_docty INPUT.
  Data : l_ekko like ekko.
*  break cab_sudhir.
  IF ZMM_INWARDHD-RCNNO is initial.
    if not IST_INWARDDT-DOCTY is initial.
      Select single * into l_ekko from ekko
           where ebeln = ZMM_INWARDHD-EBELN.
      if ( l_ekko-bsart = 'MEMI' or
           l_ekko-bsart = 'MPCM' or
           l_ekko-bsart = 'MPOI' or
           l_ekko-bsart = 'MPOM' or
           l_ekko-bsart = 'MPBM' or
           l_ekko-bsart = 'MSUB' ).
        if IST_INWARDDT-DOCTY = 'R' or
           IST_INWARDDT-DOCTY = 'L' or
           IST_INWARDDT-DOCTY = 'O' or
           IST_INWARDDT-DOCTY = 'A'.
*
        else.
          message e521(zmm).
        endif.
      elseif ( l_ekko-bsart = 'MEPI' or
             l_ekko-bsart = 'MICM' or
             l_ekko-bsart = 'MIMM' ).
        if IST_INWARDDT-DOCTY = 'A' or
           IST_INWARDDT-DOCTY = 'D'.
*
        else.
          message e522(zmm).
        endif.
      endif.
    endif.
  ENDIF.
ENDMODULE.                 " check_docty  INPUT
*&---------------------------------------------------------------------*
*&      Module  PICK_SRMSUS_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PICK_SRMSUS_DATA INPUT.
*  break cab_sudhir.
  if g_ksskflag = 'X'.
    SELECT SINGLE logsys FROM zmm_logsys INTO G_logsys
                 WHERE  appl = 'SRD'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ist_inwarddt-indelno
      IMPORTING
        OUTPUT = ist_inwarddt-indelno.


    CALL FUNCTION 'BBP_INB_DELIVERY_GETDETAIL'
      EXPORTING
        IF_DELIVERY            = ist_inwarddt-indelno
      IMPORTING
        ES_INB_DELIVERY_HEADER = g_sus_asn
      TABLES
        ET_INB_DELIVERY_DETAIL = IT_INB_DELIVERY_DETAIL
        RETURN                 = g_return.

    if not g_sus_asn-deliv_ext is initial.
      IF NOT g_logsys  IS INITIAL.
        GI_OBJECT_ID = g_sus_asn-DELIV_EXT.

        CALL FUNCTION 'ZBBP_PD_SUSASN_GETDETAIL' DESTINATION  g_logsys "'SRDCLNT530'
           EXPORTING
            I_OBJECT_ID           =  GI_OBJECT_ID
           IMPORTING
            E_HEADER              =  GE_HEADER .

        ist_inwarddt-docty = GE_HEADER-ZZDOC_TYPE.

        IST_INWARDDT-LRBEN  = GE_HEADER-ZZREF_NO.

        IST_INWARDDT-LRDAT  = GE_HEADER-ZZREF_DATE.

      ELSE.
        MESSAGE e206(zmm).
      ENDIF.
* Commented block on 06122013
*      if ist_inwarddt-lrben is initial or
*          ist_inwarddt-lrdat is initial or
*          ist_inwarddt-docty is initial or
*          ist_inwarddt-packr is initial or
*          ist_inwarddt-packs is initial or
*          ist_inwarddt-itemsrecd is initial.
**          message s994(zmm).
*        loop at screen.
*          if screen-name = 'IST_INWARDDT-LRBEN'     OR
*             screen-name = 'IST_INWARDDT-LRDAT'     OR
*             screen-name = 'IST_INWARDDT-DOCTY'     OR
*             screen-name = 'IST_INWARDDT-PACKS'     OR
*             screen-name = 'IST_INWARDDT-PACKS'     OR
*             screen-name = 'IST_INWARDDT-ITEMSRECD'.
**             screen-required = 1.
*
**            message s994(zmm). " commented by cab_dns
*            modify screen.
*          endif.
*        endloop.
**        get cursor field ist_inwarddt-lrben line DISPREC-CURRENT_LINE.  set
**        message e994(zmm).
*      endif.
* End of Uncommented
    endif.
 SHIFT ist_inwarddt-indelno LEFT DELETING LEADING '0'.
  endif.
*  break cab_sudhir.


ENDMODULE.                 " PICK_SRMSUS_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  PICK_DLY_FROM_PO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PICK_DLY_FROM_PO INPUT.
  perform get_dly_from_po.
ENDMODULE.                 " PICK_DLY_FROM_PO  INPUT
