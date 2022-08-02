extends EnemyAI

func _custom_mind_timeout():
	_set_target(player.global_transform.origin, true)

func _custom_physics_process(delta:float):
	if path_node < path.size():
		var dir:Vector3 = (path[path_node] - e.global_transform.origin)
		dir.y = -0.2
		if dir.length() <= 0.5:
			path_node += 1
		else:
			e.move_and_slide(dir.normalized() * e.speed * delta, Vector3.UP)
