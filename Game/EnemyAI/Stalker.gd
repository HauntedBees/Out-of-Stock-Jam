extends EnemyAI

var music:AudioStream = load("res://Assets/Music/Stalker.ogg")
var audio_player:AudioStreamPlayer3D
func _custom_ready():
	audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = music
	audio_player.autoplay = true
	audio_player.unit_size = 5
	e.add_child(audio_player)

func pre_death():
	audio_player.stop()
	audio_player.queue_free()

func _custom_mind_timeout():
	_set_target(player.global_transform.origin, true)

func _custom_physics_process(delta:float):
	if _distance_to_player() < 1.5:
		player.take_damage()
	if path_node < path.size():
		var dir:Vector3 = (path[path_node] - e.global_transform.origin)
		dir.y = -0.2
		if dir.length() <= 0.5:
			path_node += 1
		else:
			e.move_and_slide(dir.normalized() * e.speed * delta, Vector3.UP)
