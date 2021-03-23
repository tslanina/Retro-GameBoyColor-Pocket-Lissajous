; Pocket Lissajous
; 256b Intro
; GameBoy Color
;
; Contribution to Lovebyte Demoparty 2021
;
; Tomasz Slanina
; dox/Joker
; https://github.com/tslanina
;
;
; The size limit is 256 bytes ( $50 - $150 in ROM), including the header (and the N logo).
; It is about 180 bytes left for data and code. Header parts can also be used for data/code.
; The intro is simple, just a sin table generator
; ( see https://codebase64.org/doku.php?id=base:generating_approximate_sines_in_assembly )
; and palette/oam filler.
; Code is copied to RAM @ $c000 ( the "copier" resides in the header ;)


rNR13  equ $ff13
rNR14  equ $ff14
rLCDC  equ $ff40
rSTAT  equ $ff41
rLY    equ $ff44
rBCPS  equ $ff68
rOAM   equ $fe00

MOVE_OFFSET equ $bfb0

SECTION "start",ROM0[$50]   
start:   
       ld h,$d0
       ld de,0

.generate_sin:
                
.adder_low:
       ld a,0
       add a,e  
       ld [.adder_low+1 + MOVE_OFFSET],a 

.adder_high:
       ld a,0 
       adc a,d
       ld [.adder_high+1+ MOVE_OFFSET],a
       push af
       
       ld a,$c0
       add a,c
       ld l,a

       pop af
       push af
       ld [hl],a

       ld a,$80
       add a,b
       ld l,a
       pop af
       push af
       ld [hl],a     

       ld a,$40
       add a,c
       ld l,a

       pop af
       xor $3f

       ld [hl],a

       ld l,b
       ld [hl],a

       ld a,e
       add a,4
       ld e,a
       jr nc,.skip_top 

       inc d

.skip_top:
       inc c
       dec b
       bit 7,b

       jr z,.generate_sin

       ld hl,rOAM
       ld a,7

.fill_oam:
       ld [hl+],a
       bit 0,h
       jr z,.fill_oam

       ld a,$82
       ld [rLCDC],a
                
.main_loop:

       ld a,[rLY]
       cp 144
       jr z,.update_oam

       ld a,[rSTAT]
       and 3
       jr nz,.main_loop

       ld hl,rBCPS
       ld a,128
       ld [hl+],a
       ld a,[rLY]

.palette_chg:
       add a,0
       cp 128
       jr c,.not_invert
       cpl

.not_invert:
       rra
       srl a
       ld c,a
       ld [hl],a
       ld a,%111100
       ld [hl+],a
      
       ld a,128+7*4*2+2
       ld [hl+],a
 
       ld [hl],c
       ld [hl],c
      
       jr .main_loop

.update_oam:
       ld hl,.palette_chg+1+MOVE_OFFSET
       dec [hl]
       ld b,[hl]
       ld a,b
       cpl
       ld c,a

       jr nz,.skip_liss_change

       ld l,LOW(.liss_move+1+MOVE_OFFSET)
       ld a,[hl]
       xor 24 ; 16 <-> 8
       ld [hl],a

       ld l,LOW(.update_oam+3+MOVE_OFFSET)
       ld a,[hl]
       xor 1; inc (hl) <-> dec (hl)
       ld [hl],a

.skip_liss_change:

       ld hl,rOAM

.loop_objects:
       ld a,c

.liss_move:         
       add a,16
       ld c,a
       ld e,a
       ld d,$d0
       ld a,[de]

       add a,48 ; y center

       ld [hl+],a ;y
       
       ld a,b
       add a,8
       ld b,a
       ld e,a
       ld a,[de]

       add a,54 ; x center

       ld [hl+],a ;x

       inc l
       inc l
       bit 7,l
       jr z,.loop_objects

       ld a,c
       swap a
       set 7,a
       ld [rNR13],a
       ld a,$87
       ld [rNR14],a

       jr .main_loop


SECTION "boot",ROM0[$100]
       nop
       jp $134

SECTION "header",ROM0[$134]
       ld [rLCDC],a 
       ld b,$c0
       ld l,$50
copycopy:
       ld a,[hl+]
       ld [bc],a
       inc c
       jr nz,copycopy
       ld b,$3f
       db $c3,00 ; jump to ram
      
SECTION "header2",ROM0[$143]
       db $c0
       db 0,0,0,0,0,0,0,0,0,0,0,0


