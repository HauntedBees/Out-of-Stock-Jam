extends EnemyAI

var woosh:AudioStream = load("res://Assets/Sounds/Woosh.ogg")
var metal:AudioStream = load("res://Assets/Sounds/Metal.ogg")
var material:SpatialMaterial = load("res://Entities/Particles/Mat_Mushroom.tres")
var projectile:PackedScene = load("res://Entities/Particles/EnemyProjectile.tscn")
var sewer_scene:PackedScene = load("res://Entities/Particles/Sewer.tscn")
var sewer:Spatial
var is_hidden := false
var hide_timer := 0.0

func _custom_ready():
	sewer = sewer_scene.instance()
	e.add_child(sewer)
	sewer.global_transform.origin = e.global_transform.origin + Vector3(0, 2.1, 0)
	sewer.visible = false
	hide()

func _custom_process(delta:float):
	if hide_timer > 0.0:
		hide_timer -= delta

func _custom_mind_timeout():
	var origin:Vector3 = e.global_transform.origin
	if is_hidden: origin.y += 2.0
	var can_see_player := _can_see_player(20.0, origin)
	if is_hidden:
		if hide_timer <= 0.0 && (can_see_player || randf() < 0.2):
			reveal()
	else:
		if can_see_player:
			shoot(_direction_to_player())
		elif randf() < 0.2:
			hide()

func is_hit():
	extra_timer.start(0.2)
	yield(extra_timer, "timeout")
	hide()
	hide_timer = 1.0 + 5.0 * randf()

func shoot(dir:Vector3):
	e.play_misc_sound(woosh)
	var p:EnemyProjectile = projectile.instance()
	p.explode_on_impact = false
	p.material = material
	e.get_parent().add_child(p)
	p.global_transform.origin = e.global_transform.origin + dir * 1.0 + Vector3(0, 1, 0)
	p.apply_impulse(Vector3.ZERO, dir * (10.0 + 10.0 * randf()))

func hide():
	if is_hidden: return
	e.play_misc_sound(metal)
	e.transform.origin.y -= 3.0
	sewer.visible = true
	is_hidden = true

func reveal():
	if !is_hidden: return
	e.play_misc_sound(metal)
	e.transform.origin.y += 3.0
	sewer.visible = false
	is_hidden = false
