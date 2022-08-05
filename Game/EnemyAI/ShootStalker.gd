extends EnemyAI

var material:SpatialMaterial = load("res://Entities/Particles/Mat_Bullet.tres")
var projectile:PackedScene = load("res://Entities/Particles/EnemyProjectile.tscn")
var pew:AudioStream = load("res://Assets/Sounds/Gun.ogg")

var player_sight := 0
var moving_to_sound := false
var shoot_timer := 0.0

func _custom_ready(): add_to_group("SoundAwaiter")

func noise_made(volume:float, position:Vector3):
	if player_sight > 0: return
	if !_heard_noise(volume, position, 40.0): return
	moving_to_sound = true
	_set_target(position, true)

func is_hit():
	if PlayerInfo.time_frozen: return
	_set_target(_ppos(), true)

func _ppos() -> Vector3:
	return player.global_transform.origin + Vector3(0, 2, 0)

func _custom_mind_timeout():
	if player_sight > 0:
		_set_target(_ppos(), true)
		if !_can_see_player(30.0, e.global_transform.origin):
			player_sight -= 1
	elif _does_detect_player(30.0, e.global_transform.origin):
		player_sight = 10
		moving_to_sound = false
		_set_target(_ppos(), true)
	elif !moving_to_sound:
		e.rotation_degrees.y += 22.5

func _between(amount:float, a:float, b:float) -> bool:
	return amount >= a && amount <= b

func _custom_physics_process(delta:float):
	shoot_timer -= delta
	var can_see := _can_see_player(30.0, e.global_transform.origin)
	var d := _distance_to_player()
	if _between(d, 10.0, 15.0) && player_sight > 0 && can_see:
		if shoot_timer <= 0.0:
			match PlayerInfo.difficulty:
				0: shoot_timer = 2.0
				1: shoot_timer = 0.75
				2: shoot_timer = 0.15
			var dir := _direction_to_player() + Vector3(-0.5 + 1.0 * randf(), 0, 0) if randf() < 0.4 else Vector3.ZERO
			shoot(dir)
	elif d <= 10 && player_sight > 0 && can_see:
		var dir := -_direction_to_player().normalized()
		dir.y = 0.0
		e.move_and_slide(dir * e.speed * delta, Vector3.UP)
	elif path_node < path.size():
		var dir:Vector3 = (path[path_node] - e.global_transform.origin)
		dir.y = -0.2
		if dir.length() <= 0.5:
			path_node += 1
		else:
			e.move_and_slide(dir.normalized() * e.speed * delta, Vector3.UP)
	elif moving_to_sound:
		moving_to_sound = false

func shoot(dir:Vector3):
	e.play_misc_sound(pew)
	var p:EnemyProjectile = projectile.instance()
	p.explode_on_impact = false
	p.material = material
	e.get_parent().add_child(p)
	p.global_transform.origin = e.global_transform.origin + dir.normalized() * 3.0 + Vector3(0, 1, 0)
	p.apply_impulse(Vector3.ZERO, dir * (20.0 + 20.0 * randf()))
