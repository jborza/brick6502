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

jsr init
jsr loop

init:
  jsr initPlayer
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
  ;todo implement collision with left and right walls
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

