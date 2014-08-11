        LIST
;*******************************************************************************
; tinyRTX Filename: slcd.inc (System Liquid Crystal Display driver)
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
;   20Oct03  SHiggins@tinyRTX.com  Created from scratch.
;
;*******************************************************************************
        NOLIST
;
; SLCD routines.
;
        EXTERN      SLCD_Init
        EXTERN      SLCD_RefreshLine1
        EXTERN      SLCD_RefreshLine2
;
; SLCD data structures.
;
        EXTERN      SLCD_BufferLine1
        EXTERN      SLCD_BufferLine2
