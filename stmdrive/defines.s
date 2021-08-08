; ACSI2STM Atari hard drive emulator
; Copyright (C) 2019-2021 by Jean-Matthieu Coulon

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; Global defines

pathLen=510                             ; Length of path variables
fdmagic=$4000                           ; Magic number for file descriptors
fdmask=$c080                            ; Mask to test the fd magic number

; System calls

syscall	macro
	move.w	#\2,-(sp)               ; Push syscall identifier
	trap	#\1                     ; Do the call

	ifnc	'','\3'                 ; If a stack rewind parameter is passed
	ifgt	\3-8                    ;
	lea	\3(sp),sp               ; Rewind the stack
	elseif                          ;
	addq	#\3,sp                  ; Rewind using addq
	endc                            ;
	endc                            ;
	endm

; GEMDOS system call

gemdos	macro
	syscall	1,\1,\2
	endm

Pterm0	macro
	clr.w	-(sp)
	trap	#1
	endm

Super	macro
	clr.l	-(sp)
	move.w	#Super,-(sp)
	trap	#1
	addq	#4,sp
	endm

; GEMDOS calls
Cconin=1
Cconout=2
Cconws=9
Cconis=11
Dsetdrv=14
Dgetdrv=25
Super=32
Fgetdta=47
Ptermres=49
Dcreate=57
Ddelete=58
Dsetpath=59
Fopen=61
Fclose=62
Fread=63
Fwrite=64
Fdelete=64
Dgetpath=71
Malloc=72
Mfree=73
Mshrink=74
Fsfirst=78
Fsnext=79
Frename=86

; BIOS system call

bios	macro
	syscall	13,\1,\2
	endm

Bconin=2
Bconout=3
Rwabs=4
Setexc=5
Getbpb=7
Mediach=9
Drvmap=10

; XBIOS system calls

xbios	macro
	syscall	14,\1,\2
	endm

Floprd=8
Flopwr=9
Flopfmt=10

; System variables

flock=$43e                              ; Floppy semaphore
bootdev=$446                            ; Boot device
hz200=$4ba                              ; 200Hz timer
nflops=$4a6                             ; Number of mounted floppies
drvbits=$4c2                            ; Mounted drives


; DMA hardware registers

gpip=$fffffa01
dma=$ffff8604
dmadata=dma
dmactrl=dma+2
dmahigh=dma+5
dmamid=dma+7
dmalow=dma+9


; Exception vectors
gemdos_vector=$84
bios_vector=$b4
xbios_vector=$b8
getbpb_vector=$472
rwabs_vector=$476
mediach_vector=$47e

; GEMDOS error codes
; From emuTOS
E_OK=0          ; OK, no error
ERR=-1          ; basic, fundamental error
ESECNF=-8       ; sector not found
EWRITF=-10      ; write fault
EREADF=-11      ; read fault
EWRPRO=-13      ; write protect
E_CHNG=-14      ; media change
EBADSF=-16      ; bad sectors on format
EOTHER=-17      ; insert other disk
ENSAME=-48      ; not the same drive

; Utilities

strncpy	macro
	ifc	"\1","(a0)"
	fail
	endc
	ifnc	"\2","(a0)"
	lea	\2,a0
	endc
	ifnc	"\1","(a1)"
	lea	\1,a1
	endc
	ifnc	"\3","d0"
	move.w	\3,d0
	endc
	bsr.w	strncpy_impl
	endm

blkcopy	macro
	ifc	"\1","(a0)"
	fail
	endc
	ifnc	"\2","(a0)"
	lea	\2,a0
	endc
	ifnc	"\1","(a1)"
	lea	\1,a1
	endc
	bsr.w	blkcopy_impl
	endm

memcpy	macro
	ifc	"\1","(a0)"
	fail
	endc
	ifnc	"\2","(a0)"
	lea	\2,a0
	endc
	ifnc	"\1","(a1)"
	lea	\1,a1
	endc
	ifnc	"\3","d0"
	move.w	\3,d0
	endc
	bsr.w	memcpy_impl
	endm

; vim: ff=dos ts=8 sw=8 sts=8 noet
