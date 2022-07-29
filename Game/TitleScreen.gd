extends Control

onready var new_game:TextureButton = $MainTitle/VBoxContainer/Button_NewGame
onready var continue_game:TextureButton = $MainTitle/VBoxContainer/Button_Continue
onready var load_game:TextureButton = $MainTitle/VBoxContainer/Button_LoadGame
onready var options:TextureButton = $MainTitle/VBoxContainer/Button_Options
onready var quit:TextureButton = $MainTitle/VBoxContainer/Button_Quit

func _ready():
	continue_game.visible = false
	load_game.visible = false
