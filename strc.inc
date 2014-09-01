        LIST
;**********************************************************************************************
; tinyRTX Filename: strc.inc (System TRaCe facility)
;
; Copyright 2014 Sycamore Software, Inc.  ** www.tinyRTX.com **
; Distributed under the terms of the GNU Lesser General Purpose License v3
;
; This file is part of tinyRTX. tinyRTX is free software: you can redistribute
; it and/or modify it under the terms of the GNU Lesser General Public License
; version 3 as published by the Free Software Foundation.
;
; tinyRTX is distributed in the hope that it will be useful, but WITHOUT ANY
; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
; A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
; details.
;
; You should have received a copy of the GNU Lesser General Public License
; (filename copying.lesser.txt) and the GNU General Public License (filename
; copying.txt) along with tinyRTX.  If not, see <http://www.gnu.org/licenses/>.
;
; Revision history:
;   20Feb04  SHiggins@tinyRTX.com  Created from scratch.
;   27Aug14  SHiggins@tinyRTX.com  Added STRC_ISR_BEG_I2C and STRC_ISR_END_I2C.
;   01Sep14  SHiggins@tinyRTX.com  Changed smTrace to smTraceL, added smTraceW.
;
;*********************************************************************************************
        NOLIST
;
        EXTERN	    STRC_Init
        EXTERN	    STRC_Trace
;
STRC_TSK_BEG_1      EQU     0x11
STRC_TSK_END_1      EQU     0x12
STRC_TSK_BEG_2      EQU     0x21
STRC_TSK_END_2      EQU     0x22
STRC_TSK_BEG_3      EQU     0x31
STRC_TSK_END_3      EQU     0x32
STRC_TSK_BEG_I2C    EQU     0x61
STRC_TSK_END_I2C    EQU     0x62
STRC_ISR_BEG_I2C    EQU     0x63
STRC_ISR_END_I2C    EQU     0x64
STRC_TSK_BEG_ADC    EQU     0x71
STRC_TSK_END_ADC    EQU     0x72
;
; smTraceL: System Macro Trace with Literal: add entry to Trace buffer if enabled.
;
smTraceL	MACRO   smTraceArg
        	movlw   smTraceArg
			pagesel STRC_Trace
        	call    STRC_Trace
        	ENDM
;
; smTraceW: System Macro Trace with W: add entry to Trace buffer if enabled.
;
smTraceW	MACRO
			pagesel STRC_Trace
        	call    STRC_Trace
        	ENDM
