BluesHouseObject:
	db $0A ; border block

	db $2 ; warps
	db $7, $2, $1, $FF
	db $7, $3, $1, $FF

	db $4 ; signs
	db $1, $3, $4 ; Stove
	db $1, $2, $5 ; Sink
	db $1, $4, $6 ; Fridge
	db $1, $9, $7 ; TV

	db $3 ; objects
	object SPRITE_DAISY, $8, $4, STAY, RIGHT, $1 ; Daisy, sitting by map
	object SPRITE_DAISY, $3, $2, WALK, $1, $2, $0 ; Daisy, walking around
	object SPRITE_TOWN_MAP, $9, $4, STAY, NONE, $3, $0 ; map on table

	; warp-to
	EVENT_DISP BLUES_HOUSE_WIDTH, $7, $2
	EVENT_DISP BLUES_HOUSE_WIDTH, $7, $3
