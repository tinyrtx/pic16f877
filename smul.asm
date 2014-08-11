;*******************************************************************************
; tinyRTX Filename: smul.INC (System MULtiply)
;       16x16 PIC16 fixed point multiply routines
;
; Distributed with tinyRTX.  Supplied by Microchip and subject to Microchip
;   Technology Inc. Software License Agreement (reproduced below).
;
; Revision History:
;   04Sep03  SHiggins@tinyRTX.com  Eliminated all macros and routines except 16x16 unsigned multiply.
;               Configured for PIC16F872.
;               Put routine in FXM1616U_Code_Sec.
;
;*******************************************************************************
;
; Microchip Technology Inc. Software License Agreement
;
; The software supplied herewith by Microchip Technology Incorporated (the “Company”)
; for its PICmicro® Microcontroller is intended and supplied to you, the Company’s customer,
; for use solely and exclusively on Microchip PICmicro Microcontroller products.
; The software is owned by the Company and/or its supplier, and is protected under applicable
; copyright laws. All rights are reserved. Any use in violation of the foregoing restrictions
; may subject the user to criminal sanctions under applicable laws, as well as to civil
; liability for the breach of the terms and conditions of this license.
; THIS SOFTWARE IS PROVIDED IN AN “AS IS” CONDITION. NO WARRANTIES, WHETHER EXPRESS,
; IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY
; AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES, 
; FOR ANY REASON WHATSOEVER.
;
;*******************************************************************************
;
;	RCS Header $Id: fxm66.a16 2.3 1996/10/16 14:23:23 F.J.Testa Exp $
;	$Revision: 2.3 $
;       16x16 PIC16 FIXED POINT MULTIPLY ROUTINES
;
;       Input:  fixed point arguments in AARG and BARG
;
;       Output: product AARGxBARG in AARG
;
;       All timings are worst case cycle counts
;
;       It is useful to note that the additional unsigned routines requiring a non-power of two
;       argument can be called in a signed multiply application where it is known that the
;       respective argument is nonnegative, thereby offering some improvement in
;       performance.
;
;         Routine            Clocks     Function
;
;       FXM1616S     269        16x16 -> 32 bit signed fixed point multiply
;
;       FXM1616U     256        16x16 -> 32 bit unsigned fixed point multiply
;
;       FXM1515U     244        15x15 -> 30 bit unsigned fixed point multiply
;
;       The above timings are based on the looped macros. If space permits,
;       approximately 64-73 clocks can be saved by using the unrolled macros.
;
;*******************************************************************************
;
        errorlevel -302	
#include        <p16f877.inc>
#include        <sm16.inc>
;
;*******************************************************************************

UMUL1616L        macro

;       Max Timing:     2+13+6*15+14+2+7*16+15 = 248 clks
;       Min Timing:     2+7*6+5+1+7*6+5+4 = 101 clks
;       PM: 51          DM: 9
        
        MOVLW   0x08
        MOVWF   LOOPCOUNT

LOOPUM1616A
        RRF     BARGB1,F
        BTFSC   _C
        goto    ALUM1616NAP
        DECFSZ  LOOPCOUNT,F
        goto    LOOPUM1616A
        MOVWF   LOOPCOUNT

LOOPUM1616B
        RRF     BARGB0,F
        BTFSC   _C
        goto    BLUM1616NAP
        DECFSZ  LOOPCOUNT,F
        goto    LOOPUM1616B
        CLRF    AARGB0
        CLRF    AARGB1
        RETLW   0x00

BLUM1616NAP
        BCF     _C
        goto    BLUM1616NA

ALUM1616NAP
        BCF     _C
        goto    ALUM1616NA

ALOOPUM1616
        RRF     BARGB1,F
        BTFSS   _C
        goto    ALUM1616NA
        MOVF    TEMPB1,W
        ADDWF   AARGB1,F
        MOVF    TEMPB0,W
        BTFSC   _C
        INCFSZ  TEMPB0,W
        ADDWF   AARGB0,F

ALUM1616NA
        RRF     AARGB0,F
        RRF     AARGB1,F
        RRF     AARGB2,F
        DECFSZ  LOOPCOUNT,F
        goto    ALOOPUM1616
        MOVLW   0x08
        MOVWF   LOOPCOUNT

BLOOPUM1616
        RRF     BARGB0,F
        BTFSS   _C
        goto    BLUM1616NA
        MOVF    TEMPB1,W
        ADDWF   AARGB1,F
        MOVF    TEMPB0,W
        BTFSC   _C
        INCFSZ  TEMPB0,W
        ADDWF   AARGB0,F

BLUM1616NA
        RRF     AARGB0,F
        RRF     AARGB1,F
        RRF     AARGB2,F
        RRF     AARGB3,F
        DECFSZ  LOOPCOUNT,F
        goto    BLOOPUM1616

        endm

;*******************************************************************************
;       16x16 Bit Unsigned Fixed Point Multiply 16x16 -> 32
;       Input:  16 bit unsigned fixed point multiplicand in AARGB0
;               16 bit unsigned fixed point multiplier in BARGB0
;       Use:    CALL    FXM1616U
;       Output: 32 bit unsigned fixed point product in AARGB0
;       Result: AARG  <--  AARG x BARG
;       Max Timing:     6+248+2 = 256 clks
;       Min Timing:     6+101 = 107 clks
;       PM: 6+51+1 = 58              DM: 9
;
SMUL_CodeSec    CODE
;
        global  FXM1616U
FXM1616U
        banksel AARGB2
        CLRF    AARGB2          ; clear partial product
        CLRF    AARGB3
        MOVF    AARGB0,W
        MOVWF   TEMPB0
        MOVF    AARGB1,W
        MOVWF   TEMPB1

        UMUL1616L

        RETLW           0x00
;
        end