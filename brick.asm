; Directions (each using a separate bit)
define movingUp      1
define movingRight   2
define movingDown    4
define movingLeft    8

define leftWall     $00
define rightWall    $1F

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
  lda #$10 ;initial X coordinate
  sta playerX
  ;lda #$10; initial Y coordinate
  ;sta playerY
  ;TODO offset X by 0xE0 (last line)
  rts

initBall: 
  ; ball start location = almost the same as player
  ; 04F0 is above the player
  lda #$04
  sta ballH
  lda #$F0
  sta ballL

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
  lda #0
  sta (playerL),y
  ;draw new position
  ldy playerX
  lda #1 
  sta (playerL),y
  ;copy to playerOldX for future erasing
  sty playerOldX
drawPlayerNotNeeded:
  rts

drawBall:
  ldy ballX
  lda #$0A ;different color
  sta (ballL),y
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
  DEC playerX
  rts

moveRight:
  ;check for right wall
  lda playerX
  cmp #rightWall
  beq invalidMove
  INC playerX
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

