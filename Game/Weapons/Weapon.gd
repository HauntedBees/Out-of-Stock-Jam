class_name Weapon
extends Control

const weapon_info := {
	"Hammer": {
		"animation": "Melee",
		"power": 7.0,
		"cooldown": 0.3,
		"pushback": 300.0,
		"range": 4.0,
		"is_melee": true,
		"uses_ammo": false
	},
	"Pistol": {
		"blast_position": Vector2(-652, -426),
		"animation": "Shoot",
		"power": 5.0,
		"cooldown": 0.5,
		"pushback": 100.0,
		"range": 30.0,
		"is_melee": true,
		"uses_ammo": true
	}
}
const mayhem_info := {
	"Spindash": {
		"cost": [4, 3, 1],
		"cooldown": [1.0, 1.0, 1.0]
	},
	"Magnet": {
		"cost": [3, 3, 2],
		"cooldown": [1.0, 1.0, 1.0]
	},
	"Mayhem-Modulate": {
		"cost": [8, 8, 8],
		"cooldown": [3.0, 6.0, 10.0]
	},
	"Cloak": {
		"cost": [8, 8, 5],
		"cooldown": [5.0, 8.0, 15.0]
	}
}

var attack_animation := "Shoot"
var cooldown := 0.5
var power := 10.0
var attack_range := 50.0
var pushback := 2.0
var uses_ammo := false
var is_melee := false

onready var weapon_textures := [$Weapon/Pistol, $Weapon/Hammer]
onready var mayhem_textures := [
	$Mayhem/Powers/Spindash, 
	$Mayhem/Powers/Magnet, 
	$"Mayhem/Powers/Mayhem-Modulate",
	$Mayhem/Powers/Cloak
]
onready var mayhem_hand:TextureRect = $Mayhem/Hand
onready var blast:TextureRect = $Blast
onready var camera:Camera = get_viewport().get_camera()
onready var weapon_anim:AnimationPlayer = $WeaponAnim
onready var mayhem_anim:AnimationPlayer = $MayhemAnim
onready var rng := RandomNumberGenerator.new()

var current_weapon := ""
var cooldown_remaining := 0.0

var current_mayhem := ""
var mayhem_cooldown_remaining := 0.0

func _ready(): rng.randomize()

func update_weapon(): set_weapon(PlayerInfo.current_weapon.type)
func set_weapon(weapon:String):
	if current_weapon == weapon: return
	if weapon == "Unarmed":
		current_weapon = "Unarmed"
		for wt in weapon_textures:
			wt.visible = false
		return
	var prev_weapon := current_weapon
	current_weapon = weapon
	var w:Dictionary = weapon_info[weapon]
	cooldown = w["cooldown"]
	attack_animation = w["animation"]
	pushback = w["pushback"]
	attack_range = w["range"]
	uses_ammo = w["uses_ammo"]
	is_melee = w["is_melee"]
	power = w["power"] * 10.0
	if w.has("blast_position"):
		blast.margin_left = w["blast_position"].x
		blast.margin_bottom = w["blast_position"].y
	if prev_weapon == "":
		for wt in weapon_textures:
			wt.visible = wt.name == weapon
	else: _switch_weapon()
func _switch_weapon():
	cooldown_remaining = 99
	weapon_anim.play("MoveDown")
	yield(weapon_anim, "animation_finished")
	for wt in weapon_textures:
		wt.visible = wt.name == current_weapon
	weapon_anim.play("MoveUp")
	yield(weapon_anim, "animation_finished")
	cooldown_remaining = 0

func update_mayhem(): set_mayhem(PlayerInfo.current_mayhem)
func set_mayhem(mayhem:String):
	if current_mayhem == mayhem: return
	current_mayhem = mayhem
	_switch_mayhem()
func _switch_mayhem():
	var passive_pos := mayhem_anim.current_animation_position
	mayhem_cooldown_remaining = 99
	mayhem_anim.play("SwitchOff", -1, 2.0)
	yield(mayhem_anim, "animation_finished")
	for mt in mayhem_textures:
		mt.visible = mt.name == current_mayhem
	mayhem_hand.visible = current_mayhem != ""
	mayhem_anim.play("SwitchOn", -1, 2.0)
	yield(mayhem_anim, "animation_finished")
	mayhem_cooldown_remaining = 0
	mayhem_anim.play("Passive")
	mayhem_anim.seek(passive_pos, true)

func reload():
	cooldown_remaining = 99
	weapon_anim.play("Reload", -1, PlayerInfo.current_weapon.reload_speed_mult)
	yield(weapon_anim, "animation_finished")
	PlayerInfo.reload_weapon()
	cooldown_remaining = 0

func try_attack(delta:float):
	cooldown_remaining -= delta
	mayhem_cooldown_remaining -= delta
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED: return
	if PlayerInfo.current_weapon != PlayerInfo.UNARMED: _try_weapon_attack()
	if PlayerInfo.current_mayhem != "": _try_mayhem()

func _try_weapon_attack():
	if cooldown_remaining > 0.0 || current_weapon == "Unarmed": return
	if !Input.is_action_just_pressed("action"): return
	if uses_ammo:
		var ammo := PlayerInfo.get_loaded_ammo()
		if ammo <= 0:
			var total_ammo := PlayerInfo.get_ammo()
			if total_ammo <= 0: return
			reload()
			return
		PlayerInfo.reduce_ammo()
	cooldown_remaining = cooldown
	weapon_anim.play(attack_animation)
	var body := PlayerInfo.get_collision(attack_range)
	var damage_power := power
	var modifier := rng.randf()
	var damage_ranges := [0.2, 0.4, 0.95]
	match PlayerInfo.get_mayhem_level("Vision"):
		1, 2: damage_ranges = [0.05, 0.3, 0.96]
		3: damage_ranges = [0.01, 0.2, 0.92]
	if modifier <= damage_ranges[0]:
		damage_power = 0.0
	elif modifier >= damage_ranges[2]:
		damage_power *= 3.0
	elif modifier < damage_ranges[1]:
		damage_power *= 0.7
	if is_melee:
		match PlayerInfo.get_mayhem_level("Strength"):
			1: damage_power *= 1.08
			2: damage_power *= 1.25
			3: damage_power *= 2.25
	else:
		match PlayerInfo.get_mayhem_level("Weaponry"):
			1: damage_power *= 1.08
			2: damage_power *= 1.25
			3: damage_power *= 2.25
	if body != null: body.take_hit(camera.project_ray_normal(get_viewport().size / 2), pushback, damage_power)

func _try_mayhem():
	if mayhem_cooldown_remaining > 0.0 || current_mayhem == "": return
	if !Input.is_action_just_pressed("mayhem"): return
	var current_info:Dictionary = mayhem_info[current_mayhem]
	var current_level := PlayerInfo.get_mayhem_level(current_mayhem)
	var chaos_cost:int = current_info["cost"][current_level - 1]
	if chaos_cost > PlayerInfo.chaos_energy: return
	PlayerInfo.chaos_energy -= chaos_cost
	get_tree().call_group("equip_monitor", "update_chaos")
	var cooldown:float = current_info["cooldown"][current_level - 1]
	mayhem_cooldown_remaining = cooldown
	get_tree().call_group("player", "cause_mayhem", cooldown)
	var passive_pos := mayhem_anim.current_animation_position
	mayhem_anim.play(current_mayhem, -1, 1.0 / cooldown)
	yield(mayhem_anim, "animation_finished")
	mayhem_anim.play("RESET")
	yield(mayhem_anim, "animation_finished")
	mayhem_anim.play("Passive")
	mayhem_anim.seek(passive_pos, true)
