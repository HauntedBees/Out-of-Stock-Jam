extends Node
var items := {
	"rings_10": [10],
	"hammer": [
		Item.new("Hammer", "Weapons/Hammer.png", Vector2(1, 3), Vector2(0, 0), { "equippable": true, "uses_ammo": false })
	]
}
var item_types := {
	"Pistol": Item.new("Pistol", "Weapons/Pistol.png", Vector2(1, 3), Vector2.ZERO, {
		"equippable": true,
		"reload_amount": 6,
		"reload_speed_mult": 0.2
	}),
	"Pistol Ammo": Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 32
	}),
	"Grenade Launcher": Item.new("Grenade Launcher", "Weapons/Grenade Launcher.png", Vector2(2, 3), Vector2.ZERO, {
		"equippable": true,
		"reload_amount": 1,
		"reload_speed_mult": 0.2,
		"is_heavy": true
	}),
	"Grenade Launcher Ammo": Item.new("Grenade Launcher Ammo", "Weapons/Grenade LauncherAmmo.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 16
	}),
	"Hammer": Item.new("Hammer", "Weapons/Hammer.png", Vector2(1, 3), Vector2.ZERO, {
		"equippable": true,
		"uses_ammo": false
	})
}

func get_item(type:String, position:Vector2, amount := 0) -> Item:
	var old:Item = item_types[type]
	var item := Item.new(old.type, old.texture, old.size, old.position, old.saved_args)
	item.position = position
	if item.equippable:
		item.current_ammo = amount
	else:
		item.amount = amount
	return item
