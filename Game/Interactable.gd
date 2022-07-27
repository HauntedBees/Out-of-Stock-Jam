class_name Interactable
extends Entity

onready var label:Label = $Viewport/Label
func _ready():
	main_mesh = $InteractModel
	name_mesh = $Name
	refresh_label()

func refresh_label(): label.text = "%s (%s)" % [type, contents.size()]
