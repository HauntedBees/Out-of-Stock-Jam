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
		"max_stack_size": 30
	}),
	"Assault Rifle": Item.new("Assault Rifle", "Weapons/Assault Rifle.png", Vector2(1, 3), Vector2.ZERO, {
		"equippable": true,
		"reload_amount": 30,
		"reload_speed_mult": 0.4
	}),
	"Assault Rifle Ammo": Item.new("Assault Rifle Ammo", "Weapons/Assault RifleAmmo.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 120
	}),
	"Shotgun": Item.new("Shotgun", "Weapons/Shotgun.png", Vector2(1, 3), Vector2.ZERO, {
		"equippable": true,
		"reload_amount": 2,
		"reload_speed_mult": 0.1
	}),
	"Shotgun Ammo": Item.new("Shotgun Ammo", "Weapons/ShotgunAmmo.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 16
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
	}),
	"Sword": Item.new("Sword", "Weapons/Sword.png", Vector2(1, 3), Vector2.ZERO, {
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

func get_item_from_dictionary(d:Dictionary) -> Item: return get_item(d["type"], GASUtils.str2vec2(d["position"]), d["amount"])

func get_inventory_from_dictionaries(a:Array) -> Array:
	var inv := []
	for di in a:
		inv.append(get_item_from_dictionary(di))
	return inv
