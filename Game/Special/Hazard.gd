extends SpecialStageItem

onready var t:ShaderMaterial = ($CompleteMesh as MeshInstance).get_active_material(0)
onready var rng := RandomNumberGenerator.new()

func _ready(): rng.randomize()
func _on_timeout():
	t.set_shader_param("delta", Vector2(rng.randf_range(-0.5, 0.5), rng.randf_range(-0.5, 0.5)))
	t.set_shader_param("mult", Vector2(rng.randf_range(0.3, 3), rng.randf_range(0.3, 3)))
