; '2600 for Newbies
; Session 13 - Playfield
                processor 6502
                include "vcs.h"
                include "macro.h"

;------------------------------------------------------------------------------
PATTERN         = $80                  ; storage location (1st byte in RAM)
TIMETOCHANGE    = 20                   ; speed of "animation" - change as desired

;HOR_RES        = 160                 ; Horizontal Resolution
BLOCK_HEIGHT    = 18
BLOCK_GFX       = %11111111
;------------------------------------------------------------------------------

                SEG
                ORG $F000

; block position
P0VPos          ds      1

Reset:
   ; Clear RAM and all TIA registers
                ldx #0
                lda #0

Clear:          sta 0,x
                inx
                bne Clear

       ;------------------------------------------------
       ; Once-only initialization...
                lda #0
                sta PATTERN            ; The binary PF 'pattern'

                lda #$45
                sta COLUPF             ; set the playfield color

                ldy #0                 ; "speed" counter
       ;------------------------------------------------

                JSR Init
MainLoop:
                JSR StartOfFrame
                JSR VerticalBlank
                JSR Picture
                ;JSR ShowBlock
                JSR Overscan
                JMP MainLoop

Init:           SUBROUTINE
                    ; Init objects colors
                    LDA #$A0
                    STA COLUP0          ; Player 0 color
                    ;LDA #RED
                    ; Init objects vertical position
                    LDA #(192/2)
                    STA P0VPos          ; Player 0 vertical position
                    ; Init objects horizontal position
                    STA HMCLR
                    LDX #0              ; Player 0
                    LDA #160/2-8    ; TODO calculate horizontal center
                    JSR Position
                    STA WSYNC
                    STA HMOVE
                RTS

Position:       SUBROUTINE
                    SEC
                    STA     WSYNC
.divideby15         SBC     #15
                    BCS     .divideby15
                    EOR     #7
                    ASL
                    ASL
                    ASL
                    ASL
                    STA.WX  HMP0,x
                    STA     RESP0,x
                RTS

StartOfFrame:
                SUBROUTINE
   ; Start of new frame
   ; Start of vertical blank processing

                    lda #0
                    sta VBLANK

                    lda #2
                    sta VSYNC

                    sta WSYNC
                    sta WSYNC
                    sta WSYNC               ; 3 scanlines of VSYNC signal

                    lda #0
                    sta VSYNC
           ;------------------------------------------------
           ; 37 scanlines of vertical blank...
                    ldx #0
                RTS
VerticalBlank:
                SUBROUTINE
                    sta WSYNC
                    inx

                    cpx #37
                    bne VerticalBlank
           ;------------------------------------------------
           ; Handle a change in the pattern once every 20 frames
           ; and write the pattern to the PF1 register
                    iny                    ; increment speed count by one
                    cpy #TIMETOCHANGE      ; has it reached our "change point"?

                    bne .notyet             ; no, so branch past
                    ldy #0                 ; reset speed count
                    inc PATTERN            ; switch to next pattern

.notyet
                    lda PATTERN            ; use our saved pattern
                    sta PF1                ; as the playfield shape

           ;------------------------------------------------
           ; Do 192 scanlines of color-changing (our picture)
                    ldx #0                 ; this counts our scanline number
                RTS
Picture:
                SUBROUTINE
                    stx COLUBK             ; change background color (rainbow effect)
                    sta WSYNC              ; wait till end of scanline

                    inx

                    cpx #192
                    bne Picture
           ;------------------------------------------------

                    lda #%01000010
                    sta VBLANK          ; end of screen - enter blanking

       ; 30 scanlines of overscan...

                    ldx #0
                RTS

ShowBlock:
                SUBROUTINE
.screenloop         STA WSYNC
                    ; Player 0 vertical position
                    LDX #BLOCK_GFX
                    TYA
                    SEC
                    SBC P0VPos
                    CMP #BLOCK_HEIGHT
                    BCC .showBlock
                    LDX #0
.showBlock          STX GRP0
                    LDX #BLOCK_GFX
                    TYA
                    SEC
                    DEY
                    BNE .screenloop
                RTS

Overscan:       SUBROUTINE
                    sta WSYNC
                    inx

                    cpx #30

                    bne Overscan

                    jmp StartOfFrame
                RTS

;------------------------------------------------------------------------------

            ORG $FFFA

InterruptVectors
            .word Reset          ; NMI
            .word Reset          ; RESET
            .word Reset          ; IRQ
      END
