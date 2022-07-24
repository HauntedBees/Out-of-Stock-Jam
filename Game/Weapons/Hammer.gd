extends Weapon

func _ready():
	attack_animation = "Melee"
	cooldown = 0.2
	attack_range = 3.0
	pushback = 300.0
