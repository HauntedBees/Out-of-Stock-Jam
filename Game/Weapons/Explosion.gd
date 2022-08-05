extends Area

var force := 0.0
var damage := 0.0

onready var collider:CollisionShape = $CollisionShape

var anim_done := false
var sound_done := false
var hurt_player := false

func _on_animation_finished(_anim_name:String):
	anim_done = true
	collider.disabled = true
	if sound_done: queue_free()

func _on_AudioStreamPlayer3D_finished():
	sound_done = true
	if anim_done: queue_free()

func _on_body_entered(body:Spatial):
	var distance_vec:Vector3 = body.global_transform.origin - global_transform.origin
	var distance := max(1.0, distance_vec.length() - 1.5)
	var direction := distance_vec.normalized()
	var calc_damage := max(1.0, damage / distance)
	if body is Entity:
		var be:Entity = body
		if be is Interactable:
			calc_damage *= 10.0
		be.take_hit(direction, force, calc_damage)
	elif body is LockedDoor:
		if calc_damage > 150 && distance < 2.0:
			get_tree().call_group("destroy_monitor", "on_destroy", body.name)
			body.queue_free()
	elif body is Player:
		var pe:Player = body
		pe.velocity += direction * min(force, 10.0) * 0.1
		if hurt_player:
			pe.take_damage()
	elif body is Lamp:
		var le:Lamp = body
		le.take_hit(direction, force, calc_damage)
	elif body is Grate:
		get_tree().call_group("destroy_monitor", "on_destroy", body.name)
		body.queue_free()
	elif body is Eggsman:
		var be:Eggsman = body
		be.take_hit(direction, force, calc_damage)

func _on_area_entered(area:Area):
	if area is Trap:
		get_tree().call_group("destroy_monitor", "on_destroy", area.name)
		area.queue_free()

