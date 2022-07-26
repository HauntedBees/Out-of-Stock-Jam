class_name Emerald
extends Spatial

export(int) var emerald_number := 0
onready var gem:SpatialMaterial = ($Gem as MeshInstance).get_active_material(0)
onready var glow:SpatialMaterial = ($Glow as MeshInstance).get_active_material(0)

func _ready(): set_number(emerald_number)
func set_number(n:int):
	emerald_number = n
	match emerald_number:
		0:
			gem.albedo_color = Color(0.0, 0.3, 0.65)
			glow.albedo_color = Color(0.2, 0.7, 1.0)
		1:
			gem.albedo_color = Color(0.4, 0.0, 0.65)
			glow.albedo_color = Color(0.7, 0.2, 1.0)
		2:
			gem.albedo_color = Color(0.65, 0.0, 0.0)
			glow.albedo_color = Color(1.0, 0.2, 0.2)
		3:
			gem.albedo_color = Color(0.96, 0.0, 1.0)
			glow.albedo_color = Color(1.0, 0.2, 1.0)
		4:
			gem.albedo_color = Color(1.0, 1.0, 0.0)
			glow.albedo_color = Color(1.0, 1.0, 0.0)
		5:
			gem.albedo_color = Color(0.3, 0.65, 0.0)
			glow.albedo_color = Color(0.3, 1.0, 0.2)
		6:
			gem.albedo_color = Color(0.77, 0.77, 0.77)
			glow.albedo_color = Color(0.77, 0.77, 0.77)
