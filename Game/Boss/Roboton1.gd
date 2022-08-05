class_name Eggsman
extends RigidBody

var projectile:PackedScene = load("res://Entities/Particles/EnemyProjectile.tscn")
var boom:PackedScene = load("res://Weapons/Explosion.tscn")

onready var hurt:Texture = preload("res://Textures/Boss/Ship1Hurt.png")
onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
onready var player:KinematicBody = get_tree().get_nodes_in_group("player")[0]
onready var ball:RigidBody = $WreckingBall
onready var main_mesh:MeshInstance = $Eggsman
onready var name_mesh:MeshInstance = $Name
onready var material:SpatialMaterial = main_mesh.get_active_material(0)
onready var normal:Texture = material.albedo_texture
onready var freezies := [$Chain1, $Chain2, $Chain3, $Chain4, $Chain5, $Chain6, ball]
var highlight_timer := 0.0
var health := 2000.0
var flicker_state := 0.0
var saved_velocities := []

var current_state := 0 # 0 = follow path
var speed = 10.0
var started := false
var target := Vector3.ZERO
var is_dead := false
var advance_timer := 0.0

func take_hit(_direction:Vector3, _force:float, damage:float):
	if is_dead: return
	if !PlayerInfo.current_weapon.uses_ammo:
		print("holy shit dude")
		damage *= 6.0
	health -= damage
	print(health)
	$OofSound.play()
	flicker_state = 0.5
	material.albedo_texture = hurt
	if health <= 0.0:
		is_dead = true
		flicker_state = 10.0
		advance_timer = 10.0
		$Timer.wait_time = 1.0
		linear_velocity = Vector3(0, -2.0, 0)

func dent(): $DentSound.play()

func show_highlight():
	highlight_timer = 0.1
	material.next_pass = highlight
	name_mesh.visible = true

func _process(delta:float):
	if advance_timer > 0.0:
		advance_timer -= delta
		if advance_timer <= 0:
			print("OK MOVE ON")
	if flicker_state > 0.0:
		flicker_state -= delta
		if flicker_state <= 0:
			material.albedo_texture = normal
		else:
			match int(flicker_state * 16.0) % 2:
				1: material.albedo_texture = hurt
				0: material.albedo_texture = normal
	if highlight_timer > 0:
		highlight_timer -= delta
		if highlight_timer < 0: hide_highlight()

func _physics_process(delta:float):
	if PlayerInfo.time_frozen && ball.gravity_scale > 0.0:
		saved_velocities = []
		for idx in freezies.size():
			var b:RigidBody = freezies[idx]
			saved_velocities.append(b.linear_velocity)
			b.gravity_scale = 0.0
			b.set_physics_process(false)
			b.sleeping = true
	elif !PlayerInfo.time_frozen && ball.gravity_scale == 0.0:
		for idx in freezies.size():
			var b:RigidBody = freezies[idx]
			b.linear_velocity = saved_velocities[idx]
			b.gravity_scale = 1.0
			b.set_physics_process(true)
			b.sleeping = false
	if PlayerInfo.time_frozen: return
	if is_dead: return
	_move_to_point(delta)

func _move_to_point(delta:float):
	if !started || global_transform.origin.distance_to(target) < 10.0 || global_transform.origin.y < 5.0:
		started = true
		target = Vector3(
			-21.0 + 64.0 * randf(),
			9.0 + 15.0 * randf(),
			-35.0 + 62.0 * randf()
		)
		speed = 5.0 + 10.0 * randf()
		var velocity:Vector3 = (target - global_transform.origin).normalized() * speed
		linear_velocity = velocity
		ball.add_force(-2.0 * velocity, ball.global_transform.origin)

func hide_highlight():
	material.next_pass = null
	name_mesh.visible = false

func _on_WreckingBall_body_entered(body:Node):
	if body != player: return
	var dir:Vector3 = (ball.global_transform.origin - player.global_transform.origin)
	dir = Vector3(0, dir.y * 0.03, 0) + Vector3(dir.x, 0, dir.z).normalized()
	player.bonus_force = -dir * 300.0
	player.bonus_force_timer = 1.0
	player.take_damage()

func _on_OofArea_body_entered(body:Node):
	if body != player: return
	var dir:Vector3 = (ball.global_transform.origin - player.global_transform.origin)
	dir = Vector3(0, dir.y * 0.03, 0) + Vector3(dir.x, 0, dir.z).normalized()
	player.bonus_force = -dir * 200.0
	player.bonus_force_timer = 0.2
	player.take_damage()

func _on_Timer_timeout():
	if is_dead:
		var blast = boom.instance()
		blast.force = 1.0
		blast.damage = 0
		get_parent().add_child(blast)
		blast.global_transform.origin = global_transform.origin + Vector3(-0.5 + randf(), -0.5 + randf(), -0.5 + randf())
		get_tree().call_group("SoundAwaiter", "noise_made", 2.0, global_transform.origin)
		return
	if PlayerInfo.invisible: return
	var rand_chance:float = 0.25 if health < 500 else 0.1
	if randf() > rand_chance: return
	var dir:Vector3 = (player.global_transform.origin - global_transform.origin).normalized()
	var p:EnemyProjectile = projectile.instance()
	p.explode_on_impact = true
	p.launcher = self
	get_parent().add_child(p)
	p.global_transform.origin = global_transform.origin + dir * 1.0 + Vector3(0, 1.0, 0)
	dir.y = randf()
	p.apply_impulse(Vector3.ZERO, dir * (2.0 + 10.0 * randf()))
