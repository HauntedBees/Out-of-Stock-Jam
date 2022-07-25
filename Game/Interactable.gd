class_name Interactable
extends Entity

var contents := [
	Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2(0, 0), 95)
]

func _ready():
	main_mesh = $InteractModel
	name_mesh = $Name
