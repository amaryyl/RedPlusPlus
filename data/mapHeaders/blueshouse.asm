BluesHouse_h:
	db REDS_HOUSE ; tileset
	db BLUES_HOUSE_HEIGHT, BLUES_HOUSE_WIDTH ; dimensions
	dw BluesHouseBlocks, BluesHouseTextPointers, BluesHouseScript
	db 0
	dw BluesHouseObject
