
bckupZP
                ldx #0
:1              lda $0,x 
                sta ZP,x 
                inx 
                bne :1
                rts
rstZP
                ldx #0
:11             lda ZP,x 
                sta $0,x 
                inx 
                bne :11
                rts
