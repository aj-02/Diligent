*--- MAIN PROGRAM: MZMMPREPROLE1I01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

  if ZMM_PREP_ROLEREI-rej_fl is initial.
     clear : ZMM_PREP_ROLEREI-rej_id, ZMM_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.

*  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

    select single * from zmm_prep_rolegrp where role_type =
                    ZMM_PREP_ROLEREI-role_name.

*    select single * from zmm_prep_crcdesg where role_type =
*                    ZMM_PREP_ROLEREI-role_name .

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zmm_prep_rolerei-role_name .
       g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
    endif.

*  endif.

  if ZMM_PREP_ROLEREI-rej_fl = '' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.

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
   if old_ok_code = 'CRCROLES' or zmm_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_TABCTRL100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      endif.
   else.
      select single * from zmm_prep_roledes where role_type =
                    ZMM_PREP_ROLEREI-role_name.
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
  OKCODE = sy-ucomm.
  perform user_ok_tc using    'TABCTRL100'
                              'G_TABCTRL100_ITAB'
                              'FLAG'
                     changing OKCODE.
  sy-ucomm = OKCODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREI-PLANT' and screen-input = 0.
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
             table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-PLANT'
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

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
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

G_CCODE = ZMM_PREP_ROLEREQ-CCODE.

endif.

loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREI-GRP' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


  DATA : l_ekgrp like t024-ekgrp.
  refresh : it_cond.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF G_CCODE = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'KKL'.
    g_select = 'M%'.
    g_select_flag = 'X'.

    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
    g_select = 'V%'.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024_1 where (it_cond).
    refresh it_cond.
    append lines of it_t024_1 to it_t024.
    refresh it_t024_1.

  ENDIF.
*
  if G_CCODE <> 'KKL'.
    refresh it_cond.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
  endif.

  if g_select_flag <> 'X'.
    select * from t024 into table it_t024 where
            ( ekgrp not between 'A' and 'EZZ' ) and
            ( ekgrp not between 'K' and 'MZZ' ) and
            ( ekgrp not between 'G' and 'GZZ' ) and
            ( ekgrp not between 'R' and 'TZZ' ) and
            ( ekgrp not between 'V' and 'WZZ' ).
  endif.

  data : loop_step like sy-stepl.
  Data : l_role_name like ZMM_PREP_ROLEREI-ROLE_NAME.

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
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

 if l_role_name = 'M6' or  l_role_name = 'M7' or
     l_role_name = 'M8'.

 else.

      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

            loop at it_t024 into wa_t024.

             l_ekgrp = wa_t024-ekgrp.

              if l_ekgrp+1(1) between '0' and 'A'.
                delete it_t024.
              endif.

          endloop.


      else.

          loop at it_t024 into wa_t024.

             l_ekgrp = wa_t024-ekgrp.

              if l_ekgrp+1(1) < '0'  or
              l_ekgrp+1(1) > 'A'.
                delete it_t024.
              endif.

          endloop.

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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-GRP'
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

      if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
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

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    select * from zmm_prep_rolecrc into corresponding fields of
               table it_role.

  else.

    select * from zmm_prep_roledes into corresponding fields of
               table it_role.

  endif.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZMM_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

     g_field_wa-tabname = 'ZMM_PREP_ROLECRC'.
     g_field_wa-fieldname = 'ROLE_TYPE'.
     append g_field_wa to g_field_tab.
     g_field_wa-tabname = 'ZMM_PREP_ROLECRC'.
     g_field_wa-fieldname = 'BRIEF_DESC'.
     append g_field_wa to g_field_tab.
     g_field_wa-tabname = 'ZMM_PREP_ROLECRC'.
     g_field_wa-fieldname = 'DETAIL_DESC1'.
     append g_field_wa to g_field_tab.
 else.
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
 endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-ROLE_NAME'
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

     if not ZMM_PREP_ROLEREQ-userid is initial.
        perform check_tel.
     endif.

     if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' or
        OLD_OK_CODE = 'CRCROLES'.

        if ZMM_PREP_ROLEREQ-PERSA is initial and
           ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             perform pop_up_message.
        endif.

        if ZMM_PREP_ROLEREQ-userid is initial.
          message e035(zhelp).
        endif.

        if ZMM_PREP_ROLEREQ-userid <> old_userid and
          old_userid <> ''.
          clear ZMM_PREP_ROLEREQ-DISC_MM_FLAG.
          clear ZMM_PREP_ROLEREQ-CCODE.
          clear ZMM_PREP_ROLEREQ-FUNDC1.
          clear ZMM_PREP_ROLEREQ-FUNDC.
          clear ZMM_PREP_ROLEREQ-S_DESC.
          clear ZMM_PREP_ROLEREQ-RSN_CODE.
          clear ZMM_PREP_ROLEREQ-RSN_TEXT1.
          clear ZMM_PREP_ROLEREQ-REASON1.
          clear ZMM_PREP_ROLEREQ-TELNO.
          clear ZMM_PREP_ROLEREQ-NAME.
          clear ZMM_PREP_ROLEREQ-DESIGNATION.
          clear set_disc_mm_flag.
          clear help_list_flag.
          refresh it_m_fistb.
          clear wa_m_fistb.
        endif.

*        select single * from zusrmst where cpfno =
*                                   ZMM_PREP_ROLEREQ-userid.

        select single * from usr02 where bname =
                                   ZMM_PREP_ROLEREQ-userid.

        if sy-subrc ne 0.
          message e043(zhelp).
        else.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*          ZMM_PREP_ROLEREQ-name = zusrmst-last_name.
*          ZMM_PREP_ROLEREQ-designation = zusrmst-designation.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
            ZMM_PREP_ROLEREQ-NAME = ist_data-name.
            ZMM_PREP_ROLEREQ-DESIGNATION = ist_data-designation.
            if ist_data-disc_cd = '36' and set_disc_mm_flag <> 'X'.
                ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
                set_disc_mm_flag = 'X'.
            endif.
***************************************************31.05.2006
             if old_ok_code = 'CREATE' or old_ok_code = 'CRCROLES'.
              ZMM_PREP_ROLEREQ-CCODE = ist_data-bukrs.
             else.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.

***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*            ZMM_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

            if old_ok_code = 'CREATE'.
                if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
                   not ZMM_PREP_ROLEREQ-PERSA is initial.
                   message e108(zhelp).
                endif.
            endif.

        endif.

       clear : ist_data.
       refresh : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006


          concatenate '000' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.

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
              ZMM_PREP_ROLEREQ-FUNDC1 = fmzuob-fistl.
              ZMM_PREP_ROLEREQ-FUNDC_FL = 'X'.
*              ZMM_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
              ZMM_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             else.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
              ZMM_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             endif.

                SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZMM_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc =  0.
                   ZMM_PREP_ROLEREQ-S_DESC = CSKT-LTEXT.
              endif.

              refresh it_cond[].
              clear it_cond.
            else.
            endif.
          endif.

        endif.

     else.

***************************************************

***************************************************

           if ZMM_PREP_ROLEREQ-docno is initial.
                  message e041(zhelp).
           endif.

     endif.

endif.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

case okcode_100.

    When 'BAC' OR 'CAN'.
      perform exit_confirm.
    When 'EXT'.
      leave program.

    When 'CREATE'.

      old_ok_code = okcode_100.

    When 'CHANGE'.

     old_ok_code = okcode_100.

    When 'RELEASE'.

     old_ok_code = okcode_100.


    When 'APPROVE'.

     old_ok_code = okcode_100.

    When 'COPY'.


    When 'DISPLAY'.

      old_ok_code = okcode_100.

*    When 'MULTI'.
*
*      call screen 120 STARTING AT 10 5
*                  ENDING   AT 90 15.
*      clear okcode_100.

    WHEN 'SAV'.

      if old_ok_code = 'DELETE'.

          if ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.

*            if ZMM_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            if ZMM_PREP_ROLEREQ-STATUS = ''.
              Perform delete_request.
            else.
              message e138(ZHELP).
            endif.
          else.
            message e056(ZHELP).
          endif.
      else.
        describe table g_TABCTRL100_itab lines g_lines_rl.
        if g_lines_rl = 0.
           clear okcode_100.
           message i140(zhelp).
        else.
        if old_ok_code = 'RELEASE' and
              ZMM_PREP_ROLEREQ-req_cr_fl <> 'X'.
              message i083(zhelp).

        elseif old_ok_code = 'RELEASE' and g_lines_rl = 0.
              message i089(zhelp).

        elseif old_ok_code = 'APPROVE' and
              ( ZMM_PREP_ROLEREQ-req_app_fl <> 'X' and
              ZMM_PREP_ROLEREQ-req_app0_fl <> 'X' and
              ZMM_PREP_ROLEREQ-req_app1_fl <> 'X' ).
              message i087(zhelp).
        else.
          Perform check_items.
*          Perform check_items_save.
          Perform Save_request.
        endif.
       endif.
      endif.

    When 'MULTI'.

*      clear help_list_flag.

      call screen 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      clear okcode_100.


    WHEN 'DELETE'.

       old_ok_code = okcode_100.

    WHEN 'ATTACH'.

       if old_ok_code = 'CREATE' or
          old_ok_code = 'CROSSCO' or
          old_ok_code = 'CRCROLES'.
          message i137(zhelp).
       else.
          perform attach_files.
          if old_ok_code = 'DISPLAY' and
             ZMM_PREP_ROLEREQ-status = 'IR'.
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

    WHEN 'CRCROLES'.

       old_ok_code = okcode_100.

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

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_data INPUT.

if not zmm_prep_rolereq-docno is initial.

*  data : l_docno like zmm_prep_rolereq-docno.

l_docno = zmm_prep_rolereq-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

  zmm_prep_rolereq-docno = l_docno.

endif.

if old_doc_no <> ZMM_PREP_ROLEREq-docno.
                    clear g_hd_copied.
*           if old_doc_no <> '' and ZMM_PREP_ROLEREq-docno <> ''.
*                    clear wa_m_fistb.
*                    refresh it_m_fistb.
*           endif.
*                 perform clear.
                 perform destroy_ctrl.
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
   or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
  .

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

      if screen-name = 'ZMM_PREP_ROLEREI-SLOC' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  Data : l_plant like ZMM_PREP_ROLEREI-PLANT.

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
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_plant.


  DATA   : it_t001l type table of t001l with header line.
  DATA   : it_excp_sl type table of zmm_prep_sl_excp with header line.
  DATA   : wa_t001l like t001l.
  DATA   : l_zarea like zmm_consm-zarea.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

   if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-SLOC'
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

      if screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and screen-input = 0.
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
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

     if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.


*      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
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


*      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
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

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

         if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'..

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
                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-APPROVER'
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

      if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC' and screen-input =
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
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'
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

old_doc_no = ZMM_PREP_ROLEREq-docno.
old_userid = ZMM_PREP_ROLEREq-userid.
old_disc_mm_flag = ZMM_PREP_ROLEREq-disc_mm_flag.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
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

G_CCODE = ZMM_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

*  clear g_e_fl.

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc <> 0.
       g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
       message i117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    ZMM_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

  endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
  clear  ZMM_PREP_ROLEREI-SLOC.
  clear  ZMM_PREP_ROLEREI-plant.
  clear  ZMM_PREP_ROLEREI-grp.
  clear  ZMM_PREP_ROLEREI-approver.

  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
      clear  ZMM_PREP_ROLEREI-SLOC.
      clear  ZMM_PREP_ROLEREI-plant.
      clear  ZMM_PREP_ROLEREI-grp.
      clear  ZMM_PREP_ROLEREI-approver.
endif.


g_field = 'ZMM_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZMM_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZMM_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZMM_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if ZMM_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           if ZMM_PREP_ROLEREI-role_name <> ''.
             message e081(zhelp) with ZMM_PREP_ROLEREI-role_name.
           endif.
         endif.

   endif.

 endif.

*  endif.

  if not ZMM_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE
                                    and werks = ZMM_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZMM_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZMM_PREP_ROLEREI-role_name.

      endif.

   endif.

************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF G_CCODE = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'KKL'.
    g_select = 'M%'.
    g_select_flag = 'X'.

    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
    g_select = 'V%'.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024_1 where (it_cond).
    refresh it_cond.
    append lines of it_t024_1 to it_t024.
    refresh it_t024_1.

  ENDIF.
*
  if G_CCODE <> 'KKL'.
    refresh it_cond.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
  endif.

  if g_select_flag <> 'X'.
    select * from t024 into table it_t024 where
            ( ekgrp not between 'A' and 'EZZ' ) and
            ( ekgrp not between 'K' and 'MZZ' ) and
            ( ekgrp not between 'G' and 'GZZ' ) and
            ( ekgrp not between 'R' and 'TZZ' ) and
            ( ekgrp not between 'V' and 'WZZ' ).
  endif.


 if l_role_name = 'M6' or  l_role_name = 'M7' or
     l_role_name = 'M8'.

 else.

      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

            loop at it_t024 into wa_t024.

             l_ekgrp = wa_t024-ekgrp.

              if l_ekgrp+1(1) between '0' and 'A'.
                delete it_t024.
              endif.

          endloop.


      else.

          loop at it_t024 into wa_t024.

             l_ekgrp = wa_t024-ekgrp.

              if l_ekgrp+1(1) < '0'  or
              l_ekgrp+1(1) > 'A'.
                delete it_t024.
              endif.

          endloop.

      endif.

 endif.


**
   if  not ZMM_PREP_ROLEREI-GRP is initial.

       loop at it_t024 into wa_t024.

           if ZMM_PREP_ROLEREI-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
          move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.
          modify g_TABCTRL100_itab
                    from g_TABCTRL100_wa
                      index TABCTRL100-current_line.
          g_i = TABCTRL100-current_line.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( ZMM_PREP_ROLEREI-role_name = 'M13' or
   ZMM_PREP_ROLEREI-role_name = 'M14' or
    ZMM_PREP_ROLEREI-role_name = 'M16' or
    ZMM_PREP_ROLEREI-role_name = 'M18' or
    ZMM_PREP_ROLEREI-role_name = 'M19' ) and
    not ZMM_PREP_ROLEREI-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = ZMM_PREP_ROLEREI-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZMM_PREP_ROLEREI-PLANT'.
       message e074(zhelp).

    endif.

endif.

   if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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

    if  not ZMM_PREP_ROLEREI-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if ZMM_PREP_ROLEREI-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( ZMM_PREP_ROLEREI-role_name = 'M12' or
       ZMM_PREP_ROLEREI-role_name = 'M17' ) and
       not ZMM_PREP_ROLEREI-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if ZMM_PREP_ROLEREI-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if ZMM_PREP_ROLEREI-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not ZMM_PREP_ROLEREI-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if ZMM_PREP_ROLEREI-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
          message e075(zhelp).

       endif.

    endif.


*****************************
*****************************22.05.06

if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.

           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

         if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'..

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

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

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

if  not ZMM_PREP_ROLEREI-APPROVER is initial.

       loop at it_approver into wa_approver.

           if ZMM_PREP_ROLEREI-APPROVER = wa_approver-app_level.
              approver_flag = 'X'.
           endif.

       endloop.

       if approver_flag = 'X'.
          clear approver_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.
          modify g_TABCTRL100_itab
                    from g_TABCTRL100_wa
                      index TABCTRL100-current_line.
          g_i = TABCTRL100-current_line.
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
if ZMM_PREP_ROLEREI-rej_id is initial.
  ZMM_PREP_ROLEREI-rej_id = sy-uname.
  ZMM_PREP_ROLEREI-rej_date = sy-datum.
endif.

if not ZMM_PREP_ROLEREI-rej_fl is initial and
   ZMM_PREP_ROLEREI-rej_fl_save is initial.

    select single * from  ZMM_PREP_REJ_LIS  where
      rej_code = ZMM_PREP_ROLEREI-rej_fl .
    if sy-subrc <> 0.
      g_e_fl = 'X'.
      message e111(zhelp).
    else.
      if g_user = 'L1' and ZMM_PREP_ROLEREI-rej_fl <> 'R'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'L3' and ZMM_PREP_ROLEREI-rej_fl <> 'B'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'IM' and ZMM_PREP_ROLEREI-rej_fl <> 'I'.
        g_e_fl = 'X'.
        message e111(zhelp).
      endif.
    endif.
endif.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.

data : tel_len type i.
  tel_len = strlen( ZMM_PREP_ROLEREQ-TELNO ).
  if  ZMM_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
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
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
else.

   select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.

endif.

if g_role_name_prev <> ZMM_PREP_ROLEREI-role_name and
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
loop at g_TABCTRL100_itab into g_TABCTRL100_wa.
      g_srno = g_srno + 1.
      g_TABCTRL100_wa-srno = g_srno.
      modify g_TABCTRL100_itab from g_TABCTRL100_wa.
endloop.
describe table g_TABCTRL100_itab  lines g_lines_rl.
describe table g_TABCTRL100_itab  lines TABCTRL100-lines.
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
  comparing role_name plant grp sloc receipt_loc approver role_type_ex
  crc_pos.
endif.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
g_role_name_prev = ZMM_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fundc_data INPUT.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZMM_PREP_ROLEREQ-FUNDC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc <> 0.
     message i166(zhelp).
     g_field =  'ZMM_PREP_ROLEREQ-FUNDC'.
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
  Data : l_role_type like ZMM_PREP_ROLEREI-ROLE_NAME.
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
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
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
 ist_return_tab1-dyfldname = 'ZMM_PREP_ROLEREI-ROLE_TYPE_EX'.
 append ist_return_tab1 to ist_return_tab1.
* g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 ist_return_tab1-fldname = 'ROLE_TYPE'.
 ist_return_tab1-dyfldname = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
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
    concatenate 'ZMM_PREP_ROLEREI-' IST_RETURN_TAB-fieldname into
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
  FREE  : IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1
.

ENDMODULE.                 " POV_CRC_POS  INPUT
