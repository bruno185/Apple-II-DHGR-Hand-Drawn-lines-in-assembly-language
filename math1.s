* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Functions :
* - SetDeltaXY :
* Set deltaX, daltaY : point2.x - point1.x, point2.y - point1.y,
* signX, signY  = 0 if deltaX/daltaY positve ; = 1 if deltaX/daltaY negative
* deltaXabs, deltaYabs : absolute value of deltaX and daltaY 
* deltaMax = Max(deltaXabs, deltaYabs)
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*

SetDeltaXY

* 
* set deltaX
                lda Point2                      ; deltaX = point2.x - point1.x 
                sec 
                sbc Point1
                sta deltaX
                lda Point2+1                    
                sbc Point1+1                    ; high byte of Point2.x - Point1.x in A
                sta deltaX+1
                ;printm deltaX                   ; debug
* set signX 
                lda #0
                sta signX
                lda deltaX+1
                and #$80
                beq :1
                inc signX
:1
* set deltaY
                lda Point2+2                    ; point2.y - point1.y = deltaY
                sec 
                sbc Point1+2
                sta deltaY
                lda Point2+3
                sbc Point1+3                    ; high byte of Point2.x - Point1.x in Y
                sta deltaY+1
                ;printm deltaY                   ; debug
* set signY
                lda #0
                sta signY
                lda deltaY+1
                and #$80
                beq :2
                inc signY
:2              
                ;printm signX                    ; debug (print signX and signY)

* set |deltaX| in deltaXabs var
                lda deltaX                      ; init deltaXabs 
                sta deltaXabs
                lda deltaX+1
                sta deltaXabs+1

                and #$80                        ; deltaX positive ?
                beq dxpos                       ; yes : jump over
                ; two's complement 
                lda deltaX                      ; no : get |deltaX|
                eor #$FF
                sta deltaXabs
                lda deltaX+1
                eor #$FF
                sta deltaXabs+1
                lda deltaXabs
                clc
                adc #1
                sta deltaXabs
                lda deltaXabs+1
                adc #0
                sta deltaXabs+1          
dxpos
                cr
                ;printm deltaXabs                 ; debug 
                
* set |deltaX| in deltaYabs var
                lda deltaY                      ; init deltaYabs 
                sta deltaYabs
                lda deltaY+1
                sta deltaYabs+1

                and #$80                        ; deltaY positive ?
                beq dypos                       ; yes : jump over
                ; two's complement 
                lda deltaY                      ; no : get |deltaY|
                eor #$FF
                sta deltaYabs
                lda deltaY+1
                eor #$FF
                sta deltaYabs+1
                lda deltaYabs
                clc
                adc #1
                sta deltaYabs
                lda deltaYabs+1
                adc #0
                sta deltaYabs+1
dypos
                ;printm deltaYabs                 ; debug 

* Set max(daltaXabs,deltaYabs)

                DoCompare16 deltaXabs;deltaYabs;cmp16
                beq isegal
                bcs isbigger

issmaller       
                ;jsr print                       ; debug
                ;dfb :1-*-1
                ;asc "SMALLER"
:1              lda deltaYabs
                sta deltaMax
                lda deltaYabs+1
                sta deltaMax+1

                lda #1                          ; flag to indicate line is rather vertical
                sta VertFlag

                jmp prnMax

isegal       
                ;jsr print                       ; debug
                ;dfb :2-*-1
                ;asc "EGAL"
:2              lda deltaYabs                   ; or deltaXabs (=)
                sta deltaMax
                lda deltaYabs+1
                sta deltaMax+1

                lda #1                          ; flag to indicate line is rather vertical 
                sta VertFlag                    ; although deltaX=deltaY, but Apple II pixels are "vertical"

                jmp prnMax

isbigger      
                ;jsr print                       ; debug 
                ;dfb :3-*-1
                ;asc "BIGGER"
:3              lda deltaXabs
                sta deltaMax
                lda deltaXabs+1
                sta deltaMax+1

                lda #0                          ; flag to indicate line is not vertical (rather horizontal)
                sta VertFlag

prnMax 
                cr
                ;printm deltaMax                 ; debug
                rts


             
