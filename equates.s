;
; equate file for interfacing to toolkit/graphics
;
ToolMLI equ $4000
GrafMLI equ $4000
;
; constants
;
SrcCopy equ 0
SrcOr equ 1
SrcXor equ 2
SrcBic equ 3
SrcNotCopy equ 4
SrcNotOr equ 5
SrcNotXor equ 6
SrcNotBic equ 7
;
; grafport structure
;
viewloc equ 0
portbits equ viewloc+4
portwidth equ portbits+2                        ; 1 byte for width, the other is reserved.
portrect equ portwidth+2
penpat equ portrect+8
penloc equ penpat+10
pensize equ penloc+4
penmode equ pensize+2
txback equ penmode+1
txfont equ txback+1
;
portlength equ txfont+2
;
;
; command numbers
;
InitGraf equ 1
SetSwitches equ InitGraf+1
;
InitPort equ SetSwitches+1
SetPort equ InitPort+1
GetPort equ SetPort+1
SetPortBits equ GetPort+1
SetPenMode equ SetPortBits+1
SetPattern equ SetPenMode+1
SetColorFlags equ SetPattern+1
SetPenSize equ SetColorFlags+1
SetFont equ SetPenSize+1
SetTextBG equ SetFont+1
;
Move equ SetTextBG+1
MoveTo equ Move+1
Line equ MoveTo+1
LineTo equ Line+1
PaintRect equ LineTo+1
FrameRect equ PaintRect+1
InRect equ FrameRect+1
PaintBits equ InRect+1
PaintPoly equ PaintBits+1
FramePoly equ PaintPoly+1
InPoly equ FramePoly+1
;
TextWidth equ InPoly+1
DrawText equ TextWidth+1
;
SetZP1 equ DrawText+1
SetZP2 equ SetZP1+1
GetVersion equ SetZP2+1

; DATA STRUCTURES
;
; The following data structures are defined as types (Pascal format):
    ; byte = 0..255;

    ; bits = packed array (0..7) of boolean;

    ; pmode = (penCopy, penOr, penXor, penBic, notpenCopy, notpenOr, notpenXor, notpenBic);

    ; point = record
        ; x: integer;
        ; y: integer;
    ; end;

    ; rect = record
        ; case integer of
        ; 0: (left: integer; top: integer; right: integer; bottom: integer);
        ; 1: (topleft: point; botright: point);

    ; maplnfo = packed record
        ; viewloc: point;
        ; mspbits: pointer;
        ; mspwidth: byte;
        ; reserved: byte;
        ; maprect: rect;
    ; end;

    ; pattern = packed array [1..9] of byte;                ; 1..8 ???

    ; maskinfo = packed record
        ; ANDmask: byte;
        ; ORmask: byte;
    ; end;

    ; GrafPort = packed record
        ; portmap: maplnfo;
        ; penpattern: pattern;
        ; colormasks: maskinfo;
        ; penloc: point;
        ; penwidth: byte;
        ; penheight: byte;
        ; penmode: pmode;
        ; reserved: 0..31;
        ; textback: byte;
        ; textfont: integer;
    ; end;
