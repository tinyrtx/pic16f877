        LIST
;*******************************************************************************
; tinyRTX Filename: sisd.asm (System Interrupt Service Director)
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
;   17Oct03 SHiggins@tinyRTX.com 	Created from scratch.
;   23Jul14 SHiggins@tinyRTX.com 	Move save/restore FSR from SISD_Director to 
;									to SISD_Interrupt
;   27Aug14  SHiggins@tinyRTX.com  	Remove AD_COMPLETE_TASK and I2C_COMPLETE_TASK options.
;									Both now have some interrupt handling and a task.
;									SISD_Director_CheckI2C now calls SUSR_ISR_I2C.
;;									Also moved SISD_Director inline with SISD_Interrupt.
;
;*******************************************************************************
;
        errorlevel -302	
	    #include    <p16f877.inc>
	    #include    <srtx.inc>
	    #include    <srtxuser.inc>
        #include 	<strc.inc>
	    #include    <susr.inc>
;
;*******************************************************************************
;
; SISD service variables.
;
; Interrupt Service Routine context save/restore variables.
;
; LINKNOTE: SISD_UdataShrSec must be placed in data space shared across all banks.
;			This is because to save/restore STATUS register properly, we can't control
;			RP1 and RP0 bits.  So any values in RP1 and RP0 must be valid.  In order to
;			allow this we need memory which accesses the same across all banks.
;
SISD_UdataShrSec    UDATA_SHR
;
SISD_TempW          res     1   ; Bank 0/1/2/3; temp copy of W.
SISD_TempSTATUS     res     1   ; Bank 0/1/2/3; temp copy of STATUS.
SISD_TempPCLATH     res     1   ; Bank 0/1/2/3; temp copy of PCLATH.
SISD_TempFSR        res     1   ; Bank 0/1/2/3; temp copy of FSR.
;
;*******************************************************************************
;
SISD_ResetCodeSec   CODE            ; Reset vector address.
;
SISD_Reset
        pagesel SRTX_Init
        goto    SRTX_Init           ; Initialize SRTX and then application.
;
SISD_IntCodeSec     CODE            ; Interrupt vector address.
;
SISD_Interrupt
        movwf   SISD_TempW          ; Bank 0/1/2/3; preserve W without changing STATUS.
        movf	STATUS, W           ; Bank 0/1/2/3; preserve STATUS.
        movwf	SISD_TempSTATUS
        movf	PCLATH, W           ; Bank 0/1/2/3; preserve PCLATH.
        movwf	SISD_TempPCLATH
        movf	FSR, W              ; Bank 0/1/2/3; preserve FSR.
        movwf	SISD_TempFSR
;
; Now we can use the internal registers (W, STATUS, PCLATH and FSR).
; GOTO is used here to save stack space, and SISD_Director never called elsewhere.
;
        pagesel SISD_Director
        goto    SISD_Director       ; Service interrupt director.
;
; SISD_Director does a GOTO here when it completes.
;
SISD_InterruptExit
;
; Now we restore the internal registers (W, STATUS, PCLATH and FSR), taking special care not to disturb
; any of them.
;
        movf	SISD_TempFSR, W  	; Bank 0/1/2/3; restore FSR.        
        movwf	FSR
        movf	SISD_TempPCLATH, W  ; Bank 0/1/2/3; restore PCLATH.        
        movwf	PCLATH
        movf    SISD_TempSTATUS, W  ; Bank 0/1/2/3; restore STATUS.
        movwf	STATUS
        swapf   SISD_TempW, F       ; Bank 0/1/2/3; restore W without changing STATUS.
        swapf   SISD_TempW, W
;
        retfie                      ; Return from interrupt exception. (Return plus GIE.)
;
;*******************************************************************************
;
SISD_CodeSec	CODE
;
;*******************************************************************************
;
; SISD: System Interrupt Service Director.
;
; 3 possible sources of interrupts:
;   a) Timer1 expires. (Initiate A/D conversion, schedule new timer int in 100ms.)
;   b) A/D conversion completed. (Convert reading to ASCII.)
;   c) I2C event completed. (Multiple I2C events to transmit ASCII.)
;
;*******************************************************************************
;
; Each routine invoked by this routine must conclude with a MANDATORY return statement.
; This allows us to save a stack slot by using GOTO's here and still operate correctly.
;
SISD_Director
;
; Test for Timer1 rollover.
;
        banksel PIR1
        btfss   PIR1, TMR1IF            ; Skip if Timer1 interrupt flag set.
        goto    SISD_Director_CheckADC  ; Timer1 int flag not set, check other ints.
        bcf     PIR1, TMR1IF            ; Clear Timer1 interrupt flag.
        pagesel SUSR_Timebase
        call    SUSR_Timebase           ; User re-init of timebase interrupt.
        pagesel SRTX_Scheduler
        call    SRTX_Scheduler          ; SRTX scheduler when timebase interupt, must RETURN at end.
        pagesel SISD_Director_Exit
        goto    SISD_Director_Exit      ; Only execute single interrupt handler.
;
; Test for completion of A/D conversion.
;
SISD_Director_CheckADC
        btfss   PIR1, ADIF              ; Skip if A/D interrupt flag set.
        goto    SISD_Director_CheckI2C  ; A/D int flag not set, check other ints.
        bcf     PIR1, ADIF              ; Clear A/D interrupt flag.
        banksel PIE1
        bcf     PIE1, ADIE              ; Disable A/D interrupts.
        banksel SRTX_Sched_Cnt_TaskADC
        incfsz  SRTX_Sched_Cnt_TaskADC, F   ; Increment task schedule count.
        goto    SISD_Director_Exit          ; Task schedule count did not rollover.
        decf    SRTX_Sched_Cnt_TaskADC, F   ; Max task schedule count.
        goto    SISD_Director_Exit          ; Only execute single interrupt handler.
;
; Test for completion of I2C event.
;
SISD_Director_CheckI2C
        btfss   PIR1, SSPIF             ; Skip if I2C interrupt flag set.
        goto    SISD_Director_Exit      ; I2C int flag not set, check other ints.
        bcf     PIR1, SSPIF             ; Clear I2C interrupt flag.
        pagesel SUSR_ISR_I2C
        call    SUSR_ISR_I2C            ; User handling when I2C event.
        pagesel SISD_Director_Exit
        goto    SISD_Director_Exit      ; Only execute single interrupt handler.
;
; This point only reached if unknown interrupt occurs, any error handling can go here.
;
SISD_Director_Exit
        pagesel SISD_InterruptExit
        goto    SISD_InterruptExit      ; Return to SISD interrupt handler.
;
        end