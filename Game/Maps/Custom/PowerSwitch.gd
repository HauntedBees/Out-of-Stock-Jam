class_name PowerSwitch
extends StaticBody

onready var mat:SpatialMaterial = $MeshInstance.get_active_material(0)

func _ready():
	if PlayerInfo.current_story_state > 0:
		mat.uv1_offset.x = 0.0

func switch():
	PlayerInfo.current_story_state = 1
	mat.uv1_offset.x = 0.0
	get_tree().call_group("PlayerSound", "play_sound", "Switch")
