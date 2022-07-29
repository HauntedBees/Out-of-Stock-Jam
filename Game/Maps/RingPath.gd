extends Path

onready var ring_scene:PackedScene = load("res://Entities/Ring.tscn")
export(float) var distance := 1.0

func _ready():
	var max_length := curve.get_baked_length()
	var current_length := 0.0
	while current_length <= max_length:
		var r:Spatial = ring_scene.instance()
		r.transform.origin = curve.interpolate_baked(current_length)
		add_child(r)
		current_length += distance
