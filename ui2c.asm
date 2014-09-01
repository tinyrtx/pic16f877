        LIST
;*******************************************************************************
; tinyRTX Filename: ui2c.asm (User Inter-IC communication routines)
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
;	16Oct03	SHiggins@tinyRTX.com	Created from scratch for PICdem2plus demo board.
;   27Aug14 SHiggins@tinyRTX.com 	When msgs complete invoke UI2C_MsgTC74Complete
;									to schedule task. Then SRTX_Dispatcher will invoke
;									UI2C_MsgTC74ProcessData as proper task.
;
;*******************************************************************************
;
        errorlevel -302	
        #include    <p16f877.inc>
        #include    <srtx.inc>
        #include    <si2c.inc>
        #include    <sm16.inc>
        #include    <sbcd.inc>
        #include    <ulcd.inc>
;
;*******************************************************************************
;
; User I2C defines.
;
#define  ADDR_SLAVE_TC74            0x9a    ; TC74 slave I2C address.
#define  TC74_CONFIG_DATA_READY     0x40    ; TC74 CONFIG bit = 1 when data is ready.
;
;*******************************************************************************
;
; User I2C service variables.
;
        GLOBAL  UI2C_MsgState
;
UI2C_UdataSec   UDATA
UI2C_MsgState   res     1               ; UI2C msg state machine variable.
UI2C_TC74Data   res     1               ; Raw data from TC74.
;
;*******************************************************************************
;
; User I2C message table.
;
; LINKNOTE: UI2C_TableSec and UI2C_CodeSec must be placed within same code page.
; LINKNOTE: UI2C_TableSec must be placed in section that does not cross 0xXX00 boundary.
;
;*******************************************************************************
;
; Use I2C to read temperature from TC74.
;
;   Starting states for message group.
; NOTE: THESE #define's ARE LINKED TO UI2C_Tbl_MsgState TABLE DEFINITION BELOW.
;
#define     UI2C_STATE_TC74         0x00
;
UI2C_TableSec   CODE
UI2C_Tbl_MsgState
;
; Send I2C message content based on I2_MsgState.
;
        movlw   high UI2C_Tbl_MsgState  ; Get upper 5 bits of current address.
        movwf   PCLATH                  ; Set all 5 bits PCLATH to current location.
        banksel UI2C_MsgState
        movf    UI2C_MsgState, W        ; UI2C_MsgState application message state.
        addwf   PCL, F                  ; W = offset, index into state machine jump table.
;
; Processing for each state                                                             I2_MsgState(hex)
;
;       (UI2C_MsgTC74)
        goto    UI2C_MsgTC74ReadStatus  ; S 0x9a(W) (ACK) 0x01(W) (ACK) RS 0x9b(R) (ACK) 0x?? NACK P =  0
        goto    UI2C_MsgTC74CheckStatus ; Check received status, retry or proceed                    =  1
        goto    UI2C_MsgTC74ReadData    ; S 0x9a(W) (ACK) 0x00(W) (ACK) RS 0x9b(R) (ACK) 0x?? NACK P =  2
        goto    UI2C_MsgTC74Complete	; Message complete, schedule task to process temperature     =  3
;
; NOTE: THIS UI2C_Tbl_MsgState TABLE DEFINITION IS LINKED TO #define's ABOVE.
;
;*******************************************************************************
;
; Init I2C hardware.
;
; LINKNOTE: UI2C is NOT PAGE SAFE, there are unprotected calls out of UI2C.
;
UI2C_CodeSec    CODE
;
        GLOBAL  UI2C_Init
UI2C_Init
;
; Init MSSP module to use I2C at 100kHz baud rate.
;
; I2C Baud Rate Generator reload value computed as follows:
;  BRG reload value = ( Fosc / 4 )/ I2C bit rate) - 1
;                   = ( 4 Mhz / 4 )/ 100kHz ) - 1 = 9 = 0x09
;
;		movlw   0x09            ; BRG reload value(-1).
		movlw   0x05
		banksel SSPADD
		movwf   SSPADD          ; Init I2C BRG reload value.
;
; TRISC already configured as inputs for SDA and SCL.
;
; WCOL, SSPOV, CKP cleared;  SSP enabled; 
;   SSP mode set to b'1000' = I2C Master mode, clock = FOSC / (4 * (SSPADD+1)
;
        movlw   (0<<WCOL)|(0<<SSPOV)|(1<<SSPEN)|(0<<CKP)|(1<<SSPM3)|(0<<SSPM2)|(0<<SSPM1)|(0<<SSPM0)
        banksel SSPCON
        movwf   SSPCON          ; Master mode, SSP enable.
;
;   SSPSTAT changed: SMP slew for 100kHz, CKE uses I2C input levels, all others read-only.
;
        movlw   (1<<SMP)|(0<<CKE)|(0<<I2C_DATA)|(0<<I2C_STOP)|(0<<I2C_START)|(0<<I2C_READ)|(0<<UA)|(0<<BF)
        banksel SSPSTAT
        movwf   SSPSTAT         ; SMP slew for 100kHz.
		return
;
;*******************************************************************************
;
; UI2C_MsgDone is called from SI2C/SUSR when an I2C message completes. 
; It increments UI2C_MsgState to point to the next cmd message in the msg group.
;
        GLOBAL  UI2C_MsgDone
UI2C_MsgDone
;
        banksel UI2C_MsgState 
        incf    UI2C_MsgState, F        ; Increment UI2C_MsgState for next cmd msg.
        goto    UI2C_Tbl_MsgState       ; Start next cmd msg in msg group.
;
;*******************************************************************************
;
; Message groups set up UI2C_MsgState to execute each msg in a msg group.
;  They also initiate execution of first msg in the group.
;
;*******************************************************************************
;
; UI2C_MsgTC74 msg group gets data from TC74 thermometer.
;
        GLOBAL  UI2C_MsgTC74
UI2C_MsgTC74
;
        banksel SI2C_AddrSlave
        movlw   ADDR_SLAVE_TC74     ; TC74 slave I2C address.
        movwf   SI2C_AddrSlave      ; Slave I2C address.
;
        banksel UI2C_MsgState
        movlw   UI2C_STATE_TC74     ; First cmd msg in TC74 msg group.
        movwf   UI2C_MsgState       ; Set UI2C_MsgState to first cmd msg in msg group.
        goto    UI2C_Tbl_MsgState   ; Start first cmd msg in msg group.
;
;*******************************************************************************
;
; Command messages are responsible for either:
;   a) Setting up the transmit data for the current message, and
;      initiating execution of the first I2C hardware state by calling the appropriate SI2C wrapper.
;       (upon SI2C msg completion, command msg state will be advanced automatically by UI2C_MsgDone)
; or:
;   b) Processing any received status/data from the previous message, and
;       b1) Setting the command message state to the previous message (in case of retry)
;           and forcing execution of the next command message, or
;       b2) Setting the command message state to the succeeding message (in case of success)
;           and forcing execution of the next command message, or
;       b3) Simply returning, which effective ends the message group. 
;
;*******************************************************************************
;
; UI2C_MsgTC74ReadStatus msg reads status from the device to
;   ensure the device has completed the temperature conversion.
;
UI2C_MsgTC74ReadStatus
;
        movlw   0x01                ; TC74 cmd = Use CONFIG register.
        banksel SI2C_DataByteXmt00
        movwf   SI2C_DataByteXmt00  ; Set msg write data byte.
;
        movlw   0x01                ; Get msg data byte write count.
        movwf   SI2C_DataCntXmt     ; Set msg data byte write count.
        movwf   SI2C_DataCntRcv     ; Set msg data byte read count.
;
        pagesel SI2C_Msg_Wrt_Rd
        goto    SI2C_Msg_Wrt_Rd     ; Start message.
;
;*******************************************************************************
;
; UI2C_MsgTC74CheckStatus msg checks status data already read from the device.
;
UI2C_MsgTC74CheckStatus
;
; Check results of previous status message to make certain the TC74 device
;   has finished with its temperature conversion.  If it has not finished we must run the
;   previous status message again and wait for the conversion to complete.  After the
;   conversion is complete we can run the next message and get the temperature data.
;
        banksel SI2C_DataByteRcv00
        movfw   SI2C_DataByteRcv00              ; Get TC74 status from msg read data byte.
        andlw   TC74_CONFIG_DATA_READY          ; Mask out everything except READY bit.
        btfss   STATUS, Z                       ; Skip if zero result, meaning READY bit was not set.
        goto    UI2C_MsgTC74CheckStatusPassed   ; Jump if non-zero result, TC74 is ready.
;
UI2C_MsgTC74CheckStatusFailed
        banksel UI2C_MsgState
        decf    UI2C_MsgState, F    ; Decrement UI2C_MsgState to prev cmd msg in msg group.
        goto    UI2C_MsgTC74CheckStatusExit
;
UI2C_MsgTC74CheckStatusPassed
        banksel UI2C_MsgState
        incf    UI2C_MsgState, F    ; Increment UI2C_MsgState to next cmd msg in msg group.
;
UI2C_MsgTC74CheckStatusExit
        goto    UI2C_Tbl_MsgState   ; Start next cmd msg in msg group.
;
;*******************************************************************************
;
; UI2C_MsgTC74ReadData msg reads data from the device.
;
UI2C_MsgTC74ReadData
;
; First we need to check results of previous status message to make certain the TC74
;   device has finished with its temperature conversion.  If it has not we must run the
;   status message again and wait for the conversion to complete.  After the conversion
;   is complete we can run this message and get the temperature data.
;
        movlw   0x00                ; TC74 cmd = Use TEMP register.
        banksel SI2C_DataByteXmt00
        movwf   SI2C_DataByteXmt00  ; Set msg data byte.
;
        movlw   0x01                ; Get msg data byte write count.
        movwf   SI2C_DataCntXmt     ; Set msg data byte write count.
        movwf   SI2C_DataCntRcv     ; Set msg data byte read count.
;
        pagesel SI2C_Msg_Wrt_Rd
        goto    SI2C_Msg_Wrt_Rd     ; Start message.
;
;
;*******************************************************************************
;
; UI2C_MsgTC74Complete schedules task to process data.  Then interrupt can exit.
; SRTX Dispatcher will find task scheduled and invoke UI2C_MsgTC74ProcessData.
;
UI2C_MsgTC74Complete
;
; Save the raw temperature data in the previous message from the TC74 device.
;
        banksel SI2C_DataByteRcv00
        movfw   SI2C_DataByteRcv00          ; Get TC74 data from msg read data byte.
        banksel UI2C_TC74Data
        movwf   UI2C_TC74Data               ; Save raw data.
;;		smTraceW
;
        banksel SRTX_Sched_Cnt_TaskI2C
       	incfsz  SRTX_Sched_Cnt_TaskI2C, F   ; Increment task schedule count.
        goto    UI2C_MsgTC74CompleteExit    ; Task schedule count did not rollover.
        decf    SRTX_Sched_Cnt_TaskI2C, F   ; Max task schedule count.
;
UI2C_MsgTC74CompleteExit
		return
;
;*******************************************************************************
;
; UI2C_MsgTC74ProcessData msg converts temperature data already read from the device.
;
        GLOBAL  UI2C_MsgTC74ProcessData
UI2C_MsgTC74ProcessData
;
; Use the raw temperature data in the previous message from the TC74 device.
; Convert it to ASCII and put it in a buffer so it is displayed on the LCD.
; Assume positive temperature from 0 - 127 deg C, raw data byte is 0x00 - 0x7f.
; Convert from engineering units to BCD.
;
        movlw   0x7f
        banksel UI2C_TC74Data
        andwf   UI2C_TC74Data, W                ; AND off high bit to force positive temps.
        banksel BARGB0
        movwf   BARGB0
;
        pagesel e2bcd8u
        call    e2bcd8u                 ; 8 bit unsigned engineering unit to BCD conversion.
                                        ; AARGB0-B1 = result in BCD.
                                        ; Result is 3 nibbles, right-justified, high nibble is 0.
;
; Convert from 3-digit BCD to 3 ASCII chars, no decimal places.
;
        banksel AARGB0
        movf    AARGB0, W               ; BARGB0-B1 = result in BCD.
        movwf   BARGB0
        movf    AARGB1, W
        movwf   BARGB1
;
        pagesel bcd2a3p0
        call    bcd2a3p0                ; AARGB0-B2 = result in ASCII.
;
        bankisel    ULCD_TempAscii0
        movlw       ULCD_TempAscii0     ; Dest data buffer start address.
        movwf       FSR                 ; Indirect pointer gets dest start address.
;
        banksel     AARGB0
        movf        AARGB0, W           ; Char 0 = temperature hundreds.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
        movf        AARGB1, W           ; Char 1 = temperature tens.
        movwf       INDF                ; Store data in dest ASCII buffer.
        incf        FSR, F              ; Bump dest data pointer.
        movf        AARGB2, W           ; Char 2 = temperature ones.
        movwf       INDF                ; Store data in dest ASCII buffer.
        return
;
        end