extends Control

var label_theme:Theme = load("res://HUD/BWTheme.tres")
var button_theme:Theme = load("res://HUD/Button.tres")

onready var beep_ping:AudioStreamPlayer = $BeepSound
onready var hover_ping:AudioStreamPlayer = $HoverSound

onready var borderless:CheckButton = $TabContainer/Settings/HBoxContainer/VBoxContainer2/BorderlessWindow
onready var full_screen:CheckButton = $TabContainer/Settings/HBoxContainer/VBoxContainer2/FullScreen
onready var music_volume:HSlider = $TabContainer/Settings/HBoxContainer/VBoxContainer2/MusicVolume
onready var sound_volume:HSlider = $TabContainer/Settings/HBoxContainer/VBoxContainer2/SoundVolume
onready var difficulty:ItemList = $TabContainer/Settings/HBoxContainer/VBoxContainer2/Difficulty

onready var col1:VBoxContainer = $TabContainer/Controls/HBoxContainer/Controls0
onready var col2:VBoxContainer = $TabContainer/Controls/HBoxContainer/Controls1
onready var col3:VBoxContainer = $TabContainer/Controls/HBoxContainer/Controls2
onready var col4:VBoxContainer = $TabContainer/Controls/HBoxContainer/Controls3
onready var col5:VBoxContainer = $TabContainer/Controls/HBoxContainer/Controls4
onready var col6:VBoxContainer = $TabContainer/Controls/HBoxContainer/Controls5
onready var confirm:ConfirmationDialog = $TabContainer/Controls/ConfirmationDialog

onready var toggle_equip:CheckButton = $TabContainer/Controls/HBoxContainer/Controls5/ToggleEquip
onready var toggle_crouch:CheckButton = $TabContainer/Controls/HBoxContainer/Controls5/ToggleCrouch
onready var toggle_drag:CheckButton = $TabContainer/Controls/HBoxContainer/Controls5/ToggleDrag
onready var mouse_sens:SpinBox = $TabContainer/Controls/HBoxContainer/Controls5/MouseSensitivity
onready var input_cooldown:HSlider = $TabContainer/Controls/HBoxContainer/Controls5/InputCooldown

var in_popup := false
var target_button:Button
var current_edited_action := ""
var current_edited_action_value:InputEvent

func _change_control(button:Button, display_name:String, action:String):
	beep_ping.play()
	target_button = button
	confirm.popup_centered()
	confirm.window_title = "Edit '%s'" % display_name
	confirm.dialog_text = "Current Input:\n%s" % _get_action_value(action)
	current_edited_action = action
	current_edited_action_value = InputMap.get_action_list(action)[0]
	in_popup = true

func _ready():
	borderless.pressed = PlayerInfo.borderless_window
	full_screen.pressed = PlayerInfo.full_screen
	music_volume.value = PlayerInfo.music_volume
	sound_volume.value = PlayerInfo.sound_volume
	difficulty.select(PlayerInfo.difficulty)
	
	confirm.get_child(1).align = HALIGN_CENTER
	confirm.get_child(0).focus_mode = 0
	var hbox:HBoxContainer = confirm.get_child(2)
	hbox.get_child(1).focus_mode = 0
	hbox.get_child(3).focus_mode = 0
	_add_control(col1, col2, "Move Forward", "move_forward")
	_add_control(col1, col2, "Move Backward", "move_backward")
	_add_control(col1, col2, "Strafe Left", "strafe_left")
	_add_control(col1, col2, "Strafe Right", "strafe_right")
	_add_control(col1, col2, "Jump", "jump")
	_add_control(col1, col2, "Crouch", "crouch", "By default, you will crouch until you release this input.\nDisable \"Hold to Crouch\" on the right to make this a toggle.")
	_add_control(col1, col2, "Fire Weapon", "action")
	_add_control(col1, col2, "Use Mayhem Action", "mayhem")
	_add_control(col1, col2, "Use/Check Object", "use")
	_add_control(col1, col2, "Toggle Inventory", "toggle_inventory")
	_add_control(col1, col2, "Reload Weapon", "reload")
	_add_control(col1, col2, "Pause", "pause")
	
	_add_control(col3, col4, "Toggle Equip", "equip_modifier", "To switch between Mayhem Actions, hold down this input and press an Equip Slot input.\nDisable \"Hold to Toggle Equip\" on the right to make this a toggle.")
	_add_control(col3, col4, "Equip Slot 1", "equip1")
	_add_control(col3, col4, "Equip Slot 2", "equip2")
	_add_control(col3, col4, "Equip Slot 3", "equip3")
	_add_control(col3, col4, "Equip Slot 4", "equip4")
	_add_control(col3, col4, "Equip Slot 5", "equip5")
	_add_control(col3, col4, "Equip Slot 6", "equip6")
	_add_control(col3, col4, "Equip Slot 7", "equip7")
	_add_control(col3, col4, "Equip Slot 8", "equip8")
	_add_control(col3, col4, "Equip Slot 9", "equip9")
	_add_control(col3, col4, "Equip Slot 10", "equip0")
	
	_add_control(col5, null, "Press Toggle Equip", "")
	_add_control(col5, null, "Press Toggle Crouch", "")
	_add_control(col5, null, "Drag Move Items", "")
	_add_control(col5, null, "Mouse Sensitivity", "")
	_add_control(col5, null, "Input Cooldown", "")
	toggle_equip.pressed = PlayerInfo.equip_toggle
	toggle_crouch.pressed = PlayerInfo.crouch_toggle
	toggle_drag.pressed = PlayerInfo.inv_drag_to_move
	mouse_sens.value = PlayerInfo.mouse_sensitivity
	input_cooldown.value = GASConfig.input_cooldown_length

func _add_control(label_column:VBoxContainer, button_column:VBoxContainer, display_name:String, action_name:String, tooltip:String = ""):
	var l := Label.new()
	l.rect_min_size = Vector2(210, 60)
	l.valign = Label.VALIGN_CENTER
	l.align = Label.ALIGN_RIGHT
	l.text = display_name
	l.theme = label_theme
	label_column.add_child(l)
	if button_column == null: return
	var b := Button.new()
	b.rect_min_size = Vector2(120, 60)
	b.theme = button_theme
	b.text = _get_action_value(action_name)
	b.connect("mouse_entered", self, "_on_control_mouse_entered")
	b.connect("pressed", self, "_change_control", [b, display_name, action_name])
	if tooltip != "": b.hint_tooltip = tooltip
	button_column.add_child(b)

func _get_action_value(action_name:String) -> String:
	var action:InputEvent = InputMap.get_action_list(action_name)[0]
	return _get_event_value(action)
func _get_event_value(action:InputEvent) -> String:
	if action is InputEventMouseButton:
		var am:InputEventMouseButton = action
		match am.button_index:
			BUTTON_LEFT: return "LMB"
			BUTTON_RIGHT: return "RMB"
			BUTTON_MIDDLE: return "MMB"
			BUTTON_WHEEL_UP: return "W^"
			BUTTON_WHEEL_DOWN: return "Wv"
			BUTTON_WHEEL_LEFT: return "W<"
			BUTTON_WHEEL_RIGHT: return "W>"
			_: return "Mouse %s" % am.button_index
	elif action is InputEventKey:
		var ak:InputEventKey = action
		return OS.get_scancode_string(ak.scancode) 
	elif action is InputEventJoypadButton:
		var ab:InputEventJoypadButton = action
		return "Gamepad %s" % ab.button_index
	elif action is InputEventJoypadMotion:
		var am:InputEventJoypadMotion = action
		return "Gamepad %s%s" % ["+" if am.axis_value > 0 else "-", am.axis]
	return action.as_text()

func _unhandled_input(event:InputEvent):
	if !in_popup: return
	if event is InputEventMouseMotion: return
	current_edited_action_value = event
	confirm.dialog_text = "Current Input:\n%s" % _get_event_value(event)

func _on_ConfirmationDialog_confirmed():
	beep_ping.play()
	GASInput.remap_action(current_edited_action, current_edited_action_value, true)
	target_button.text = _get_event_value(current_edited_action_value)
	current_edited_action = ""
	current_edited_action_value = null
	target_button = null

func _on_ConfirmationDialog_popup_hide():
	beep_ping.play()
	in_popup = false

func _on_BackButton_pressed():
	beep_ping.play()
	PlayerInfo.save_global_config()
	visible = false

func _on_ToggleEquip_toggled(button_pressed:bool): PlayerInfo.equip_toggle = button_pressed
func _on_ToggleCrouch_toggled(button_pressed:bool): PlayerInfo.crouch_toggle = button_pressed
func _on_ToggleDrag_toggled(button_pressed:bool): PlayerInfo.inv_drag_to_move = button_pressed
func _on_MouseSensitivity_value_changed(value:float): PlayerInfo.mouse_sensitivity = value

func _on_control_mouse_entered(): hover_ping.play()
func _on_tab_changed(_tab:int): beep_ping.play()

func _on_BorderlessWindow_pressed():
	beep_ping.play()
	PlayerInfo.set_borderless(borderless.pressed)
func _on_FullScreen_pressed():
	beep_ping.play()
	PlayerInfo.set_full_screen(full_screen.pressed)
func _on_SoundVolume_value_changed(value:float): PlayerInfo.set_sound_volume(value)
func _on_MusicVolume_value_changed(value:float): PlayerInfo.set_music_volume(value)
func _on_Difficulty_item_selected(index:int):
	beep_ping.play()
	PlayerInfo.difficulty = index
func _on_InputCooldown_value_changed(value:float):
	GASConfig.input_cooldown_length = value
	GASConfig.input_cooldown_enabled = value > 0.0
