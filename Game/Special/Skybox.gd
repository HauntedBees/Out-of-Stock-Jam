extends MeshInstance

onready var material:SpatialMaterial = get_active_material(0)
onready var rng := RandomNumberGenerator.new()

func _ready(): rng.randomize()
func _on_timeout():
	material.uv1_offset = Vector3(rng.randf_range(-0.5, 0.5), rng.randf_range(-0.5, 0.5), 0)
	material.uv1_scale = Vector3(rng.randf_range(0.3, 3), rng.randf_range(0.3, 3), 1)
