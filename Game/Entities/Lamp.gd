class_name Lamp
extends StaticBody

export(float) var health := 5.0
export(float) var flicker_chance := 0.002

onready var flicker_timer:Timer = $Timer
onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
onready var main_mesh:MeshInstance = $MeshInstance
var material:SpatialMaterial
var light:Light

var highlight_timer := 0.0
var rng := RandomNumberGenerator.new()
var light_on := true

func _ready():
	rng.randomize()
	light = $SpotLight
	main_mesh.mesh = main_mesh.mesh.duplicate()
	material = main_mesh.get_active_material(0).duplicate()
	main_mesh.material_override = material

func show_highlight():
	highlight_timer = 0.1
	main_mesh.get_active_material(0).next_pass = highlight

func _process(delta:float):
	if PlayerInfo.time_frozen: return
	if light_on && rng.randf() < flicker_chance:
		flicker_timer.start()
		light.visible = false
		light_on = false
	if highlight_timer > 0:
		highlight_timer -= delta
		if highlight_timer < 0: hide_highlight()

func hide_highlight():
	main_mesh.get_active_material(0).next_pass = null
	
func take_hit(_direction:Vector3, _force:float, damage:float):
	health -= damage
	if health <= 0:
		get_tree().call_group("destroy_monitor", "on_destroy", name)
		queue_free()

func _on_timeout():
	if PlayerInfo.time_frozen:
		flicker_timer.start()
		return
	light_on = true
	light.visible = true
