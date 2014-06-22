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
                    LDA #BLUE
                    STA COLUP0          ; Player 0 color
                    LDA #RED
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
                    ;LDA #(VERT_BLANK*SCANLINE_TIME)/53 ; PAL 53, NTSC 43
                    LDA #(VERT_BLANK*SCANLINE_TIME)/64 ; PAL 53, NTSC 43
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
                    STA P0VPos
                    ;CMP #0
                    ;BNE .loop
.loop               LDA INTIM
                    BNE .loop
                    RTS

; Draw Screen
DrawScreen:         SUBROUTINE
                    LDA #WHITE
                    STA COLUPF          ; Playfield foreground color
                    LDA #GREEN
                    STA COLUBK          ; Playfield Backfround color
                    STA WSYNC
                    STA VBLANK          ; End the VBLANK period with a zero
; >>>>>>>>>>>>>>>>>>>>>>>>>>>> Kernel starts here <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Kernel ends here <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    RTS

; Over Scan
OverScan:           SUBROUTINE
                    LDA #2            ; VBlank On Value
                    STA VBLANK        ; Activate vertical blank
                    LDA #(OVERSCAN*SCANLINE_TIME)/64 ;2
                    STA TIM64T        ; Start timer
; >>>>>>>>>>>>>>>>>>>>>>>>>> Extra code starts here <<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    LDA #0
                    STA GRP0          ; Clear Player 0
                    STA COLUPF        ; Clear PF foreground
                    STA COLUBK        ; Clear PF background
; >>>>>>>>>>>>>>>>>>>>>>>>>> Extra ends starts here <<<<<<<<<<<<<<<<<<<<<<<<<<<<
OverScanLoop:       LDA INTIM         ; Get current machine cycle
                    BNE OverScanLoop  ; Loop until A is zero
                    RTS

; Subroutines

; HPosition - Horizontal Position Object
; Input: 
;  A = Object's Horizontal Position
;  X = Object (0 = Player0; 1 = Player1; 2 = Missile0; 3 = Missile1; 4 = Ball)
; WTF?
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

; Interrupts - Not used by the 2600 but exists on a 7800
           ORG ROMStart + ROMSize - 3*2
             .word   ROMStart ; NMI
             .word   ROMStart ; RESET
             .word   ROMStart ; IRQ
           END
