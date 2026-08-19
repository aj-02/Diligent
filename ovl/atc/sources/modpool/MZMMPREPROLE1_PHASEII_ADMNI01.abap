*--- MAIN PROGRAM: MZMMPREPROLE1_PHASEII_ADMNI01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 697.
************************************************************************
MODULE USER_COMMAND_0100 INPUT.

okcode = sy-ucomm.

Case okcode.

    When 'BAC' OR 'CAN'.

      perform bac_confirm.
*      refresh control 'TABCTRL100' from screen '0100'.
      clear okcode.
      leave program.

    When 'CREATE'.

      g_mode = 'CRE'.
      clear okcode.

    When 'CHANGE'.

      g_mode = 'CHA'.
      clear okcode.

    When 'DISPLAY'.

      g_mode = 'DIS'.
      clear okcode.

    When 'DELETE'.

      g_mode = 'DEL'.
      clear okcode.

    when 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
        .
*        Perform Save_request.

      clear okcode.

    when 'RELEASE'.

      g_mode = 'REL'.
      clear okcode.

    when 'APPROVE'.

      g_mode = 'APR'.
      clear okcode.

 ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: modify table
module TABCTRL100_modify input.

  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABCTRL100_wa.

*  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

    select single * from zmm_prep_rolegrp where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with ZIC_PREP_ROLEREI-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

*  endif.

  if ZIC_PREP_ROLEREI-rej_fl = ''.

      if sy-subrc = 0 and old_ok_code = 'APPROVE'.
        if zmm_prep_rolegrp-approver1 = g_user
           or zmm_prep_rolegrp-approver2 = g_user
           or zmm_prep_rolegrp-approver3 = g_user.
        else.

          if okcode_100 = 'SAV'.
             if err_flg <> 'X'.
                 err_flg = 'X'.
                 clear : sy-ucomm, okcode_100.
             endif.
            message e047(zhelp) with zmm_prep_rolegrp-role_type.
          endif.
        endif.
      endif.

   endif.

  if not g_TABCTRL100_wa-role_name is initial.
**
   if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_TABCTRL100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      endif.
   else.
      select single * from zmm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_TABCTRL100_wa-role_desc = zmm_prep_roledes-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      endif.

   endif.
**
  endif.
  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line.

  if sy-subrc <> 0.
    append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

  if G_TABCTRL100_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABCTRL100_WA-FLAG.
            append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
module TABCTRL100_mark input.
  if TABCTRL100-line_sel_mode = 1 and
     g_TABCTRL100_wa-flag = 'X'.
     loop at g_TABCTRL100_itab into g_TABCTRL100_wa
       where flag = 'X'.
       g_TABCTRL100_wa-flag = ''.
       modify g_TABCTRL100_itab
         from g_TABCTRL100_wa
         transporting flag.
     endloop.
     g_TABCTRL100_wa-flag = 'X'.
  endif.
  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
module TABCTRL100_user_command input.
**  OKCODE = sy-ucomm.
**  perform user_ok_tc using    'TABCTRL100'
**                              'G_TABCTRL100_ITAB'
**                              'FLAG'
**                     changing OKCODE.
**  sy-ucomm = OKCODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.
  TYPES :
           BEGIN of ty_bukrs,
             werks like zd_t001w_bukrs-werks,
             name1 like zd_t001w_bukrs-name1,
           END of ty_bukrs.

  DATA   : it_bukrs type table of ty_bukrs with header line.

  select * from zd_t001w_bukrs into corresponding fields of
             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_BUKRS
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_GRP INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000'  ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-GRP' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

endloop.

  DATA : l_ekgrp like t024-ekgrp.
  data : loop_step like sy-stepl.
  Data : l_role_name like ZIC_PREP_ROLEREI-ROLE_NAME.

  Data l_disc_mm_flag like ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

*  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
*       EXPORTING
*            STRUC = 'ZIC_PREP_ROLEREQ'
*            FIELD = 'DISC_MM_FLAG'
*            REPID = SY-CPROG
*            DYNNR = '0100'
*       IMPORTING
*            VALUE = l_disc_mm_flag.
*
*  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = l_disc_mm_flag.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_role_name.

  if l_role_name = 'M6' or  l_role_name = 'M7' or
     l_role_name = 'M8'.
    concatenate '%' G_CCODE '%' into g_line1.
    select * from t024 into table it_t024 where TELFX like g_line1.

  else.
    if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      concatenate '%' G_CCODE '%' 'IND' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    else.
      concatenate  '%' G_CCODE '%' 'MM' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    endif.
   endif.

 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T024'.
 g_field_wa-fieldname = 'EKGRP'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T024'.
 g_field_wa-fieldname = 'EKNAM'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'EKGRP'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-GRP'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t024
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:it_t024,IST_RETURN_TAB, g_field_tab.
  FREE : it_t024,IST_RETURN_TAB, g_field_tab.
  Clear g_field_wa.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.

  TYPES : Begin of z_role_des,
            role_type like zmm_prep_roledes-role_type,
            brief_desc like zmm_prep_roledes-brief_desc,
            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
            sort_field like zmm_prep_roledes-brief_desc,
            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
          end of z_role_des.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_role type table of z_role_des with header line.

  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    select * from zmm_prep_rolecrc into corresponding fields of
               table it_role.

  else.

    select * from zmm_prep_roledes into corresponding fields of
               table it_role.

  endif.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data INPUT.

 if old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
       old_ok_code = 'DELETE' or old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or ( OLD_OK_CODE = 'CRCROLES' )
       or old_ok_code = 'RELEASE' or ( OLD_OK_CODE = 'APPROVE' ).

     if not  ZIC_PREP_ROLEREQ-userid is initial.
        perform check_tel.
     endif.

     if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' or
        OLD_OK_CODE = 'CRCROLES'.

        if  ZIC_PREP_ROLEREQ-PERSA is initial and
            ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             perform pop_up_message.
        endif.

        if  ZIC_PREP_ROLEREQ-userid is initial.
          message e035(zhelp).
        endif.

        if  ZIC_PREP_ROLEREQ-userid <> old_userid and
          old_userid <> ''.
          clear  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
          clear  ZIC_PREP_ROLEREQ-CCODE.
          clear  ZIC_PREP_ROLEREQ-FUNDC1.
          clear  ZIC_PREP_ROLEREQ-FUNDC.
          clear  ZIC_PREP_ROLEREQ-S_DESC.
          clear  ZIC_PREP_ROLEREQ-RSN_CODE.
          clear  ZIC_PREP_ROLEREQ-RSN_TEXT1.
          clear  ZIC_PREP_ROLEREQ-REASON1.
          clear  ZIC_PREP_ROLEREQ-TELNO.
          clear  ZIC_PREP_ROLEREQ-NAME.
          clear  ZIC_PREP_ROLEREQ-DESIGNATION.
          clear set_disc_mm_flag.
          clear set_disc_fi_flag.
          clear help_list_flag.
          refresh it_m_fistb.
          clear wa_m_fistb.
        endif.

*        select single * from zusrmst where cpfno =
*                                    ZIC_PREP_ROLEREQ-userid.

        select single * from usr02 where bname =
                                    ZIC_PREP_ROLEREQ-userid.

        if sy-subrc ne 0.
          message e043(zhelp).
        else.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-name = zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-designation = zusrmst-designation.

        select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
             ZIC_PREP_ROLEREQ-NAME = ist_data-name.
             ZIC_PREP_ROLEREQ-DESIGNATION = ist_data-designation.
            if ist_data-disc_cd = '36' and set_disc_mm_flag <> 'X'.
                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
                set_disc_mm_flag = 'X'.
            endif.
            if ist_data-disc_cd = '13' and set_disc_fi_flag <> 'X'.
                ZIC_PREP_ROLEREQ-DISC_fi_FLAG = 'X'.
                set_disc_fi_flag = 'X'.
            endif.
***************************************************31.05.2006
             if old_ok_code = 'CREATE' or old_ok_code = 'CRCROLES'.
               ZIC_PREP_ROLEREQ-CCODE = ist_data-bukrs.
             else.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.
             if old_ok_code = 'APPROVE'.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.
***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*             ZIC_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

            if old_ok_code = 'CREATE'.
                if  ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
                   not  ZIC_PREP_ROLEREQ-PERSA is initial.
                   message e108(zhelp).
                endif.
            endif.

        endif.

       clear : ist_data.
       refresh : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006


          concatenate '000'  ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

*          select single * from lfb1 where lifnr = cpf_lfb1.

* Select Company-KBU01, Cost Centre-kst01
* from pa0027  .
    clear wa_pa0027.

    SELECT *
 FROM PA0027 INTO WA_PA0027 UP TO 1 ROWS WHERE PERNR = CPF_LFB1 AND ENDDA = '99991231' AND SPRPS = ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT. " SPRPS - Lock Indicator 'X'

          if sy-subrc = 0.
            if old_ok_code <> 'CROSSCO'.
              concatenate  '''' '%' wa_pa0027-kst01
                           '''' into  g_line1.
              concatenate  'OBJNR'  'LIKE' g_line1 into g_line1
              separated by space.
              refresh :  it_cond.
              append g_line1 to it_cond.
              SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE (IT_COND)
 ORDER BY PRIMARY KEY .
 ENDSELECT.
            endif.
            if sy-subrc = 0.
             if old_ok_code = 'CREATE' or old_ok_code = 'CRCROLES'.
               ZIC_PREP_ROLEREQ-FUNDC1 = fmzuob-fistl.
               ZIC_PREP_ROLEREQ-FUNDC_FL = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
               ZIC_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             else.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
               ZIC_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             endif.

                SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZIC_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc =  0.
                    ZIC_PREP_ROLEREQ-S_DESC = CSKT-LTEXT.
              endif.

              refresh it_cond[].
              clear it_cond.
            else.
            endif.
          endif.

        endif.

     else.

***************************************************

           if  ZIC_PREP_ROLEREQ-docno is initial.
                  message e041(zhelp).
           endif.

     endif.

**********************************************************nn

     select single * from usr02 where bname =
                                    ZIC_PREP_ROLEREQ-userid.

        if sy-subrc ne 0.
        else.
        select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0 and ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
            read table ist_data index 1. "#EC CI_NOORDER
             if old_ok_code = 'APPROVE'.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.
          endif.
        endif.
********************************************************nn
endif.

*Begin of <RD1K963151>.
if ZIC_PREP_ROLEREQ-USERIDCR is not  INITIAL.
      select single * from usr21 where bname = ZIC_PREP_ROLEREQ-USERIDCR.
      if sy-subrc ne 0.
        MESSAGE e803(zmm) with 'User Not Found'.
        endif.
select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data1
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERIDCR and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .
if sy-subrc = 0.
  READ TABLE ist_data1 index 1. "#EC CI_NOORDER
  ZIC_PREP_ROLEREQ-NAMECR = ist_data1-name.
  if sy-subrc = 0 .
    clear ist_data1[].
    endif.
  endif.
  endif.

  if ZIC_PREP_ROLEREQ-USERIDAP is not INITIAL.
    select single * from usr21 where bname = ZIC_PREP_ROLEREQ-USERIDAP.
      if sy-subrc ne 0.
        MESSAGE e803(zmm) with 'User Not Found'.
        endif.
  select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data2
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERIDAP and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .
    if sy-subrc = 0 .
      READ TABLE ist_data2 index 1. "#EC CI_NOORDER
      ZIC_PREP_ROLEREQ-NAMEAPP = ist_data2-name.
      if sy-subrc = 0.
        clear ist_data2[].
        endif.
      endif.
  endif.
*End of <RD1K963151>.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

if moduleid = 'FI' .
   perform call_fi.
endif.

case okcode_100.

    When 'BAC' OR 'CAN'.
      perform exit_confirm.
    When 'EXT'.
      leave program.

    When 'CREATE'.

      old_ok_code = okcode_100.
      moduleid = 'MM'.

    When 'CHANGE'.

     old_ok_code = okcode_100.

    When 'RELEASE'.

     old_ok_code = okcode_100.


    When 'APPROVE'.

     old_ok_code = okcode_100.

    When 'COPY'.


    When 'DISPLAY'.

      old_ok_code = okcode_100.

    When 'ROLE_DEL'.

      old_ok_code = okcode_100.

    WHEN 'SAV'.

      if old_ok_code = 'DELETE'.

          if  ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            if  ZIC_PREP_ROLEREQ-STATUS = ''.
              Perform delete_request.
            else.
              message e138(ZHELP).
            endif.
          else.
            message e056(ZHELP).
          endif.
      else.
*        describe table g_TABLCTRL110_itab lines g_lines_rl.
*        if g_lines_rl = 0.
*           clear okcode_100.
*           message i140(zhelp).
*        else.
        if old_ok_code = 'RELEASE' and
               ZIC_PREP_ROLEREQ-req_cr_fl <> 'X'.
              message i083(zhelp).

        elseif old_ok_code = 'RELEASE' and g_lines_rl = 0.
              message i089(zhelp).

        elseif old_ok_code = 'APPROVE' and
               (  ZIC_PREP_ROLEREQ-req_app_fl <> 'X' and
               ZIC_PREP_ROLEREQ-req_app0_fl <> 'X' and
               ZIC_PREP_ROLEREQ-req_app1_fl <> 'X' ).
**13/04/07
               if module_changed_flag <> 'X'.
                  message i087(zhelp).
               else.
                  Perform Save_request.
               endif.
        elseif old_ok_code = 'APPROVE' and  g_mult_module_fl = 'X'.
           set parameter id 'ZROLEREQNOFORDETAILS'
                  field zic_prep_rolereq-docno.
           call screen 200 starting at 10 15  ending at 90 25.
           perform confirm_app.
           if g_choice_app = 'J'.
              clear g_choice_app.
              if moduleid <> 'MM'.
               g_approver_level = 'L3'.
              endif.
              Perform Save_request.
           endif.
        else.
*          Perform check_items.
          if moduleid <> 'MM'.
           g_approver_level = 'L3'.
          endif.
          Perform Save_request.
        endif.
**       endif.
      endif.

    When 'MULTI'.

*      clear help_list_flag.

      call screen 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      clear okcode_100.


    WHEN 'DELETE'.

       old_ok_code = okcode_100.

    WHEN 'ATTACH'.

*       if old_ok_code = 'CREATE' or
*          old_ok_code = 'CROSSCO' or
*          old_ok_code = 'CRCROLES'.
*          message i137(zhelp).
*       else.
*          perform attach_files.
*       endif.
      if old_ok_code = 'CREATE' or
          old_ok_code = 'CROSSCO' or
          old_ok_code = 'CRCROLES'.
          message i137(zhelp).
       else.
          perform attach_files.
          if old_ok_code = 'DISPLAY' and
             ZIC_PREP_ROLEREQ-status = 'IR'.
             attach_fl = 'X'.
             Perform confirm_more.

            If g_choice_more = 'J'.
              clear g_choice_more.
            else.
              Perform Save_request.
            endif.
          endif.
       endif.

*       old_ok_code = okcode_100.

    WHEN 'LIST'.

       perform list_files.

*       old_ok_code = okcode_100.

    WHEN 'CORR'.

        Call Screen 105 starting at 85 05 ending at 148 24.
        clear okcode_100.

    WHEN 'CROSSCO'.

       old_ok_code = okcode_100.
       moduleid = 'MM'.

    WHEN 'CRCROLES'.

       old_ok_code = okcode_100.

    WHEN 'SUMMARY'.

      set parameter id 'ZROLEREQNOFORDETAILS'
                  field zic_prep_rolereq-docno.
*      call transaction 'ZIC_DETAILS' .

      call screen 200 starting at 10 15  ending at 90 25.

    WHEN OTHERS.

        clear okcode_100.


endcase.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.


ENDMODULE.                 " USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_ok_code INPUT.

  if sy-ucomm = 'DBLCLK'.
     clear sy-ucomm.
  endif.
  okcode_100 = sy-ucomm.

  clear :  err_flg.

**  get cursor line g_cursor_line.
**  g_curr_line = g_cursor_line.
**  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
**  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_data INPUT.

if not  ZIC_PREP_ROLEREQ-docno is initial.

*  data : l_docno like  ZIC_PREP_ROLEREQ-docno.

l_docno =  ZIC_PREP_ROLEREQ-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

   ZIC_PREP_ROLEREQ-docno = l_docno.

endif.

if old_doc_no <>  ZIC_PREP_ROLEREQ-docno.
                    clear g_hd_copied.
                    clear g_mult_module_fl.
                 perform destroy_ctrl.
endif.

if not moduleid is initial and old_moduleid <> moduleid.
            g_TABLCTRL110_copied = ''.
            g_TABLCTRL111_copied = ''.
            g_TABLCTRL112_copied = ''.
            g_TABLCTRL113_copied = ''.
            g_TABLCTRL114_copied = ''.
            g_TABLCTRL115_copied = ''.
endif.

ENDMODULE.                 " clear_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.

GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
       IMPORTING
            TEXT       =  LT_TEXT_TABLE1
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE1
            ITF_TEXT    = TLINETAB1.
*
  if ( old_ok_code = 'CREATE' )
  or ( old_ok_code = 'CROSSCO' )
  or ( old_ok_code = 'CRCROLES' )
  or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' )
   or ( old_ok_code = 'DISPLAY' and  ZIC_PREP_ROLEREQ-comm_fl = 'X'
        and  ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

    CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
         IMPORTING
              TEXT       =  LT_TEXT_TABLE2
              IS_MODIFIED = GV_XTHEAD_UPDKZ
         EXCEPTIONS
              ERROR_DP               = 1
              ERROR_CNTL_CALL_METHOD = 2
              OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
         TABLES
              TEXT_STREAM = LT_TEXT_TABLE2
              ITF_TEXT    = TLINETAB2.
    DESCRIBE TABLE TLINETAB2 LINES g_lines_2.
  ENDIF..

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0105 INPUT.

Data: okcode105 like sy-ucomm.

  okcode105 = sy-ucomm.

  Case okcode105.
    When 'OK'.
      clear okcode105.
    When 'CANCEL'.
      refresh tlinetab2[].
      clear okcode105.
  Endcase.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SLOC' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  Data : l_plant like ZIC_PREP_ROLEREI-PLANT.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_plant.


  DATA   : it_t001l type table of t001l with header line.
  DATA   : it_excp_sl type table of zmm_prep_sl_excp with header line.
  DATA   : wa_t001l like t001l.
  DATA   : l_zarea like zmm_consm-zarea.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

   if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

         loop at it_t001l into wa_t001l.

             SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc = 0.

                  if l_zarea+0(1) <> 'M'.
                    delete it_t001l.
                  endif.

              else.

                 delete it_t001l.

              endif.

          endloop.

    else.

          loop at it_t001l into wa_t001l.

             SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc = 0.

                if l_zarea+0(1) = 'M'.
                  delete it_t001l.
                endif.

              else.

                  delete it_t001l.

              endif.

          endloop.

    endif.

    select * from zmm_prep_sl_excp into table it_excp_sl.

************************************

    loop at it_excp_sl.

       read table it_t001l with key werks = it_excp_sl-werks
       lgort = it_excp_sl-lgort.

       if sy-subrc = 0.

          delete it_t001l where werks = it_excp_sl-werks
          and lgort = it_excp_sl-lgort.

       endif.

    endloop.

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'WERKS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGORT'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGOBE'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t001l
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
     clear dis_flag.

  ENDIF.

  REFRESH:IT_t001l,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_t001l,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_APPROVER INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-APPROVER' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  data : it_approver like table of zmm_prep_approve.
  data : wa_approver like zmm_prep_approve.

  data : it_approver1 like table of zmm_prep_app_CRC.
  data : wa_approver1 like zmm_prep_app_CRC.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_role_name.

     if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*
*
*              if l_role_name = 'M11'.
*
*                  loop at it_approver into wa_approver.
*
*                    if wa_approver-M11_FLAG <> 'X'.
*                      delete it_approver.
*                    endif.
*
*                  endloop.
*
*              endif.
*
*      endif.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*         if l_role_name = 'M11'.
*
*            loop at it_approver into wa_approver.
*
*                if wa_approver-M11_FLAG <> 'X'.
*                    delete it_approver.
*                 endif.
*
*            endloop.
*
*         endif.
*
*      endif.
*******************************************************
           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-M11S_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.

             if l_role_name = 'M11M'.

                loop at it_approver into wa_approver.

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'
                        or wa_approver-M11M_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-MM_FLAG = 'X'
                         or wa_approver-M11M_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.
**************************************************22.05.06

        if l_role_name = 'M8'.

            loop at it_approver into wa_approver.

                if wa_approver-M8_FLAG <> 'X'.
                    delete it_approver.
                 endif.

            endloop.

         endif.

         if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

             if l_role_name = 'M3'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

             if l_role_name = 'M3A'. "22.05.06

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3A_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

            if l_role_name = 'M3B'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3B_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

           endif.                       " 22.05.06


             if l_role_name = 'M11S'.

                loop at it_approver1 into wa_approver1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11S_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11S_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

            if l_role_name = 'M11M'.

                loop at it_approver1 into wa_approver1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11M_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11M_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

             it_approver[] = it_approver1[].

         endif.

 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
 g_field_wa-fieldname = 'APP_LEVEL'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
 g_field_wa-fieldname = 'L_DESC'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'APP_LEVEL'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-APPROVER'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_approver
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 else.
     clear dis_flag.

  ENDIF.

  REFRESH:it_approver,IST_RETURN_TAB, it_approver1,g_field_tab.
  FREE  : it_approver,IST_RETURN_TAB, it_approver1,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RECEIPT_LOC INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC' and screen-input =
 0.
        dis_flag = 'X'.
      endif.

  endloop.


  data : it_recpt like table of zmm_location.
  data : wa_recpt like zmm_location.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_role_name.

      select * from zmm_location into table it_recpt.


             if l_role_name = 'M12'.

                  loop at it_recpt into wa_recpt.

                    if wa_recpt-loccg <> 'RL'.
                      delete it_recpt.
                    endif.

                  endloop.

              endif.


              if l_role_name = 'M17'.

                  loop at it_recpt into wa_recpt.

                    if wa_recpt-loccg <> 'CF'.
                      delete it_recpt.
                    endif.

                  endloop.

              endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

   g_field_wa-tabname = 'ZMM_LOCATION'.
   g_field_wa-fieldname = 'LOCCD'.
   append g_field_wa to g_field_tab.
   g_field_wa-tabname = 'ZMM_LOCATION'.
   g_field_wa-fieldname = 'LOCCG'.
   append g_field_wa to g_field_tab.
   g_field_wa-tabname = 'ZMM_LOCATION'.
   g_field_wa-fieldname = 'LOCDS'.
   append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LOCCD'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_recpt
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 else.
     clear dis_flag.

  ENDIF.

  REFRESH:it_recpt,IST_RETURN_TAB,g_field_tab.
  FREE  : it_recpt,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

if sy-ucomm = 'EXT'.
      leave program.
endif.


ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.

old_doc_no =  ZIC_PREP_ROLEREQ-docno.
old_userid =  ZIC_PREP_ROLEREQ-userid.
old_disc_mm_flag =  ZIC_PREP_ROLEREQ-disc_mm_flag.
old_moduleid = moduleid.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

*  clear g_e_fl.

  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i117(zhelp).
    elseif ZIC_PREP_ROLEREI-ROLE_NAME+0(1) <> 'C'.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

  endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-RECEIPT_LOC.
  clear  ZIC_PREP_ROLEREI-SLOC.
  clear  ZIC_PREP_ROLEREI-plant.
  clear  ZIC_PREP_ROLEREI-grp.
  clear  ZIC_PREP_ROLEREI-approver.

  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZIC_PREP_ROLEREI-RECEIPT_LOC.
      clear  ZIC_PREP_ROLEREI-SLOC.
      clear  ZIC_PREP_ROLEREI-plant.
      clear  ZIC_PREP_ROLEREI-grp.
      clear  ZIC_PREP_ROLEREI-approver.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZIC_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZIC_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if  ZIC_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           if ZIC_PREP_ROLEREI-role_name <> ''.
             message e081(zhelp) with ZIC_PREP_ROLEREI-role_name.
           endif.
         endif.

   endif.

 endif.

*  endif.

  if not ZIC_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.
*
*
* if l_role_name = 'M6' or  l_role_name = 'M7' or
*     l_role_name = 'M8'.
*
* else.
*
*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*            loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) between '0' and 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*
*      else.
*
*          loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) < '0'  or
*              l_ekgrp+1(1) > 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*      endif.
*
* endif.
*
**
 if g_TABLCTRL110_wa-role_name = 'M6' or
     g_TABLCTRL110_wa-role_name = 'M7' or
     g_TABLCTRL110_wa-role_name = 'M8'.
    concatenate '%' G_CCODE '%' into g_line1.
    select * from t024 into table it_t024 where TELFX like g_line1.
  else.
    if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      concatenate '%' G_CCODE '%' 'IND' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    else.
      concatenate  '%' G_CCODE '%' 'MM' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    endif.
   endif.
**
   if  not ZIC_PREP_ROLEREI-GRP is initial.

       loop at it_t024 into wa_t024.

           if ZIC_PREP_ROLEREI-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL110_wa.
          modify g_TABLCTRL110_itab
                    from g_TABLCTRL110_wa
                      index TABLCTRL110-current_line.
          g_i = TABLCTRL110-current_line.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( ZIC_PREP_ROLEREI-role_name = 'M13' or
   ZIC_PREP_ROLEREI-role_name = 'M14' or
    ZIC_PREP_ROLEREI-role_name = 'M16' or
    ZIC_PREP_ROLEREI-role_name = 'M18' or
    ZIC_PREP_ROLEREI-role_name = 'M19' ) and
    not ZIC_PREP_ROLEREI-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = ZIC_PREP_ROLEREI-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
       message e074(zhelp).

    endif.

endif.

   if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

         loop at it_t001l into wa_t001l.

             SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc = 0.

                  if l_zarea+0(1) <> 'M'.
                    delete it_t001l.
                  endif.

              else.

                 delete it_t001l.

              endif.

          endloop.

    else.

          loop at it_t001l into wa_t001l.

             SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc = 0.

                if l_zarea+0(1) = 'M'.
                  delete it_t001l.
                endif.

              else.

                  delete it_t001l.

              endif.

          endloop.

    endif.

    if  not ZIC_PREP_ROLEREI-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if ZIC_PREP_ROLEREI-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( ZIC_PREP_ROLEREI-role_name = 'M12' or
       ZIC_PREP_ROLEREI-role_name = 'M17' ) and
       not ZIC_PREP_ROLEREI-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if ZIC_PREP_ROLEREI-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if ZIC_PREP_ROLEREI-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not ZIC_PREP_ROLEREI-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if ZIC_PREP_ROLEREI-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          message e075(zhelp).

       endif.

    endif.


*****************************
*****************************22.05.06

if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.

           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-M11S_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.

             if l_role_name = 'M11M'.

                loop at it_approver into wa_approver.

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'
                        or wa_approver-M11M_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-MM_FLAG = 'X'
                         or wa_approver-M11M_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.
**************************************************22.05.06

        if l_role_name = 'M8'.

            loop at it_approver into wa_approver.

                if wa_approver-M8_FLAG <> 'X'.
                    delete it_approver.
                 endif.

            endloop.

         endif.

         if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

             if l_role_name = 'M3'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

             if l_role_name = 'M3A'. "22.05.06

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3A_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

            if l_role_name = 'M3B'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3B_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

           endif.                       " 22.05.06


             if l_role_name = 'M11S'.

                loop at it_approver1 into wa_approver1.

                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11S_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11S_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

            if l_role_name = 'M11M'.

                loop at it_approver1 into wa_approver1.

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11M_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11M_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

             it_approver[] = it_approver1[].

         endif.
*********************************************22.05.06

if  not ZIC_PREP_ROLEREI-APPROVER is initial.

       loop at it_approver into wa_approver.

           if ZIC_PREP_ROLEREI-APPROVER = wa_approver-app_level.
              approver_flag = 'X'.
           endif.

       endloop.

       if approver_flag = 'X'.
          clear approver_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL110_wa.
          modify g_TABLCTRL110_itab
                    from g_TABLCTRL110_wa
                      index TABLCTRL110-current_line.
          g_i = TABLCTRL110-current_line.
          message e135(zhelp).
          call screen 100.

       endif.

   endif.


endif.

ENDMODULE.                 " validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE record_rej_id_data INPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> 'CHANGE'.
**13/04/07
if ZIC_PREP_ROLEREI-rej_id is initial.
  ZIC_PREP_ROLEREI-rej_id = sy-uname.
  ZIC_PREP_ROLEREI-rej_date = sy-datum.
endif.

if not ZIC_PREP_ROLEREI-rej_fl is initial and
   ZIC_PREP_ROLEREI-rej_fl_save is initial.

    select single * from  ZMM_PREP_REJ_LIS  where
      rej_code = ZIC_PREP_ROLEREI-rej_fl .
    if sy-subrc <> 0.
      g_e_fl = 'X'.
      message e111(zhelp).
    else.
      if g_user = 'L1' and ZIC_PREP_ROLEREI-rej_fl <> 'R'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'L3' and ZIC_PREP_ROLEREI-rej_fl <> 'B'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'IM' and ZIC_PREP_ROLEREI-rej_fl <> 'I'.
        g_e_fl = 'X'.
        message e111(zhelp).
      endif.
    endif.
endif.
**
endif.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.

data : tel_len type i.
  tel_len = strlen(  ZIC_PREP_ROLEREQ-TELNO ).
  if   ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
    message e097(zhelp).
  Else.
    if tel_len < 7.
      message e098(zhelp).
    Endif.
  Endif.

ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data1 INPUT.

if old_ok_code = 'CRCROLES'.

   SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
else.

   select single * from zmm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

endif.

if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
            not g_role_name_prev is initial.
    g_role_name_flag = 'X'.
endif.
g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_read  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_read INPUT.
clear g_read_fl.
ENDMODULE.                 " clear_read  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno INPUT.
clear g_srno.
loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL110_wa-srno = g_srno.
      modify g_TABLCTRL110_itab from g_TABLCTRL110_wa.
endloop.
describe table g_TABLCTRL110_itab  lines g_lines_rl.
describe table g_TABLCTRL110_itab  lines TABLCTRL110-lines.
clear g_srno.

ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup INPUT.
if not g_TABCTRL100_itab[] is initial .

  delete adjacent duplicates from g_TABCTRL100_itab
  comparing role_name plant grp sloc receipt_loc approver.

endif.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
g_role_name_prev = ZIC_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: modify table
module TABLCTRL110_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL110_wa.

  select single * from zmm_prep_rolegrp where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

  if ZIC_PREP_ROLEREI-rej_fl = ''.

      if sy-subrc = 0 and old_ok_code = 'APPROVE'.
        if zmm_prep_rolegrp-approver1 = g_user
           or zmm_prep_rolegrp-approver2 = g_user
           or zmm_prep_rolegrp-approver3 = g_user.
        else.

          if okcode_100 = 'SAV'.
             if err_flg <> 'X'.
                 err_flg = 'X'.
                 clear : sy-ucomm, okcode_100.
             endif.
            message e047(zhelp) with zmm_prep_rolegrp-role_type.
          endif.
        endif.
      endif.

   endif.

  if not g_TABLCTRL110_wa-role_name is initial.
   if old_ok_code = 'CRCROLES' or zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        g_TABCTRL100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
      endif.
   else.
      select single * from zmm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0.
        g_TABLCTRL110_wa-role_desc = zmm_prep_roledes-brief_desc.
      endif.
   endif.
  endif.

 modify g_TABLCTRL110_itab
    from g_TABLCTRL110_wa
    index TABLCTRL110-current_line.

  if sy-subrc <> 0.
    append g_TABLCTRL110_wa to g_TABLCTRL110_itab.
  endif.

  if G_TABLCTRL110_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL110_WA-FLAG.
            append g_TABLCTRL110_wa to g_TABLCTRL110_itab.
  endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: mark table
module TABLCTRL110_mark input.
  if TABLCTRL110-line_sel_mode = 1 and
     g_TABLCTRL110_wa-flag = 'X'.
     loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa
       where flag = 'X'.
       g_TABLCTRL110_wa-flag = ''.
       modify g_TABLCTRL110_itab
         from g_TABLCTRL110_wa
         transporting flag.
     endloop.
     g_TABLCTRL110_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL110_itab
    from g_TABLCTRL110_wa
    index TABLCTRL110-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: process user command
module TABLCTRL110_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL110'
                              'G_TABLCTRL110_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_110 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL110-top_line + g_cursor_line - 1.
  g_curr_line_110 = g_curr_line.

ENDMODULE.                 " get_cursor_line_110  INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: modify table
module TABLCTRL111_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL111_wa.

  select single * from zpm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL111_wa-role_desc = zpm_prep_roledes-brief_desc.

    modify g_TABLCTRL111_itab
      from g_TABLCTRL111_wa
      index TABLCTRL111-current_line.

  if sy-subrc <> 0.
    append g_TABLCTRL111_wa to g_TABLCTRL111_itab.
  endif.

  if G_TABLCTRL111_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL111_WA-FLAG.
            append g_TABLCTRL111_wa to g_TABLCTRL111_itab.
  endif.
endmodule.

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: mark table
module TABLCTRL111_mark input.
  if TABLCTRL111-line_sel_mode = 1 and
     g_TABLCTRL111_wa-flag = 'X'.
     loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa
       where flag = 'X'.
       g_TABLCTRL111_wa-flag = ''.
       modify g_TABLCTRL111_itab
         from g_TABLCTRL111_wa
         transporting flag.
     endloop.
     g_TABLCTRL111_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL111_itab
    from g_TABLCTRL111_wa
    index TABLCTRL111-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: process user command
module TABLCTRL111_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL111'
                              'G_TABLCTRL111_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_111 INPUT.

 get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL111-top_line + g_cursor_line - 1.
  g_curr_line_111 = g_curr_line.

ENDMODULE.                 " get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11 INPUT.

select single * from zpm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
            not g_role_name_prev is initial.
    g_role_name_flag = 'X'.
endif.
g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11a INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zpm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-SHOP_NO.
  clear  ZIC_PREP_ROLEREI-plant.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZIC_PREP_ROLEREI-SHOP_NO.
     clear  ZIC_PREP_ROLEREI-plant.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

     select * from zpm_prep_roledes into corresponding fields of
                 table it_role.

     if zic_prep_rolereq-ccode = 'BDW' or
        zic_prep_rolereq-ccode = 'SBW'.
     else.
        delete it_role where role_type = 'PM14' or
        role_type = 'PM15' or role_type = 'PM16'.
     endif.

     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.
ENDMODULE.                 " validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno11 INPUT.

clear g_srno.
loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL111_wa-srno = g_srno.
      modify g_TABLCTRL111_itab from g_TABLCTRL111_wa.
endloop.
describe table g_TABLCTRL111_itab  lines g_lines_rl.
describe table g_TABLCTRL111_itab  lines TABLCTRL111-lines.
clear g_srno.

ENDMODULE.                 " change_srno11  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PM INPUT.
loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.

*  TYPES : Begin of z_role_des,
*            role_type like zmm_prep_roledes-role_type,
*            brief_desc like zmm_prep_roledes-brief_desc,
*            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
*            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
*            sort_field like zmm_prep_roledes-brief_desc,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
*          end of z_role_des.

*  DATA   : it_role type table of z_role_des with header line.
*

    select * from zpm_prep_roledes into corresponding fields of
               table it_role.

   sort it_role ascending by sort_field.

   if zic_prep_rolereq-ccode = 'BDW' or
      zic_prep_rolereq-ccode = 'SBW'.
   else.
      delete it_role where role_type = 'PM14' or
      role_type = 'PM15' or role_type = 'PM16'.
   endif.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SHOP_NO INPUT.
  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SHOP_NO' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
  TYPES :
           BEGIN of ty_shop,
             werks like t357-werks,
             beber like t357-beber,
             fing  like t357-fing,
           END of ty_shop.

  DATA   : it_shop type table of ty_shop with header line.

  select * from T357 into corresponding fields of
             table it_shop  where werks =  '53C1' or
                                  werks =  '24C1'.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'BEBER'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SHOP_NO'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_SHOP
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_MODULEID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_MODULEID INPUT.

  data : it_module like table of ZIC_MODULES.
  data : wa_module like ZIC_MODULES.

**  data : l_docno like zic_prep_rolereq-DOCNO.
*  data : l_dynnr like sy-dynnr.
*
*  if sy-dynnr <> '0100'.
*     l_dynnr = '0100'.
*  else.
*     l_dynnr = sy-dynnr.
*  endif.

*  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
*       EXPORTING
*            STRUC = 'ZIC_PREP_ROLEREQ'
*            FIELD = 'DOCNO'
*            REPID = SY-CPROG
*            DYNNR = '0100'
*       IMPORTING
*            VALUE = l_docno.

l_docno = ZIC_PREP_ROLEREQ-DOCNO.

* clear l_dynnr.

    if old_ok_code = 'CREATE'  or
       old_ok_code = 'CROSSCO'  or
       old_ok_code = 'CRCROLES' or
       old_ok_code = 'CHANGE'.

       select  moduleid from zice_prep_module into corresponding fields
        of table it_module.

     else.

        select distinct moduleid from zic_prep_rolerei into
          corresponding fields of table it_module where DOCNO = l_docno.

     endif.

     loop at it_module into wa_module.
        select single * from zice_prep_module where moduleid =
        wa_module-moduleid.
        wa_module-z_desc = zice_prep_module-z_desc.
        modify it_module from wa_module.
      endloop.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'MODULEID'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'MODULEID'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_module
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 else.
     clear dis_flag.

  ENDIF.

  REFRESH:it_module,IST_RETURN_TAB.
  FREE  : it_module,IST_RETURN_TAB.

ENDMODULE.                 " POV_MODULEID  INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: modify table
module TABLCTRL112_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL112_wa.
  select single * from zps_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
*       g_val_err = 'X'.
*       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL112_wa-role_desc = zps_prep_roledes-brief_desc.

   modify g_TABLCTRL112_itab
    from g_TABLCTRL112_wa
    index TABLCTRL112-current_line.
    if sy-subrc <> 0.
      append g_TABLCTRL112_wa to g_TABLCTRL112_itab.
    endif.

    if G_TABLCTRL112_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL112_WA-FLAG.
            append g_TABLCTRL112_wa to g_TABLCTRL112_itab.
    endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: mark table
module TABLCTRL112_mark input.
  if TABLCTRL112-line_sel_mode = 1 and
     g_TABLCTRL112_wa-flag = 'X'.
     loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa
       where flag = 'X'.
       g_TABLCTRL112_wa-flag = ''.
       modify g_TABLCTRL112_itab
         from g_TABLCTRL112_wa
         transporting flag.
     endloop.
     g_TABLCTRL112_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL112_itab
    from g_TABLCTRL112_wa
    index TABLCTRL112-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: process user command
module TABLCTRL112_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL112'
                              'G_TABLCTRL112_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_112 INPUT.
 get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL112-top_line + g_cursor_line - 1.
  g_curr_line_112 = g_curr_line.

ENDMODULE.                 " get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data12 INPUT.

if not ZIC_PREP_ROLEREI-role_name is initial.

  select single * from zps_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

  if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
              not g_role_name_prev is initial.
      g_role_name_flag = 'X'.
  endif.
  g_read_fl = 'X'.

 endif.
ENDMODULE.                 " validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data12a INPUT.
if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X' and not ZIC_PREP_ROLEREI-ROLE_NAME is initial
   and not ZIC_PREP_ROLEREI-SERVICE is initial.

    select single * from zps_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    else.
       g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
*  clear  ZIC_PREP_ROLEREI-SERVICE.
  clear  ZIC_PREP_ROLEREI-PROJECT.
  clear  ZIC_PREP_ROLEREI-LOCATION.
*  clear  ZIC_PREP_ROLEREI-REGION.
  clear  ZIC_PREP_ROLEREI-ASSET.
  clear  ZIC_PREP_ROLEREI-BASIN.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
      clear g_role_name_flag.
*      clear  ZIC_PREP_ROLEREI-SERVICE.
      clear  ZIC_PREP_ROLEREI-PROJECT.
      clear  ZIC_PREP_ROLEREI-LOCATION.
*      clear  ZIC_PREP_ROLEREI-REGION.
      clear  ZIC_PREP_ROLEREI-ASSET.
      clear  ZIC_PREP_ROLEREI-BASIN.
endif.


g_field = 'ZIC_PREP_ROLEREI-SERVICE'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-SERVICE is initial.

      select * from zps_prep_service into corresponding fields of
                 table it_service where
                 service = ZIC_PREP_ROLEREI-SERVICE.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
            g_i = g_curr_line_112.
            message e169(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-PROJECT is initial.

      select * from zps_prep_project into corresponding fields of
                 table it_project where
                 service = ZIC_PREP_ROLEREI-service and
                 project = ZIC_PREP_ROLEREI-PROJECT.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
            g_i = g_curr_line.
            message e170(zhelp) with ZIC_PREP_ROLEREI-project.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-LOCATION is initial.

      select * from zps_prep_loca into corresponding fields of
             table it_loca where ccode = zic_prep_rolereq-ccode
             and location = ZIC_PREP_ROLEREI-LOCATION and
             service = zic_prep_rolerei-service.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
            g_i = g_curr_line.
            message e171(zhelp) with ZIC_PREP_ROLEREI-location.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ASSET is initial.

      if ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
         select * from zps_prep_asst_ex into corresponding fields of
               table it_asset where ccode = 'MUM' and
                     asset = ZIC_PREP_ROLEREI-ASSET.

         if sy-subrc <> 0 and ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
              g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-ASSET'.
              g_i = g_curr_line.
              message e172(zhelp) with ZIC_PREP_ROLEREI-asset.
          endif.

      else.
          if ZIC_PREP_ROLEREI-ASSET <> ZIC_PREP_ROLEREQ-CCODE and
             ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
             g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-ASSET'.
              g_i = g_curr_line.
              message e172(zhelp) with ZIC_PREP_ROLEREI-asset.
          endif.
      endif.
   endif.


   if not ZIC_PREP_ROLEREI-BASIN is initial.

       if ZIC_PREP_ROLEREI-BASIN <> ZIC_PREP_ROLEREQ-CCODE and
           ZIC_PREP_ROLEREI-BASIN <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-BASIN'.
            g_i = g_curr_line.
            message e173(zhelp) with ZIC_PREP_ROLEREI-basin.
       endif.

    endif.

   if not ZIC_PREP_ROLEREI-role_name is initial and
          not zic_prep_rolerei-service is initial.

     select * from zps_prep_roledes into corresponding fields of
                 table it_role.

     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno12 INPUT.
clear g_srno.
loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL112_wa-srno = g_srno.
      modify g_TABLCTRL112_itab from g_TABLCTRL112_wa.
endloop.
describe table g_TABLCTRL112_itab  lines g_lines_rl.
describe table g_TABLCTRL112_itab  lines TABLCTRL112-lines.
clear g_srno.
ENDMODULE.                 " change_srno12  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PS INPUT.

  data : l_service like ZIC_PREP_ROLEREI-SERVICE.

  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.

  DATA: BEGIN OF seltab OCCURS 0,
         SIGN(1),
         OPTION(2),
         LOW  LIKE ZIC_PREP_ROLEREI-ROLE_NAME,
         HIGH LIKE ZIC_PREP_ROLEREI-ROLE_NAME,
      END OF seltab.

   CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.


   select * from zps_prep_serv_rl into corresponding fields of
            table it_role where service = l_service.

   loop at it_role.

     seltab-sign   = 'I'.
     seltab-OPTION = 'EQ'.
     seltab-low    = IT_ROLE-ROLE_TYPE.
     append seltab.

   endloop.

   select * from zps_prep_roledes into corresponding fields of
               table it_role where role_type in seltab.

   sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab, seltab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab, seltab.
  Clear : g_field_wa.



ENDMODULE.                 " POV_ROLE_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  dummy  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dummy INPUT.
 perform check_module_fi.
 if not old_moduleid is initial and old_moduleid <> moduleid and
*    old_ok_code = 'CHANGE'.
**13/04/07
    ( old_ok_code = 'CHANGE' or old_ok_code = 'APPROVE' ).
    okcode_100 = 'SAV'.
    new_moduleid = moduleid.
    moduleid = old_moduleid.
    module_changed_flag = 'X'.
    clear old_moduleid.
 endif.
ENDMODULE.                 " dummy  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SERVIVES_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SERVISES_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SERVICE' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_service type table of zps_prep_service with header line.

  select * from zps_prep_service into corresponding fields of
             table it_service.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'SERVICE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SERVICE'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_SERVICE
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_SERVICE,IST_RETURN_TAB.
  FREE : IT_SERVICE,IST_RETURN_TAB.

ENDMODULE.                 " POV_SERVIVES_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PROJECTS_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PROJECTS_PS INPUT.

 loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PROJECT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  data : loop_step like sy-stepl.
*  Data : l_service like ZIC_PREP_ROLEREI-SERVICE.
*
  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_project type table of zps_prep_project with header line.

  select * from zps_prep_project into corresponding fields of
             table it_project where service = l_service.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'PROJECT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PROJECT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_PROJECT
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_PROJECT,IST_RETURN_TAB.
  FREE : IT_PROJECT,IST_RETURN_TAB.

ENDMODULE.                 " POV_PROJECTS_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ASSET_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ASSET_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ASSET' and screen-input = 0.
        dis_flag = 'X'.
      endif.

endloop.

 CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.

*  types :
*        begin of asset_ty,
*              ccode type ZIC_PREP_ROLEREQ-CCODE,
*              asset type ZIC_PREP_ROLEREI-BASIN,
*              a_desc type Zchar80,
*        end of asset_ty.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_asset type table of asset_ty with header line.

  if ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
     select * from zps_prep_asst_ex into corresponding fields of table
               it_asset.
  else.
      move ZIC_PREP_ROLEREQ-CCODE to it_asset-asset.
      move ZIC_PREP_ROLEREQ-CCODE to it_asset-ccode.
      append it_asset.
  endif.
  move 'ALL'                  to it_asset-asset.
  move 'ALL'                  to it_asset-ccode.
  move 'ALL'                  to it_asset-a_desc.

  if l_service <> 'WS'.
    append it_asset.
  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ASSET'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ASSET'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_ASSET
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ASSET,IST_RETURN_TAB.
  FREE  : IT_ASSET,IST_RETURN_TAB.
  CLEAR : IT_ASSET.

ENDMODULE.                 " POV_ASSET_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_BASIN_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_BASIN_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-BASIN' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  types :
*        begin of basin_ty,
*              ccode type ZIC_PREP_ROLEREQ-CCODE,
*              basin type ZIC_PREP_ROLEREI-BASIN,
*              b_desc type Zchar80,
*        end of basin_ty.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_basin type table of basin_ty with header line.

  move ZIC_PREP_ROLEREQ-CCODE to it_basin-basin.
  move ZIC_PREP_ROLEREQ-CCODE to it_basin-ccode.
  select single * from t001 where bukrs = ZIC_PREP_ROLEREQ-CCODE.
  move t001-BUTXT to it_basin-b_desc.
  append it_basin.
  move 'ALL'                  to it_basin-basin.
  move 'ALL'                  to it_basin-ccode.
  move 'ALL'                  to it_basin-b_desc.
  append it_basin.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'BASIN'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-BASIN'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_BASIN
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_BASIN,IST_RETURN_TAB.
  FREE : IT_BASIN,IST_RETURN_TAB.

ENDMODULE.                 " POV_BASIN_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_LOCATION_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_LOCATION_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-LOCATION' and screen-input = 0.
        dis_flag = 'X'.
      endif.

endloop.

CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_location type table of zps_prep_loc with header line.

  select * from zps_prep_loca into corresponding fields of
             table it_loca where service = l_service and
             ccode = zic_prep_rolereq-ccode.

*  if l_service = 'RD' and zic_prep_rolereq-ccode = 'AMD'.
*     clear it_location.
*     refresh it_location[].
*     it_location-ccode = zic_prep_rolereq-ccode.
*     it_location-location = 'IR'.
*     it_location-l_desc = 'INSTITUTE OF RESERVOIR STUDIES'.
*     append it_location.
*  else.
*  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LOCATION'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-LOCATION'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_LOCA
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_LOCA,IST_RETURN_TAB.
  FREE : IT_LOCA,IST_RETURN_TAB.

ENDMODULE.                 " POV_LOCATION_PS  INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: modify table
module TABLCTRL113_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL113_wa.

  select single * from zpp_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL113_wa-role_desc = zpp_prep_roledes-brief_desc.

    modify g_TABLCTRL113_itab
    from g_TABLCTRL113_wa
    index TABLCTRL113-current_line.

    if sy-subrc <> 0.
      append g_TABLCTRL113_wa to g_TABLCTRL113_itab.
    endif.

    if G_TABLCTRL113_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL113_WA-FLAG.
            append g_TABLCTRL113_wa to g_TABLCTRL113_itab.
    endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: mark table
module TABLCTRL113_mark input.
  if TABLCTRL113-line_sel_mode = 1 and
     g_TABLCTRL113_wa-flag = 'X'.
     loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa
       where flag = 'X'.
       g_TABLCTRL113_wa-flag = ''.
       modify g_TABLCTRL113_itab
         from g_TABLCTRL113_wa
         transporting flag.
     endloop.
     g_TABLCTRL113_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL113_itab
    from g_TABLCTRL113_wa
    index TABLCTRL113-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: process user command
module TABLCTRL113_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL113'
                              'G_TABLCTRL113_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_113 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL113-top_line + g_cursor_line - 1.
  g_curr_line_113 = g_curr_line.

ENDMODULE.                 " get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data13 INPUT.

  select single * from zpp_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

  if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
              not g_role_name_prev is initial.
      g_role_name_flag = 'X'.
  endif.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data13a INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zpp_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    else.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-PLANT.
  clear  ZIC_PREP_ROLEREI-SLOC.
  clear  ZIC_PREP_ROLEREI-RES.
  clear  ZIC_PREP_ROLEREI-CTF_SLOC.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
      clear g_role_name_flag.
      clear  ZIC_PREP_ROLEREI-PLANT.
      clear  ZIC_PREP_ROLEREI-SLOC.
      clear  ZIC_PREP_ROLEREI-RES.
      clear  ZIC_PREP_ROLEREI-CTF_SLOC.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

  select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
   if sy-subrc = 0.

   select single * from zhelp_pproles1 into corresponding fields of
                        zhelp_pproles1 where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.

   if sy-subrc <> 0.

   select single * from ZPP_PREP_GENERIC into corresponding fields of
                        ZPP_PREP_GENERIC where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            message e195(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.
   else.
             g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.


   endif.

   endif.

   if not ZIC_PREP_ROLEREI-SLOC is initial.

    select single * from t001l into corresponding fields of
             it_t001l  where werks = ZIC_PREP_ROLEREI-PLANT
             and lgort = ZIC_PREP_ROLEREI-SLOC.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
            g_i = g_curr_line.
            message e073(zhelp) with ZIC_PREP_ROLEREI-sloc.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-RES is initial.

      select single * from zpp_prep_res into corresponding fields of
             it_res  where role_type = ZIC_PREP_ROLEREI-ROLE_NAME
             and
             plant = ZIC_PREP_ROLEREI-PLANT
             and
             res = ZIC_PREP_ROLEREI-RES.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-RES'.
            g_i = g_curr_line.
            message e183(zhelp) with ZIC_PREP_ROLEREI-res.

      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ctf_sloc is initial.

     select single * from ZPP_PREP_DROLEEX where role_type =
         ZIC_PREP_ROLEREI-ROLE_NAME
         and plant = ZIC_PREP_ROLEREI-PLANT
         and sloc = ZIC_PREP_ROLEREI-SLOC
         and ctf_sloc = ZIC_PREP_ROLEREI-CTF_SLOC.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
            g_i = g_curr_line.
            message e073(zhelp) with ZIC_PREP_ROLEREI-ctf_sloc.

      endif.

    endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

     select * from zpp_prep_roledes into corresponding fields of
                 table it_role.

     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno13 INPUT.

clear g_srno.
loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL113_wa-srno = g_srno.
      modify g_TABLCTRL113_itab from g_TABLCTRL113_wa.
endloop.
describe table g_TABLCTRL113_itab  lines g_lines_rl.
describe table g_TABLCTRL113_itab  lines TABLCTRL113-lines.
clear g_srno.

ENDMODULE.                 " change_srno13  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PP INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


    select * from zpp_prep_roledes into corresponding fields of
               table it_role.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT_PP INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

  select * from zd_t001w_bukrs into corresponding fields of
             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_BUKRS
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC_PP INPUT.
loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SLOC' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_plant.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'WERKS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGORT'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGOBE'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t001l
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
     clear dis_flag.

  ENDIF.

  REFRESH:IT_t001l,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_t001l,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.


ENDMODULE.                 " POV_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RES_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RES_PP INPUT.

data : l_role_type like ZIC_PREP_ROLEREI-ROLE_NAME .

 loop at screen.
  if screen-name = 'ZIC_PREP_ROLEREI-RES' and screen-input = 0.
        dis_flag = 'X'.
  endif.
 endloop.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_role_type.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_plant.

  select * from zpp_prep_res into corresponding fields of
             table it_res  where role_type = l_role_type and
             plant = l_plant..

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'RES'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-RES'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_res
*            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
     clear dis_flag.

  ENDIF.

  REFRESH:IT_RES,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_RES,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_RES_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CTF_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CTF_SLOC_PP INPUT.

 data : l_sloc like ZIC_PREP_ROLEREI-SLOC .

 loop at screen.
  if screen-name = 'ZIC_PREP_ROLEREI-CTF_SLOC' and screen-input = 0.
        dis_flag = 'X'.
  endif.
 endloop.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_role_type.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_plant.

   CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SLOC'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_sloc.

***********************************

  select single * from ZPP_PREP_DROLEEX where role_type = l_role_type
         and plant = l_plant and sloc = l_sloc.

  if sy-subrc = 0.

    concatenate 'LGORT'  'LIKE'  into g_line separated by
    space.
    concatenate g_line+0(10) '''' '%Z%' ''''  into
                g_line.
    append g_line to it_cond.

    select * from t001l into corresponding fields of
               table it_t001l  where werks = l_plant and
               (it_cond).
  endif.
***********************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'WERKS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGORT'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGOBE'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t001l
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
     clear dis_flag.

  ENDIF.

  REFRESH:IT_T001L,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_T001L,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_CTF_SLOC_PP  INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: modify table
module TABLCTRL114_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL114_wa.

  select single * from zsd_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL114_wa-role_desc = zpp_prep_roledes-brief_desc.

  modify g_TABLCTRL114_itab
    from g_TABLCTRL114_wa
    index TABLCTRL114-current_line.

    if sy-subrc <> 0.
      append g_TABLCTRL114_wa to g_TABLCTRL114_itab.
    endif.

    if G_TABLCTRL114_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL114_WA-FLAG.
            append g_TABLCTRL114_wa to g_TABLCTRL114_itab.
    endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: mark table
module TABLCTRL114_mark input.
  if TABLCTRL114-line_sel_mode = 1 and
     g_TABLCTRL114_wa-flag = 'X'.
     loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa
       where flag = 'X'.
       g_TABLCTRL114_wa-flag = ''.
       modify g_TABLCTRL114_itab
         from g_TABLCTRL114_wa
         transporting flag.
     endloop.
     g_TABLCTRL114_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL114_itab
    from g_TABLCTRL114_wa
    index TABLCTRL114-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: process user command
module TABLCTRL114_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL114'
                              'G_TABLCTRL114_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_114 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL114-top_line + g_cursor_line - 1.
  g_curr_line_114 = g_curr_line.

ENDMODULE.                 " get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data14 INPUT.

select single * from zsd_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

  if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
              not g_role_name_prev is initial.
      g_role_name_flag = 'X'.
  endif.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data14a INPUT.
if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zsd_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name and
                    disc_fi_fl = ZIC_PREP_ROLEREQ-disc_fi_flag.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       if ZIC_PREP_ROLEREQ-disc_fi_flag = 'X' and
       ZIC_PREP_ROLEREI-role_name = 'SXX'.
       else.
         message i118(zhelp).
       endif.
    else.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-SALE_ORG.
  clear  ZIC_PREP_ROLEREI-DIV.
  clear  ZIC_PREP_ROLEREI-PLANT.
  clear  ZIC_PREP_ROLEREI-SHIP_POINT.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
      clear g_role_name_flag.
      clear  ZIC_PREP_ROLEREI-SALE_ORG.
      clear  ZIC_PREP_ROLEREI-DIV.
      clear  ZIC_PREP_ROLEREI-PLANT.
      clear  ZIC_PREP_ROLEREI-SHIP_POINT.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

  select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_114.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-SALE_ORG is initial.

    select single * from tvko client specified into corresponding fields
             of it_tvko  where mandt = sy-mandt and
             bukrs =  zic_prep_rolereq-ccode and
             vkorg = ZIC_PREP_ROLEREI-SALE_ORG.

      if sy-subrc <> 0 and ZIC_PREP_ROLEREI-SALE_ORG <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            g_i = g_curr_line_114.
            message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
***
      else.
           if zic_prep_rolereq-ccode = 'MUM' and
              ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' and
              ZIC_PREP_ROLEREI-SALE_ORG <> 'MUMPHPOP'.
              g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
              g_i = g_curr_line_114.
              message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
           endif.
***
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-DIV is initial.

    select single * from tvkos client specified into corresponding
             fields of it_tvkos  where mandt = sy-mandt and
             vkorg =  ZIC_PREP_ROLEREI-SALE_ORG and
             spart =  ZIC_PREP_ROLEREI-DIV.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-DIV'.
            g_i = g_curr_line_114.
            message e187(zhelp) with ZIC_PREP_ROLEREI-DIV.

      endif.

   endif.


   if not ZIC_PREP_ROLEREI-SHIP_POINT is initial.

       select single * from tvswz into corresponding fields of
             it_tvswz  where werks = ZIC_PREP_ROLEREI-PLANT and
             vstel = ZIC_PREP_ROLEREI-SHIP_POINT.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
            g_i = g_curr_line.
            message e188(zhelp) with ZIC_PREP_ROLEREI-SHIP_POINT.

      endif.

    endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

        select * from zsd_prep_roledes into corresponding fields of
                 table it_role where
                    disc_fi_fl = ZIC_PREP_ROLEREQ-disc_fi_flag.
     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if ZIC_PREP_ROLEREQ-disc_fi_flag = 'X' and
     ZIC_PREP_ROLEREI-role_name = 'SXX'.
       check_role_flag = 'X'.
     endif.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno14 INPUT.

clear g_srno.
loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL114_wa-srno = g_srno.
      modify g_TABLCTRL114_itab from g_TABLCTRL114_wa.
endloop.
describe table g_TABLCTRL114_itab  lines g_lines_rl.
describe table g_TABLCTRL114_itab  lines TABLCTRL114-lines.
clear g_srno.

ENDMODULE.                 " change_srno14  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_SD INPUT.
loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


    select * from zsd_prep_roledes into corresponding fields of
               table it_role.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT_SD INPUT.

data : l_vkorg like tvkwz-vkorg.
data : l_div like ZIC_PREP_ROLEREI-DIV.

  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

   CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SALE_ORG'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_vkorg.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'DIV'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_div.

  data : it_tvkwz like table of tvkwz with header line.

*  select * from zd_t001w_bukrs into corresponding fields of
*             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

  SELECT * FROM TVTA INTO CORRESPONDING FIELDS OF TVTA UP TO 1 ROWS
 WHERE VKORG = L_VKORG AND SPART = L_DIV
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  select * from tvkwz into corresponding fields of
             table it_tvkwz  where vkorg =  l_vkorg
             and vtweg = tvta-vtweg.
    sort it_tvkwz by werks.
  delete adjacent duplicates from it_tvkwz comparing werks.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  g_field_wa-tabname = 'TVKWZ'.
  g_field_wa-fieldname = 'VKORG'.
  append g_field_wa to g_field_tab.
  g_field_wa-tabname = 'TVKWZ'.
  g_field_wa-fieldname = 'WERKS'.
  append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_TVKWZ
            FIELD_TAB       = G_FIELD_TAB
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_TVKWZ,IST_RETURN_TAB,G_FIELD_TAB.
  FREE : IT_TVKWZ,IST_RETURN_TAB,G_FIELD_TAB.

ENDMODULE.                 " POV_PLANT_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SALE_ORG_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SALE_ORG_SD INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SALE_ORG' and screen-input = 0.
        dis_flag = 'X'.
      endif.

 endloop.

 CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_role_type.

  select * from tvko client specified into corresponding fields of
             table it_tvko  where mandt = sy-mandt and
             bukrs =  zic_prep_rolereq-ccode.

  if zic_prep_rolereq-ccode = 'MUM'.
      loop at it_tvko.
      if ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP'.
         if it_tvko-vkorg = 'HZRS'.
         else.
          delete it_tvko.
         endif.
      else.
        if it_tvko-vkorg = 'HZRS'.
              delete it_tvko.
        endif.
      endif.
      endloop.
  endif.
  if l_role_type = 'SXX'.
    it_tvko-vkorg = 'ALL'.
    it_tvko-bukrs = 'ALL'.
    append it_tvko.
  endif.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'TVKO'.
 g_field_wa-fieldname = 'VKORG'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'TVKO'.
 g_field_wa-fieldname = 'BUKRS'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'VKORG'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SALE_ORG'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_TVKO
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_TVKO,IST_RETURN_TAB,G_FIELD_TAB.
  FREE : IT_TVKO,IST_RETURN_TAB,G_FIELD_TAB.


ENDMODULE.                 " POV_SALE_ORG_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_DIV_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_DIV_SD INPUT.

*  data : l_vkorg like tvkos-vkorg.

  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-DIV' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SALE_ORG'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_vkorg.


  select * from tvkos client specified into corresponding fields of
             table it_tvkos  where mandt = sy-mandt and
             vkorg =  l_vkorg.

*  delete adjacent  duplicates from it_tvkos comparing werks.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  g_field_wa-tabname = 'TVKOS'.
  g_field_wa-fieldname = 'VKORG'.
  append g_field_wa to g_field_tab.
  g_field_wa-tabname = 'TVKOS'.
  g_field_wa-fieldname = 'SPART'.
  append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'SPART'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-DIV'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_TVKOS
            FIELD_TAB       = G_FIELD_TAB
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_TVKOS,IST_RETURN_TAB,G_FIELD_TAB.
  FREE : IT_TVKOS,IST_RETURN_TAB,G_FIELD_TAB.

ENDMODULE.                 " POV_DIV_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHIP_POINT_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHIP_POINT_SD INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SHIP_POINT' and screen-input =
0.
        dis_flag = 'X'.
      endif.

  endloop.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_plant.

 CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'DIV'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_div.

*  select * from tvswz into corresponding fields of
*             table it_tvswz  where werks = l_plant.

   select single * from ZSD_PREP_LDGGRP into corresponding fields of
             ZSD_PREP_LDGGRP  where div = l_div.

   select * from tvstz into corresponding fields of table it_tvstz
            where ladgr = zsd_prep_ldggrp-ladgr and
            werks = l_plant.

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

  g_field_wa-tabname = 'TVSTZ'.
  g_field_wa-fieldname = 'WERKS'.
  append g_field_wa to g_field_tab.
  g_field_wa-tabname = 'TVSTZ'.
  g_field_wa-fieldname = 'VSTEL'.
  append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'VSTEL'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_tvstz
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
     clear dis_flag.

  ENDIF.

  REFRESH:IT_tvstz,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_tvstz,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " SHIP_POINT_SD  INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: modify table
module TABLCTRL115_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL115_wa.
  select single * from zqm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL115_wa-role_desc = zqm_prep_roledes-brief_desc.
  modify g_TABLCTRL115_itab
    from g_TABLCTRL115_wa
    index TABLCTRL115-current_line.
  if sy-subrc <> 0.
      append g_TABLCTRL115_wa to g_TABLCTRL115_itab.
  endif.

    if G_TABLCTRL115_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL115_WA-FLAG.
            append g_TABLCTRL115_wa to g_TABLCTRL115_itab.
    endif.
endmodule.

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: mark table
module TABLCTRL115_mark input.
  if TABLCTRL115-line_sel_mode = 1 and
     g_TABLCTRL115_wa-flag = 'X'.
     loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa
       where flag = 'X'.
       g_TABLCTRL115_wa-flag = ''.
       modify g_TABLCTRL115_itab
         from g_TABLCTRL115_wa
         transporting flag.
     endloop.
     g_TABLCTRL115_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL115_itab
    from g_TABLCTRL115_wa
    index TABLCTRL115-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: process user command
module TABLCTRL115_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL115'
                              'G_TABLCTRL115_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_QM INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


    select * from zqm_prep_roledes into corresponding fields of
               table it_role.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT_QM INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

  select * from zqm_prep_loc into corresponding fields of
             table it_plant.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'PLANT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_PLANT
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_PLANT,IST_RETURN_TAB.
  FREE : IT_PLANT,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_115 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL115-top_line + g_cursor_line - 1.
  g_curr_line_115 = g_curr_line.

ENDMODULE.                 " get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data15 INPUT.
select single * from zqm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
            not g_role_name_prev is initial.
    g_role_name_flag = 'X'.
endif.
g_read_fl = 'X'.
ENDMODULE.                 " validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno15 INPUT.
clear g_srno.
loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL115_wa-srno = g_srno.
      modify g_TABLCTRL115_itab from g_TABLCTRL115_wa.
endloop.
describe table g_TABLCTRL115_itab  lines g_lines_rl.
describe table g_TABLCTRL115_itab  lines TABLCTRL115-lines.
clear g_srno.
ENDMODULE.                 " change_srno15  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ASSET_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ASSET_QM INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ASSET_QM' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

     select * from zqm_prep_asset into corresponding fields of table
               it_asset where ccode = ZIC_PREP_ROLEREQ-CCODE.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ASSET'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ASSET_QM'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_ASSET
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    clear dis_flag.

  ENDIF.

  REFRESH:IT_ASSET,IST_RETURN_TAB.
  FREE  : IT_ASSET,IST_RETURN_TAB.
  CLEAR : IT_ASSET.

ENDMODULE.                 " POV_ASSET_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_module_fi  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_module_fi INPUT.
  if ( old_ok_code = 'CHANGE' or
  old_ok_code = 'DISPLAY' ) and moduleid = 'FI'.
     select single * from zic_prep_rolerei into
                     corresponding fields of wa_module1 where
                     docno = zic_prep_rolereq-docno and
                     moduleid = 'FI'.
     if sy-subrc <> 0.
        if old_ok_code = 'CHANGE'.
          message e196(zhelp) with zic_prep_rolereq-docno.
        else.
          message e198(zhelp) with zic_prep_rolereq-docno.
        endif.
     endif.
  endif.
ENDMODULE.                 " check_module_fi  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data15a INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zqm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-ASSET_QM.
  clear  ZIC_PREP_ROLEREI-plant.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZIC_PREP_ROLEREI-ASSET_QM.
     clear  ZIC_PREP_ROLEREI-plant.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ASSET_QM is initial.

    if ZIC_PREP_ROLEREQ-CCODE = 'MUM' or ZIC_PREP_ROLEREQ-CCODE = 'KKL'.

      select single * from ZQM_PREP_ASSET into zqm_prep_asset where
                      ccode =  ZIC_PREP_ROLEREQ-CCODE and
                      asset =  ZIC_PREP_ROLEREI-ASSET_QM.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET_QM'.
            g_i = g_curr_line.
           message e172(zhelp) with ZIC_PREP_ROLEREI-asset_qm.
      endif.

    endif.

   endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

     select * from zqm_prep_roledes into corresponding fields of
                 table it_role.

     if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fundc_data INPUT.

 select single * from fmzuob where fistl = ZIC_PREP_ROLEREQ-fundc.
  if sy-subrc <> 0.
     message i166(zhelp).
     g_field =  'ZIC_PREP_ROLEREQ-FUNDC'.
  endif.

ENDMODULE.                 " validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CRC_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CRC_POS INPUT.

loop at screen.

      if screen-name = 'CRC_POS' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  data : loop_step like sy-stepl.
*  Data : l_role_type like ZIC_PREP_ROLEREI-ROLE_NAME.
  data : ist_return_tab1 like standard table of dselc with header line.
  data : ist_return_tab2 like standard table of DYNPREAD with header
         line.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_role_type.

  select * from zmm_prep_crcdesg into corresponding fields of
             table it_pos where role_type = l_role_type.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'CRC_POS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'CRC_ORDER_AUTH'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'ROLE_TYPE_EX'.
 append g_field_wa to g_field_tab.

* g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 ist_return_tab1-fldname = 'ROLE_TYPE_EX'.
 ist_return_tab1-dyfldname = 'ZIC_PREP_ROLEREI-ROLE_TYPE_EX'.
 append ist_return_tab1 to ist_return_tab1.
* g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 ist_return_tab1-fldname = 'ROLE_TYPE'.
 ist_return_tab1-dyfldname = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
 append ist_return_tab1 to ist_return_tab1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'CRC_POS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'CRC_POS'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_POS
            FIELD_TAB       = G_FIELD_TAB
            RETURN_TAB      = IST_RETURN_TAB
            DYNPFLD_MAPPING = IST_RETURN_TAB1
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    read table IST_RETURN_TAB with key fieldname = 'CRC_POS'.
    ist_return_tab2-fieldname = IST_RETURN_TAB-fieldname.
    ist_return_tab2-fieldvalue = IST_RETURN_TAB-fieldval.
    ist_return_tab2-stepl = loop_step.
    append ist_return_tab2 to ist_return_tab2.
    read table IST_RETURN_TAB with key fieldname = 'ROLE_TYPE_EX'.
    concatenate 'ZIC_PREP_ROLEREI-' IST_RETURN_TAB-fieldname into
    IST_RETURN_TAB-fieldname.
    ist_return_tab2-fieldname = IST_RETURN_TAB-fieldname.
    ist_return_tab2-fieldvalue = IST_RETURN_TAB-fieldval.
    ist_return_tab2-stepl = loop_step.
    append ist_return_tab2 to ist_return_tab2.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME                     = sy-cprog
        DYNUMB                     = sy-dynnr
      TABLES
        DYNPFIELDS                 = IST_RETURN_TAB2
     EXCEPTIONS
       INVALID_ABAPWORKAREA       = 1
       INVALID_DYNPROFIELD        = 2
       INVALID_DYNPRONAME         = 3
       INVALID_DYNPRONUMMER       = 4
       INVALID_REQUEST            = 5
       NO_FIELDDESCRIPTION        = 6
       UNDEFIND_ERROR             = 7
       OTHERS                     = 8
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    clear dis_flag.

  ENDIF.

  REFRESH:IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1.
  FREE  : IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1.

ENDMODULE.                 " POV_CRC_POS  INPUT
