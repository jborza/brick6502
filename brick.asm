; Directions (each using a separate bit)
define movingUp      1
define movingRight   2
define movingDown    4
define movingLeft    8
define movingUpLeft  9
define movingUpRight 10
define movingDownLeft 12
define movingDownRight 6

define COLOR_BLACK    $0
define COLOR_WHITE    $1
define COLOR_RED      $2
define COLOR_CYAN     $3
define COLOR_LIGHTRED $A

define leftWall     $E0
define rightWall    $FF

; ASCII values of key controls
define ASCII_w      $77
define ASCII_a      $61
define ASCII_s      $73
define ASCII_d      $64

; System variables
define sysRandom    $fe
define sysLastKey   $ff

define playerL      $00 ; screen location of player, low byte
define playerH      $01 ; screen location of player, high byte

define playerDirection $02
define playerX $03
define playerY $04 ;unused

define playerOldX $05

define ballL $10 ; screen location of the ball
define ballH $11 ; screen location of the ball

define ballX $12
define ballY $13
define ballOldPosL $14
define ballOldPosH $15
define ballDirection $16


jsr init
jsr loop

init:
  jsr initPlayer
  jsr initBall
  rts

initPlayer:
  ; player screen location = 0x0500 (05=H)
  lda #05
  sta playerH
  lda #$F0 ;initial X coordinate
  sta playerX
  ;lda #$10; initial Y coordinate
  ;sta playerY
  ;TODO offset X by 0xE0 (last line)
  rts

initBall: 
  ; ball start location = above, to the right of the player
  lda #$11
  sta ballX
  lda #$1e
  sta ballY
  rts

loop:
  jsr readKeys
  jsr checkCollision
  jsr updatePlayer
  jsr updateDisplay
  jmp loop

; UPDATE subroutines

updateDisplay:
  ;copy player onto the 0x200-0x5FF "screen" 
  ;todo remove previous location of the player
  jsr drawPlayer
  jsr drawBall
  rts

drawPlayer:
  ldy playerOldX
  ;if playerOldX and playerX are the same, skip
  cpy playerX
  beq drawPlayerNotNeeded
  ;draw is needed, erase old position
  lda #COLOR_BLACK
  sta (playerL),y
  ;draw new position
  ldy playerX
  lda #COLOR_WHITE
  sta (playerL),y
  ;copy to playerOldX for future erasing
  sty playerOldX
drawPlayerNotNeeded:
  rts

drawBall:
  jsr ballCoordinatesToScreen  
  ldy #$0
  ;erase old ball position
  lda #COLOR_BLACK
  sta (ballOldPosL),y
  ;draw new position
  lda #COLOR_LIGHTRED ;different color
  sta (ballL),y
  ;copy new position to old position
  lda ballL
  sta ballOldPosL
  lda ballH
  sta ballOldPosH
  rts

ballCoordinatesToScreen:
  ;ball = ballY * 32 + ballX + 0x0200
  lda #0
  sta ballH ; clear ballH as we'll be shifting later
  lda ballY
  sta ballL
  asl ballL ;*2 max 3E
  asl ballL ;*4 max 7C
  asl ballL ;*8 max F8
  asl ballL ;*16, can carry
  rol ballH ;rotate high byte left 
  asl ballL; *32, can carry
  rol ballH ;rotate high byte left
  clc ;clear carry before the addition
  lda ballL ; ballL = ballL + ballX
  adc ballX 
  sta ballL 
  inc ballH ;increment by 2 to offset by 0x200
  inc ballH
  rts

updateBall:
  rts

updatePlayer:
  ldx playerDirection
  cpx #movingLeft
  beq moveLeft
  cpx #movingRight
  beq moveRight
  rts

moveLeft:
  ;when at wall, skip moving
  lda playerX
  cmp #leftWall
  beq invalidMove
  dec playerX
  dec ballX
  rts

moveRight:
  ;check for right wall
  lda playerX
  cmp #rightWall
  beq invalidMove
  inc playerX
  inc ballX
  rts

invalidMove:
  rts

checkCollision:
  ;collision with left and right walls done in controls
  rts

; INPUT subroutines

readKeys:
  lda sysLastKey
  ;clear key
  ldx #0
  stx sysLastKey
  ;compare pressed key to controls
  cmp #ASCII_a
  beq leftPressed
  cmp #ASCII_d
  beq rightPressed
  ;nothing pressed here
  jmp nothingPressed

leftPressed:
  lda #movingLeft
  sta playerDirection
  rts

rightPressed:
  lda #movingRight
  sta playerDirection
  rts

nothingPressed:
  lda #$0
  sta playerDirection
  rts

