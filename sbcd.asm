        LIST
;*******************************************************************************
; tinyRTX Filename: sbcd.inc (System BCD conversion)
;
;   PIC16 FIXED POINT ENGINEERING UNIT TO BCD ROUTINES
;     Input:  fixed point arguments in BARG
;     Output: BCD nibbles in AARG
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
; 	04Sep03  SHiggins@tinyRTX.com  Created e2bcd16u and bcd2a5p3.
;   21Jan04  SHiggins@tinyRTX.com  Added e2bcd8u and bcd2a3p0.
;   10Jun14  SHiggins@tinyRTX.com  Renamed from e2bcd16 to sbcd for conformance.
;
;*******************************************************************************
;
        errorlevel -302	
#include        <p16f877.inc>
#include        <sm16.inc>
;
;**********************************************************************************************
;       16 Bit Unsigned Fixed Point Conversion to BCD
;       Input:  16 bit unsigned fixed point multiplicand in BARGB0, BARGB1
;       Use:    CALL    e2bcd16u
;       Output: 5 BCD digit result in AARGB0, AARGB1, AARGB2 (high nibble 0)
;       Result: AARG  <--  BCD( BARG )
;
SBCD_CodeSec    CODE
;
        global  e2bcd16u
e2bcd16u
        banksel AARGB0
        clrf    AARGB0      ; Clear result locations.
        clrf    AARGB1    
        clrf    AARGB2
;    
; Subtract off 10,000 (0x2710) until result negative to get 10,000's digit.
;
        movlw   0x27                ; Set subtract value to 10,000 (0x2710).
        movwf   TEMPB0
        movlw   0x10
        movwf   TEMPB1
;
e2bcd16u_Digit5Loop
        movf    TEMPB1, W
        subwf   BARGB1, F           ; Subtract LSB.
        movf    TEMPB0, W
        btfss   _C                  ; Skip if LSB result is positive.
        incfsz  TEMPB0, W           ; LSB result was negative, carry from MSB.
        subwf   BARGB0, F           ; Subtract MSB.
        btfss   _C                  ; Skip if MSB result is positive.
        goto    e2bcd16u_Digit5Done ; MSB result was negative, add value back in, done with this digit.
        incf    AARGB0, F           ; Increment 10,000 digit in LS nibble of result byte.
        goto    e2bcd16u_Digit5Loop ; 10,000 digit not done yet.  
;
e2bcd16u_Digit5Done
        movf    TEMPB1, W
        addwf   BARGB1, F           ; Add LSB.
        movf    TEMPB0, W
        btfsc   _C                  ; Skip if LSB result does not overflow.
        incfsz  TEMPB0, W           ; LSB result overflowed, carry into MSB.
        addwf   BARGB0, F           ; Add MSB.
;
; Subtract off 1,000 (0x03e8) until result negative to get 1,000's digit.
;
        movlw   0x03                ; Set subtract value to 1,000 (0x03e8).
        movwf   TEMPB0
        movlw   0xe8
        movwf   TEMPB1
;
e2bcd16u_Digit4Loop
        movf    TEMPB1, W
        subwf   BARGB1, F           ; Subtract LSB.
        movf    TEMPB0, W
        btfss   _C                  ; Skip if LSB result is positive.
        incfsz  TEMPB0, W           ; LSB result was negative, carry from MSB.
        subwf   BARGB0, F           ; Subtract MSB.
        btfss   _C                  ; Skip if MSB result is positive.
        goto    e2bcd16u_Digit4Done ; MSB result was negative, add value back in, done with this digit.
        incf    AARGB1, F           ; Increment 1,000 digit in LS nibble of result byte.
        goto    e2bcd16u_Digit4Loop ; 1,000 digit not done yet.  
;
e2bcd16u_Digit4Done
        movf    TEMPB1, W
        addwf   BARGB1, F           ; Add LSB.
        movf    TEMPB0, W
        btfsc   _C                  ; Skip if LSB result does not overflow.
        incfsz  TEMPB0, W           ; LSB result overflowed, carry into MSB.
        addwf   BARGB0, F           ; Add MSB.
;
        swapf   AARGB1, F           ; Swap 1,000's digit to MS nibble of result byte.
;
; Subtract off 100 (0x0064) until result negative to get 100's digit.
;
        movlw   0x00                ; Set subtract value to 100 (0x0064).
        movwf   TEMPB0
        movlw   0x64
        movwf   TEMPB1
;
e2bcd16u_Digit3Loop
        movf    TEMPB1, W
        subwf   BARGB1, F           ; Subtract LSB.
        movf    TEMPB0, W
        btfss   _C                  ; Skip if LSB result is positive.
        incfsz  TEMPB0, W           ; LSB result was negative, carry from MSB.
        subwf   BARGB0, F           ; Subtract MSB.
        btfss   _C                  ; Skip if MSB result is positive.
        goto    e2bcd16u_Digit3Done ; MSB result was negative, add value back in, done with this digit.
        incf    AARGB1, F           ; Increment 100 digit in LS nibble of result byte.
        goto    e2bcd16u_Digit3Loop ; 100 digit not done yet.  
;
e2bcd16u_Digit3Done
        movf    TEMPB1, W
        addwf   BARGB1, F           ; Add LSB.
        movf    TEMPB0, W
        btfsc   _C                  ; Skip if LSB result does not overflow.
        incfsz  TEMPB0, W           ; LSB result overflowed, carry into MSB.
        addwf   BARGB0, F           ; Add MSB.
;
; Subtract off 10 (0x000a) until result negative to get 10's digit. (One-byte subtractions now.)
;
        movlw   0x0a                ; Set subtract value to 10 (0x000a).
        movwf   TEMPB1
;
e2bcd16u_Digit2Loop
        movf    TEMPB1, W
        subwf   BARGB1, F           ; Subtract LSB.
        btfss   _C                  ; Skip if LSB result is positive.
        goto    e2bcd16u_Digit2Done ; MSB result was negative, add value back in, done with this digit.
        incf    AARGB2, F           ; Increment 10 digit in LS nibble of result byte.
        goto    e2bcd16u_Digit2Loop ; 10 digit not done yet.  
;
e2bcd16u_Digit2Done
        movf    TEMPB1, W
        addwf   BARGB1, F           ; Add LSB.
;
        swapf   AARGB2, F           ; Swap 10's digit to MS nibble of result byte.
;
; Remaining value is 1's digit.
;
        movf    BARGB1, W           ; Get 1's digit (upper nibble will be clear, as value < 10).
        addwf   AARGB2, F           ; Add 1's digit into LS nibble.
;
        retlw   0x00
;
;**********************************************************************************************
;       8 Bit Unsigned Fixed Point Conversion to BCD
;       Input:  8 bit unsigned fixed point multiplicand in BARGB0
;       Use:    CALL    e2bcd8u
;       Output: 3 BCD digit result in AARGB0, AARGB1 (high nibble 0)
;       Result: AARG  <--  BCD( BARG )
;
        global  e2bcd8u
e2bcd8u
        banksel AARGB0
        clrf    AARGB0      ; Clear result locations.
        clrf    AARGB1    
;
; Subtract off 100 (0x64) until result negative to get 100's digit.
;
        movlw   0x64                ; Set subtract value to 100 (0x64).
;
e2bcd8u_Digit3Loop
        subwf   BARGB0, F           ; Subtract LSB.
        btfss   _C                  ; Skip if LSB result is positive.
        goto    e2bcd8u_Digit3Done  ; MSB result was negative, add value back in, done with this digit.
        incf    AARGB0, F           ; Increment 100 digit in LS nibble of result byte.
        goto    e2bcd8u_Digit3Loop  ; 100 digit not done yet.  
;
e2bcd8u_Digit3Done
        addwf   BARGB0, F           ; Add value back in.
;
; Subtract off 10 (0x0a) until result negative to get 10's digit.
;
        movlw   0x0a                ; Set subtract value to 10 (0x000a).
;
e2bcd8u_Digit2Loop
        subwf   BARGB0, F           ; Subtract LSB.
        btfss   _C                  ; Skip if LSB result is positive.
        goto    e2bcd8u_Digit2Done  ; MSB result was negative, add value back in, done with this digit.
        incf    AARGB1, F           ; Increment 10 digit in LS nibble of result byte.
        goto    e2bcd8u_Digit2Loop  ; 10 digit not done yet.  
;
e2bcd8u_Digit2Done
        addwf   BARGB0, F           ; Add value back in.
        swapf   AARGB1, F           ; Swap 10's digit to MS nibble of result byte.
;
; Remaining value is 1's digit.
;
        movf    BARGB0, W           ; Get 1's digit (upper nibble will be clear, as value < 10).
        addwf   AARGB1, F           ; Add 1's digit into LS nibble.
;
        return
;
;**********************************************************************************************
;       16 Bit, 5-digit BCD Conversion to ASCII, with decimal point.
;       Input:  5-digit BCD in BARGB0, BARGB1, BARGB2 (high nibble 0)
;
;               ---BARGB0---  ---BARGB1---  ---BARGB2--- 
;               0000   bcd-4  bcd-3  bcd-2  bcd-1  bcd-0
;
;       Use:    CALL    bcd2a5p3
;       Output: 6-char ASCII result in AARGB0-5 with 
;
;               ---AARGB0---  ---AARGB1---  ---AARGB2---  ---AARGB3---  ---AARGB4---  ---AARGB5--- 
;               ascii-4       ascii-3       ascii-dec pt  ascii-2       ascii-1       ascii-0      
;
;       Result: AARG  <--  ASCII( BARG )
;
        global  bcd2a5p3
bcd2a5p3
;
        banksel BARGB0
        movf    BARGB0, W           ; Get bcd-4.
        addlw   0x30                ; bcd-4 becomes ascii-4.
        movwf   AARGB0              ; ascii-4 goes to result byte.
;
        swapf   BARGB1, W           ; Get bcd-3.
        andlw   0x0f                ; Clear upper nibble.
        addlw   0x30                ; bcd-3 becomes ascii-3.
        movwf   AARGB1              ; ascii-3 goes to result byte.
;
        movlw   0x2e                ; Get ASCII for decimal point.
        movwf   AARGB2              ; Decimal point goes to result byte.
;
        movf    BARGB1, W           ; Get bcd-2.
        andlw   0x0f                ; Clear upper nibble.
        addlw   0x30                ; bcd-2 becomes ascii-2.
        movwf   AARGB3              ; ascii-2 goes to result byte.
;
        swapf   BARGB2, W           ; Get bcd-1.
        andlw   0x0f                ; Clear upper nibble.
        addlw   0x30                ; bcd-1 becomes ascii-1.
        movwf   AARGB4              ; ascii-1 goes to result byte.
;
        movf    BARGB2, W           ; Get bcd-0.
        andlw   0x0f                ; Clear upper nibble.
        addlw   0x30                ; bcd-0 becomes ascii-0.
        movwf   AARGB5              ; ascii-0 goes to result byte.
;
        retlw   0x00
;
;**********************************************************************************************
;       8 Bit, 3-digit BCD Conversion to ASCII, no decimal point.
;       Input:  3-digit BCD in BARGB0, BARGB1 (high nibble 0)
;
;               ---BARGB0---  ---BARGB1---
;               0000   bcd-2  bcd-1  bcd-0
;
;       Use:    CALL    bcd2a3p0
;       Output: 3-char ASCII result in AARGB0-2 with 
;
;               ---AARGB0---  ---AARGB1---  ---AARGB2---
;                 ascii-2       ascii-1       ascii-0      
;
;       Result: AARG  <--  ASCII( BARG )
;
        global  bcd2a3p0
bcd2a3p0
;
        banksel BARGB0
        movf    BARGB0, W           ; Get bcd-2.
        addlw   0x30                ; bcd-2 becomes ascii-2.
        movwf   AARGB0              ; ascii-2 goes to result byte.
;
        swapf   BARGB1, W           ; Get bcd-1.
        andlw   0x0f                ; Clear upper nibble.
        addlw   0x30                ; bcd-1 becomes ascii-1.
        movwf   AARGB1              ; ascii-1 goes to result byte.
;
        movf    BARGB1, W           ; Get bcd-0.
        andlw   0x0f                ; Clear upper nibble.
        addlw   0x30                ; bcd-0 becomes ascii-0.
        movwf   AARGB2              ; ascii-0 goes to result byte.
;
        retlw   0x00
;
        end