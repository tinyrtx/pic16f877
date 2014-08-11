        LIST
;**********************************************************************************************
; tinyRTX Filename: susr.inc (System to USeR interface)
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
;   31Oct03  SHiggins@tinyRTX.com  Created from scratch.
;   30Jul14  SHiggins@tinyRTX.com  Reduce from 4 tasks to 3 to reduce stack needs.
;
;*******************************************************************************
        NOLIST
;
        EXTERN      SUSR_POR_PhaseA
        EXTERN      SUSR_POR_PhaseB
        EXTERN      SUSR_Timebase
        EXTERN      SUSR_Task1
        EXTERN      SUSR_Task2
        EXTERN      SUSR_Task3
        EXTERN      SUSR_TaskADC
        EXTERN      SUSR_TaskI2C
        EXTERN      SUSR_TaskI2C_MsgDone
;
        LIST
