extends MeshInstance

var potential_animals := [
	preload("res://Textures/Entities/Animals/Squirrel.png"),
	preload("res://Textures/Entities/Animals/Rabbit.png"),
	preload("res://Textures/Entities/Animals/Bird.png"),
	preload("res://Textures/Entities/Animals/Seal.png"),
	preload("res://Textures/Entities/Animals/Pig.png"),
	preload("res://Textures/Entities/Animals/Penguin.png"),
	preload("res://Textures/Entities/Animals/Chick.png")
]

func _ready():
	var material:SpatialMaterial = get_active_material(0)
	material.albedo_texture = potential_animals[floor(potential_animals.size() * randf())]

func _on_animation_finished(_anim_name:String):
	queue_free()
