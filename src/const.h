;*******************************************************************************
;  Constant Declarations
;*******************************************************************************
; Joystick Constants for Player 0
P0UP       = %00010000
P0DOWN     = %00100000
P0LEFT     = %01000000
P0RIGHT    = %10000000
; Joystick Constants for Player 1
P1UP       = %00000001
P1DOWN     = %00000010
P1LEFT     = %00000100
P1RIGHT    = %00001000
; Console switches
SELECT     = %00000010
RESET      = %00000001

; TV Color Encoding (Vertical Sync/Vertical Blank/Screen Lines/Overscan)
;
; PAL  (3/45/228/36)
; NTSC (3/37/192/30)

TV_ENCODING     = 1
SCANLINE_TIME   = 76
WHITE           = $0E
; IF TV_ENCODING == 1 THEN PAL, ELSE NTSC
 IF TV_ENCODING == 1
 ECHO "PAL Encoding"
; TIA PAL Colors
BLACK           = $10
AMBAR           = $20
LIGHT_GREEN     = $30
BROWN           = $40
GREEN           = $50
RED             = $60
CYAN            = $70
LIGHT_PURPLE    = $80
LIGHT_BLUE      = $90
PURPLE          = $A0
BLUE            = $B0
DARK_PURPLE     = $C0
DARK_BLUE       = $D0
; NTSC Screen constants
VERT_BLANK      = 45
SCREEN_LINES    = 228
OVERSCAN        = 36
 ELSE
 ECHO "NTSC Encoding"
; TIA NTSC Colors 
BLACK           = $00
YELLOW          = $10
AMBAR           = $20
ORANGE          = $30
RED             = $40
VIOLET          = $50
PURPLE          = $60
LIGHT_BLUE      = $70
BLUE            = $80
DARK_BLUE       = $90
CYAN            = $A0
LIGHT_GREEN     = $B0
GREEN           = $C0
DARK_GREEN      = $D0
LIGHT_BROWN     = $E0
BROWN           = $F0
; NTSC Screen constants
VERT_BLANK      = 36
SCREEN_LINES    = 192
OVERSCAN        = 30
 ENDIF
