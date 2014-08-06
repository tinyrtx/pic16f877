        LIST
;*******************************************************************************
; TinyRTX Filename: ui2c.inc (User Inter-IC communication routines)
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
;   11Nov03  SHiggins@TinyRTX.com  Created from scratch.
;
;*******************************************************************************
;
        EXTERN      UI2C_Init
        EXTERN      UI2C_MsgTC74
        EXTERN      UI2C_MsgDone