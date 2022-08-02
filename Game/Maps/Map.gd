class_name Map
extends Spatial

var destroyed_object_names := [] # Lamps and LockedDoors
func _ready():
	add_to_group("destroy_monitor")
	get_tree().call_group("equip_monitor", "update_weapon", true)
	get_tree().call_group("equip_monitor", "update_mayhem")
	if SceneSwitcher.memory.keys().size() > 0:
		_load_player()
	_load_from_map_info()
func on_destroy(body:String): destroyed_object_names.append(body)

func _load_from_map_info():
	if !PlayerInfo.map_infos.has(name): return
	var map_info:Dictionary = PlayerInfo.map_infos[name]
	destroyed_object_names = map_info["_destroyed"]
	for n in get_children():
		_load_node(map_info, n)

func _load_player():
	var player = get_tree().get_nodes_in_group("player")[0] # fucking cyclic references
	var d := SceneSwitcher.memory
	player.in_water = d["in_water"]
	player.water_y = d["water_y"]
	player.needs_safe_oxygen = d["needs_safe_oxygen"]
	player.safe_oxygen_level = d["safe_oxygen_level"]
	player.direction = GASUtils.str2vec3(d["direction"])
	player.velocity = GASUtils.str2vec3(d["velocity"])
	player._handle_crouch(d["is_crouched"])
	player.in_water = d["in_water"]
	if player.in_water:
		player.get_in_water(player.water_y)
	player.global_transform.origin = GASUtils.str2vec3(d["position"])
	var rotation:Vector2 = GASUtils.str2vec2(d["rotation"])
	player.vision.rotation_degrees.x = rotation.x
	player.rotation_degrees.y = rotation.y
	PlayerInfo.paused = false
	PlayerInfo.in_cutscene = false
	SceneSwitcher.memory = {}

func get_as_dictionary() -> Dictionary:
	var info := {
		"_destroyed": destroyed_object_names,
		"_map_name": name
	}
	for n in get_children():
		_check_node(info, n)
	return info

func _check_node(info_ref:Dictionary, n:Node):
	if n is Entity:
		var e:Entity = n
		info_ref[n.name] = e.as_dict()
	elif n is SecurityControl:
		var s:SecurityControl = n
		info_ref[n.name] = { "cleared": s.cleared }
	elif "IS_SPECIAL_POST" in n:
		# warning-ignore:unsafe_property_access
		info_ref[n.name] = { "cleared": n.cleared }
	elif n is LockedDoor:
		var l:LockedDoor = n
		info_ref[n.name] = { "is_open": l.is_open }
	else:
		for c in n.get_children():
			_check_node(info_ref, c)
	# TODO: moving platforms if they're actually used

func _load_node(info:Dictionary, n:Node):
	if destroyed_object_names.has(n.name):
		n.queue_free()
	if info.has(n.name):
		var my_info:Dictionary = info[n.name]
		if n is Entity:
			var e:Entity = n
			e.from_dict(my_info)
		elif n is SecurityControl:
			var s:SecurityControl = n
			s.cleared = my_info["cleared"]
		elif "IS_SPECIAL_POST" in n:
			if my_info["cleared"]:
				# warning-ignore:unsafe_method_access
				n.clear()
		elif n is LockedDoor:
			var l:LockedDoor = n
			if my_info["is_open"]:
				l.open(true)
		else:
			for c in n.get_children():
				_load_node(info, c)
	else:
		for c in n.get_children():
			_load_node(info, c)
	# TODO: moving platforms if they're actually used