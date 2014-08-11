        LIST
;**********************************************************************************************
; tinyRTX Filename: uapp.inc (User APPlication interface)
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
;  31Oct03  SHiggins@tinyRTX.com  Created from scratch.
;  29Jul14  SHiggins@tinyRTX.com  Moved UAPP_Timer1Init to MACRO to save stack.
;
;*********************************************************************************************
        NOLIST
;
        EXTERN      UAPP_POR_Init
;
        LIST
;*******************************************************************************
;
UAPP_Timer1Init MACRO
;
; Init Timer1 module to generate timer interrupt every 100ms.
;
; 1:8 pre-scaler; T1 oscillator disabled; T1SYNC* ignored;
; TMR1CS internal clock Fosc/4; Timer1 off.
;
        banksel T1CON
        movlw   (1<<T1CKPS1)|(1<<T1CKPS0)|(0<<T1OSCEN)|(0<<T1SYNC)|(0<<TMR1ON)
		movwf	T1CON                   ; Initialize Timer1 but don't start it.
;
; 4 Mhz Fosc/4 is base clock = 1 Mhz = 1.0 us per clock.
; 1:8 prescale = 1.0 * 8 = 8.0 us per clock.
; 12,500 counts * 8.0us/clock = 100,000 us/rollover = 100ms/rollover.
; Timer preload value = 65,536 - 12,500 = 53,036 = 0xcf2c.
;
		movlw	0x2c                    ; Timer1 preload value, low byte.
		movwf	TMR1L
		movlw	0xcf                    ; Timer1 preload value, high byte.
		movwf	TMR1H
;
        banksel PIE1
        bsf     PIE1, TMR1IE            ; Enable Timer1 interrupts.
;
        banksel T1CON
		bsf		T1CON,TMR1ON            ; Turn on Timer1 module.
        ENDM
;