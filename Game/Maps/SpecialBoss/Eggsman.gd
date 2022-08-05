extends KinematicBody

var boom:PackedScene = load("res://Weapons/Explosion.tscn")
onready var player:NewPlayer = $"../NewPlayer"
onready var hurt:Texture = preload("res://Textures/Boss/Ship1Hurt.png")
onready var main_mesh:MeshInstance = $MeshInstance
onready var material:SpatialMaterial = main_mesh.get_active_material(0)
onready var normal:Texture = material.albedo_texture
var velocity := Vector3(0, 0, -30)
var health := 1420.0
var flicker_state := 0.0
var move := 0.0
var is_dead := false
var advance_timer := 0.0

func take_hit(_dir:Vector3, _force:float, damage:float):
	if is_dead: return
	health -= damage
	print(health)
	$OofSound.play()
	flicker_state = 0.5
	material.albedo_texture = hurt
	if health <= 0.0:
		is_dead = true
		velocity = Vector3(0, -2, 0)
		flicker_state = 10.0
		advance_timer = 10.0

func _physics_process(delta:float):
	if is_dead:
		velocity = move_and_slide(velocity, Vector3.UP)
		return
	var dist:float = abs((player.global_transform.origin - global_transform.origin).length())
	move += delta
	velocity.x = 10.0 * sin(move)
	if dist > 100.0:
		velocity.z = max(1.0, velocity.z / 2.0)
	elif dist <= 50.0:
		velocity.z *= 1.5
	velocity = move_and_slide(velocity, Vector3.UP)

func _on_Timer_timeout() -> void:
	if is_dead:
		if advance_timer <= 0:
			return
		var blast = boom.instance()
		blast.force = 1.0
		blast.damage = 0
		get_parent().add_child(blast)
		blast.global_transform.origin = global_transform.origin + Vector3(-0.5 + randf(), -0.5 + randf(), -0.5 + randf())
		get_tree().call_group("SoundAwaiter", "noise_made", 2.0, global_transform.origin)
		return
	var r := randf()
	velocity.z = player.velocity.z
	if r < 0.05:
		velocity.z *= 2.0
	elif r < 0.25:
		velocity.z *= 1.2

func _process(delta:float):
	if advance_timer > 0.0:
		advance_timer -= delta
		if advance_timer <= 0:
			$"../WinEnd".visible = true
			player.game_over = true
	if flicker_state > 0.0:
		flicker_state -= delta
		if flicker_state <= 0:
			material.albedo_texture = normal
		else:
			match int(flicker_state * 16.0) % 2:
				1: material.albedo_texture = hurt
				0: material.albedo_texture = normal
