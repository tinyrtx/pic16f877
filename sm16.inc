        LIST
;*******************************************************************************
; tinyRTX Filename: sm16.inc (System Math 16-bit library.)
;   Header file for sm16.asm
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
; 23Sep03  SHiggins@tinyRTX.com  Created from scratch.
; 10Jun14  SHiggins@tinyRTX.com  Renamed from ma16 to sm16 for conformance.
;
;**********************************************************************************************
;
        NOLIST
;
		#define	_C		STATUS,0
		#define	_Z		STATUS,2
;
        EXTERN  AARGB7
        EXTERN  AARGB6
        EXTERN  AARGB5
        EXTERN  AARGB4
        EXTERN  AARGB3
        EXTERN  AARGB2
        EXTERN  AARGB1
        EXTERN  AARGB0
        EXTERN  AARG
;
        EXTERN  BARGB3
        EXTERN  BARGB2
        EXTERN  BARGB1
        EXTERN  BARGB0
        EXTERN  BARG
;
        EXTERN  TEMPB3
        EXTERN  TEMPB2
        EXTERN  TEMPB1
        EXTERN  TEMPB0
        EXTERN  TEMP
;
        EXTERN  LOOPCOUNT
;
SIGN    EQU     0x109    ; save location for sign in MSB
