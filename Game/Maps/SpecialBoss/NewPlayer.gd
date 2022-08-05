class_name NewPlayer
extends KinematicBody

var BEAM_SCENE := load("res://Maps/SpecialBoss/Beam.tscn")

const GRAVITY = -40.0
const MAX_SPEED := 30.0
const JUMP_SPEED := 24.0
const ACCELERATION := 4.5
const DECELERATION := 16.0

#onready var pause_screen:PauseScreen = $PauseScreen
onready var ring_count:Label = $"../HUD/LeftHUD/Rings/HealthAmount"

onready var vision:Spatial = $Vision
onready var camera:Camera = $Vision/Camera
onready var crosshair:TextureRect = $"../HUD/Crosshair"

var velocity := Vector3()
var direction := Vector3()
var shoot_delay := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta:float):
	if PlayerInfo.paused: return

func _physics_process(delta:float):
	if PlayerInfo.paused: return
	shoot_delay -= delta
	_handle_input()
	_handle_movement(delta)
	_handle_cursor()
	if Input.is_action_pressed("action") && (shoot_delay <= 0 || GASInput.is_action_just_pressed("action")):
		shoot_delay = 0.1
		var beam:Projectile = BEAM_SCENE.instance()
		fire_projectile(beam)

func _handle_cursor():
	var body = PlayerInfo.get_collision(100.0)
	if body != null:
		crosshair.modulate.a = 1
	else: crosshair.modulate.a = 0.25

func _handle_input():
	var movement := Vector2(0, 1)
	if Input.is_action_pressed("strafe_left"):
		movement.x -= 1
	elif Input.is_action_pressed("strafe_right"):
		movement.x += 1
	movement = movement.normalized()
	
	var camera_basis := camera.get_global_transform().basis
	direction = Vector3()
	direction += -camera_basis.z * movement.y
	direction += camera_basis.x * movement.x

func _handle_movement(delta:float):
	direction.y = 0
	direction = direction.normalized()
	if Input.is_action_pressed("move_forward"):
		direction.z -= 0.5
	elif Input.is_action_pressed("move_backward"):
		direction.z += 0.5
	var speed_mult := 1.25
	velocity.y += delta * GRAVITY
	var vel_xz := Vector3(velocity.x, 0, velocity.z)
	var acceleration := speed_mult * (ACCELERATION if direction.dot(vel_xz) > 0 else DECELERATION)
	vel_xz = vel_xz.linear_interpolate(direction * speed_mult * MAX_SPEED, acceleration * delta)
	velocity = move_and_slide(Vector3(vel_xz.x, velocity.y, vel_xz.z), Vector3.UP)

func _input(event:InputEvent):
	var pause_pressed := GASInput.is_action_just_pressed("pause")
	if PlayerInfo.paused:
		if pause_pressed:
			pass#pause_screen.close()
		return
	elif pause_pressed:
		pass#pause_screen.open()
		return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # aiming
		if event is InputEventMouseMotion: return _handle_camera_movement(event)
	if event.is_action_pressed("jump") && GASInput.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED
		get_tree().call_group("PlayerSound", "play_sound", "Jump")

func _handle_camera_movement(event:InputEventMouseMotion):
	vision.rotate_x(deg2rad(event.relative.y * -PlayerInfo.mouse_sensitivity))
	rotate_y(deg2rad(event.relative.x * -PlayerInfo.mouse_sensitivity))
	var camera_rotation := vision.rotation_degrees
	camera_rotation.x = clamp(camera_rotation.x, -85, 85)
	vision.rotation_degrees = camera_rotation

func add_rings(amount:int):
	PlayerInfo.rings += amount
	ring_count.text = String(PlayerInfo.rings)

func fire_projectile(p:Projectile):
	p.launcher = self
	get_parent().add_child(p)
	var launch_source := camera.project_ray_normal(get_viewport().size * 0.6)
	var launch_direction := camera.project_ray_normal(get_viewport().size * 0.5)
	p.global_transform.origin = global_transform.origin + launch_source * 10.0 + Vector3(0, 0.5, 0)
	p.apply_impulse(Vector3.ZERO, launch_direction * p.launch_force)

func lose_ring(amount := 0):
	if PlayerInfo.paused: return
	PlayerInfo.rings = max(PlayerInfo.rings - amount, 0)
	ring_count.text = String(PlayerInfo.rings)
	get_tree().call_group("PlayerSound", "play_sound", "Hurt")
	if PlayerInfo.rings == 0:
		print("FUCK")
		#_game_over()

#func _game_over():
#	if game_over.visible: return
#	get_tree().call_group("PlayerSound", "play_sound", "GameOver", "Ring")
#	full_hud.visible = false
#	game_over.visible = true
#	game_over_anim.play("Die")
#	PlayerInfo.paused = true
#	game_over_timer.start(3.5)
#	yield(game_over_timer, "timeout")
#	if PlayerInfo.last_save_point == "":
#		pause_screen.open(true)
#	else:
#		var point_info:PoolStringArray = PlayerInfo.last_save_point.split("/")
#		PlayerInfo.last_save_point = ""
#		PlayerInfo.paused = false
#		PlayerInfo.current_map = point_info[0]
#		PlayerInfo.return_timeout = 2.0
#		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Map", "save_to_dictionary")
#		SceneSwitcher.switch_scene("res://Maps/%s.tscn" % point_info[0], false)
#		SceneSwitcher.memory = {
#			"source": "MAP",
#			"destination": point_info[1]
#		}

func _on_Timer_timeout():
	lose_ring(1)
