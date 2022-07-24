class_name Weapon
extends Control

export(String) var attack_animation := "Shoot"
export(float) var cooldown := 0.5
export(float) var attack_range := 50.0
export(float) var pushback := 2.0
export(int) var ammo := 0

onready var camera:Camera = get_viewport().get_camera()
onready var anim:AnimationPlayer = $AnimationPlayer

var cooldown_remaining := 0.0

func try_attack(delta:float):
	cooldown_remaining -= delta
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED || !Input.is_action_just_pressed("action"): return
	if cooldown_remaining > 0.0: return
	cooldown_remaining = cooldown
	anim.play(attack_animation)
	var center := get_viewport().size / 2
	var from := camera.project_ray_origin(center)
	var to := from + camera.project_ray_normal(center) * attack_range
	var res := get_viewport().world.direct_space_state.intersect_ray(from, to)
	if !res.has("collider"): return
	var body: PhysicsBody = res["collider"]
	if body is Enemy:
		(body as Enemy).take_hit(camera.project_ray_normal(center), pushback, 69.0)
