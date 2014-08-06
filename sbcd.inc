        LIST
;*******************************************************************************
; TinyRTX Filename: sbcd.inc (System BCD conversion)
;
; Copyright 2014 Sycamore Software, Inc.  ** www.TinyRTX.com **
; Distributed under the terms of the GNU Lesser General Purpose License v3
;
; This file is part of TinyRTX. TinyRTX is free software: you can redistribute
; it and/or modify it under the terms of the GNU Lesser General Public License
; version 3 as published by the Free Software Foundation.
;
; TinyRTX is distributed in the hope that it will be useful, but WITHOUT ANY
; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
; A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
; details.
;
; You should have received a copy of the GNU Lesser General Public License
; (filename copying.lesser.txt) and the GNU General Public License (filename
; copying.txt) along with TinyRTX.  If not, see <http://www.gnu.org/licenses/>.
;
; Revision history:
;   09Sep03  SHiggins@TinyRTX.com  Created from scratch.
;   10Jun14  SHiggins@TinyRTX.com  Renamed from e2bcd16 to sbcd for conformance.
;
;*******************************************************************************
;
        NOLIST
;
        extern  e2bcd16u
        extern  e2bcd8u
        extern  bcd2a5p3
        extern  bcd2a3p0
