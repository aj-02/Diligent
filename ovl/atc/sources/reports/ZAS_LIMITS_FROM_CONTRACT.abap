*--- MAIN PROGRAM: ZAS_LIMITS_FROM_CONTRACT ---*
*&---------------------------------------------------------------------*
*& Report  ZAS_LIMITS_FROM_CONTRACT                                    *
*& For note 905859                                                     *
*&---------------------------------------------------------------------*
*& This program correct the release documentation for contracts in case*
*& the user created the item with reference to one item of a contract  *
*& and limits from another item or contract.                           *
*& Also will delete the item reference to contract                     *
*&---------------------------------------------------------------------*

REPORT  zas_limits_from_contract MESSAGE-ID se.
************************************************************************
* Date        Transport     USERID       Description
* 13/09/2008  <RD1K960036>  SAB_PUNIT    1) Replaced obsolete FM
*                                           'POPUP_TO_CONFIRM_STEP'
************************************************************************
TABLES: ekpo,
        esuc,
        ekab.

DATA: ls_esuc LIKE esuc,
      lt_esuc LIKE esuc OCCURS 0,
      ls_ekab LIKE ekab,
      lt_ekab LIKE ekab OCCURS 0.


PARAMETERS: po_no LIKE ekpo-ebeln OBLIGATORY VALUE CHECK,
            po_po LIKE ekpo-ebelp OBLIGATORY VALUE CHECK,
            correct as checkbox default space.

* Get asked data from EKPO
SELECT SINGLE * FROM ekpo WHERE ebeln = po_no AND ebelp = po_po.

* If not found...
IF sy-subrc NE 0.
  MESSAGE i506.
  EXIT.
ENDIF.

* If is not service type...
IF ekpo-pstyp NE '9'.
  MESSAGE i501.
  EXIT.
ENDIF.

* If have no reference to contract in item...
IF ekpo-konnr IS INITIAL.
  write: 'No reference to contract in item.'.
  EXIT.
ENDIF.

* Get contracts from limit
SELECT * FROM esuc INTO TABLE lt_esuc WHERE packno = ekpo-packno.

* If there are no limits from contract...
IF sy-subrc NE 0.
  write: 'No limits from contract exists in PO.'.
  EXIT.
ENDIF.

* Get data from contract release docu for asked PO item.
SELECT * FROM ekab INTO TABLE lt_ekab
    WHERE ebeln = ekpo-ebeln AND
          ebelp = ekpo-ebelp.

* If no release docu...
IF sy-subrc NE 0.
  Write: 'No release documentation for contract.'.
  EXIT.
ENDIF.

Data: local_flag value space,
      performed like esuc-actvalue.

* Look if there is other contract in limit than in item and if yes
* if was any value already performed
loop at lt_esuc into ls_esuc.
  if ls_esuc-ebeln ne ekpo-konnr or ls_esuc-ebelp ne ekpo-ktpnr.
    local_flag = 'X'.
    performed = performed + ls_esuc-actvalue.
  endif.
endloop.

* If no other contract in limit than in item...
If local_flag eq space.
  write: 'No other contract in limits than in item found.'.
  exit.
endif.

* If nothing was performed for the different contract the contract from
* limit can be deleted manually in transaction ME22N
if performed = 0.
  Data: answer.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*           DEFAULTOPTION = 'N'
*           TEXTLINE1     = 'No performed services from other contract.'
*           TEXTLINE2     = 'Do you want to delete the item reference?'
*           TITEL         = 'Possible manual correction in ME22N!'
*      IMPORTING
*           ANSWER        = ANSWER.
*  case answer.
*    when 'N'.
*      Write: 'The different contract than in item must be deleted'.
*      exit.
*    when 'A'.
*      exit.
*  endcase.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR                    = 'Possible manual correction in ME22N!'
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION               = 'No performed services from other contract.'
                                     &  'Do you want to delete the item reference?'
       TEXT_BUTTON_1               = 'Yes'(001)
*      ICON_BUTTON_1               = ' '
       TEXT_BUTTON_2               = 'No'(002)
*      ICON_BUTTON_2               = ' '
       DEFAULT_BUTTON              = '2'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
*      START_COLUMN                = 25
*      START_ROW                   = 6
*      POPUP_TYPE                  =
*      IV_QUICKINFO_BUTTON_1       = ' '
*      IV_QUICKINFO_BUTTON_2       = ' '
     IMPORTING
       ANSWER                      = answer
*    TABLES
*      PARAMETER                   =
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2
             .
   IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
  case answer.
    when '2'.
      Write: 'The different contract than in item must be deleted'.
      exit.
    when 'A'.
      exit.
  endcase.

* end of <RD1K960036>
endif.

* Prepare data for correction and docu
Write: / 'For purchase order ',
       ekpo-ebeln,
       ' position ',
       ekpo-ebelp,
       ' the reference to contract ',
       ekpo-konnr,
       ekpo-ktpnr,
       ' will be cleared.'.
uline.
Write: / 'The following data will be corrected in EKAB (contract',
         ' release documentation): '.
uline.

** select the proper (wrong) entry in EKAB
read table lt_ekab into ls_ekab with key konnr = ekpo-konnr
                                         ktpnr = ekpo-ktpnr
                                         ebeln = ekpo-ebeln
                                         ebelp = ekpo-ebelp.
** normally cannot be the case
if sy-subrc ne 0.
  write: 'No release documentation found to be updated!'.
  exit.
endif.

clear local_flag.

** findout if in limits exist also the contract from item reference
read table lt_esuc into ls_esuc with key ebeln = ekpo-konnr
                                         ebelp = ekpo-ktpnr.
if sy-subrc ne 0.
*** if not, delete entry from EKAB
  write: / 'Entry with key ',
           ekpo-konnr,
           ekpo-ktpnr,
           ekpo-ebeln,
           ekpo-ebelp,
           ' will be deleted from EKAB.'.
  local_flag = 'X'.
else.
*** if yes correct it to performed from limits
  write: / 'For entry with key ',
           ekpo-konnr,
           ekpo-ktpnr,
           ekpo-ebeln,
           ekpo-ebelp,
           'the value will be changed in EKAB from ',
           ls_ekab-netwr,
           ' to ',
           ls_esuc-actvalue.
  ls_ekab-netwr = ls_esuc-actvalue.
endif.

** clear the reference to contract in PO item
write: / 'Reference to contract ',
          ekpo-konnr,
          ekpo-ktpnr,
          ' in PO item will be cleared.'.

clear: ekpo-konnr, ekpo-ktpnr.

* Correct data = update in database.
If correct ne space.
  update ekpo.
  if local_flag ne space.
    delete ekab from ls_ekab.
  else.
    update ekab from ls_ekab.
  endif.
else.
  uline.
  Write: / 'Report was run in test mode!'.
endif.

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL
