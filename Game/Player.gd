class_name Player
extends KinematicBody

var RING_SCENE := load("res://Entities/Ring.tscn")

const GRAVITY = -9.8
const MAX_SPEED := 20.0
const JUMP_SPEED := 12.0
const ACCELERATION := 4.5
const DECELERATION := 16.0

onready var drown:Control = $HUD/DrownCountdown
onready var panic:AudioStreamPlayer = $PlayerSoundBank/PanicAtTheShitshow
onready var full_hud:Control = $HUD
onready var game_over:Control = $Dead
onready var game_over_timer:Timer = $Dead/Timer
onready var game_over_anim:AnimationPlayer = $Dead/AnimationPlayer
onready var ouchie:TextureRect = $HUD/Ouchie
onready var pause_screen:PauseScreen = $PauseScreen
onready var magnet_area:Area = $Magnet
onready var magnet_area_shape:CollisionShape = $Magnet/CollisionShape
onready var spindash_area_shape:CollisionShape = $Spindash/CollisionShape
onready var mayhem_screen:Control = $MayhemScreen

onready var water_overlay:TextureRect = $Underwater
onready var head:CollisionShape = $Head
onready var player_stats:PlayerStatsHUD = $HUD/LeftHUD
onready var inventory:Inventory = $HUD/Inventory
onready var weapon:Weapon = $HUD/Weapon
onready var vision:Spatial = $Vision
onready var camera:Camera = $Vision/Camera
onready var crosshair:TextureRect = $HUD/Crosshair
onready var hacking_terminal:HackingTerminal = $HackingTerminal

# Saved
var velocity := Vector3()
var direction := Vector3()
var is_crouched := false
var in_water := false
var water_y := 0.0
var needs_safe_oxygen := false
var safe_oxygen_level := 0.0

# Unsaved
var in_terminal := false
var in_inventory := false
var search_target:Entity
var hack_target:SecurityControl
var equip_toggled := false
var invincible_time := 0.0
var bonus_force := Vector3.ZERO
var bonus_force_timer := 0.0

var active_mayhem := 0.0
var mayhem_targets := []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapon.set_weapon(PlayerInfo.current_weapon.type)
	update_environment()

func _process(delta:float):
	if PlayerInfo.paused: return
	if PlayerInfo.return_timeout > 0.0:
		PlayerInfo.return_timeout -= delta
	if invincible_time > 0.0:
		invincible_time -= delta
		if invincible_time <= 0.0:
			ouchie.visible = false
	toggle_water()
	handle_safe_oxygen(delta)

func handle_safe_oxygen(delta:float):
	if !needs_safe_oxygen: return
	var old_safe_oxygen := safe_oxygen_level
	safe_oxygen_level -= delta
	if old_safe_oxygen >= 10.0 && safe_oxygen_level < 10.0:
		panic.play()
		drown.start_timer()
	elif safe_oxygen_level <= 0.0:
		_game_over()

func toggle_water():
	if in_water:
		if head.global_transform.origin.y <= water_y:
			if !water_overlay.visible:
				_water_submerge()
				get_tree().call_group("PlayerSound", "play_sound", "EnterWater")
			water_overlay.visible = true
			return
	if water_overlay.visible:
		_water_exit()
		get_tree().call_group("PlayerSound", "play_sound", "LeaveWater")
	water_overlay.visible = false

func _water_submerge():
	needs_safe_oxygen = true
	match PlayerInfo.get_mayhem_level("Swim"):
		0, 1: safe_oxygen_level = 20.0
		2: safe_oxygen_level = 30.0
		3: safe_oxygen_level = 60.0
	if PlayerInfo.difficulty == 0:
		safe_oxygen_level *= 2.0

func _water_exit():
	needs_safe_oxygen = false
	drown.visible = false
	panic.stop()

func _physics_process(delta:float):
	if PlayerInfo.paused || in_terminal || PlayerInfo.in_cutscene: return
	if weapon != null: weapon.try_attack(delta)
	if active_mayhem > 0:
		active_mayhem -= delta
		if active_mayhem <= 0:
			match PlayerInfo.current_mayhem:
				"Magnet": magnet_area_shape.disabled = true
				"Spindash": spindash_area_shape.disabled = true
				"Mayhem-Modulate": PlayerInfo.time_frozen = false
				"Cloak":
					get_tree().call_group("PlayerSound", "play_sound", "Uncloak")
					PlayerInfo.invisible = false
		else:
			match PlayerInfo.current_mayhem:
				"Magnet": _mayhem_magnet()
				"Spindash":
					for m in mayhem_targets:
						var me:Entity = m
						me.take_hit(Vector3.ZERO, 0.0, 3.0 * PlayerInfo.get_mayhem_level("Spindash"))
	_handle_input()
	_handle_movement(delta)
	_handle_cursor()
	_handle_move_too_far_from_target()

func _handle_move_too_far_from_target():
	if search_target == null: return
	if search_target.global_transform.origin.distance_to(global_transform.origin) > 5.0:
		_on_close_item_search()

func _handle_cursor():
	var body = PlayerInfo.get_collision(100.0)
	if body != null && !(body is PowerSwitch):
		body.show_highlight()
		var dist:float = (body.transform.origin - transform.origin).length()
		if dist <= weapon.attack_range:
			crosshair.modulate.a = 1
			return
	else: crosshair.modulate.a = 0.25

func _handle_input():
	if GASInput.is_action_just_pressed("reload"):
		weapon.reload()
	_handle_movement_input()
	if GASInput.is_action_just_pressed("crouch"):
		_handle_crouch(!is_crouched if PlayerInfo.crouch_toggle else true)
	elif !PlayerInfo.crouch_toggle && Input.is_action_just_released("crouch"):
		_handle_crouch(false)

func _handle_crouch(is_crouch:bool):
	if in_water: return
	is_crouched = is_crouch
	head.disabled = is_crouched
	camera.transform.origin.y = -0.35 if is_crouch else 0.55

func get_in_water(water_depth:float):
	if is_crouched:
		_handle_crouch(false)
	water_y = water_depth
	in_water = true

func _handle_movement_input():
	var movement := Vector2()
	if Input.is_action_pressed("move_forward") || (active_mayhem > 0 && PlayerInfo.current_mayhem == "Spindash"):
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
	var speed_mult := 1.0
	if active_mayhem > 0 && PlayerInfo.current_mayhem == "Spindash":
		velocity.y = 0.0
		speed_mult = 1.6 + 0.6 * (PlayerInfo.get_mayhem_level("Spindash") - 1)
	else:
		if in_water:
			var swim_level := PlayerInfo.get_mayhem_level("Swim")
			if swim_level == 0:
				if !is_on_floor():
					velocity.y += delta * GRAVITY * 3.0
			else:
				if swim_level < 3:
					speed_mult *= 0.75
				var my_gravity := GRAVITY
				if Input.is_action_pressed("jump"):
					my_gravity = -GRAVITY / 2.0
				elif Input.is_action_pressed("crouch"):
					my_gravity = GRAVITY / 2.0
				else:
					my_gravity = GRAVITY / 14.0
				velocity.y = my_gravity
		else:
			velocity.y += delta * GRAVITY
	var vel_xz := Vector3(velocity.x, 0, velocity.z)
	var acceleration := speed_mult * (ACCELERATION if direction.dot(vel_xz) > 0 else DECELERATION)
	vel_xz = vel_xz.linear_interpolate(direction * speed_mult * MAX_SPEED, acceleration * delta)
	
	velocity = move_and_slide(Vector3(vel_xz.x, velocity.y, vel_xz.z) + bonus_force * delta, Vector3.UP)
	if bonus_force_timer > 0:
		bonus_force_timer -= delta
		bonus_force *= 0.99
		if bonus_force_timer <= 0.0:
			bonus_force = Vector3.ZERO

func _input(event:InputEvent):
	if game_over.visible: return
	var pause_pressed := GASInput.is_action_just_pressed("pause")
	if PlayerInfo.in_elevator:
		return
	if mayhem_screen.visible:
		if pause_pressed || (event.is_action("toggle_inventory") && GASInput.is_action_just_pressed("toggle_inventory")) || (event.is_action("use") && GASInput.is_action_just_pressed("use")):
			_on_MayhemScreen_closed()
		return
	elif PlayerInfo.paused:
		if pause_pressed:
			pause_screen.close()
		return
	elif pause_pressed:
		if in_terminal: return
		_toggle_inventory(false)
		pause_screen.open()
		return
	if in_terminal:
		if (event.is_action("toggle_inventory") && GASInput.is_action_just_pressed("toggle_inventory")) || (event.is_action("use") && GASInput.is_action_just_pressed("use")):
			_close_terminal()
		return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # aiming
		if event is InputEventMouseMotion: return _handle_camera_movement(event)
	if event.is_action_pressed("equip_modifier") && GASInput.is_action_just_pressed("equip_modifier"):
		if PlayerInfo.equip_toggle:
			equip_toggled = !equip_toggled
		else:
			equip_toggled = true
	elif event.is_action_released("equip_modifier") && Input.is_action_just_released("equip_modifier"):
		if !PlayerInfo.equip_toggle:
			equip_toggled = false
	if event.is_action_pressed("jump") && is_on_floor() && !in_water:
		velocity.y = JUMP_SPEED
		get_tree().call_group("PlayerSound", "play_sound", "Jump")
	elif event.is_action("toggle_inventory") && GASInput.is_action_just_pressed("toggle_inventory"):
		_toggle_inventory(!in_inventory)
	_handle_equip_switch()
	_handle_use_item(event)

func _handle_camera_movement(event:InputEventMouseMotion):
	vision.rotate_x(deg2rad(event.relative.y * -PlayerInfo.mouse_sensitivity))
	rotate_y(deg2rad(event.relative.x * -PlayerInfo.mouse_sensitivity))
	var camera_rotation := vision.rotation_degrees
	camera_rotation.x = clamp(camera_rotation.x, -85, 85)
	vision.rotation_degrees = camera_rotation

func _handle_use_item(event:InputEvent):
	if !(event.is_action("use") && GASInput.is_action_just_pressed("use")): return
	if in_inventory && search_target != null:
		_on_close_item_search()
		return
	var body:Spatial = PlayerInfo.get_collision(2.8, true)
	if body == null: return
	if body is Entity:
		var body_as_entity:Entity = body
		if body is Enemy:
			var body_as_enemy:Enemy = body
			if !body_as_enemy.is_dead: return
		elif body is Interactable:
			var bi:Interactable = body
			if bi.shoot_to_get:
				bi._die()
				return
		search_target = body_as_entity
		inventory.search_contents = body_as_entity.contents
		_toggle_inventory(true, true)
	elif body is SecurityControl:
		get_tree().call_group("PlayerSound", "play_sound", "Beep")
		var bs:SecurityControl = body
		hack_target = bs
		hacking_terminal.configure(bs.cleared, bs.first_button_text, bs.second_button_text, bs.third_button_text, bs.level_requirement)
		_open_terminal(hacking_terminal)
	elif body is MayhemKiosk:
		mayhem_screen.visible = true
		mayhem_screen.set_shards()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PlayerInfo.paused = true
	elif body is Elevator:
		var e:Elevator = body
		e.use()
	elif body is PowerSwitch:
		var ps:PowerSwitch = body
		ps.switch()

func _on_MayhemScreen_closed():
	mayhem_screen.visible = false
	PlayerInfo.paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_HackingTerminal_hacked():
	if hack_target == null: return
	hack_target.cleared = true

func _on_HackingTerminal_button_pressed(idx:int):
	if hack_target == null: return
	hack_target.button_press(idx)

func _open_terminal(terminal:Control):
	in_terminal = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	terminal.visible = true

func _close_terminal():
	in_terminal = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hacking_terminal.visible = false
	hack_target = null
	# TODO: the other one too

func _toggle_inventory(new_position:bool, search := false):
	PlayerInfo.inv_is_dragging = false
	in_inventory = new_position
	if !in_inventory && search_target != null:
		_on_close_item_search()
		return
	inventory.is_search = search
	if in_inventory:
		inventory.refresh_items()
	else:
		inventory.close_cleanup()
	inventory.visible = in_inventory
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if in_inventory else Input.MOUSE_MODE_CAPTURED)

func _handle_equip_switch():
	for i in range(0, 10):
		if !GASInput.is_action_just_pressed("equip%s" % i): continue
		if equip_toggled:
			if active_mayhem > 0:
				get_tree().call_group("PlayerSound", "play_sound", "Denied")
				return
			var mayhem := ""
			match i:
				1: mayhem = "Spindash"
				2: mayhem = "Magnet"
				3: mayhem = "Mayhem-Modulate"
				4: mayhem = "Cloak"
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
func add_chaos_energy(amount:int):
	PlayerInfo.chaos_energy = int(min(PlayerInfo.chaos_energy + amount, PlayerInfo.max_chaos_energy))
	player_stats.update_chaos()
func add_emerald_shard(amount:int):
	PlayerInfo.emerald_shards += amount
	player_stats.update_shards()

func cause_mayhem(time:float):
	if active_mayhem > 0: return
	active_mayhem = time
	mayhem_targets = []
	match PlayerInfo.current_mayhem:
		"Magnet":
			magnet_area_shape.disabled = false
			var magnet_size := 0.5 + PlayerInfo.get_mayhem_level("Magnet") / 2.0
			var s:CylinderShape = magnet_area_shape.shape
			s.radius = 6.0 * magnet_size
			s.height = 5.0 * magnet_size
		"Spindash":
			spindash_area_shape.disabled = false
		"Mayhem-Modulate":
			PlayerInfo.time_frozen = true
		"Cloak":
			PlayerInfo.invisible = true

func _mayhem_magnet():
	var areas := magnet_area.get_overlapping_areas()
	var super_charged := PlayerInfo.get_mayhem_level("Magnet") == 3
	for a in areas:
		var ring:Spatial = a
		if !a.is_in_group("Ring"): continue
		var ring_direction := (global_transform.origin - ring.global_transform.origin).normalized()
		ring.global_transform.origin += ring_direction * (0.6 if super_charged else 0.25)

func _on_Spindash_entered(body:Spatial):
	if body == self: return
	if !(body is Entity): return
	(body as Entity).take_hit(camera.project_ray_normal(get_viewport().size / 2), 2500.0, 15.0 * PlayerInfo.get_mayhem_level("Spindash"))
	if mayhem_targets.find(body) < 0:
		mayhem_targets.append(body)

func _on_Spindash_exited(body:Spatial):
	if body == self: return
	if !(body is Entity): return
	mayhem_targets.erase(body)

func update_environment():
	var vision_level := PlayerInfo.get_mayhem_level("Vision")
	if vision_level < 2: return
	camera.environment.fog_enabled = false
	camera.environment.ambient_light_energy = 0.2
	if vision_level < 3: return
	camera.environment.ambient_light_energy = 0.5

func fire_projectile(p:Projectile):
	p.launcher = self
	get_parent().add_child(p)
	var launch_direction := camera.project_ray_normal(get_viewport().size / 2)
	p.global_transform.origin = head.global_transform.origin + launch_direction * 0.5
	p.apply_impulse(Vector3.ZERO, launch_direction * p.launch_force)

func take_damage():
	if PlayerInfo.paused || invincible_time > 0.0: return
	if PlayerInfo.rings == 0:
		_game_over()
	else:
		match PlayerInfo.difficulty:
			0: invincible_time = 8.0
			1: invincible_time = 3.0
			2: invincible_time = 0.5
		ouchie.visible = true
		fuck_it_up(PlayerInfo.rings)
		get_tree().call_group("PlayerSound", "play_sound", "Hurt")

func lose_ring():
	if PlayerInfo.paused || invincible_time > 0.0: return
	if PlayerInfo.rings == 0:
		_game_over()
	else:
		PlayerInfo.rings -= 1
		player_stats.update_rings()
		get_tree().call_group("PlayerSound", "play_sound", "Hurt")

func _game_over():
	if game_over.visible: return
	get_tree().call_group("PlayerSound", "play_sound", "GameOver", "Ring")
	full_hud.visible = false
	game_over.visible = true
	game_over_anim.play("Die")
	PlayerInfo.paused = true
	game_over_timer.start(3.5)
	yield(game_over_timer, "timeout")
	if PlayerInfo.last_save_point == "":
		pause_screen.open(true)
	else:
		var point_info:PoolStringArray = PlayerInfo.last_save_point.split("/")
		PlayerInfo.last_save_point = ""
		PlayerInfo.paused = false
		PlayerInfo.current_map = point_info[0]
		PlayerInfo.return_timeout = 2.0
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Map", "save_to_dictionary")
		SceneSwitcher.switch_scene("res://Maps/%s.tscn" % point_info[0], false)
		SceneSwitcher.memory = {
			"source": "MAP",
			"destination": point_info[1]
		}

func fuck_it_up(rings_to_lose:int):
	if rings_to_lose == 0:
		return
	var amount := rings_to_lose if rings_to_lose < 4 else 4
	PlayerInfo.rings -= amount
	player_stats.update_rings()
	for i in amount:
		var ring:Spatial = RING_SCENE.instance()
		ring.delay_timeout = 0.4
		ring.launch_on_start = true
		get_parent().add_child(ring)
		ring.global_transform.origin = global_transform.origin + Vector3(0, 0.5, 0)
	yield(get_tree(), "idle_frame")
	fuck_it_up(rings_to_lose - amount)
