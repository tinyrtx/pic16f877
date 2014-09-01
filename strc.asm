        LIST
;*******************************************************************************
; tinyRTX Filename: strc.asm (System TRaCe service)
;
; Copyright 2014 Sycamore Software, Inc.  ** tinyRTX.com **
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
;   20Feb04 SHiggins@tinyRTX.com Created from scratch.
;	27Aug24	SHiggins@tinyRTX.com Added interrupt protection to ensure trace validity.
;
;*******************************************************************************
;
        errorlevel -302	
	    #include    <p16f877.inc>
;
;*******************************************************************************
;
; STRC trace buffer and related service variables.
;
STRC_UdataSec   UDATA
;
STRC_Buffer     res     0x4f                ; Trace buffer.
STRC_BufferEnd  res     1                   ; Trace buffer end.
STRC_Ptr        res     1                   ; Pointer to current location in trace buffer.
STRC_TempFSR    res     1                   ; Saved copy of FSR.
STRC_TempW      res     1                   ; Saved copy of W (input argument).
STRC_TempINTCON res     1                   ; Saved copy of INTCON.
;
;*******************************************************************************
;
; STRC Trace Service.
;
STRC_CodeSec  CODE	
;
; Initialize trace buffer.
;
        GLOBAL  STRC_Init
STRC_Init
;
        movlw       STRC_Buffer         ; Get buffer start addr.
        movwf       FSR                 ; Buffer start addr goes in FSR.
        banksel     STRC_Ptr
        movwf       STRC_Ptr            ; Buffer start addr goes in pointer for STRC_Trace.
        decf        STRC_Ptr, F         ; Decrement pointer for first normal usage.
;
        bankisel    STRC_Buffer         ; Set indirect data bank.
;
STRC_InitLoop
        clrf        INDF                ; Clear buffer location.
        incf        FSR, F              ; Increment pointer to next buffer addr.
        movlw       STRC_BufferEnd+1    ; Buffer end addr goes in W.
        subwf       FSR, W              ; Subtract end addr(W) from current addr(FSR).
        btfss       STATUS, Z           ; Skip if Zero flag set (addrs match).
        goto        STRC_InitLoop       ; No skip means no match means more init.
;
        return
;
;*******************************************************************************
;
;   Value in W is stored at location pointed to by STRC_Ptr++.
;   FSR is preserved.
;
        GLOBAL  STRC_Trace
STRC_Trace
;
        banksel     STRC_TempW
        movwf       STRC_TempW          ; Save input arg.
		movfw		INTCON				; Save INTCON.GIE.
		movwf		STRC_TempINTCON
		bcf			INTCON, GIE			; Disable interrupts.
        movfw       FSR
        movwf       STRC_TempFSR        ; Save FSR.

        bankisel    STRC_Buffer         ; Set indirect data bank.
        incf        STRC_Ptr, F         ; Bump current pointer.
        movfw       STRC_Ptr            ; Get current pointer.
        movwf       FSR                 ; Move current pointer to indirect pointer.
        movfw       STRC_TempW          ; Retrieve input arg.
        movwf       INDF                ; Save input arg in buffer.
;;
;; Experimental code to trace GIE status along with single nibble task/ISR trace code.
;;
;;		bankisel    STRC_Buffer         ; Set indirect data bank.
;;		incf        STRC_Ptr, F         ; Bump current pointer.
;;		movfw       STRC_Ptr            ; Get current pointer.
;;		movwf       FSR                 ; Move current pointer to indirect pointer.
;;		movfw       STRC_TempINTCON     ; Retrieve saved INTCON.
;;		andlw		0xf0
;;		addwf		STRC_TempW, W
;;		movwf       INDF                ; Save input arg in buffer.
;
        movlw       STRC_BufferEnd      ; Buffer end addr goes in W.
        subwf       FSR, W              ; Subtract end addr(W) from current addr(FSR).
        btfss       STATUS, Z           ; Skip if Zero flag set (addrs match).
        goto        STRC_TraceExit      ; No skip means no match means just leave.
;
; Trace buffer is full.  Code will reset pointer to beginning of buffer
;
STRC_TraceFull
        movlw       STRC_Buffer         ; Get buffer start addr.
        movwf       STRC_Ptr            ; Buffer start addr goes in pointer for STRC_Trace.
        decf        STRC_Ptr, F         ; Decrement pointer for first normal usage.
;  
STRC_TraceExit
        movfw       STRC_TempFSR
        movwf       FSR                 	; Restore FSR.
		btfsc		STRC_TempINTCON, GIE	; If saved GIE was set..
		bsf			INTCON, GIE				; ..then re-enable interrupts.
        return
;
        end