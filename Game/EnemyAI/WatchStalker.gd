extends EnemyAI

var player_sight := 0
var moving_to_sound := false

func _custom_ready(): add_to_group("SoundAwaiter")

func noise_made(volume:float, position:Vector3):
	if player_sight > 0: return
	if !_heard_noise(volume, position, 40.0): return
	moving_to_sound = true
	print(position)
	_set_target(position, true)


func _custom_mind_timeout():
	if player_sight > 0:
		_set_target(player.global_transform.origin, true)
		if !_can_see_player(30.0, e.global_transform.origin):
			player_sight -= 1
	elif _does_detect_player(30.0, e.global_transform.origin):
		player_sight = 6
		moving_to_sound = false
		_set_target(player.global_transform.origin, true)
	elif !moving_to_sound:
		e.rotation_degrees.y += 22.5

func _custom_physics_process(delta:float):
	if _distance_to_player() < 1.5 && player_sight > 0:
		player.take_damage()
	if path_node < path.size():
		var dir:Vector3 = (path[path_node] - e.global_transform.origin)
		dir.y = -0.2
		if dir.length() <= 0.5:
			path_node += 1
		else:
			e.move_and_slide(dir.normalized() * e.speed * delta, Vector3.UP)
	elif moving_to_sound:
		moving_to_sound = false
