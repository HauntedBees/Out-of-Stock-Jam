extends Control

const SAVE_PATH := "user://save_%s.save"

onready var beep_ping:AudioStreamPlayer = $BeepSound
onready var hover_ping:AudioStreamPlayer = $HoverSound
onready var new_game:TextureButton = $MainTitle/VBoxContainer/Button_NewGame
onready var continue_game:TextureButton = $MainTitle/VBoxContainer/Button_Continue
onready var load_game:TextureButton = $MainTitle/VBoxContainer/Button_LoadGame
onready var options:TextureButton = $MainTitle/VBoxContainer/Button_Options
onready var quit:TextureButton = $MainTitle/VBoxContainer/Button_Quit

onready var options_screen:Control = $OptionsScreen
onready var save_screen:SaveScreen = $SaveScreen

func _ready():
	var has_saves := has_saves()
	continue_game.visible = has_saves
	load_game.visible = has_saves

func has_saves() -> bool:
	var f := File.new()
	if f.file_exists(SAVE_PATH % "Autosave"): return true
	for i in 14:
		if f.file_exists(SAVE_PATH % i): return true
	return false

func _on_button_mouse_entered(): hover_ping.play()

func _on_Continue_pressed():
	beep_ping.play()
	yield(beep_ping, "finished")
	var dates := []
	dates.append({ "key": "Autosave", "date": _get_date("Autosave") })
	for i in 14:
		var key := String(i)
		dates.append({ "key": key, "date": _get_date(key) })
	dates.sort_custom(self, "_sort_dates")
	var first:String = dates[0]["key"]
	save_screen.load_data(first)
func _sort_dates(a:Dictionary, b:Dictionary) -> bool:
	return a["date"] > b["date"]

func _get_date(key:String) -> String:
	var f := File.new()
	if !f.file_exists(SAVE_PATH % key):
		return ""
	f.open(SAVE_PATH % key, File.READ)
	f.get_line() # skip location
	var date:String = f.get_line()
	f.close()
	return date

func _on_LoadGame_pressed(): 
	beep_ping.play()
	save_screen.setup(true)
func _on_SaveScreen_back_save():
	beep_ping.play()
	save_screen.visible = false
func _on_Options_pressed(): 
	beep_ping.play()
	options_screen.visible = true

