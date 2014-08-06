        LIST
;*******************************************************************************
; TinyRTX Filename: srtxuser.inc (System Real Time eXecutive to USER interface)
;
; Copyright 2014 Sycamore Software, Inc.  ** www.TinyRTX.com **
; Distributed under the terms of the GNU Lesser General Purpose License v3
;
; This file is part of TinyRTX. TinyRTX is free software: you can redistribute
; it and/or modify it under the terms of the GNU Lesser General Public License
; version 3 as published by the Free Software Foundation.
;
; TinyRTX is distributed in the hope that it will be useful, but WITHOUT ANY
; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
; A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
; details.
;
; You should have received a copy of the GNU Lesser General Public License
; (filename copying.lesser.txt) and the GNU General Public License (filename
; copying.txt) along with TinyRTX.  If not, see <http://www.gnu.org/licenses/>.
;
; Revision history:
;   17Oct03  SHiggins@TinyRTX.com  Created from scratch.
;   30Jul14  SHiggins@TinyRTX.com  Reduce from 4 tasks to 3 to reduce stack needs.
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
SRTX_CNT_RELOAD_TASK3   EQU     0x32	; 50 = 5.000 sec
;
AT_INTERRUPT        SET     0
SCHEDULE_TASK       SET     1
;
; SRTX configuration options allow users's AD Complete task to execute either:
;  a) directly from SISD interrupt handler, quicker but possible stack problems, or
;  b) from task scheduled by SISS, more latency but less stack usage.
; NOTE: Only one of the following two statements should be uncommented.
;
;AD_COMPLETE_TASK    SET     AT_INTERRUPT
AD_COMPLETE_TASK    SET     SCHEDULE_TASK
;
; SRTX configuration options allow users's I2C interrupt task to execute either:
;  a) directly from SISD interrupt handler, quicker but possible stack problems, or
;  b) from task scheduled by SISS, more latency but less stack usage.
; NOTE: Only one of the following two statements should be uncommented.
;
I2C_COMPLETE_TASK   SET     AT_INTERRUPT
;I2C_COMPLETE_TASK   SET     SCHEDULE_TASK
;
        LIST
