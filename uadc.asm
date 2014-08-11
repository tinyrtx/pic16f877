        LIST
;*******************************************************************************
; tinyRTX Filename: uadc.asm (User Analog to Digital Conversion routines)
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
;   27Jan04  SHiggins@tinyRTX.com  Split out from main user application.  For PICdem2plus demo board.
;   30Jan04  SHiggins@tinyRTX.com  Updated to use 1023 steps to full range, not 1024.
;   29Jul14  SHiggins@tinyRTX.com  Move UADC_SetupDelay to inline in UADC_Trigger, reducing stack.
;
;*******************************************************************************
;
        errorlevel -302	
        #include    <p16f877.inc>
        #include    <sm16.inc>
        #include    <smul.inc>
        #include    <sbcd.inc>
        #include    <ulcd.inc>
;
;*******************************************************************************
;
; User ADC defines.
;
;*******************************************************************************
;
; User ADC service variables.
;
UADC_UdataSec       UDATA
;
UADC_DelayTimer     res     1   ; Countdown delay timer.
UADC_Channel        res     1   ; A/D channel select.
UADC_ADCON0_Temp    res     1   ; Temp reg copy.
UADC_ResultRawHi    res     1   ; Raw A/D result, high byte.
UADC_ResultRawLo    res     1   ; Raw A/D result, low byte.
UADC_ResultScaledHi res     1   ; Scaled A/D result, high byte.
UADC_ResultScaledLo res     1   ; Scaled A/D result, low byte.
;
;*******************************************************************************
;
; Init ADC registers.
;
; LINKNOTE: UADC is PAGE SAFE, there are no unprotected calls out of UADC.
;
UADC_CodeSec        CODE
;
        GLOBAL      UADC_Init
UADC_Init
;
; Ensure RA0 set as input to allow it to function as analog input.
;
        banksel     TRISA
        bsf         TRISA, 0    ; TRISA bit 0 set to allow AN0 to function as analog input.
;
; A/D conversion clock is 4MHz/2; A/D channel = 0; no conversion active; A/D on.
;
        movlw   (0<<ADCS1)|(0<<ADCS0)|(0<<CHS2)|(0<<CHS1)|(0<<CHS0)|(0<<GO)|(1<<ADON)
        banksel ADCON0
        movwf   ADCON0
;
; Right-justified 10-bit A/D result; Vref+ on Vdd; 1 analog on AN0, AN7-AN1 are discretes.
;
        movlw   (1<<ADFM)|(1<<PCFG3)|(1<<PCFG2)|(1<<PCFG1)|(0<<PCFG0)
        banksel ADCON1
        movwf   ADCON1
;
        return
;
;*******************************************************************************
;
        GLOBAL  UADC_Trigger
UADC_Trigger
;
; Delay for A/D acquisition time.
; (STRICTLY SPEAKING, THIS IS ONLY NEEDED IF CHANGING ACTIVE A/D PORT SELECTION.)
;
; Delay 20us for A/D sample setup.  Assumes 4MHz clock.
; (7*3) = 21 cycles * (1us/cycle) = 21 us.
;
        movlw   D'6'                    ; Init uses 3 cycles.
        banksel UADC_DelayTimer
        movwf   UADC_DelayTimer         ; Delay timer.
;
UADC_SetupDelay_Loop                    ; Loop uses 3 cycles each iteration.
        decfsz  UADC_DelayTimer, F      ; Delay timer.
        goto    UADC_SetupDelay_Loop    ; Loop until timer expires.
;
; Trigger A/D conversion.
;
        banksel PIE1
        bsf     PIE1, ADIE              ; Enable A/D interrupts. (BEFORE setting GO flag!)
        banksel ADCON0
        bsf     ADCON0, GO              ; Trigger A/D conversion.
        return
;
;*******************************************************************************
;
        GLOBAL  UADC_RawToASCII
UADC_RawToASCII
;
; Save completed A/D result bytes.
;
        banksel ADRESH              ; Bank 0.
        movf    ADRESH, W           ; Get A/D result high byte.
        banksel UADC_ResultRawHi    ; Bank 0.
        movwf   UADC_ResultRawHi    ; Bank 0, high byte of A/D result.
;
        banksel ADRESL              ; Bank 1.
        movf    ADRESL, W           ; Get A/D result low byte.
        banksel UADC_ResultRawLo    ; Bank 0.
        movwf   UADC_ResultRawLo    ; Bank 0, low byte of A/D result.
;
; AD_ResultRawHi:AD_ResultRawLo contains right-justified 10-bit result, upper 6 bits are 0.
; 0x0000 = 0.00 Vdc, 0x03ff = 5.00 Vdc.
; Zeros in bit 15 through bit 10; result msb = bit 9, lsb = bit 0.
;
; Convert raw A/D to engineering units.
;
; Assuming 1023 counts = 0x3ff = 5 volts.
; N(computer counts) = E(volts) * (1023 counts/5.0 volts) so N = E * 204.6
; (With N = E * 204.6, E = N/204.6, or E(volts) = N * 0.00489 (each N is 4.89mV) )
;
; For display purposes, we desire E = N * .001 (each N is 1.0 mV), or N = E * 1000.
; Therefore we rescale from N = E * 204.6 to N = E * 1000, so mult by 1000/204.6 (or 4.89).
; Since we cannot do integer multiply by 4.89 directly, we use an extra 8 bits of precision
; in the multiplier and then discard the extra 8 bits in the result.
;
; Begin with N = E * 204.6.
; Multiply by ((1000/204.6)*256) = 1251, now N = E * 1000 * 256.
; Drop lower 8 bits of result is like dividing by 256, now N = E * 1000.
;
        banksel UADC_ResultRawHi
        movf    UADC_ResultRawHi, W     ; AARGB0-B1 = raw A/D result.
        banksel AARGB0
        movwf   AARGB0
        banksel UADC_ResultRawLo
        movf    UADC_ResultRawLo, W
        banksel AARGB1
        movwf   AARGB1
        movlw   0x04                    ; BARGB0-B1 = 1251.
        movwf   BARGB0
        movlw   0xe3
        movwf   BARGB1
;
        pagesel FXM1616U
        call    FXM1616U                ; 16 x 16 unsigned multiply, AARG <- AARG x BARG.
                                        ; AARGB0-AARGB3 = raw A/D * 1251.
                                        ; To divide by 256 we ignore AARGB3 result byte.
        banksel AARGB1
        movf    AARGB1, W               ; AARGB1-B2 = scaled A/D result.
        banksel UADC_ResultScaledHi
        movwf   UADC_ResultScaledHi
        banksel AARGB2
        movf    AARGB2, W
        banksel UADC_ResultScaledLo
        movwf   UADC_ResultScaledLo
;
; Convert from engineering units to BCD.
;
        banksel UADC_ResultScaledHi
        movf    UADC_ResultScaledHi, W  ; BARGB0-B1 = scaled A/D result.
        banksel BARGB0
        movwf   BARGB0
        banksel UADC_ResultScaledLo
        movf    UADC_ResultScaledLo, W
        banksel BARGB1
        movwf   BARGB1
;
        pagesel e2bcd16u
        call    e2bcd16u                ; 16 bit unsigned engineering unit to BCD conversion.
                                        ; AARGB0-B2 = scaled A/D result in BCD.
                                        ; Result is 5 nibbles, right-justified, high nibble is 0.
;
; Convert from 5-digit BCD to 6 ASCII chars, add decimal point, 3 decimal places.
;
        banksel AARGB0
        movf    AARGB0, W               ; BARGB0-B2 = scaled A/D result in BCD.
        movwf   BARGB0
        movf    AARGB1, W
        movwf   BARGB1
        movf    AARGB2, W
        movwf   BARGB2
;
        pagesel bcd2a5p3
        call    bcd2a5p3                ; AARGB0-B5 = scaled A/D result in ASCII with dec pt.
;
        bankisel    ULCD_VoltAscii0
        movlw       ULCD_VoltAscii0     ; Dest data buffer start address.
        movwf       FSR                 ; Indirect pointer gets dest start address.
;
; AARGB0 (leading zero) is ignored as we know that range is from 00.000 to 04.999.                                       
;
        banksel     AARGB1
        movf        AARGB1, W           ; Char 0 = volts ones.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
        movf        AARGB2, W           ; Char 1 = volts decimal point.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
        movf        AARGB3, W           ; Char 2 = volts tenths.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
        movf        AARGB4, W           ; Char 3 = volts hundredths.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
        movf        AARGB5, W           ; Char 4 = volts thousandths.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
;
        return
;
        end