class_name SaveScreen
extends Control

###############################
## SAVE FILE FORMAT          ##
## line 1: location name     ##
## line 2: save date         ##
## line 3: mayhem ruby count ##
## line 4: ring count        ##
## line 5: play time         ##
## line 6: player info       ##
## lines 7+: map info        ##
###############################

signal back_save()
var button_theme:Theme = preload("res://HUD/MenuButtonTheme.tres")

onready var beep_ping:AudioStreamPlayer = $BeepSound
onready var hover_ping:AudioStreamPlayer = $HoverSound
onready var panel:VBoxContainer = $SaveOptions
onready var save_desc:RichTextLabel = $SaveDescription
onready var screenshot:TextureRect = $Screenshot
onready var ruby_container:Control = $RubyHolder

var is_load := false
var current_screen:Image

func _on_button_mouse_entered(): 
	hover_ping.play()
func _on_BackButton_pressed(): emit_signal("back_save")
func setup(load_screen:bool):
	is_load = load_screen
	for pc in panel.get_children():
		pc.queue_free()
	if is_load: _load_save_info("Autosave")
	for i in 14:
		_load_save_info(String(i))
	visible = true
func _hover(button:Button, is_empty := false):
	if button.disabled: return
	hover_ping.play()
	if is_empty: return
	screenshot.texture = GASUtils.load_screen_as_texture(button.get_meta("Key"))
	_set_desc(button.get_meta("Playtime"), button.get_meta("Location"), button.get_meta("Rubies"), button.get_meta("Rings"))
func _set_desc(play_time:int, location:String, rubies:int, rings:int):
	var hours := floor(play_time / 3600.0)
	var minutes := int(floor(play_time / 60.0)) % 60
	var seconds := play_time % 60
	var play_time_str := "%02d:%02d:%02d" % [hours, minutes, seconds]
	var format_params := [play_time_str, location, ("None" if rubies == 0 else ""), ("#FF0000" if rings == 0 else "#FF00FF"), rings]
	save_desc.bbcode_text = "Playtime: [color=#FF00FF]%s[/color]\nLocation: [color=#FF00FF]%s[/color]\nMayhem Rubies: %s\nRings: [color=%s]%s[/color]" % format_params
	save_desc.visible = true
	for i in 7:
		var ruby:Control = ruby_container.get_child(i)
		ruby.visible = rubies > i
	
func _load_save_info(save_key:String):
	var button := Button.new()
	button.theme = button_theme
	button.align = Button.ALIGN_LEFT
	var game := File.new()
	var file_name := "user://save_%s.save" % save_key
	var prefix:String = save_key if save_key == "(Autosave) " else ""
	var is_empty := false
	if game.file_exists(file_name):
		game.open(file_name, File.READ)
		var location_line := game.get_line()
		var date_line := game.get_line()
		var rubies_line := int(game.get_line())
		var rings_line := int(game.get_line())
		var playtime_line := float(game.get_line())
		button.set_meta("Location", location_line)
		button.set_meta("Save Time", date_line)
		button.set_meta("Rubies", rubies_line)
		button.set_meta("Rings", rings_line)
		button.set_meta("Playtime", playtime_line)
		button.set_meta("Key", save_key)
		button.text = "%s%s [%s]" % [prefix, location_line, date_line]
		game.close()
	elif save_key == "Autosave":
		return
	else:
		button.text = "< EMPTY >"
		is_empty = true
		if is_load: button.disabled = true
	if is_load:
		button.connect("pressed", self, "load_data", [save_key])
	else:
		button.connect("pressed", self, "save_data", [save_key, button])
	button.connect("mouse_entered", self, "_hover", [button, is_empty])
	panel.add_child(button)

func load_data(key:String):
	beep_ping.play()
	var game := File.new()
	game.open("user://save_%s.save" % key, File.READ)
	# Metadata
	var location_line := game.get_line()
	game.get_line() # skip date
	PlayerInfo.mayhem_rubies = int(game.get_line())
	PlayerInfo.rings = int(game.get_line())
	PlayerInfo.play_time = float(game.get_line())
	# Player Data
	var player_info:Dictionary = parse_json(game.get_line())
	PlayerInfo.difficulty = int(player_info["difficulty"])
	PlayerInfo.chaos_energy = int(player_info["chaos_energy"])
	PlayerInfo.max_chaos_energy = int(player_info["max_chaos_energy"])
	PlayerInfo.emerald_shards = int(player_info["emerald_shards"])
	PlayerInfo.map_stickers = player_info["map_stickers"]
	PlayerInfo.inventory = ContentIndex.get_inventory_from_dictionaries(player_info["inventory"])
	PlayerInfo.current_weapon = ContentIndex.get_item_from_dictionary(player_info["current_weapon"])
	PlayerInfo.current_mayhem = player_info["current_mayhem"]
	PlayerInfo.inv_drag_to_move = player_info["inv_drag_to_move"]
	PlayerInfo.crouch_toggle = player_info["crouch_toggle"]
	PlayerInfo.mouse_sensitivity = player_info["mouse_sensitivity"]
	PlayerInfo.equip_toggle = player_info["equip_toggle"]
	GASConfig.input_cooldown_enabled = player_info["input_cooldown_enabled"]
	GASConfig.input_cooldown_length = player_info["input_cooldown_length"]
	GASInput.restore_actions_from_dictionary(player_info["controls"])
	# Map Data
	var map_datas:Dictionary = {}
	while game.get_position() < game.get_len():
		var map_info:Dictionary = parse_json(game.get_line())
		var map_name:String = map_info["_map_name"]
		map_datas[map_name] = map_info
		map_datas[map_name]["_destroyed"] = map_info["_destroyed"]
	PlayerInfo.map_infos = map_datas
	game.close()
	SceneSwitcher.switch_scene("res://Maps/%s.tscn" % location_line, false)
	SceneSwitcher.memory = player_info

func save_data(key:String, button:Button):
	beep_ping.play()
	button.set_meta("Key", key)
	current_screen.save_png("user://save_%s.png" % key)
	screenshot.texture = GASUtils.load_screen_as_texture(key)
	var file_name := "user://save_%s.save" % key
	var game := File.new()
	game.open(file_name, File.WRITE)
	_save_metadata(game, button)
	_save_game_data(game)
	game.close()
	_set_desc(int(PlayerInfo.play_time), PlayerInfo.current_map, PlayerInfo.mayhem_rubies, PlayerInfo.rings)

func _save_metadata(game:File, button:Button):
	var now := OS.get_datetime()
	var now_string := "%d-%02d-%02d %02d:%02d" % [now.year, now.month, now.day, now.hour, now.minute]
	game.store_line(PlayerInfo.current_map)
	game.store_line(now_string)
	game.store_line(String(PlayerInfo.mayhem_rubies))
	game.store_line(String(PlayerInfo.rings))
	game.store_line(String(PlayerInfo.play_time))
	button.set_meta("Location", PlayerInfo.current_map)
	button.set_meta("Save Time", now_string)
	button.set_meta("Playtime", PlayerInfo.play_time)
	button.set_meta("Rubies", PlayerInfo.mayhem_rubies)
	button.set_meta("Rings", PlayerInfo.rings)
	button.text = "%s [%s]" % [PlayerInfo.current_map, now_string]
func _save_game_data(game:File):
	# Save Player Data
	var player = get_tree().get_nodes_in_group("player")[0] # cyclical shit's getting mad at me here
	var pspat:Spatial = player
	var player_info := {
		"in_water": player.in_water,
		"water_y": player.water_y,
		"needs_safe_oxygen": player.needs_safe_oxygen,
		"safe_oxygen_level": player.safe_oxygen_level,
		"direction": player.direction,
		"velocity": player.velocity,
		"is_crouched": player.is_crouched,
		"position": pspat.global_transform.origin,
		"rotation": Vector2(player.vision.rotation_degrees.x, player.rotation_degrees.y),
		"difficulty": PlayerInfo.difficulty,
		"mouse_sensitivity": PlayerInfo.mouse_sensitivity,
		"chaos_energy": PlayerInfo.chaos_energy,
		"max_chaos_energy": PlayerInfo.max_chaos_energy,
		"emerald_shards": PlayerInfo.emerald_shards,
		"map_stickers": PlayerInfo.map_stickers,
		"inventory": PlayerInfo.inventory_as_dicts(),
		"current_weapon": PlayerInfo.current_weapon.as_dict(),
		"current_mayhem": PlayerInfo.current_mayhem,
		"inv_drag_to_move": PlayerInfo.inv_drag_to_move,
		"crouch_toggle": PlayerInfo.crouch_toggle,
		"equip_toggle": PlayerInfo.equip_toggle,
		"controls": GASInput.get_actions_as_dictionary(),
		"input_cooldown_enabled": GASConfig.input_cooldown_enabled,
		"input_cooldown_length": GASConfig.input_cooldown_length
	}
	game.store_line(to_json(player_info))
	# Save Non-Current Map Data
	for k in PlayerInfo.map_infos.keys():
		if PlayerInfo.current_map == k: continue
		game.store_line(to_json(PlayerInfo.map_infos[k]))
	# Save Current Map Data
	var root := get_tree().get_root()
	var current_scene:Map = root.get_child(root.get_child_count() - 1)
	var dict := current_scene.get_as_dictionary()
	game.store_line(to_json(dict))
