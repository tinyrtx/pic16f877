        LIST
;*******************************************************************************
; tinyRTX Filename: si2cuser.asm (System Inter-IC (I2C) - USER configuration)
;   SI2C configuration is defined by these #defines.
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
;   11Nov03  SHiggins@tinyRTX.com  Created from scratch.
;
;*******************************************************************************
        NOLIST
;
; SI2C configuration is defined by these #defines.
; User should set them to match hardware configuration.
; NOTE: User is also responsible for proper hardware initialization so
;   hardware addressed by these #defines may be used.
;
; Bits for variable SI2C_Flags, all are active high.
;
#define  SI2C_Flag_SlvAckError   0
#define  SI2C_Flag_ChkAck        6
#define  SI2C_Flag_InUse         7
