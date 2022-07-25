extends KinematicBody

const GRAVITY = -4.8
const MAX_SPEED := 20.0
const JUMP_SPEED := 18.0
const ACCELERATION := 4.5
const DECELERATION := 16.0

var velocity := Vector3()
var direction := Vector3()

onready var player_stats := $HUD/LeftHUD
onready var inventory := $HUD/Inventory
onready var weapon:Weapon = $HUD/Weapon
onready var vision:Spatial = $Vision
onready var camera:Camera = $Vision/Camera
onready var crosshair:TextureRect = $HUD/Crosshair
var MOUSE_SENSITIVITY := -0.15

var in_inventory := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapon.set_weapon(PlayerInfo.current_weapon.type)

func _physics_process(delta:float):
	if weapon != null && PlayerInfo.current_weapon != PlayerInfo.UNARMED: weapon.try_attack(delta)
	_handle_input()
	_handle_movement(delta)
	_handle_cursor()

func _handle_cursor():
	var body := PlayerInfo.get_collision(100.0)
	if body != null:
		body.show_highlight()
		var dist := (body.transform.origin - transform.origin).length()
		if dist <= weapon.attack_range:
			crosshair.modulate.a = 1
			return
	else: crosshair.modulate.a = 0.25

func _handle_input():
	var movement := Vector2()
	if Input.is_action_pressed("move_forward"):
		movement.y += 1
	elif Input.is_action_pressed("move_backward"):
		movement.y -= 1
	if Input.is_action_pressed("strafe_left"):
		movement.x -= 1
	elif Input.is_action_pressed("strafe_right"):
		movement.x += 1
	movement = movement.normalized()
	
	var camera_basis := camera.get_global_transform().basis
	direction = Vector3()
	direction += -camera_basis.z * movement.y
	direction += camera_basis.x * movement.x
	# TODO: jumping
	# TODO: free cursor

func _handle_movement(delta:float):
	direction.y = 0
	direction = direction.normalized()
	velocity.y += delta * GRAVITY
	var vel_xz := Vector3(velocity.x, 0, velocity.z)
	var acceleration := ACCELERATION if direction.dot(vel_xz) > 0 else DECELERATION
	vel_xz = vel_xz.linear_interpolate(direction * MAX_SPEED, acceleration * delta)
	velocity = move_and_slide(Vector3(vel_xz.x, velocity.y, vel_xz.z), Vector3.UP)


func _input(event:InputEvent):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # aiming
		if event is InputEventMouseMotion: return _handle_camera_movement(event)
	if event.is_action_pressed("toggle_inventory"):
		_toggle_inventory(!in_inventory)
	_handle_equip_switch(event)
	_handle_use_item(event)

func _handle_camera_movement(event:InputEventMouseMotion):
	vision.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
	rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY))
	var camera_rotation := vision.rotation_degrees
	camera_rotation.x = clamp(camera_rotation.x, -50, 50)
	vision.rotation_degrees = camera_rotation

func _handle_use_item(event:InputEvent):
	if !event.is_action_pressed("use"): return
	var body := PlayerInfo.get_collision(2.5)
	if body == null || body is Enemy: return
	inventory.search_contents = body.contents
	_toggle_inventory(true, true)

func _toggle_inventory(new_position:bool, search := false):
	in_inventory = new_position
	inventory.is_search = search
	if in_inventory: inventory.refresh_items()
	inventory.visible = in_inventory
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if in_inventory else Input.MOUSE_MODE_CAPTURED)

func _handle_equip_switch(event:InputEvent):
	for i in range(0, 10):
		if !event.is_action_pressed("equip%s" % i): continue
		var item:Item = inventory.get_equipment(i)
		if item == null: return
		PlayerInfo.current_weapon = item
		get_tree().call_group("equip_monitor", "update_weapon")

func _on_close_item_search(): _toggle_inventory(false)
