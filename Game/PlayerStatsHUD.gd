extends TextureRect

onready var ring_count := $Rings/HealthAmount
onready var chaos_count := $HealthChaos/ChaosAmount
onready var chaos_bar := $HealthChaos/ChaosBar
onready var shard_amount := $Shards/ShardAmount
onready var weapon_texture := $Weapon/Texture
onready var weapon_ammo := $Weapon/Ammo

func _ready():
	ring_count.text = String(PlayerInfo.rings)
	chaos_count.text = String(PlayerInfo.chaos_energy)
	chaos_bar.value = 100.0 * PlayerInfo.chaos_energy / PlayerInfo.max_chaos_energy
	shard_amount.text = String(PlayerInfo.emerald_shards)
	update_weapon()

func update_weapon():
	weapon_texture.texture = load("res://Textures/%s" % PlayerInfo.current_weapon.texture)
	update_ammo()

func update_ammo():
	if PlayerInfo.current_weapon.uses_ammo:
		weapon_ammo.visible = true
		weapon_ammo.text = "%s/%s" % [PlayerInfo.get_loaded_ammo(), PlayerInfo.get_ammo()]
	else: weapon_ammo.visible = false
