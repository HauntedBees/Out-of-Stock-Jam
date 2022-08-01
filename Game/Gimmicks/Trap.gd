class_name Trap
extends Area

func _on_body_entered(body:Node):
	var player = get_tree().get_nodes_in_group("player")[0]
	if body != player: return
	player.take_damage()
