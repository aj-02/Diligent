*--- MAIN PROGRAM: SAPMZM06B_O ---*
*eject
*{   INSERT         SO7K000061                                         1
* IS-Oil Downstream amendment                               "SO3K002226
*}   INSERT
***********************************************************************
* Modulpool  SAPMM06B                                                 *
*                                                                     *
* Bestellanforderungen                                                *
***********************************************************************
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                   Chng ID     *
*                                                                     *
* 17.12.07    CAB_SPYADAV   Set procurement profile value   SP001     *
*                           to '01' in case of PR value >=            *
*                           Rs 1 crore so that above PR               *
*                           can be process in SRM only                *
*                           (FS NO. FS-MM-PLI-018 V 1.1)              *
*                           (Include name : ZMM06BF0B_BUCHEN )        *
*                                                                     *
* 26.12.07    CAB_SPYADAV   Update Pr.profile value only on  SP002    *
*                           at the time of final relaseof PR          *
*                                                                     *
* 08.01.08    CAB_SPYADAV   Display information message all  SP003    *
*                           at the time of releasing PR               *
* 22.04.08                  Copy of ZME54 without SRM changes         *
*                                                                     *
***********************************************************************
*---------------------------------------------------------------------*
*  Datenteil                                                          *
*---------------------------------------------------------------------*
INCLUDE MZM06B_OTOP.
*include mzm06btop.
*INCLUDE MM06BTOP.

*eject
*---------------------------------------------------------------------*
*  PBO-Module alphabetisch geordnet                                   *
*---------------------------------------------------------------------*
INCLUDE MZM06B_OO0B.
*include mzm06bo0b.
*INCLUDE MM06BO0B.
INCLUDE MZM06B_OO0D.
*include mzm06bo0d.
*INCLUDE MM06BO0D.
INCLUDE MZM06B_OO0F.
*include mzm06bo0f.
*INCLUDE MM06BO0F.
INCLUDE MZM06B_OO0H.
*include mzm06bo0h.
*INCLUDE MM06BO0H.
INCLUDE MZM06B_OO0I.
*include mzm06bo0i.
*INCLUDE MM06BO0I.
INCLUDE MZM06B_OO0L.
*include mzm06bo0l.
*INCLUDE MM06BO0L.
INCLUDE MZM06B_OO0M.
*include mzm06bo0m.
*INCLUDE MM06BO0M.
INCLUDE MZM06B_OO0N.
*include mzm06bo0n.
*INCLUDE MM06BO0N.
INCLUDE MZM06B_OO0P.
*include mzm06bo0p.
*INCLUDE MM06BO0P.
INCLUDE MZM06B_OO0R.
*include mzm06bo0r.
*INCLUDE MM06BO0R.
INCLUDE MZM06B_OO0V.
*include mzm06bo0v.
*INCLUDE MM06BO0V.

*eject
*---------------------------------------------------------------------*
*  PAI-Module alphabetsich geordnet                                   *
*---------------------------------------------------------------------*
INCLUDE MZM06B_OI0A.
*include mzm06bi0a.
*INCLUDE MM06BI0A.
INCLUDE MZM06B_OI0B.
*include mzm06bi0b.
*INCLUDE MM06BI0B.
INCLUDE MZM06B_OI0C.
*include mzm06bi0c.
*INCLUDE MM06BI0C.
INCLUDE MZM06B_OI0E.
*include mzm06bi0e.
*INCLUDE MM06BI0E.
INCLUDE MZM06B_OI0F.
*include mzm06bi0f.
*INCLUDE MM06BI0F.
INCLUDE MZM06B_OI0I.
*include mzm06bi0i.
*INCLUDE MM06BI0I.
INCLUDE MZM06B_OI0K.
*include mzm06bi0k.
*INCLUDE MM06BI0K.
INCLUDE MZM06B_OI0L.
*include mzm06bi0l.
*INCLUDE MM06BI0L.
INCLUDE MZM06B_OI0M.
*include mzm06bi0m.
*INCLUDE MM06BI0M.
INCLUDE MZM06B_OI0P.
*include mzm06bi0p.
*INCLUDE MM06BI0P.
INCLUDE MZM06B_OI0R.
*include mzm06bi0r.
*INCLUDE MM06BI0R.
INCLUDE MZM06B_OI0S.
*include mzm06bi0s.
*INCLUDE MM06BI0S.
INCLUDE MZM06B_OI0T.
*include mzm06bi0t.
*INCLUDE MM06BI0T.
INCLUDE MZM06B_OI0V.
*include mzm06bi0v.
*INCLUDE MM06BI0V.
INCLUDE MZM06B_OI0W.
*include mzm06bi0w.
*INCLUDE MM06BI0W.

*eject
*---------------------------------------------------------------------*
*  Form-Routinen alphabetisch geordnet                                *
*---------------------------------------------------------------------*
INCLUDE MZM06B_OF0A.
*include mzm06bf0a.
*INCLUDE MM06BF0A.
INCLUDE MZM06B_OF0B.
*include mzm06bf0b.
*INCLUDE MM06BF0B.
INCLUDE MZM06B_OF0C.
*include mzm06bf0c.
*INCLUDE MM06BF0C.
INCLUDE MZM06B_OF0D.
*include mzm06bf0d.
*INCLUDE MM06BF0D.
INCLUDE MZM06B_OF0E.
*include mzm06bf0e.
*INCLUDE MM06BF0E.
INCLUDE MZM06B_OF0F.
*include mzm06bf0f.
*INCLUDE MM06BF0F.
INCLUDE MZM06B_OF0G.
*include mzm06bf0g.
*INCLUDE MM06BF0G.
INCLUDE MZM06B_OF0L.
*include mzm06bf0l.
*INCLUDE MM06BF0L.
INCLUDE MZM06B_OF0M.
*include mzm06bf0m.
*INCLUDE MM06BF0M.
INCLUDE MZM06B_OF0N.
*include mzm06bf0n.
*INCLUDE MM06BF0N.
INCLUDE MZM06B_OF0O.
*include mzm06bf0o.
*INCLUDE MM06BF0O.
INCLUDE MZM06B_OF0P.
*include mzm06bf0p.
*INCLUDE MM06BF0P.
INCLUDE MZM06B_OF0R.
*include mzm06bf0r.
*INCLUDE MM06BF0R.
INCLUDE MZM06B_OF0S.
*include mzm06bf0s.
*INCLUDE MM06BF0S.
INCLUDE MZM06B_OF0U.
*include mzm06bf0u.
*INCLUDE MM06BF0U.
INCLUDE MZM06B_OF0V.
*include mzm06bf0v.
*INCLUDE MM06BF0V.
INCLUDE MZM06B_OF0W.
*include mzm06bf0w.
*INCLUDE MM06BF0W.

*eject
*---------------------------------------------------------------------*
*  Form-Routinen fuer spezielle Tabellenbearbeitung                   *
*---------------------------------------------------------------------*
INCLUDE MZM06B_OFAC.
*include mzm06bfac.
*INCLUDE MM06BFAC.            "Unterroutinen Verfügbarkeitsprüfung
INCLUDE MZM06B_OFBB.
*include mzm06bfbb.
*INCLUDE MM06BFBB.            "Unterroutinen Tabelle BSNB
INCLUDE MZM06B_OFBN.
*include mzm06bfbn.
*INCLUDE MM06BFBN.            "Unterroutinen Tabelle BSN
INCLUDE MZM06B_OFBC.
*include mzm06bfbc.
*INCLUDE MM06BFBC.            "Unterroutinen Tabelle BSC
INCLUDE MZM06B_OFDA.
*include mzm06bfda.
*INCLUDE MM06BFDA.            "Unterroutinen Anlieferungsadressen
INCLUDE MZM06B_OFFM.
*include mzm06bffm.
*INCLUDE MM06BFFM.            "Unterroutinen Finanzmittelrechnung
INCLUDE MZM06B_OFLB.
*include mzm06bflb.
*INCLUDE MM06BFLB.            "Unterroutinen Komponentenbearbeitung
INCLUDE MZM06B_OFMS.
*include mzm06bfms.
*INCLUDE MM06BFMS.            "Unterroutinen Dienstleistungsabwicklung
INCLUDE MZM06B_OFRF.
*include mzm06bfrf.
*INCLUDE MM06BFRF.            "Unterroutinen Referenzbearbeitung
INCLUDE MZM06B_OFSE.
*include mzm06bfse.
*INCLUDE MM06BFSE.            "Unterroutinen Selektionstabelle
INCLUDE MZM06B_OFTC.
*include mzm06bftc.
*INCLUDE MM06BFTC.            "Unterroutinen Table Control
INCLUDE MZM06B_OFTE.
*include mzm06bfte.
*INCLUDE MM06BFTE.            "Unterroutinen Textverarbeitung
include fm06bcdc.            "Unterroutinen Änderungsbeleg

*eject
*---------------------------------------------------------------------*
*  Module für F4-Hilfe                                                *
*---------------------------------------------------------------------*
INCLUDE MZM06B_OH00.
*include mzm06bh00.
*INCLUDE MM06BH00.

INCLUDE MZM06B_OIR1.
*include mzm06bir1.
*INCLUDE MM06BIR1.

INCLUDE MZM06B_OFR1.
*include mzm06bfr1.
*INCLUDE MM06BFR1.

include mm06bf0o_oo_wrapping.
*{   INSERT         SO7K000061                                        2
* IS-Oil amendment
*                                                                     *
INCLUDE MZM06B_OOOI.
*include mzm06booi.
*INCLUDE MM06BOOI.            "SO3K002226
INCLUDE MZM06B_OIOI.
*include mzm06bioi.
*INCLUDE MM06BIOI.            "SO3K002226
INCLUDE MZM06B_OFOI.
*include mzm06bfoi.
*INCLUDE MM06BFOI.            "SO3K002226

include roio_mm06b.                                         "SO6K013626
*}   INSERT

INCLUDE ZMM06BF0B_UPD_PR_REL_VALUE_O.
*include zmm06bf0b_upd_pr_rel_value.
