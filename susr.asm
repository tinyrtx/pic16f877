        TITLE "SUSR - SRTX to User Application interface"
;
;*******************************************************************************
; tinyRTX Filename: susr.asm (System USeR interface)
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
; Revision History:
;  31Oct03  SHiggins@tinyRTX.com  Created to isolate user vars and routine calls.
;  24Feb04  SHiggins@tinyRTX.com  Add trace.
;  29Jul14  SHiggins@tinyRTX.com  Moved UAPP_Timer1Init to MACRO to save stack.
;  30Jul14  SHiggins@tinyRTX.com  Reduce from 4 tasks to 3 to reduce stack needs.
;
;*******************************************************************************
;
        list p=16f877,f=inhx32
        errorlevel -302	
        #include <p16f877.inc>
        #include <slcd.inc>
        #include <si2c.inc>
        #include <strc.inc>
        #include <uapp.inc>
        #include <ulcd.inc>
        #include <uadc.inc>
        #include <ui2c.inc>
;
;*******************************************************************************
;
;  RAM variable definitions.
;
SUSR_UdataSec       UDATA
;
SUSR_Temp           res     1   ; Place holder, no SUSR variables yet.
;
;*******************************************************************************
;
; SUSR: System to User Redirection.
;
; These routines provide the interface from the SRTX (System Real Time eXecutive)
;   and SISD (Interrupt Service Routine Director) to user application code.
;
SUSR_CodeSec    CODE
;
; User initialization at Power-On Reset Phase A.
;  Application time-critical initialization, no interrupts.
;
        GLOBAL  SUSR_POR_PhaseA
SUSR_POR_PhaseA
        nop
        return
;
; User initialization at Power-On Reset Phase B.
;  Application non-time critical initialization.
;
        GLOBAL  SUSR_POR_PhaseB
SUSR_POR_PhaseB
        pagesel UAPP_POR_Init
        call    UAPP_POR_Init           ; User app POR Init. (Enables global interrupts.)
;
;  UAPP_POR_Init enabled global interrupts.
;
        pagesel UADC_Init
        call    UADC_Init               ; User ADC hardware init.
        pagesel SLCD_Init
        call    SLCD_Init               ; System LCD init.
        pagesel ULCD_Init
        call    ULCD_Init               ; User LCD init.
        pagesel UI2C_Init
        call    UI2C_Init               ; User I2C hardware init.
        return
;
; User initialization of timebase timer and corresponding interrupt.
;
        GLOBAL  SUSR_Timebase
SUSR_Timebase
		UAPP_Timer1Init         ; Re-init Timer1 so new int in 100ms. (Enables Timer1 interrupt.)
;
; UAPP_Timer1Init enabled Timer1 interrupts.
;
        return
;
; User interface to Task1.
;
        GLOBAL  SUSR_Task1
SUSR_Task1
        smTrace STRC_TSK_BEG_1
        banksel PORTB
        movlw   0x01
        xorwf   PORTB, F                ; Toggle LED 1.
        pagesel UADC_Trigger
        call    UADC_Trigger            ; Initiate new A/D conversion. (Enables ADC interrupt.)
;
; UADC_Trigger enabled ADC interrupts.
;
        smTrace STRC_TSK_END_1
        return
;
; User interface to Task2.
;
        GLOBAL  SUSR_Task2
SUSR_Task2
        smTrace STRC_TSK_BEG_2
        banksel PORTB
        movlw   0x02
        xorwf   PORTB, F                ; Toggle LED 2.
        pagesel ULCD_RefreshLine1
        call    ULCD_RefreshLine1       ; Update LCD data buffer with scrolling message.
        pagesel SLCD_RefreshLine1
        call    SLCD_RefreshLine1       ; Send LCD data buffer to LCD.
        smTrace STRC_TSK_END_2
        return
;
; User interface to Task3.
;
        GLOBAL  SUSR_Task3
SUSR_Task3
        smTrace STRC_TSK_BEG_3
        banksel PORTB
        movlw   0x04
        xorwf   PORTB, F                ; Toggle LED 3.
        pagesel UI2C_MsgTC74
        call    UI2C_MsgTC74			; Use I2C to get raw temperature from TC74.
        smTrace STRC_TSK_END_3
        return
;
; User interface to TaskAD.
; User handling when A/D conversion complete interrupt occurs.
;
        GLOBAL  SUSR_TaskADC
SUSR_TaskADC
        smTrace STRC_TSK_BEG_ADC
        pagesel UADC_RawToASCII
        call    UADC_RawToASCII         ; Convert A/D result to ASCII msg for display.
        pagesel ULCD_RefreshLine2
        call    ULCD_RefreshLine2       ; Update LCD data buffer with A/D and temperature.
        pagesel SLCD_RefreshLine2
        call    SLCD_RefreshLine2       ; Send LCD data buffer to LCD.
        smTrace STRC_TSK_END_ADC
        return
;
; User handling when I2C event interrupt occurs.
;
        GLOBAL  SUSR_TaskI2C
SUSR_TaskI2C
        smTrace STRC_TSK_BEG_I2C
        pagesel SI2C_Tbl_HwState
        call    SI2C_Tbl_HwState        ; Service I2C event.
        smTrace STRC_TSK_END_I2C
        return
;
; User handling when I2C message completed.
;
        GLOBAL  SUSR_TaskI2C_MsgDone
SUSR_TaskI2C_MsgDone
        pagesel UI2C_MsgDone
        goto    UI2C_MsgDone
;
        end