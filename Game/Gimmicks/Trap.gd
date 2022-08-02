class_name Trap
extends Area

func _on_body_entered(body:Node):
	var player = get_tree().get_nodes_in_group("player")[0]
	if body != player: return
	get_tree().call_group("destroy_monitor", "on_destroy", name)
	get_tree().call_group("PlayerSound", "play_sound", "Trap")
	player.take_damage()
	queue_free()
