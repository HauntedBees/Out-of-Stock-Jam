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

onready var how_buttons := [
	$HowToPlay/VBoxContainer/HowPlayBtn,
	$HowToPlay/VBoxContainer/BasicCtrlsBtn,
	$HowToPlay/VBoxContainer/MayhemBtn,
	$HowToPlay/VBoxContainer/StagesBtn,
	$HowToPlay/VBoxContainer/HackingBtn,
	$HowToPlay/VBoxContainer/OptionsBtn
]
onready var how_to_play := [
	$HowToPlay/HowToPlay,
	$HowToPlay/BasicControls,
	$HowToPlay/MayhemControls,
	$HowToPlay/SpecialStages,
	$HowToPlay/Hacking,
	$HowToPlay/Accessibility
]
onready var cutscene := [
	$OpeningCutscene/TextureRect,
	$OpeningCutscene/TextureRect2,
	$OpeningCutscene/TextureRect3,
	$OpeningCutscene/TextureRect4,
	$OpeningCutscene/TextureRect5,
	$OpeningCutscene/TextureRect6,
	$OpeningCutscene/TextureRect7,
	$OpeningCutscene/TextureRect8,
	$OpeningCutscene/TextureRect9
]
onready var cutscene_text:RichTextLabel = $OpeningCutscene/Textbox/CutsceneText

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

func _on_Button_Quit_pressed(): get_tree().quit()

func _on_NewGame_pressed():
	beep_ping.play()
	$OpeningInfo.visible = true

func _on_HowToPlay_pressed():
	beep_ping.play()
	$HowToPlay.visible = true
	_set_how_play(0)

func _on_StraightToGame_pressed():
	PlayerInfo.current_map = "Medical Bay"
	SceneSwitcher.switch_scene("res://Maps/Medical Bay.tscn", false)
	SceneSwitcher.memory = {
		"source": "MAP",
		"destination": "SpawnPoint"
	}

func _on_HowPlayBtn_pressed(): _set_how_play(0)
func _on_BasicCtrlsBtn_pressed(): _set_how_play(1)
func _on_MayhemBtn_pressed(): _set_how_play(2)
func _on_StagesBtn_pressed(): _set_how_play(3)
func _on_HackingBtn_pressed():_set_how_play(4)
func _on_OptionsBtn_pressed(): _set_how_play(5)
func _set_how_play(idx:int):
	beep_ping.play()
	for i in how_buttons.size():
		var b:Button = how_buttons[i]
		b.pressed = i == idx
	for i in how_to_play.size():
		var s:Control = how_to_play[i]
		s.visible = i == idx

var cutscene_dialog:PoolStringArray = [
	"[color=#CCAAAA]???[/color]: Hmm, what's this?",
	"[color=#CCAAAA]???[/color]: Oh, my, it looks like your cryogenic chamber got stuck for a while.",
	"[color=#CCAAAA]???[/color]: Ah, yes... you were supposed to be awoken from stasis 2 months ago!",
	"[color=#CCAAAA]???[/color]: Unfortunately for you, a lot has happened in those 2 months.",
	"[color=#CCAAAA]???[/color]: This colony is now controlled by [color=#FF00FF]Doctor Roboton[/color], and I am one of his [color=#FF00FF]Roboticizers[/color].",
	"[color=#CCAAAA]???[/color]: Which means it's now time to [color=#FF0000]roboticize you[/color].",
	"[color=#CCAAAA]???[/color]: Just doing my job; [color=#FF0000]nothing personnel, kid[/color].",
	"You can feel yourself slowly succumbing to the [color=#FF00FF]mayhem[/color] of roboticization.",
	"[color=#CCAAAA]???[/color]: URK.",
	"Behind the [color=#FF00FF]now dead Roboticizer[/color] you see a woman holding a gun.",
	"[color=#AACCAA]???[/color]: That was close. I'm glad I caught you in time; you're our only hope now.",
	"[color=#AACCAA]???[/color]: I'm Princess Oaknut, and I used to lead this space station. Until [color=#FF00FF]Roboton[/color] happened.",
	"[color=#AACCAA]Oaknut[/color]: He and his minions invaded the station and began killing and roboticizing everyone.",
	"[color=#AACCAA]Oaknut[/color]: You're the only one who can stop him, he's not stopping with just this station.",
	"[color=#AACCAA]Oaknut[/color]: Once he overrides the controls in the captain's chamber... our species is doomed.",
	"[color=#AACCAA]Oaknut[/color]: Please, stop him. I'm glad I was able to catch you before it was too late for you.",
	"[color=#AACCAA]Oaknut[/color]: But now, it's too late for me... There are other enemies around the station that did a number on me. Please be careful.",
	"[color=#AACCAA]Oaknut[/color]: Take the [color=#FF00FF]items[/color] in that [color=#FF00FF]desk[/color]; you'll need them.",
	"[color=#AACCAA]Oaknut[/color]: Good... luck..."
]
var cutscene_idx := 0
var cutscene_advances := [1, 5, 6, 7, 8, 9, 17, 18]
var cutscene_advance_idx := 0

func _on_ShowOpening_pressed():
	beep_ping.play()
	_start_cutscene()
func _start_cutscene():
	$TitleMusic.stop()
	$BackgroundMusic.play()
	$OpeningCutscene.visible = true
	for c in cutscene:
		c.visible = false
	cutscene[0].visible = true
	cutscene_text.bbcode_text = cutscene_dialog[0]

func _is_action(event:InputEvent, action:String) -> bool:
	return event.is_action(action) && GASInput.is_action_just_pressed(action)

func _on_OpeningCutscene_gui_input(event:InputEvent):
	if !(_is_action(event, "action") || _is_action(event, "use")):
		return
	cutscene_idx += 1
	if cutscene_idx >= cutscene_dialog.size():
		_on_StraightToGame_pressed()
		return
	if cutscene_idx == 8:
		$Bang.play()
	cutscene_text.bbcode_text = cutscene_dialog[cutscene_idx]
	if cutscene_idx == cutscene_advances[cutscene_advance_idx]:
		cutscene_advance_idx += 1
		cutscene[cutscene_advance_idx].visible = true
