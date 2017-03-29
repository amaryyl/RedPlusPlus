SECTION "bank2E",ROMX,BANK[$2E]
; Handles sprite attributes

ATK_PAL_GREY    EQU 0
ATK_PAL_BLUE    EQU 1
ATK_PAL_RED     EQU 2
ATK_PAL_BROWN   EQU 3
ATK_PAL_YELLOW  EQU 4
ATK_PAL_GREEN   EQU 5
ATK_PAL_ICE		EQU 6
ATK_PAL_PURPLE	EQU 7


PAL_ORANGE	EQU 0
PAL_BLUE	EQU 1
PAL_GREEN	EQU 2
PAL_BROWN	EQU 3
PAL_PURPLE	EQU 4
PAL_EMOJI	EQU 5
PAL_PLANT	EQU 6
PAL_ROCK	EQU 7
PAL_RANDOM	EQU 8 ; sprite IDs assigned this have no fixed pal, but use a random (consistent) one instead

LoadSpritePalettes:
	ld hl,SpritePalettes
	jr LoadPaletteData

LoadAttackSpritePalettes:
	ld hl,AttackSpritePalettes

LoadPaletteData:
	ld de,W2_SprPaletteData
	ld b,$40
.sprCopyLoop
	ld a,[hli]
	ld [de],a
	inc de
	dec b
	jr nz,.sprCopyLoop
	ld a,1
	ld [W2_LastOBP0],a
	ret

; Set overworld sprite colors
; On entering, A contains the flags (without a color palette) and de is the destination.
ColorOverworldSprites:
	push af
	push bc
	push de
	and $f8
	ld b,a

	ld a,[$ff8f]
	ld e,a
	ld d,$c1
	ld a,[de]		; Load A with picture ID
	dec a

	ld de, SpritePaletteAssignments
	add e
	ld e,a
	jr nc,.noCarry
	inc d
.noCarry
	ld a,[de]		; Get the picture ID's palette

	; If it's PAL_RANDOM, that means no particular palette is assigned
	cp PAL_RANDOM
	jr nz,.norandomColor

	; This is a (somewhat) random but consistent color
	ld a,[$ff8f]
	swap a
	and 3

.norandomColor

	pop de
	or b
	ld [de],a
	inc hl
	inc e
	pop bc
	pop af
	ret

; Currently this just colorizes attack sprites but it can be
; used in other non-overworld scenarios.
ColorNonOverworldSprites:
	ld a,2
	ld [rSVBK],a

	ld hl, wOAMBuffer
	ld b, 40
	ld d, W2_SpritePaletteMap>>8
.nextSprite
	ld a,[hli] ; y-coord
	and a
	jr z,.end

	inc hl
	ld a,[hli] ; tile
	ld e, a
	ld a,[hl] ; flags
	ld c,a
	ld a,[de]
	cp 8 ; if 8, colorize based on attack type
	jr z,.getAttackType
	cp 9 ; if 9, do not colorize
	jr nz,.setPalette
	xor a
	jr .setPalette

.getAttackType
	push hl
	ld a,[H_WHOSETURN]
	and a
	jr z,.playersTurn
	ld a,[wEnemyMoveType] ; Enemy move type
	jr .gotType
.playersTurn
	ld a,[wPlayerMoveType] ; Move type
.gotType
	ld hl, TypeColorTable
	add l
	ld l,a
	jr nc,.noCarry
	inc h
.noCarry
	ld a,[hl]
	pop hl

.setPalette
	or c
	ld [hli],a

	dec b
	jr nz, .nextSprite

.end
	xor a
	ld [rSVBK],a
	ret

LoadAnimationTilesetPalettes:
	di
	push de
	ld a,[wWhichBattleAnimTileset] ; Animation tileset
	ld c,a
	ld a,2
	ld [rSVBK],a

	xor a
	ld [W2_UseOBP1],a

	call LoadAttackSpritePalettes

	ld a,c
	and a
	ld hl, AnimationTileset1Palettes
	jr z,.gotPalette
	ld hl, AnimationTileset2Palettes
.gotPalette
	ld de, W2_SpritePaletteMap
	ld b, $80
.copyLoop
	ld a,[hli]
	ld [de],a
	inc e
	dec b
	jr nz,.copyLoop

	xor a
	ld [rSVBK],a

	pop de
	reti

; Set all sprite palettes to not be colorized by "ColorNonOverworldSprites".
; ASSUMES THAT WRAM BANK 2 IS LOADED.
ClearSpritePaletteMap:
	ld hl, W2_SpritePaletteMap
	ld b,$0 ; $100
	ld a,9
.loop
	ld [hli],a
	dec b
	jr nz,.loop
	ret


	ORG $2e, $6000

	jp ColorOverworldSprites

SpritePaletteAssignments: ; Characters on the overworld
	; 0x01: SPRITE_RED
	db PAL_ORANGE

	; 0x02: SPRITE_BLUE
	db PAL_BLUE

	; 0x03: SPRITE_OAK
	db PAL_BROWN

	; 0x04: SPRITE_BUG_CATCHER
	db PAL_RANDOM

	; 0x05: SPRITE_SLOWBRO
	db PAL_RANDOM

	; 0x06: SPRITE_LASS
	db PAL_RANDOM

	; 0x07: SPRITE_BLACK_HAIR_BOY_1
	db PAL_RANDOM

	; 0x08: SPRITE_LITTLE_GIRL
	db PAL_RANDOM

	; 0x09: SPRITE_BIRD
	db PAL_ORANGE

	; 0x0a: SPRITE_FAT_BALD_GUY
	db PAL_RANDOM

	; 0x0b: SPRITE_GAMBLER
	db PAL_RANDOM

	; 0x0c: SPRITE_BLACK_HAIR_BOY_2
	db PAL_RANDOM

	; 0x0d: SPRITE_GIRL
	db PAL_RANDOM

	; 0x0e: SPRITE_HIKER
	db PAL_RANDOM

	; 0x0f: SPRITE_FOULARD_WOMAN
	db PAL_RANDOM

	; 0x10: SPRITE_GENTLEMAN
	db PAL_BLUE

	; 0x11: SPRITE_DAISY
	db PAL_BLUE

	; 0x12: SPRITE_BIKER
	db PAL_RANDOM

	; 0x13: SPRITE_SAILOR
	db PAL_RANDOM

	; 0x14: SPRITE_COOK
	db PAL_RANDOM

	; 0x15: SPRITE_BIKE_SHOP_GUY
	db PAL_RANDOM

	; 0x16: SPRITE_MR_FUJI
	db PAL_GREEN

	; 0x17: SPRITE_GIOVANNI
	db PAL_BLUE

	; 0x18: SPRITE_ROCKET
	db PAL_ORANGE

	; 0x19: SPRITE_MEDIUM
	db PAL_RANDOM

	; 0x1a: SPRITE_WAITER
	db PAL_RANDOM

	; 0x1b: SPRITE_ERIKA
	db PAL_RANDOM

	; 0x1c: SPRITE_MOM_GEISHA
	db PAL_RANDOM

	; 0x1d: SPRITE_BRUNETTE_GIRL
	db PAL_RANDOM

	; 0x1e: SPRITE_LANCE
	db PAL_ORANGE

	; 0x1f: SPRITE_OAK_SCIENTIST_AIDE
	db PAL_BROWN

	; 0x20: SPRITE_OAK_AIDE
	db PAL_BROWN

	; 0x21: SPRITE_ROCKER ($20)
	db PAL_RANDOM

	; 0x22: SPRITE_SWIMMER
	db PAL_BLUE

	; 0x23: SPRITE_WHITE_PLAYER
	db PAL_RANDOM

	; 0x24: SPRITE_GYM_HELPER
	db PAL_RANDOM

	; 0x25: SPRITE_OLD_PERSON
	db PAL_RANDOM

	; 0x26: SPRITE_MART_GUY
	db PAL_RANDOM

	; 0x27: SPRITE_FISHER
	db PAL_RANDOM

	; 0x28: SPRITE_OLD_MEDIUM_WOMAN
	db PAL_RANDOM

	; 0x29: SPRITE_NURSE
	db PAL_ORANGE

	; 0x2a: SPRITE_CABLE_CLUB_WOMAN
	db PAL_GREEN

	; 0x2b: SPRITE_MR_MASTERBALL
	db PAL_RANDOM

	; 0x2c: SPRITE_LAPRAS_GIVER
	db PAL_RANDOM

	; 0x2d: SPRITE_WARDEN
	db PAL_RANDOM

	; 0x2e: SPRITE_SS_CAPTAIN
	db PAL_RANDOM

	; 0x2f: SPRITE_FISHER2
	db PAL_RANDOM

	; 0x30: SPRITE_BLACKBELT
	db PAL_RANDOM

	; 0x31: SPRITE_GUARD ($30)
	db PAL_BLUE

	; 0x32: SPRITE_ROCKET_F
	db PAL_ORANGE

	; 0x33: SPRITE_MOM
	db PAL_RANDOM

	; 0x34: SPRITE_BALDING_GUY
	db PAL_RANDOM

	; 0x35: SPRITE_YOUNG_BOY
	db PAL_RANDOM

	; 0x36: SPRITE_GAMEBOY_KID
	db PAL_RANDOM

	; 0x37: SPRITE_GAMEBOY_KID_COPY
	db PAL_RANDOM

	; 0x38: SPRITE_CLEFAIRY
	db PAL_ORANGE

	; 0x39: SPRITE_AGATHA
	db PAL_BLUE

	; 0x3a: SPRITE_BRUNO
	db PAL_BROWN

	; 0x3b: SPRITE_LORELEI
	db PAL_ORANGE

	; 0x3c: SPRITE_SEEL
	db PAL_BLUE

	; SPRITE_BROCK
	db PAL_BROWN

	; SPRITE_MISTY
	db PAL_ORANGE

	; SPRITE_SURGE
	db PAL_GREEN

	; SPRITE_SABRINA
	db PAL_ORANGE

	; SPRITE_KOGA
	db PAL_PURPLE

	; SPRITE_BLAINE
	db PAL_BROWN

	; SPRITE_BRENDAN
	db PAL_GREEN

	; SPRITE_FLANNERY
	db PAL_ORANGE

	; SPRITE_GREETER
	db PAL_RANDOM

	; SPRITE_LAPRAS
	db PAL_BLUE

	; SPRITE_SURF_PIKACHU
	db PAL_ORANGE

	; SPRITE_LOOKER
	db PAL_BROWN

	; SPRITE_SWIMMER_F
	db PAL_BLUE

	; SPRITE_OFFICER_JENNY
	db PAL_BLUE

	; SPRITE_JESSIE
	db PAL_ORANGE

	; SPRITE_JAMES
	db PAL_BLUE

	; SPRITE_GOLD
	db PAL_ORANGE

	; SPRITE_CRYSTAL
	db PAL_BLUE

	; SPRITE_SILVER
	db PAL_ORANGE
	
	; SPRITE_MEI
	db PAL_ORANGE
	
	; SPRITE_ELM
	db PAL_BROWN
	
	; SPRITE_GOLD_MOM
	db PAL_ORANGE
	
	; SPRITE_KURT
	db PAL_BROWN
	
	; SPRITE_KIMONO_GIRL
	db PAL_ORANGE
	
	; SPRITE_FALKNER
	db PAL_BLUE
	
	; SPRITE_BUGSY
	db PAL_GREEN
	
	; SPRITE_WHITNEY
	db PAL_ORANGE
	
	; SPRITE_MORTY
	db PAL_BLUE
	
	; SPRITE_JASMINE
	db PAL_BROWN
	
	; SPRITE_CHUCK
	db PAL_BROWN
	
	; SPRITE_PRYCE
	db PAL_BROWN
	
	; SPRITE_CLAIR
	db PAL_BLUE
	
	; SPRITE_WILL
	db PAL_ORANGE
	
	; SPRITE_KAREN
	db PAL_BROWN


	; 1-Frame Sprites Below here


	; 0x3d: SPRITE_BALL
	db PAL_ORANGE

	; 0x3e: SPRITE_OMANYTE
	db PAL_BLUE

	; 0x3f: SPRITE_BOULDER
	db PAL_ROCK

	; 0x40: SPRITE_PAPER_SHEET
	db PAL_ORANGE

	; 0x41: SPRITE_BOOK_MAP_DEX
	db PAL_ORANGE

	; 0x42: SPRITE_CLIPBOARD
	db PAL_ORANGE

	; 0x43: SPRITE_SNORLAX
	db PAL_ORANGE

	; 0x44: SPRITE_BAG
	db PAL_BROWN

	; 0x45: SPRITE_OLD_AMBER
	db PAL_BROWN

	; 0x46: SPRITE_POKEDEX
	db PAL_ORANGE

	; 0x47: SPRITE_BERRY_TREE
	db PAL_PLANT

	; 0x48: SPRITE_LYING_OLD_MAN
	db PAL_RANDOM

	; SPRITE_BENCH_GUY
	db PAL_RANDOM

	; SPRITE_SUDOWOODO
	db PAL_GREEN

	; SPRITE_POKEY
	db PAL_ORANGE

	; SPRITE_DITTO
	db PAL_ORANGE

	; SPRITE_CELEBI
	db PAL_GREEN

	; SPRITE_GYARADOS
	db PAL_ORANGE

	; SPRITE_ARTICUNO
	db PAL_BLUE

	; SPRITE_ZAPDOS
	db PAL_ORANGE

	; SPRITE_MOLTRES
	db PAL_ORANGE

	; SPRITE_MEWTWO
	db PAL_PURPLE

	; SPRITE_MEW
	db PAL_PURPLE

	; SPRITE_FOSSIL
	db PAL_ROCK

	; SPRITE_ROCK_SMASH
	db PAL_ROCK

	; SPRITE_TOWN_MAP
	db PAL_BLUE

	; SPRITE_N64
	db PAL_BLUE

	; SPRITE_TROPHY
	db PAL_BROWN


AnimationTileset1Palettes:
	INCBIN "color/animtileset1palettes.bin"

AnimationTileset2Palettes:
	INCBIN "color/animtileset2palettes.bin"

TypeColorTable: ; Used for a select few sprites to be colorized based on attack type
	db 0 ; NORMAL EQU $00
	db 0 ; FIGHTING EQU $01
	db 0 ; FLYING EQU $02
	db 0 ; POISON EQU $03
	db 0 ; GROUND EQU $04
	db 0 ; ROCK EQU $05
	db 0
	db 0 ; BUG EQU $07
	db 0 ; GHOST EQU $08
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 2 ; FIRE EQU $14
	db 1 ; WATER EQU $15
	db 0 ; GRASS EQU $16
	db 0 ; ELECTRIC EQU $17
	db 0 ; PSYCHIC EQU $18
	db 0 ; ICE EQU $19
	db 1 ; DRAGON EQU $1A

INCLUDE "color/spritepalettes.asm"
