extends Control

onready var loading_label:Label = $Label
onready var percent_label:Label = $PercentLabel
onready var timer:Timer = $Timer

var i := 0
func _on_Timer_timeout():
	i = (i + 1) % 4
	match i:
		0: loading_label.text = "Loading"
		1: loading_label.text = "Loading."
		2: loading_label.text = "Loading.."
		3: loading_label.text = "Loading..."

var loader:ResourceInteractiveLoader
func _ready():
	loader = ResourceLoader.load_interactive("res://Maps/%s.tscn" % PlayerInfo.map_to_load)
	percent_label.text = "0/0"

func _process(delta:float):
	if loader == null: return
	var err := loader.poll()
	if err == ERR_FILE_EOF:
		percent_label.text = "%s/%s" % [loader.get_stage_count(), loader.get_stage_count()]
		var scene = loader.get_resource().instance()
		get_node("/root").add_child(scene)
		queue_free()
	elif err == OK:
		percent_label.text = "%s/%s" % [loader.get_stage(), loader.get_stage_count()]
	else:
		print("OH FUCK")
		print(err)
