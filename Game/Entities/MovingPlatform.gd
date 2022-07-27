extends StaticBody

export(NodePath) var path_follow_path:NodePath
onready var path_follow:PathFollow = get_node(path_follow_path)

func _physics_process(delta:float):
	path_follow.offset += delta
