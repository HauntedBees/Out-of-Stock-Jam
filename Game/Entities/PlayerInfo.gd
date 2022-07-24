extends Node

var drag_to_move := true
var inventory_rows := 8

var inventory := [
	{
		type = "PistolAmmo",
		texture = "Weapons/PistolAmmo.png",
		size = Vector2(2, 1),
		amount = 69,
		position = Vector2(1, 1)
	},
	{
		type = "Pistol",
		texture = "Weapons/Pistol.png",
		size = Vector2(1, 3),
		flip_texture = true,
		amount = 1,
		position = Vector2(0, 0)
	}
]
