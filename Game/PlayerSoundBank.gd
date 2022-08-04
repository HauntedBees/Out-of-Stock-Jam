extends Spatial

var sounds := {
	"Hurt": preload("res://Assets/Sounds/PlayerDamage.ogg"),
	"Ring": preload("res://Assets/Sounds/Ring.ogg"),
	"NoRing": preload("res://Assets/Sounds/NoRing.ogg"),
	"Woosh": preload("res://Assets/Sounds/Woosh.ogg"),
	"Sword": preload("res://Assets/Sounds/Sword.ogg"),
	"Bonk": preload("res://Assets/Sounds/Bonk.ogg"),
	"Rifle": preload("res://Assets/Sounds/Rifle.ogg"),
	"Gun": preload("res://Assets/Sounds/Gun.ogg"),
	"Thwop": preload("res://Assets/Sounds/Thwop.ogg"),
	"GameOver": preload("res://Assets/Sounds/GameOver.ogg"),
	"Trap": preload("res://Assets/Sounds/Trap.ogg"),
	"Jump": preload("res://Assets/Sounds/Jump.ogg"),
	"Reload": preload("res://Assets/Sounds/Reload.ogg"),
	"EnterWater": preload("res://Assets/Sounds/EnterWater.ogg"),
	"LeaveWater": preload("res://Assets/Sounds/LeaveWater.ogg"),
	"Switch": preload("res://Assets/Sounds/Switch.ogg"),
	"Beep": preload("res://Assets/MenuSounds/Beep.ogg"),
	"Denied": preload("res://Assets/MenuSounds/Denied.ogg"),
	"Spindash": preload("res://Assets/Sounds/Spindash.ogg"),
	"Magnet": preload("res://Assets/Sounds/Magnet.ogg"),
	"Cloak": preload("res://Assets/Sounds/Cloak.ogg"),
	"Uncloak": preload("res://Assets/Sounds/Uncloak.ogg"),
	"Mayhem-Modulate": preload("res://Assets/Sounds/Mayhem-Modulate.ogg"),
	"Pop": preload("res://Assets/Sounds/Pop.ogg"),
	"Bounce": preload("res://Assets/Sounds/Bounce.ogg")
}
onready var dedicated_channels := {
	"Ring": $RingStream,
	"Weapon": $WeaponStream
}

onready var sound1:AudioStreamPlayer = $Player1
onready var sound2:AudioStreamPlayer = $Player3
onready var sound3:AudioStreamPlayer = $Player2

func play_sound(path:String, dedicated_channel := "") -> void:
	if !sounds.has(path): return
	var player := sound1
	if dedicated_channel == "":
		dedicated_channel = path
	if dedicated_channels.has(dedicated_channel):
		player = dedicated_channels[dedicated_channel]
	else:
		if player.playing: player = sound2
		if player.playing: player = sound3
		if player.playing:
			sound1.stop()
			player = sound1
	player.stream = sounds[path]
	player.play()
