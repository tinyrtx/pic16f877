        LIST
;*******************************************************************************
; tinyRTX Filename: srtxuser.inc (System Real Time eXecutive to USER interface)
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
;   17Oct03  SHiggins@tinyRTX.com  	Created from scratch.
;   30Jul14  SHiggins@tinyRTX.com  	Reduce from 4 tasks to 3 to reduce stack needs.
;   27Aug14  SHiggins@tinyRTX.com  	Remove AD_COMPLETE_TASK and I2C_COMPLETE_TASK options.
;									Both now have some interrupt handling and a task.
;
;*******************************************************************************
       NOLIST
;
; Counts to load task timer at initialization (must be non-zero.)
; Each task will be first scheduled at the SRTX-timer event which
;   occurs as equated below.  However, please note that immediately
;   after initialization is complete, a single "faux" SRTX-timer
;   event occurs, which allows all tasks equated to "1" below to run.
; Allowed range is (1 - 255).
;
SRTX_CNT_INIT_TASK1     EQU     1
SRTX_CNT_INIT_TASK2     EQU     1
SRTX_CNT_INIT_TASK3     EQU     1
;
; Counts to reload task timer each expiration.  This is the number of
;   SRTX-timer events which must occur before the task is again scheduled.
; Allowed range is (1 - 255).
;
SRTX_CNT_RELOAD_TASK1   EQU     0x01	;  1 = 100 ms
SRTX_CNT_RELOAD_TASK2   EQU     0x0a	; 10 = 1.000 sec
SRTX_CNT_RELOAD_TASK3   EQU     0x14	; 20 = 2.000 sec
