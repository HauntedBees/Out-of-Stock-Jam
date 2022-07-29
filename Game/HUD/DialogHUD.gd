extends Control

onready var label:Label = $Textbox/DialogText

func post_message(s:String):
	label.text = s
	visible = true

func end_message():
	visible = false
	get_tree().call_group("DialogAwaiter", "done_message")

func _input(event:InputEvent):
	if event.is_action_pressed("action") || event.is_action_pressed("use"):
		end_message()
