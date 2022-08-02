class_name HackingTerminal
extends Control

signal button_pressed(idx)
signal hacked()
signal exit()

onready var beep_ping:AudioStreamPlayer = $BeepSound
onready var hover_ping:AudioStreamPlayer = $HoverSound

onready var first_button:Button = $TextureRect/VBoxContainer/Button1
onready var second_button:Button = $TextureRect/VBoxContainer/Button2
onready var third_button:Button = $TextureRect/VBoxContainer/Button3
onready var hacking_game:HackingGame = $HackingGame
onready var access_status:Label = $TextureRect/DeniedText

func configure(access_granted:bool, first_button_text:String, second_button_text:String, third_button_text:String, level_requirement:int):
	first_button.text = first_button_text
	first_button.visible = first_button_text != ""
	first_button.disabled = !access_granted
	second_button.text = second_button_text
	second_button.visible = second_button_text != ""
	second_button.disabled = !access_granted
	third_button.text = third_button_text
	third_button.visible = third_button_text != ""
	third_button.disabled = !access_granted
	open(level_requirement, access_granted)

func open(level_requirement:int, access_granted:bool):
	hacking_game.level = level_requirement - 1
	hacking_game.render_map()
	if access_granted:
		hacking_game.show_granted()
		access_status.text = "Access: Granted"
		hacking_game.modulate.a = 0.25
	else:
		hacking_game.set_access(PlayerInfo.get_mayhem_level("Hacking") >= level_requirement)
		access_status.text = "Access: Denied"
		hacking_game.modulate.a = 1.0
		
func _on_successful_hack():
	first_button.disabled = false
	second_button.disabled = false
	third_button.disabled = false
	access_status.text = "Access: Granted"
	emit_signal("hacked")
	hacking_game.modulate.a = 0.25

func _on_ExitButton_pressed():
	beep_ping.play()
	emit_signal("exit")

func _on_Button_pressed(i:int):
	beep_ping.play()
	emit_signal("button_pressed", i)

func _on_button_mouse_entered(): hover_ping.play()
