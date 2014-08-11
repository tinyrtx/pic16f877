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
;*******************************************************************************
;
        errorlevel -302	
;	    #include    <p16f877.inc>
;
;*******************************************************************************
;
SM16_UdataSec   UDATA
;
        GLOBAL  AARGB7
        GLOBAL  AARGB6
        GLOBAL  AARGB5
        GLOBAL  AARGB4
        GLOBAL  AARGB3
        GLOBAL  AARGB2
        GLOBAL  AARGB1
        GLOBAL  AARGB0
        GLOBAL  AARG
AARGB7  res 1
AARGB6  res 1
AARGB5  res 1
AARGB4  res 1
AARGB3  res 1
AARGB2  res 1
AARGB1  res 1
AARGB0  res 1
AARG    res 1
;
        GLOBAL  BARGB3
        GLOBAL  BARGB2
        GLOBAL  BARGB1
        GLOBAL  BARGB0
        GLOBAL  BARG
BARGB3  res 1
BARGB2  res 1
BARGB1  res 1
BARGB0  res 1
BARG    res 1
;
        GLOBAL  TEMPB3
        GLOBAL  TEMPB2
        GLOBAL  TEMPB1
        GLOBAL  TEMPB0
        GLOBAL  TEMP
TEMPB3  res 1
TEMPB2  res 1
TEMPB1  res 1
TEMPB0  res 1
TEMP    res 1
;
        GLOBAL  LOOPCOUNT
LOOPCOUNT   res 1
;
        end