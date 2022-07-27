class_name Entity
extends KinematicBody

onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
var main_mesh:MeshInstance
var name_mesh:MeshInstance
export(String) var type := "Roboticizer"

var health := 100.0
var is_dead := false

var forced_velocity := Vector3.ZERO
var forced_velocity_timer := 0.0

var highlight_timer := 0.0

var contents := [
	Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2(0, 0), {"amount": 95})
]

func show_highlight():
	highlight_timer = 0.1
	main_mesh.get_active_material(0).next_pass = highlight
	name_mesh.visible = true

func _process(delta:float):
	if highlight_timer > 0:
		highlight_timer -= delta
		if highlight_timer < 0: hide_highlight()

func hide_highlight():
	main_mesh.get_active_material(0).next_pass = null
	name_mesh.visible = false

func take_hit(direction:Vector3, force:float, damage:float):
	if is_dead: return
	if abs(force) > 0.05:
		forced_velocity = direction * force
		forced_velocity.y = 0.0
		forced_velocity_timer = 0.2
	health -= damage
	if health <= 0:
		is_dead = true
		_die()
	else: 
		_hit_animation()

func _hit_animation(): return
func _die(): return

func _physics_process(delta:float):
	if forced_velocity_timer >= 0.0:
		move_and_slide(forced_velocity * delta, Vector3.UP)
		forced_velocity_timer -= delta

func refresh_label(): return
