class_name PauseScreen
extends Control

onready var beep_ping:AudioStreamPlayer = $BeepSound
onready var hover_ping:AudioStreamPlayer = $HoverSound

onready var conans_hint:RichTextLabel = $ConansHint
onready var save_screen:SaveScreen = $SaveScreen
onready var options_screen:Control = $OptionsScreen

onready var continue_button:Control = $VBoxContainer/Button_Continue
onready var options_button:Control = $VBoxContainer/Button_Options
onready var save_button:Control = $VBoxContainer/Button_SaveGame
onready var game_over_label:Control = $GameOverLabel

var hint_idx := 0
var rng := RandomNumberGenerator.new()

func _ready(): rng.randomize()

func open(game_over := false):
	beep_ping.play()
	save_screen.current_screen = GASUtils.get_screen()
	visible = true
	PlayerInfo.paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hint_idx = rng.randi_range(0, HINTS.size() - 1)
	_draw_hint()
	continue_button.visible = !game_over
	options_button.visible = !game_over
	save_button.visible = !game_over
	game_over_label.visible = game_over
func close():
	beep_ping.play()
	if save_screen.visible:
		save_screen.visible = false
		return
	if options_screen.visible:
		options_screen.visible = false
		return
	visible = false
	PlayerInfo.paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_Options_pressed():
	beep_ping.play()
	options_screen.visible = true
func _on_SaveGame_pressed(): 
	beep_ping.play()
	save_screen.setup(false)
func _on_LoadGame_pressed():
	beep_ping.play()
	save_screen.setup(true)

func _on_NextHint_pressed():
	beep_ping.play()
	hint_idx = (hint_idx + 1) % HINTS.size()
	_draw_hint()
func _on_PrevHint_pressed():
	beep_ping.play()
	hint_idx = posmod(hint_idx - 1, HINTS.size())
	_draw_hint()
func _draw_hint(): conans_hint.bbcode_text = HINTS[hint_idx]
const HINTS := [
	"Hold down the [color=#FF00FF]Toggle Equip[/color] button (the [color=#FF00FF]Shift Key[/color]) while pressing a [color=#FF00FF]Number Key[/color] to equip Mayhem Abilities.",
	"With the [color=#FF00FF]Strength Mayhem Ability[/color], you can use [color=#FF00FF]Heavy Weapons[/color] like the [color=#FF00FF]Grenade Launcher[/color].",
	"You'll normally sink in water, and drown after a short time, but you can increase your lung capacity with the [color=#FF00FF]Swim Mayhem Ability[/color], which will also let you swim.",
	"You can save [color=#FF00FF]Inventory[/color] space by combining some items, like [color=#FF00FF]Ammo[/color] and [color=#FF00FF]Food[/color], into stacks. Each item has a different maximum stack size, so try to optimize what you can.",
	"People die when they are killed.",
	"Some holes are too big to jump over, but you're unaffected by gravity when using the [color=#FF00FF]Spin Dash Mayhem Ability[/color], which may be just what you need to get over that hurdle.",
	"Eating [color=#FF00FF]Food[/color] will recover lost [color=#FF00FF]Mayhem Energy[/color], allowing you to use more of your [color=#FF00FF]Mayhem Abilities[/color].",
	"As long as you have at least one [color=#FF00FF]Ring[/color], you're safe from enemy attacks. But if an enemy hits you when you have no [color=#FF00FF]Rings[/color], you'll die.",
	"If you have at least [color=#FF00FF]50 Rings[/color], you can enter [color=#FF00FF]Cyberspace[/color] at a [color=#FF00FF]Lamp Post[/color], where you can earn a [color=#FF00FF]Mayhem Ruby[/color].",
	"If you die, you'll reappear at the last [color=#FF00FF]Lamp Post[/color] you touched. Haven't touched a [color=#FF00FF]Lamp Post[/color] yet? You should do that soon."
]

func _on_button_mouse_entered(): hover_ping.play()
