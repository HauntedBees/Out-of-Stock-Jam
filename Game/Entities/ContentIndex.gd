extends Node

var item_types := {
	# Auto-Consumables
	"Rings": Item.new("Rings", "Entities/RingBox.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"immediate": true
	}),
	"Mayhem Shards": Item.new("Mayhem Shards", "HUD/EmeraldShard.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"immediate": true
	}),
	# Mayhem Boosters
	"Strobbery": Item.new("Strobbery", "Items/Strobbery.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 1
	}),
	"Onion": Item.new("Onion", "Items/Onion.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 2
	}),
	"Capsicum": Item.new("Capsicum", "Items/Capsicum.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 3
	}),
	"Broccoli": Item.new("Broccoli", "Items/Broccoli.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 4
	}),
	"Pasta": Item.new("Pasta", "Items/Pasta.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 5
	}),
	"Yoggy": Item.new("Yoggy", "Items/Yoggy.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 10
	}),
	"Tofu": Item.new("Tofu", "Items/Tofu.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 25
	}),
	"Tea": Item.new("Tea", "Items/Tea.png", Vector2(1, 1), Vector2.ZERO, {
		"max_stack_size": 99,
		"usable": true,
		"mayhem_recovered": 50
	}),
	# Weapons
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

var items := {
	"sysadmin1": [get_item("Rings", Vector2(1, 2), 10)],
	"sysadmin2": [
		get_item("Pasta", Vector2(2, 2), 1),
		get_item("Yoggy", Vector2(1, 2), 1)
	],
	"sysadmin3": [get_item("Mayhem Shards", Vector2(3, 2), 2)],
	"sysadmin4": [
		get_item("Shotgun", Vector2(0, 0), 2),
		get_item("Shotgun Ammo", Vector2(1, 2), 4),
		get_item("Shotgun Ammo", Vector2(2, 2), 3)
	],
	"common1": [
		get_item("Strobbery", Vector2(1, 1), 1),
		get_item("Pistol Ammo", Vector2(3, 0), 2)
	],
	"common2": [
		get_item("Broccoli", Vector2(0, 0), 1),
		get_item("Pistol Ammo", Vector2(0, 1), 1)
	],
	"uncommon1": [
		get_item("Strobbery", Vector2(0, 0), 2),
		get_item("Pistol Ammo", Vector2(0, 1), 5)
	],
	"uncommon2": [
		get_item("Rings", Vector2.ZERO, 10),
		get_item("Onion", Vector2(0, 1), 2)
	],
	"common3": [get_item("Capsicum", Vector2(2, 2), 1)],
	"common4": [get_item("Pistol Ammo", Vector2(0, 2), 3)],
	"coffeemachine": [get_item("Tea", Vector2(2, 1), 1)],
	"common5": [
		get_item("Pistol Ammo", Vector2(1, 0), 2),
		get_item("Onion", Vector2(2, 1), 1)
	],
	"pistol": [
		get_item("Pistol", Vector2(0, 0), 1),
		get_item("Pistol Ammo", Vector2(2, 1), 2),
	],
	"mega_ammo": [
		get_item("Pistol Ammo", Vector2(0, 0), 10),
		get_item("Shotgun Ammo", Vector2(1, 1), 10),
		get_item("Assault Rifle Ammo", Vector2(0, 1), 80),
		get_item("Grenade Launcher Ammo", Vector2(1, 0), 5)
	],
	"machinegun": [
		get_item("Assault Rifle", Vector2(0, 0), 15),
		get_item("Assault Rifle Ammo", Vector2(1, 1), 14),
	],
	"nades": [
		get_item("Grenade Launcher", Vector2(0, 0), 1),
		get_item("Grenade Launcher Ammo", Vector2(2, 1), 1),
	],
	"sord": [
		get_item("Sword", Vector2(1, 0), 1)
	],
	"mole": [
		get_item("Capsicum", Vector2(0, 1), 1),
		get_item("Broccoli", Vector2(0, 0), 1),
		get_item("Onion", Vector2(2, 1), 1),
	],
	"rings_10": [10],
	"rings_30": [30],
	"mayhem_full": [1000],
	"yog": [get_item("Yoggy", Vector2(2, 1), 1)],
	"some_food": [
		get_item("Strobbery", Vector2(1, 0), 2),
		get_item("Pasta", Vector2(2, 1), 1)
	],
	"tofu": [get_item("Tofu", Vector2(2, 1), 1)],
	"inv_rings10": [get_item("Rings", Vector2.ZERO, 10)],
	"inv_rings20": [get_item("Rings", Vector2.ZERO, 20)],
	"shard": [get_item("Mayhem Shards", Vector2(1, 1), 1)],
	"shard2": [get_item("Mayhem Shards", Vector2(1, 1), 2)],
	"shard10": [get_item("Mayhem Shards", Vector2(1, 1), 10)],
	"starter": [
		get_item("Hammer", Vector2.ZERO, 1),
		get_item("Mayhem Shards", Vector2(2, 2), 5),
		get_item("Rings", Vector2(3, 1), 10)
		#Item.new("Hammer", "Weapons/Hammer.png", Vector2(1, 3), Vector2(0, 0), { "equippable": true, "uses_ammo": false })
	]
}

func get_item(type:String, position:Vector2, amount := 0) -> Item:
	if type == "Unarmed": return PlayerInfo.UNARMED
	var old:Item = item_types[type]
	var item := Item.new(old.type, old.texture, old.size, old.position, old.saved_args)
	item.position = position
	if item.equippable:
		item.current_ammo = amount
	else:
		item.amount = amount
	return item

func get_item_from_dictionary(d:Dictionary) -> Item: return get_item(d["type"], GASUtils.str2vec2(d["position"]), d["amount"])

func get_inventory_from_name(s:String) -> Array:
	if !items.has(s): return []
	var item_list:Array = items[s]
	var copy_list := []
	for i in item_list:
		var it:Item = i
		copy_list.append(get_item_from_dictionary(it.as_dict()))
	return copy_list

func get_inventory_from_dictionaries(a:Array) -> Array:
	var inv := []
	for di in a:
		if di is Dictionary:
			inv.append(get_item_from_dictionary(di))
		else:
			print("not a dict: %s" % di)
			inv.append(di)
	return inv
