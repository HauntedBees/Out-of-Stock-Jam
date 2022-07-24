class_name Weapon
extends Control

onready var weapon_textures := [$Weapon/Pistol, $Weapon/Hammer]
onready var blast := $Blast

var weapon_info := {
	"Hammer": {
		"animation": "Melee",
		"cooldown": 0.3,
		"pushback": 300.0,
		"range": 5.0
	},
	"Pistol": {
		"blast_position": Vector2(-652, -426),
		"animation": "Shoot",
		"cooldown": 0.5,
		"pushback": 100.0,
		"range": 30.0
	}
}

export(String) var attack_animation := "Shoot"
export(float) var cooldown := 0.5
export(float) var attack_range := 50.0
export(float) var pushback := 2.0
export(int) var ammo := 0

onready var camera:Camera = get_viewport().get_camera()
onready var anim:AnimationPlayer = $AnimationPlayer

var current_weapon := ""
var cooldown_remaining := 0.0

func set_weapon(weapon:String):
	if current_weapon == weapon: return
	var prev_weapon := current_weapon
	current_weapon = weapon
	var w:Dictionary = weapon_info[weapon]
	cooldown = w["cooldown"]
	attack_animation = w["animation"]
	pushback = w["pushback"]
	attack_range = w["range"]
	# TODO: ammo
	if w.has("blast_position"):
		blast.margin_left = w["blast_position"].x
		blast.margin_bottom = w["blast_position"].y
	if prev_weapon == "":
		for wt in weapon_textures:
			wt.visible = wt.name == weapon
	else: _switch_weapon()
		
func _switch_weapon():
	cooldown_remaining = 99
	anim.play("MoveDown")
	yield(anim, "animation_finished")
	for wt in weapon_textures:
		wt.visible = wt.name == current_weapon
	anim.play("MoveUp")
	yield(anim, "animation_finished")
	cooldown_remaining = 0

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
