extends Spatial

onready var ring_scene:PackedScene = preload("res://Special/Ring.tscn")
onready var spike_scene:PackedScene = preload("res://Special/Spike.tscn")
onready var hazard_scene:PackedScene = preload("res://Special/Hazard.tscn")
onready var complete_scene:PackedScene = preload("res://Special/CompleteArea.tscn")

const WAIT_TIME := 2.0

const ROTATE_TIME := 0.1
const MOVE_SPEED := 7.0
const FIRST_START_Z := -10.0
const START_Z := -5.0

onready var stage_info:SpecialStages = $SpecialStages
onready var player:Spatial = $Player
onready var player_collider:RigidBody = $Player/PlayerCollider
onready var player_anim:AnimationPlayer = $Player/PlayerAnimation
onready var tween:Tween = $Tween
onready var cone_zone:MeshInstance = $ConeZone
onready var cone_container:Spatial = $ConeContainer
onready var ring_label:Label = $HUD/Scoreboard/HBoxContainer/VBoxContainer/RingCount
onready var emerald:Emerald = $Emerald

onready var scoreboard:TextureRect = $HUD/Scoreboard
onready var info_popup:TextureRect = $HUD/Popup
onready var info_message:Label = $HUD/Popup/Label
onready var good_job:TextureRect = $HUD/Popup/Good
onready var bad_job:TextureRect = $HUD/Popup/Bad
onready var timer:Timer = $MiscTimer

var item_type := "Ring"
var in_rotate := false
var is_hurt := false
var stage_speed := 0.1

var stage_num := 0
var stage_part := 0
var rings := 0

# R has a length of 9
var stage:SpecialStageLevelInfo

func _ready():
	($ConeAnimation as AnimationPlayer).playback_speed = stage_speed
	tween.interpolate_property($Camera, "rotation_degrees:x", -20, -15, 2.5)
	tween.interpolate_property($Camera, "translation", 
		Vector3(0, 2.6, 45.0),
		Vector3(0, 0, 38.0),
		2.5
	)
	emerald.set_number(stage_num)
	tween.start()
	_get_stage()

func _get_stage(shrink_scoreboard := false):
	is_hurt = false
	stage = stage_info.get_stage(stage_num, stage_part)
	_show_amount_message()
	timer.start(WAIT_TIME)
	yield(timer, "timeout")
	_set_stage()
	if shrink_scoreboard:
		tween.interpolate_property(scoreboard, "rect_scale", Vector2(1.35, 1.35), Vector2(1, 1), 1.0)
		tween.start()
	timer.start(WAIT_TIME)
	yield(timer, "timeout")
	info_popup.visible = false
func _set_stage():
	cone_container.transform.origin.z = 0.0
	for i in stage.environment:
		var s:Array = i.split(":")
		var type:PackedScene
		var side := int(s[0][1])
		var pos:Vector2 = str2var("Vector2(%s)" % s[1])
		var type_text:String = s[0][0]
		match type_text.to_lower():
			"c": type = complete_scene
			"r": type = ring_scene
			"s": type = spike_scene
			"h": type = hazard_scene
		if type_text == "C" || type_text == type_text.to_lower():
			_create_object(type, side, pos)
		else:
			for d in 6:
				_create_object(type, side, pos - Vector2(0, 1.5 * d))
func _create_object(type:PackedScene, side:int, position:Vector2):
	var obj:Area = type.instance()
	obj.connect("body_entered", self, "_on_object_entered", [obj])
	var start := FIRST_START_Z if stage_part == 0 else START_Z
	obj.transform.origin = Vector3(3.16, start - position.y, position.x * 1.2).rotated(Vector3.UP, side * PI / 3.0)
	obj.rotation_degrees.z = 90
	obj.rotation_degrees.y = 60 * side
	cone_container.add_child(obj)

func _show_amount_message(): _show_message("Collect %s Rings" % stage.ring_requirement)
func _show_message(text:String, good := false, bad := false):
	info_popup.visible = true
	info_message.text = text
	good_job.visible = good
	bad_job.visible = bad

func _physics_process(delta:float):
	_handle_player_movement(delta)
	cone_container.transform.origin.z += delta * 100.0 * stage_speed

func _handle_player_movement(delta:float):
	if in_rotate: return
	var dx := 0
	if Input.is_action_pressed("strafe_left"):
		dx = -1
	elif Input.is_action_pressed("strafe_right"):
		dx = 1
	player.transform.origin.x += dx * MOVE_SPEED * delta
	if abs(player.transform.origin.x) > 2.1:
		var rot_amount := -PI / 3.0 * sign(player.transform.origin.x)
		var current_basis := cone_zone.transform.basis
		var new_basis := current_basis.rotated(Vector3(0, 0, 1), rot_amount)
		var container_basis := cone_container.transform.basis
		var new_container_basis := container_basis.rotated(Vector3(0, 0, 1), rot_amount)
		tween.interpolate_property(cone_zone, "transform:basis", current_basis, new_basis, ROTATE_TIME)
		tween.interpolate_property(cone_container, "transform:basis", container_basis, new_container_basis, ROTATE_TIME)
		tween.interpolate_property(player, "translation:x", player.transform.origin.x, -player.transform.origin.x * 0.8, ROTATE_TIME)
		in_rotate = true
		tween.start()
		yield(tween, "tween_completed")
		in_rotate = false

func _on_object_entered(body:Node, me:SpecialStageItem):
	if body != player_collider: return
	match me.item_type:
		"ring":
			rings += 1
			ring_label.text = String(rings)
			me.queue_free()
		"spike":
			if is_hurt: return
			rings = int(max(rings - 10, 0))
			ring_label.text = String(rings)
			is_hurt = true
			player_anim.play("Hurt")
			yield(player_anim, "animation_finished")
			is_hurt = false
			player_anim.play("Run")
		"complete":
			if is_hurt: return
			is_hurt = true
			tween.interpolate_property(scoreboard, "rect_scale", Vector2(1, 1), Vector2(1.35, 1.35), 1.0)
			tween.start()
			yield(tween, "tween_completed")
			if rings >= stage.ring_requirement:
				_show_message("Good Job!", true)
				_advance_to_next_part()
			else:
				_show_message("Too Bad...", false, true)
				_exit_special_stage()
		"hazard":
			if is_hurt: return
			is_hurt = true
			player_anim.play("Fall")
			_show_message("You Fell...!", false, true)
			yield(player_anim, "animation_finished")
			player.visible = false
			_exit_special_stage()

func _advance_to_next_part():
	for i in cone_container.get_children():
		cone_container.remove_child(i)
	timer.start(WAIT_TIME * 1.5)
	yield(timer, "timeout")
	if stage.is_last:
		info_popup.visible = false
		tween.interpolate_property(scoreboard, "rect_scale", Vector2(1.35, 1.35), Vector2(1, 1), 1.0)
		tween.interpolate_property(emerald, "translation:z", -42.0, 32.0, 5.0)
		tween.start()
		yield(tween, "tween_all_completed")
		timer.start(2.0)
		yield(timer, "timeout")
		_show_message("You got a Mayhem Ruby !", true)
		print("TODO: this")
	else:
		stage_part += 1
		_get_stage(true)

func _exit_special_stage():
	print("TODO: FAILURE")
