extends MeshInstance
export(String) var text := "I'm Sign"
onready var label:Label = $Viewport/Label
func _ready(): label.text = text
