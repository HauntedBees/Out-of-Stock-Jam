extends Spatial

onready var water:MeshInstance = $MeshInstance

func _on_body_entered(body:Node):
	if !(body is Player): return
	var player:Player = body
	player.get_in_water(water.global_transform.origin.y)

func _on_body_exited(body:Node):
	if !(body is Player): return
	var player:Player = body
	player.in_water = false
	player.needs_safe_oxygen = false
