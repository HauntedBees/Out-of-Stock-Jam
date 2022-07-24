extends Node

const INV_OFFSET := Vector2(16, 64)
const INV_DELTA := 96
const INV_WIDTH := 12
const INV_HEIGHT := 3

var inv_is_dragging := false

var drag_to_move := true
var inventory_rows := 8

var inventory := [
	Item.new("PistolAmmo", "Weapons/PistolAmmo.png", Vector2(2, 1), Vector2(1, 1), 69),
	Item.new("Hammer", "Weapons/Hammer.png", Vector2(1, 3), Vector2(5, 0), 1, false, false, true),
	Item.new("Pistol", "Weapons/Pistol.png", Vector2(1, 3), Vector2(0, 0), 1, true, false, true)
]
