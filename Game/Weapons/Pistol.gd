extends Weapon

func _ready():
	attack_animation = "Shoot"
	cooldown = 0.2
	attack_range = 20.0
	pushback = 1000.0
