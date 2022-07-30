class_name Player
extends KinematicBody

const GRAVITY = -9.8
const MAX_SPEED := 20.0
const JUMP_SPEED := 12.0
const ACCELERATION := 4.5
const DECELERATION := 16.0

var velocity := Vector3()
var direction := Vector3()

onready var head:CollisionShape = $Head
onready var player_stats:PlayerStatsHUD = $HUD/LeftHUD
onready var inventory:Inventory = $HUD/Inventory
onready var weapon:Weapon = $HUD/Weapon
onready var vision:Spatial = $Vision
onready var camera:Camera = $Vision/Camera
onready var crosshair:TextureRect = $HUD/Crosshair
var MOUSE_SENSITIVITY := -0.15
var search_target:Entity

var in_inventory := false
var is_crouched := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapon.set_weapon(PlayerInfo.current_weapon.type)

func _physics_process(delta:float):
	if PlayerInfo.in_cutscene: return
	if weapon != null && PlayerInfo.current_weapon != PlayerInfo.UNARMED: weapon.try_attack(delta)
	_handle_input()
	_handle_movement(delta)
	_handle_cursor()
	_handle_move_too_far_from_target()

func _handle_move_too_far_from_target():
	if search_target == null: return
	if search_target.global_transform.origin.distance_to(global_transform.origin) > 5.0:
		_on_close_item_search()

func _handle_cursor():
	var body:Spatial = PlayerInfo.get_collision(100.0)
	if body != null:
		body.show_highlight()
		var dist := (body.transform.origin - transform.origin).length()
		if dist <= weapon.attack_range:
			crosshair.modulate.a = 1
			return
	else: crosshair.modulate.a = 0.25

var crouch_toggle := false # TODO: move to settings. also, create settings.
func _handle_input():
	if Input.is_action_just_pressed("reload"):
		weapon.reload()
	_handle_movement_input()
	
	if Input.is_action_just_pressed("crouch"):
		_handle_crouch(!is_crouched if crouch_toggle else true)
	elif !crouch_toggle && Input.is_action_just_released("crouch"):
		_handle_crouch(false)
		
	# TODO: jumping
	# TODO: free cursor

func _handle_crouch(is_crouch:bool):
	is_crouched = is_crouch
	head.disabled = is_crouched
	camera.transform.origin.y = -0.35 if is_crouch else 0.55

func _handle_movement_input():
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
	if event.is_action_pressed("jump") && is_on_floor():
		velocity.y = JUMP_SPEED
	elif Input.is_action_just_pressed("toggle_inventory"):
		_toggle_inventory(!in_inventory)
	_handle_equip_switch()
	_handle_use_item(event)

func _handle_camera_movement(event:InputEventMouseMotion):
	vision.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
	rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY))
	var camera_rotation := vision.rotation_degrees
	camera_rotation.x = clamp(camera_rotation.x, -85, 85)
	vision.rotation_degrees = camera_rotation

func _handle_use_item(event:InputEvent):
	if !event.is_action_pressed("use"): return
	if in_inventory && search_target != null:
		_on_close_item_search()
		return
	var body:Entity = PlayerInfo.get_collision(2.5, true)
	if body == null || (body is Enemy && !body.is_dead): return
	search_target = body
	inventory.search_contents = body.contents
	_toggle_inventory(true, true)

func _toggle_inventory(new_position:bool, search := false):
	in_inventory = new_position
	if !in_inventory && search_target != null:
		_on_close_item_search()
		return
	inventory.is_search = search
	if in_inventory: inventory.refresh_items()
	inventory.visible = in_inventory
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if in_inventory else Input.MOUSE_MODE_CAPTURED)

func _handle_equip_switch():
	for i in range(0, 10):
		if !Input.is_action_just_pressed("equip%s" % i): continue
		if Input.is_action_pressed("equip_modifier"):
			var mayhem := ""
			match i:
				1: mayhem = "Spindash"
				2: mayhem = "Magnet"
			if mayhem == "": return
			if PlayerInfo.get_mayhem_level(mayhem) == 0: return
			if PlayerInfo.current_mayhem == mayhem:
				PlayerInfo.current_mayhem = ""
			else:
				PlayerInfo.current_mayhem = mayhem
			get_tree().call_group("equip_monitor", "update_mayhem")
		else:
			var item:Item = inventory.get_equipment(i)
			if item == null: return
			if PlayerInfo.current_weapon == item:
				PlayerInfo.current_weapon = PlayerInfo.UNARMED
			else:
				PlayerInfo.current_weapon = item
			get_tree().call_group("equip_monitor", "update_weapon")

func _on_close_item_search():
	if search_target != null: search_target.refresh_label()
	search_target = null
	_toggle_inventory(false)

func add_rings(amount:int):
	PlayerInfo.rings += amount
	player_stats.update_rings()
