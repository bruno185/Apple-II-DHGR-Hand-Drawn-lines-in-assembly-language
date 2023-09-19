* * * * * * * * * * * * * * * * * * * * * * * *
*  "Hand drawn lines" with Graphics Primitives *           
* * * * * * * * * * * * * * * * * * * * * * * *
*
*
                put macros
GP_call     MAC                                         ; call to graphic primitives (macro)
                jsr GrafMLI                             ; graphic primitives only entry point
                dfb ]1                                  ; command ID (1 byte)
                da  ]2                                  ; address of parameter(s) (2 bytes), 0 if no paramter
                EOM

                org $800
                put equates                             ; Graphics Primitives equates
                put equ                                 ; general Apple II equates

MyBuffer        equ $8000                               ; starting address of storage for MyPort grafport
TestFont        equ $800                                ; loading address of "TEST.FONT" file
KeyBoard        equ $C000                               ; ascii code of last key pressed (+ 128 if strobe not cleared) 
Strobe          equ $C010                               ; Keyboard Strobe
ptr             equ $06
ptr2            equ $08

                jsr home                        ; clear screen

debut    
                jsr WaitForKeyPress
                jsr AdjutVars
                jsr Graf

                jsr initrandom

                lda #<linedata                  ; init ptr2 to beginning of lines data
                sta ptr2
                lda #>linedata
                sta ptr2+1 

bigloop
                ldy #0
                ldx #0

copy8
                lda (ptr2),y                    ; copy 2 points to Point 1 ad Point2 vars
                sta Point1,x 
                iny
                inx 
                cpx #8
                bne copy8 

                jsr SetDeltaXY                  ; calcutate deltas
                

                DoCompare16 deltaMax;seglength;cmp16
                beq DoshortLine
                bcc DoshortLine
                                 
                lda #0                          ; here if deltaMax > seglength           
                sta shortLineflag
                jmp longline

DoshortLine     lda #1                          ; here if line is too short for variations
                sta shortLineflag
                jmp dg 

longline
                jsr SetNpPt                     ; determine number of points to be displaced
                jsr SetInc                      ; set increment in X and Y direction between points to dispalce
                jsr PopTab                      ; fill a table of points

dg              jsr DoLine                      ; draw a line (split in segments and draw each segment)


                lda ptr2                        ; set ptr2 point2 to next couple of points
                clc
                adc #8
                sta ptr2
                lda #0
                adc ptr2+1
                sta ptr2+1

                ldy #0                          ; test end of data ($FF $FF marker)
                lda (ptr2),y 
                cmp #$FF
                bne bigloop
                iny 
                lda (ptr2),y
                cmp #$FF
                bne bigloop                     ; loop if end not reached

                jmp debut
                rts

* * * * * * * * * * * * GRAF * * * * * * * * * * * *
DoLine          
                lda shortLineflag            
                beq dolong                      ; if shortLineflag = 0 : process long line 
                                                ; (longer than seglength)
                GP_call MoveTo;Point1           ; else draw a straight line
                GP_call LineTo;Point2           ; from Point1 to Point2 
                rts
dolong       
                jsr mvpt01

doline2         lda savnbpt
                sta segcount

                GP_call MoveTo;theopt

domove          
                GP_call LineTo;theopt

                lda domove+4                            ; modify code above
                clc
                adc #4
                sta domove+4
                lda domove+5
                adc #0
                sta domove+5

                dec segcount                            ; update counter
                lda segcount
                bne domove                              ; if not 0 then loop

                lda #<theopt                            ; reset modified code
                sta domove+4
                lda #>theopt
                sta domove+5 

outdraw         rts
************ loop back here

dowait          jsr WaitForKeyPress
                cmp #$1B                                ; test escape key
                bne noquit
                jmp Quitprog
noquit
                clc
                jsr ClearIt                             ; clear DHGR screen
                GP_call SetPattern;White                ; reset pen to white
                lda #<theopt                            ; reset modified code
                sta domove+4
                lda #>theopt
                sta domove+5 

                jmp DoLine                              ; loop
                rts
segcount        ds 1


* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* move points randomly 
mvpt01          lda savnbpt
                sta nbpt

                lda #<theopt                    ; set ptr to fisrt point
                sta ptr 
                lda #>theopt
                sta ptr+1 

mvpt            jsr random                      ; init x deviation amount
                lda R1
                ;and #3                          ; ? to reduce number of calls to random function
                cmp maxvar
                bcs mvpt                        ; loop if > #maxvar 
                sta xmov                        ; set x displacement

                lda #0                          ; init neg. flag to 0
                sta xneg
                lda R2 
                asl                             ; get random # in carry
                bcc initymov                    ; if carry = 0 : no action                   
                lda #1                          ; else set neg. flag to 1
                sta xneg

initymov
                jsr random
                lda R3                          ; init y deviation amount
                and #3                          ; ? to reduce number of calls to random function
                ldx VertFlag                    ; test verticality of the line
                beq vertoff                     ; 
                cmp maxvar                     ; vertical : normal variation 
                bcs initymov
                bcs verton                      ; always branch

vertoff         
                pha 
                lda maxvar
                sta tempo
                dec tempo
                pla
                cmp tempo                   ; horizontal : reduce vertical variation
                bcs initymov                    ; to take account of pixels size
verton          sta ymov

                lda #0                          ; init neg. flag to 0
                sta yneg

                lda R4 
                asl                             ; get random # in carry 
                bcc :22                         ; if carry = 0 : no action 
                lda #1 
                sta yneg    

:22                                             ; set x variation (positive)
                ldy #0
                lda xneg
                bne donegx
                lda (ptr),y 
                clc
                adc xmov
                sta (ptr),y 
                iny
                lda (ptr),y 
                adc #0
                sta (ptr),y 
                jmp :33
                
donegx          ldy #0                          ; set x variation (negative)
                lda (ptr),y 
                sec
                sbc xmov
                sta (ptr),y 
                iny
                lda (ptr),y 
                sbc #0
                sta (ptr),y 

:33
                ldy #2                          ; set y variation (positive)
                lda yneg
                bne donegy
                lda (ptr),y 
                clc
                adc ymov
                sta (ptr),y 
                iny
                lda (ptr),y 
                adc #0
                sta (ptr),y 
                jmp :44
                
donegy          ldy #2
                lda (ptr),y 
                sec
                sbc ymov
                sta (ptr),y 
                iny
                lda (ptr),y 
                sbc #0
                sta (ptr),y 

:44
                lda ptr 
                clc
                adc #4
                sta ptr
                lda ptr+1
                adc #0
                sta ptr+1               
                dec nbpt
                beq :1 
                jmp mvpt
:1              rts

Quitprog
                ;jsr rstZP
                jsr $fb39                       ; SETTXT
                lda #3
                jsr $FE95                       ; OUTPRT
                * https://retrocomputing.stackexchange.com/questions/19681/apple-ii-toggles-between-40-and-80-columns-in-assembly-language-apple-iic
                lda #21                        ; to turn off 80 col. firmware
                ;lda #17                       ; to swith to 40 col.
                ;lda #18                       ; to swith to 80 col.
                jsr cout                       ; to turn off 80 col.firmware
                ;lda #0                          ; for next call. See https://6502disassembly.com/a2-rom/Applesoft.html
                ;jsr $d649                       ; "NEW" Applesoft command (otherwise LIST command will crash)
                
                rts

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
PopTab          ; populate table of points
                movInt Point1;curptX+2                  ; init curptX, integer part   
                movInt Point1+2;curptY+2                ; init curptY, integer part  

                movInt Point1;theopt                    ; init 1st element of table (X coordinate)
                movInt Point1+2;theopt+2                ; init 1st element of table (X coordinate) 

                lda #<theopt                            ; int ptr to point to theopt+4
                clc
                adc #4
                sta ptr
                lda #>theopt
                adc #0
                sta ptr+1

loopPokeTab
                lda signX
                bne dosubx
                addInt32 curptX;XincDec                 ; add X increment to curptX (integer and decimal parts)
                jmp ynow
dosubx          subInt32 curptX;XincDec

ynow
                lda signY
                bne dosuby
                addInt32 curptY;YincDec                 ; add Y increment to curptY (integer and decimal parts) 
                jmp oknow
dosuby
                subInt32 curptY;YincDec
oknow
                ldy #0                                  ; copy integer part of curptX to table
                lda curptX+2
                sta (ptr),y 
                iny
                lda curptX+3
                sta (ptr),y 

                lda ptr                                 ; inc ptr 
                clc
                adc #2
                sta ptr
                lda ptr+1
                adc #0
                sta ptr+1

                ldy #0                                  ; copy integer part of curptY to table
                lda curptY+2
                sta (ptr),y 
                iny
                lda curptY+3
                sta (ptr),y 

                lda ptr                                 ; inc ptr 
                clc
                adc #2
                sta ptr
                lda ptr+1
                adc #0
                sta ptr+1

                dec nbpt
                beq endpoptable
                jmp loopPokeTab 
endpoptable
                rts

*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
* On keypressed, modify vars
*
maxvardef       equ 3
seglengthdef    equ 8
pensizeXdef     equ 2
pensizeYdef     equ 1

seglengthmax    equ 100
seglengthmin    equ 3
maxvarmax       equ 50
maxvarmin       equ 3

pensizeXmax     equ 12
pensizeXmin     equ 1
pensizeYmax     equ 12
pensizeYmin     equ 1

AdjutVars
                cmp #'O'                        ; O : reset original values
                bne notO
                lda #maxvardef
                sta maxvar
                lda #seglengthdef
                sta seglength
                lda #pensizeXdef
                sta pensize2
                lda #pensizeYdef
                sta pensize2+1  
                rts         

notO            cmp #'X'                        ; X : pensize.x bigger
                bne notX
                lda pensize2
                cmp #pensizeXmax
                bcs psxmax
                inc pensize2
psxmax          rts

notX            cmp #'W'                        ; W : pensize.x smaller
                bne notW
                lda pensize2
                cmp #pensizeXmin
                beq psxmin
                dec pensize2
psxmin          rts

notW            cmp #'Y'                        ; Y : pensize.y bigger
                bne notY
                lda pensize2+1
                cmp #pensizeYmax
                bcs psymax
                inc pensize2+1
psymax          rts

notY            cmp #'U'                        ; U : pensize.y smaller
                bne notU
                lda pensize2+1
                cmp #pensizeYmin
                beq psymin
                dec pensize2+1
psymin          rts

notU            cmp #'S'                        ; S : segments smaller
                bne notS
                lda seglength
                cmp #seglengthmax
                bcs notL
                inc seglength
                rts

notS            cmp #'D'                        ; D : segments longer                        
                bne notD
                lda seglength
                cmp #seglengthmin 
                bcc notL
                dec seglength

notD            cmp #'M'                        ; M : bigger variations
                bne notM
                lda maxvar
                cmp #maxvarmax
                bcs notL
                inc maxvar
                rts
                
notM            cmp #'L'                        ; L : smaller variations
                bne notL
                lda maxvar
                cmp #maxvarmin
                bcc notL
                dec maxvar
notL            rts
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
ClearIt         ; fill port with black
                bcs :1
                GP_call SetPenMode;ModeCopy             ; pen + destination = pen

                GP_call SetPattern;Black                ; black (0,0,...)
                GP_call SetPenMode;ModeCopy 
                GP_call PaintRect;WowRect               ; paint very large rectangle in black
                rts

:1              GP_call SetPattern;White
                GP_call SetPenMode;ModeCopy 
                GP_call PaintRect;WowRect               ; paint very large rectangle in black
                ;GP_call SetPattern;White                ; restore pattern to white (1,1,...)
                rts
WowRect         dw 0,0,10000,10000                      ; very large rectangle
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
Graf 
                GP_call InitGraf;0
                GP_call InitPort;ScreenPort             ; Set up ScreenPort for drawing onto screen
                GP_call SetPort;ScreenPort              ;  set grafport to screen
                clc                                     ; flag : carry on : paint white else paint black
                jsr ClearIt
                GP_call SetPattern;White
                GP_call SetPenSize;pensize2             ; large width, to "make" square pixels
                rts 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* Quit proc.
ProDOSquit
                ;GP_call SetSwitches;Switch
                jsr $BF00 ; ProDOS Quit
                dfb $65
                dw QuitParams
                rts     
;Switch          dfb 8

* 
* * * * * * * * * * * * UTILITIES * * * * * * * * * * * *
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* Random number generator
*     
R1       hex 00
R2       hex 00
R3       hex 00
R4       hex 00
*
random  ror R4          ; Bit 25 to carry
        lda R3          ; Shift left 8 bits
        sta R4
        lda R2
        sta R3
        lda R1
        sta R2
        lda R4          ; Get original bits 17-24
        ror             ; Now bits 18-25 in ACC
        rol R1          ; R1 holds bits 1-7
        eor R1          ; Seven bits at once
        ror R4          ; Shift right by one bit
        ror R3
        ror R2
        ror
        sta R1
        rts
*
* Routine to seed the random number generator with a
* reasonable initial value:
*
initrandom 
        ; lda $4E      ; Seed the random number generator
        lda rseed
        sta R1          ; based on delay between keypresses
        sta R3
        ; lda $4F
        lda rseed+1
        sta R2
        sta R4
        rts
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* print a string from stack
*
print
stack           equ $100        
                ; init 
                tsx
                stx savstack                    ; save stack regiter                  
                inx 
                lda stack,x 
                sta ptr
                lda stack+1,x 
                sta ptr+1

                ; get data and process
                ldy #$01
                lda (ptr),y                     ; get length of data
                sta savlength                   ; save it
                tax                             ; init counter (x)
:1              iny                             ; next char
                lda (ptr),y                     ; load char
                jsr cout                        ; print char
                dex                             ; dec counter
                bne :1

                ; restore and return
                ldx savstack                    ; restore stack register value
                inx
                lda stack,x 
                sec                             ; to take account of length byte !! (dfb :1-*-1)
                adc savlength
                sta stack,x 
                inx 
                lda stack,x 
                adc #0
                sta stack,x
                rts
savlength       ds 1
savstack        ds 1

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
WaitForKeyPress                                         ; wait a key from user
                jsr Bell                                ; play a sound

Wait            
                inc rseed 
                bne :1
                inc rseed+1
:1
                bit Strobe                              ; test keybord input
                bpl Wait                                ; loop while no key pressed
                lda KeyBoard                            ; get key value
                rts
rseed           dw 46990
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* Librairies
                put math1                       ; calculting for this program
                put math2                       ; division using fixed point functions
                put fpdlib                      ; my fixed point library
                put data

*
* * * * * * * * * * * * DATA * * * * * * * * * * * *
deltaX          ds 2
deltaY          ds 2
deltaXabs       ds 2
deltaYabs       ds 2
deltaMax        ds 2
curptX          ds 4
curptY          ds 4

signX           ds 1
signY           ds 1

XincDec         ds 2                            ; decimal part of Xinc
Xinc            ds 2
YincDec         ds 2                            ; decimal part of Xinc
Yinc            ds 2

theopt          ds 511
theoptend       ds 1
theoptsav       ds 511
theoptsavend    ds 1

nbpt            ds 2
savnbpt         ds 2

shortLineflag   ds 1
VertFlag        ds 1

*****
Point1          dw 25,10                        ; upper left corner
Point2          dw 501,190                      ; bottom right corner
*****
pnt1            dw 1,1
pnt2          dw 1,191


fsignX          ds 1
fsignY          ds 1

vert_line       dw 10,-10
xmov            ds 1
ymov            ds 1
xneg            ds 1
yneg            ds 1
maxvar          dfb 4                           ; Attention !! if changed, "and #3" instructions should also be modified
seglength       dw 4

dataptr         ds 2

QuitParams      dfb 4                           ; parameters for ProDOS quit mli call
                dw 0,0,0,0  

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* Graphics Primtives vars.
*
ScreenPort      ds portlength                           ; space for ScreenPort (= standard grafport = screen grafport)

Black           dfb 0,0,0,0,0,0,0,0,0                   ; black pattern
White           ds 8,$FF                                ; white pattern
                dfb 0

ModeNotOr       dfb 5
ModeCopy        dfb 0   

DoNotSave       dfb 0
SaveZP          dfb $80

pensize1        dfb 1,1                         ; standard pensize
pensize2        dfb 2,1                         ; enlarge your pen

