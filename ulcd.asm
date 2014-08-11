        LIST
;*******************************************************************************
; tinyRTX Filename: ulcd.asm (User Liquid Crystal Display routines)
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
;   21Oct03 SHiggins@tinyRTX.com Created from scratch for PICdem2plus demo board.
;   11Aug14 SHiggins@tinyRTX.com Change ULCD data from Tiny to tiny.
;
;*******************************************************************************
;
        errorlevel -302	
        #include    <p16f877.inc>
        #include    <sm16.inc>
        #include    <slcd.inc>
;
;*******************************************************************************
;
; User LCD defines.
;
#define ULCD_LINE_1_START   0x00
#define ULCD_LINE_1_END     0x50
#define ULCD_LINE_1_LENGTH  0x10
;
;*******************************************************************************
;
; User LCD service variables.
;
ULCD_UdataSec       UDATA
;
ULCD_DataXferCnt    res     1   ; Data transfer counter.
ULCD_DataSrcIdx     res     1   ; Data source index.
ULCD_PositionIdx    res     1   ; Position index (0x00-0x40)
;
; These ULCD_VoltAscii0-4 variables must be kept sequential.
;
        GLOBAL  ULCD_VoltAscii0
ULCD_VoltAscii0     res     1   ; ASCII A/D result, char 0.
ULCD_VoltAscii1     res     1   ; ASCII A/D result, char 1.
ULCD_VoltAscii2     res     1   ; ASCII A/D result, char 2.
ULCD_VoltAscii3     res     1   ; ASCII A/D result, char 3.
ULCD_VoltAscii4     res     1   ; ASCII A/D result, char 4.
;
; These ULCD_TempAscii0-2 variables must be kept sequential.
;
        GLOBAL  ULCD_TempAscii0
ULCD_TempAscii0     res     1   ; ASCII temperature result, char 0.
ULCD_TempAscii1     res     1   ; ASCII temperature result, char 1.
ULCD_TempAscii2     res     1   ; ASCII temperature result, char 2.
;
;*******************************************************************************
;
; User LCD display table.
;
; LINKNOTE: ULCD_TableSec and ULCD_CodeSec must be placed within same code page.
; LINKNOTE: ULCD_TableSec must be placed in section that does not cross 0xXX00 boundary.
;
ULCD_TableSec       CODE
ULCD_TableLookup
    movlw   high ULCD_TableLookup   ; Get upper 5 bits of table addr.
    movwf   PCLATH                  ; Set all 5 bits PCLATH to current table addr.
    banksel ULCD_DataSrcIdx
    movf    ULCD_DataSrcIdx, W      ; Get current data index.
    addwf   PCL, F
;
	;	"--Display-Data--"  ; offset
	dt	"                "  ; 0x00
	dt	"tinyRTX from... "  ; 0x10
	dt	"Sycamore Softwar"  ; 0x20
	dt	"e, Inc.   SHiggi"  ; 0x30
	dt	"ns@tinyRTX.com  "  ; 0x40
	dt	"                "  ; 0x00 and identically 0x50
;
;*******************************************************************************
;
; Init LCD display variables.
;
; LINKNOTE: ULCD is PAGE SAFE, there are no unprotected calls out of ULCD.
;
ULCD_CodeSec        CODE
;
        GLOBAL      ULCD_Init
ULCD_Init
        movlw       ULCD_LINE_1_START
        banksel     ULCD_PositionIdx
        movwf       ULCD_PositionIdx
        return
;
;*******************************************************************************
;
; Refresh contents of LCD Line 1 display buffer with current data.
;
        GLOBAL      ULCD_RefreshLine1
ULCD_RefreshLine1
;
        movlw       ULCD_LINE_1_LENGTH  ; Copy entire first line of table to display buffer.
        banksel     ULCD_DataXferCnt
        movwf       ULCD_DataXferCnt
        movf        ULCD_PositionIdx, W ; Get saved table start address.
        movwf       ULCD_DataSrcIdx     ; Start source data table index.
;
        bankisel    SLCD_BufferLine1
        movlw       SLCD_BufferLine1    ; Dest data buffer start address.
        movwf       FSR                 ; Indirect pointer gets dest start address.
;
ULCD_RefreshLine1Loop
        call        ULCD_TableLookup    ; Get data at current index.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        incf        ULCD_DataSrcIdx, F  ; Bump source data table index.
        decfsz      ULCD_DataXferCnt, F ; Dec count of data to copy.
        goto        ULCD_RefreshLine1Loop   ; More data to copy.
;
        incf        ULCD_PositionIdx, F ; Bump saved table start address.
        movlw       ULCD_LINE_1_END     ; Address past last valid start address.
        subwf       ULCD_PositionIdx, W ; W = saved addr less valid addr.
        btfss       STATUS, Z           ; Skip if Z = 1, now past last valid address.
        goto        ULCD_RefreshLine1Exit       ; Z = 0, start addr still valid.
        movlw       ULCD_LINE_1_START   ; Get first valid addr.
        banksel     ULCD_PositionIdx
        movwf       ULCD_PositionIdx    ; Reset start addr to first valid addr.
;
ULCD_RefreshLine1Exit
        return
;
;*******************************************************************************
;
; Refresh contents of LCD Line 2 display buffer with current data.
;
        GLOBAL      ULCD_RefreshLine2
ULCD_RefreshLine2
        bankisel    SLCD_BufferLine2
        movlw       SLCD_BufferLine2    ; Dest data buffer start address.
        movwf       FSR                 ; Indirect pointer gets dest start address.
;
        banksel     ULCD_VoltAscii0
        movf        ULCD_VoltAscii0, W  ; Char 0 = volts ones.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_VoltAscii1, W  ; Char 1 = volts decimal point.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_VoltAscii2, W  ; Char 2 = volts tenths.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_VoltAscii3, W  ; Char 3 = volts hundredths.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_VoltAscii4, W  ; Char 4 = volts thousandths.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       ' '                 ; Char 5 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       'V'                 ; Char 6 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       ' '                 ; Char 7 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       '+'                 ; Char 8 = ASCII pos/neg sign.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_TempAscii0, W  ; Char 9 = degrees hundreds.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_TempAscii1, W  ; Char 10 = degrees tens.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movf        ULCD_TempAscii2, W  ; Char 11 = degrees ones.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       ' '                 ; Char 12 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       'd'                 ; Char 13 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       'g'                 ; Char 14 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
        movlw       'C'                 ; Char 15 = ASCII constant.
        movwf       INDF                ; Store data in dest data buffer
        incf        FSR, F              ; Bump dest data pointer.
;
        return
;
        end