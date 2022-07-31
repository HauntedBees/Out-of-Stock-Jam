extends Area

var force := 0.0
var damage := 0.0

func _on_animation_finished(_anim_name:String): queue_free()

func _on_body_entered(body:Spatial):
	var distance_vec:Vector3 = body.global_transform.origin - global_transform.origin
	var distance := max(1.0, distance_vec.length() - 1.5)
	var direction := distance_vec.normalized()
	var calc_damage := damage / distance
	if body is Entity:
		var be:Entity = body
		if be is Interactable:
			calc_damage *= 10.0
		be.take_hit(direction, force, calc_damage)
	elif body is LockedDoor:
		if calc_damage > 150 && distance < 2.0:
			body.queue_free()
	elif body is Player:
		var pe:Player = body
		pe.velocity += direction * force * 0.1
		print("TODO: this whole thing")
	elif body is Lamp:
		var le:Lamp = body
		le.take_hit(direction, force, calc_damage)
