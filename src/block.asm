; BLOCK TESTE
    PROCESSOR 6502

; Includes
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "const.h"

; Constants
ROMStart    = $F000
ROMSize     = $0800

HOR_RES        = 160                 ; Horizontal Resolution
PLAYER_HEIGHT  = 18
PLAYER_GFX     = %11111111           ; Players grafix

; Zeropage variables declaration
                SEG.U   Variables
                ORG     $80
P0VPos          ds      1            ; Player 0 vertical position
score           .byte

; Start of code
                    SEG     Code
                    ORG     ROMStart

ROMStart:
  CLEAN_START                         ; Init mem, TIA, RIOT and set stack

; Game Init
                    JSR GameInit      ; Initialize the game

; Main Loop
MainLoop:
                    JSR VerticalBlank ;Execute the vertical blank
                    JSR CheckSwitches ;Check console switches during Vblank
                    JSR GameCalc      ;Do calculations during Vblank
                    JSR DrawScreen    ;Draw the screen
                    JSR OverScan      ;Do more calculations during overscan
                    JMP MainLoop      ;Continue forever

; Game Initialization
GameInit:           SUBROUTINE
                    ; Init objects colors
                    LDA #BROWN
                    STA COLUP0          ; Player 0 color
                    ; Init objects vertical position
                    LDA #(SCREEN_LINES/2)
                    STA P0VPos          ; Player 0 vertical position
                    ; Init objects horizontal position
                    STA HMCLR
                    LDX #0              ; Player 0
                    LDA #HOR_RES/2-8    ; TODO calculate horizontal center
                    JSR HPosition
                    STA WSYNC
                    STA HMOVE
                    RTS

; Vertical Blank - Do Vertical Sync
VerticalBlank:      SUBROUTINE
                    LDA #2
                    STA WSYNC         ; Finish current line
                    STA VSYNC         ; Begin vertical sync
                    STA WSYNC         ; First line of VSYNC
                    STA WSYNC         ; Second line of VSYNC
                    LDA #(VERT_BLANK*SCANLINE_TIME)/53
                    STA TIM64T        ;  Start timer
                    LDA #0            ;
                    STA CXCLR         ; Clear colision register
                    STA WSYNC         ; Third line of VSYNC
                    STA VSYNC         ;
                    RTS

; Check Console Switches
CheckSwitches:      SUBROUTINE
                    LDA P0UP
                    BIT SWCHA
                    BNE .exit
                    LDA P0VPos
                    CMP #SCREEN_LINES-PLAYER_HEIGHT
                    BCS .exit
                    LDA #6
                    ADC P0VPos
                    STA P0VPos          ;
.exit               RTS

; Game Calculations
GameCalc:           SUBROUTINE
                    CLC
                    LDA P0VPos
                    ADC #-2
                    CMP #2
                    BCC .gameOver
                    STA P0VPos
.loop               LDA INTIM
                    BNE .loop
.gameOver           ; TODO GAME OVER
                    RTS

DrawScreen:         SUBROUTINE
                    LDA #BLACK
                    STA COLUPF          ; Playfield foreground color
                    LDA #DARK_PURPLE
                    STA COLUBK          ; Playfield Backfround color
                    STA WSYNC
                    STA VBLANK          ; End the VBLANK period with a zero

                    LDY #SCREEN_LINES
.screenloop         STA WSYNC
                    ; Player 0 vertical position
                    LDX #PLAYER_GFX
                    TYA
                    SEC
                    SBC P0VPos
                    CMP #PLAYER_HEIGHT
                    BCC .showBlock
                    LDX #0
.showBlock          STX GRP0
                    LDX #PLAYER_GFX
                    TYA
                    SEC
                    DEY
                    BNE .screenloop

                    RTS

; Over Scan
OverScan:           SUBROUTINE
                    LDA #2            ; VBlank On Value
                    STA VBLANK        ; Activate vertical blank
                    LDA #(OVERSCAN*SCANLINE_TIME)/53 ;2
                    STA TIM64T        ; Start timer

                    LDA #0
                    STA GRP0          ; Clear Player 0
                    STA COLUPF        ; Clear PF foreground
                    STA COLUBK        ; Clear PF background

OverScanLoop:       LDA INTIM         ; Get current machine cycle
                    BNE OverScanLoop  ; Loop until A is zero
                    RTS

HPosition:          SUBROUTINE
                    SEC
                    STA     WSYNC
.divideby15         SBC     #15
                    BCS     .divideby15
                    EOR     #7
                    ASL
                    ASL
                    ASL
                    ASL
                    STA.WX  HMP0,x     ; Horizontal Move object
                    STA     RESP0,x    ; Reset object's horizontal position
                    RTS

; damn digits
                    ORG     $f600

Digits:
                    .byte   <Zero,  <One,   <Two,   <Three, <Four
                    .byte   <Five,  <Six,   <Seven, <Eight, <Nine

One:
                    .byte   %11111111
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11111101
Seven:
                    .byte   %11111111
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11111101
Four:
                    .byte   %11111111
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11111101
Zero:
                    .byte   %11000011
                    .byte   %10111101
                    .byte   %10111101
                    .byte   %10111101
                    .byte   %11111111
                    .byte   %10111101
                    .byte   %10111101
                    .byte   %10111101
Three:
                    .byte   %11000011
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11111101
Nine:
                    .byte   %11000011
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11111101
Eight:
                    .byte   %11000011
                    .byte   %10111101
                    .byte   %10111101
                    .byte   %10111101
Six:
                    .byte   %11000011
                    .byte   %10111101
                    .byte   %10111101
                    .byte   %10111101
Two:
                    .byte   %11000011
                    .byte   %10111111
                    .byte   %10111111
                    .byte   %10111111
Five:
                    .byte   %11000011
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11111101
                    .byte   %11000011
                    .byte   %10111111
                    .byte   %10111111
                    .byte   %10111111
                    .byte   %11000011

; Interrupts - Not used by the 2600 but exists on a 7800
           ORG ROMStart + ROMSize - 3*2
             .word   ROMStart ; NMI
             .word   ROMStart ; RESET
             .word   ROMStart ; IRQ
           END
