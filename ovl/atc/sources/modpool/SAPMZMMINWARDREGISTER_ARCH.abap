*--- MAIN PROGRAM: SAPMZMMINWARDREGISTER_ARCH ---*

***********************************************************************
* Program    : SAPMZMMINWARDREGISTER                                  *
*                                                                     *
* Title      : To maintain Inward Register in SAP                     *
*                                                                     *
* Functional Specification No.: FS-MM-INV-004                         *
*                                                                     *
* Author     : A.Elango                    Date : 30-May-2003         *
*                                                                     *
* Login Id   : SAB_ELANGO                                             *
*                                                                     *
* Desciption : To maintain Inward Register in SAP                     *
*                                                                     *
* Transaction Code : ZMMINWARD                                        *
*                                                                     *
***********************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
*  1) Change in INCLUDE MZMMINWARDREGISTERO01
*  2) Change in INCLUDE MZMMINWARDREGISTERF01
************************************************************************


*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMINWARDREGISTER                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

INCLUDE MZMMINWARDREGISTER_ARCHTOP.
*INCLUDE MZMMINWARDREGISTERTOP .

INCLUDE MZMMINWARDREGISTER_ARCHO01.
*INCLUDE MZMMINWARDREGISTERO01 .

INCLUDE MZMMINWARDREGISTER_ARCHI01.
*INCLUDE MZMMINWARDREGISTERI01 .

INCLUDE MZMMINWARDREGISTER_ARCHF01.
*INCLUDE MZMMINWARDREGISTERF01 .
