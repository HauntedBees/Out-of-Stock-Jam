extends Node

var loader:ResourceInteractiveLoader
onready var root := get_tree().get_root()
var target:String
var keep_last_scene:bool
var cached_scene:Node
var cached_caller:Node
var memory:Dictionary

func get_memory_type() -> String:
	if memory == null || memory.keys().size() == 0:
		return "None"
	if memory.has("source"):
		return memory["source"]
	else:
		return "None"

func return_to_last_scene(args):
	var current_scene := root.get_child(root.get_child_count() - 1)
	current_scene.queue_free()
	PlayerInfo.return_timeout = 0.5
	root.add_child(cached_scene)
	cached_scene = null
	if cached_caller != null:
		cached_caller.call("on_return", args)
		cached_caller = null

func switch_scene(target_route:String, retain_previous:bool, caller:Node = null):
	memory = {}
	target = target_route
	keep_last_scene = retain_previous
	cached_caller = caller
	loader = ResourceLoader.load_interactive("res://LoadingScreen.tscn")

func _process(_delta:float):
	if loader == null: return
	var err := loader.poll()
	if err == ERR_FILE_EOF:
		var scene:LoadingScreen = loader.get_resource().instance()
		scene.target = target
		var current_scene := root.get_child(root.get_child_count() - 1)
		if keep_last_scene:
			cached_scene = current_scene
			root.remove_child(current_scene)
		else:
			current_scene.queue_free()
		root.add_child(scene)
		loader = null
	elif err != OK:
		print("OH FUCK")
		print(err)
