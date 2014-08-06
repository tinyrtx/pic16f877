        LIST
;*******************************************************************************
;*******************************************************************************
; TinyRTX Filename: si2c.inc (System Inter-IC (I2C) communication services)
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
        NOLIST
;
; SI2C routines.
;
		EXTERN  SI2C_Tbl_HwState
		EXTERN  SI2C_Msg_Write
		EXTERN  SI2C_Msg_Wrt_Rd
;
; SI2C data structures.
;
        EXTERN  SI2C_Flags
        EXTERN  SI2C_AddrSlave
        EXTERN  SI2C_DataCntXmt
        EXTERN  SI2C_DataPtrXmt
        EXTERN  SI2C_DataByteXmt00
        EXTERN  SI2C_DataByteXmt01
        EXTERN  SI2C_DataByteXmt02
        EXTERN  SI2C_DataByteXmt03
        EXTERN  SI2C_DataCntRcv
        EXTERN  SI2C_DataPtrRcv
        EXTERN  SI2C_DataByteRcv00
        EXTERN  SI2C_DataByteRcv01
        EXTERN  SI2C_DataByteRcv02
        EXTERN  SI2C_DataByteRcv03
;
        LIST
