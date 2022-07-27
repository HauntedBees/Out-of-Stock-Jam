class_name Gimmick
extends Area

export(NodePath) var collider_path:NodePath
onready var collider:CollisionShape = get_node(collider_path)

func _ready(): connect("body_entered", self, "_on_enter")

func _on_enter(body:Node):
	if !(body is Player): return
	_on_player(body)

func _on_player(player:Player): return
