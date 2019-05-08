; Directions (each using a separate bit)
define movingUp      1
define movingRight   2
define movingDown    4
define movingLeft    8

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
  jsr ballCoordinatesToScreen
  ; todo erase old ball position
  ldy #$0
  lda #$0A ;different color
  sta (ballL),y
  rts

ballCoordinatesToScreen:
  ;ball = ballY * 32 + ballX + 0x0200
  ;high byte: ballY / 8 + 2 (display offset)
  lda ballY
  lsr
  lsr
  lsr
  clc  ;clear carry before the addition
  adc #$02 ;add 2 to get display offset 0x0200
  sta ballH

  ;low byte: (ballY % 8) * 32 + ballX
  lda ballY
  sec
  modulo_ball_coord: ;while a >= 0
  sbc #8 ;subtract 8 
  bpl modulo_ball_coord
  adc #8 ;add back 8, now we have the modulo result
  asl ; * 32
  asl
  asl
  asl
  asl
  clc ;clear carry before the addition
  adc ballX ; + ballX
  sta ballL
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

