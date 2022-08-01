extends Area

const IS_SPECIAL_POST := true # can't just do class_name SpecialPost because ayyy cyclical references lmao

onready var warning:TextureRect = $RingWarning
onready var ruby:MeshInstance = $Ruby
onready var rmat:SpatialMaterial = ruby.get_active_material(0)

var cleared := false

func _ready(): set_color()

func set_color():
	if cleared: return
	match PlayerInfo.mayhem_rubies:
		0: rmat.albedo_color = Color(0.0, 0.3, 0.65)
		1: rmat.albedo_color = Color(0.4, 0.0, 0.65)
		2: rmat.albedo_color = Color(0.65, 0.0, 0.0)
		3: rmat.albedo_color = Color(0.96, 0.0, 1.0)
		4: rmat.albedo_color = Color(1.0, 1.0, 0.0)
		5: rmat.albedo_color = Color(0.3, 0.65, 0.0)
		6: rmat.albedo_color = Color(0.77, 0.77, 0.77)

func rubies_changed(): set_color()

func on_return(beat_stage:bool):
	if !beat_stage: return
	cleared = true
	ruby.visible = false
	PlayerInfo.mayhem_rubies += 1
	get_tree().call_group("RubyWatcher", "rubies_changed")

func _on_body_entered(body:Node):
	if cleared || !(body is Player): return
	if PlayerInfo.return_timeout > 0.0: return
	if PlayerInfo.rings < 50:
		warning.visible = true
	else:
		SceneSwitcher.switch_scene("res://Special/SpecialStage.tscn", true, self)
		get_tree().call_group("player", "add_rings", -50)

func _on_body_exited(body:Node):
	if cleared || !(body is Player): return
	warning.visible = false

func clear():
	cleared = true
	warning.visible = false
	ruby.visible = false
