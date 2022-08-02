extends Area

onready var mesh:MeshInstance = $MeshInstance
onready var player:Spatial = get_tree().get_nodes_in_group("player")[0]
onready var tween:Tween = $Tween

var direction:Vector3
var time_remaining := 4.0
var speed := 5.0
var hurt_timer := 0.0
var has_player := false

func _ready():
	var material:SpatialMaterial = mesh.get_active_material(0).duplicate()
	mesh.material_override = material
	material.albedo_color.a = 1.0
	direction = Vector3(
		-1.0 + 2.0 * randf(),
		-0.5 + randf(),
		-1.0 + 2.0 * randf()
	).normalized()

func _fade():
	tween.interpolate_property(mesh.material_override, "albedo_color:a", 1.0, 0.0, 1.0)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()

func _process(delta:float):
	if has_player:
		hurt_timer -= delta
		if hurt_timer <= 0.0:
			match PlayerInfo.difficulty:
				0: hurt_timer = 5.0
				1: hurt_timer = 1.0
				2: hurt_timer = 0.25
			player.lose_ring()
	time_remaining -= delta
	if time_remaining <= 0.0 && !tween.is_active():
		_fade()
func _on_animation_finished(_anim_name:String):
	queue_free()

func _physics_process(delta:float):
	if tween.is_active(): return
	var dist := player.global_transform.origin - global_transform.origin
	if dist.length() <= 10.0:
		direction = dist.normalized()
	transform.origin += direction * speed * delta

func _on_Toxicloud_body_entered(body:Node):
	if body is StaticBody:
		direction = Vector3.ZERO
		_fade()
		return
	if body != player: return
	player.ouchie.visible = true
	has_player = true
	hurt_timer = 0.0

func _on_Toxicloud_body_exited(body:Node):
	if body != player: return
	if player.invincible_time <= 0.0:
		player.ouchie.visible = false
	has_player = false
