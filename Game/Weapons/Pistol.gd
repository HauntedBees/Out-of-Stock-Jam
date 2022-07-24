extends Weapon

func _ready():
	attack_animation = "Shoot"
	cooldown = 0.3
	attack_range = 20.0
	pushback = 100.0
