extends Area

func _on_body_entered(body:Node):
	if !(body is Player): return
	get_tree().call_group("player", "add_rings", 1)
	queue_free()
