extends TextureButton

signal select_mayhem(name, image, text, cost)

export(String) var mayhem_name := ""
onready var info_label:Label = get_parent().find_node("InfoLabel")
onready var info_texture:Texture = load("res://Textures/Entities/Mayhem/%s_Info.png" % mayhem_name)

export(String, MULTILINE) var main_text := ""
export(int) var level_one_cost := 0
export(String, MULTILINE) var level_one := ""
export(int) var level_two_cost := 0
export(String, MULTILINE) var level_two := ""
export(int) var level_three_cost := 0
export(String, MULTILINE) var level_three := ""

func _onmouse_entered():
	info_label.text = "%s (Level %s)" % [mayhem_name, PlayerInfo.get_mayhem_level(mayhem_name)]

func _on_mouse_exited():
	info_label.text = "Choose a mayhem power to upgrade"

func _on_pressed():
	var level := PlayerInfo.get_mayhem_level(mayhem_name)
	var cost := 0
	var text := main_text + "\n\n"
	match level:
		0:
			cost = level_one_cost
			text += level_one
		1:
			cost = level_two_cost
			text += level_two
		2:
			cost = level_three_cost
			text += level_three
		3:
			text = "You have already reached the max level for this Mayhem."
	emit_signal("select_mayhem", mayhem_name, info_texture, text, cost)
