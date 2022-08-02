extends EnemyAI

var toxicloud_scene:PackedScene = preload("res://Entities/Particles/Toxicloud.tscn")
var timer := 5.0

func _custom_process(delta:float):
	timer -= delta
	if timer <= 0.0:
		timer = 3.0 + 3.0 * randf()
		var cloud:Spatial = toxicloud_scene.instance()
		cloud.global_transform.origin = e.global_transform.origin
		e.get_parent().add_child(cloud)
