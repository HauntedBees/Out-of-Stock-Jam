class_name PlayerStatsHUD
extends TextureRect

onready var ring_count:Label = $Rings/HealthAmount
onready var chaos_count:Label = $HealthChaos/ChaosAmount
onready var chaos_bar:TextureProgress = $HealthChaos/ChaosBar
onready var shard_amount:Label = $Shards/ShardAmount
onready var weapon_texture:TextureRect = $Weapon/Texture
onready var mayhem_texture:TextureRect = $Power/Texture
onready var weapon_ammo:Label = $Weapon/Ammo

func _ready():
	update_rings()
	update_chaos()
	update_shards()
	update_weapon()
	update_mayhem()

func update_rings(): ring_count.text = String(PlayerInfo.rings)
func update_chaos():
	chaos_count.text = String(PlayerInfo.chaos_energy)
	chaos_bar.value = 100.0 * PlayerInfo.chaos_energy / PlayerInfo.max_chaos_energy
func update_shards(): shard_amount.text = String(PlayerInfo.emerald_shards)

func update_mayhem():
	if PlayerInfo.current_mayhem == "":
		mayhem_texture.visible = false
	else:
		mayhem_texture.visible = true
		mayhem_texture.texture = load("res://Textures/Entities/Mayhem/%s.png" % PlayerInfo.current_mayhem)

func update_weapon():
	if PlayerInfo.current_weapon == PlayerInfo.UNARMED:
		weapon_texture.visible = false
	else:
		weapon_texture.visible = true
		weapon_texture.texture = load("res://Textures/%s" % PlayerInfo.current_weapon.texture)
	update_ammo()

func update_ammo():
	if PlayerInfo.current_weapon.uses_ammo:
		weapon_ammo.visible = true
		weapon_ammo.text = "%s/%s" % [PlayerInfo.get_loaded_ammo(), PlayerInfo.get_ammo()]
	else: weapon_ammo.visible = false
