extends KinematicBody

export(float) var speed := 10.0
export(NodePath) var path_path:NodePath
onready var player:KinematicBody = get_tree().get_nodes_in_group("player")[0]
var points := []
var point_idx := 0
var velocity := Vector3.ZERO
var touching_player := false

func _ready():
	var path:Path = get_node(path_path)
	points = path.curve.get_baked_points()
	global_transform.origin = points[0]

func _physics_process(delta:float):
	var target:Vector3 = points[point_idx]
	if global_transform.origin.distance_to(target) < 1.0:
		point_idx = (point_idx + 1) % points.size()
	velocity = (target - global_transform.origin).normalized() * speed * delta
	global_transform.origin += velocity
	if touching_player: player.global_transform.origin += velocity

func _on_Area_body_entered(body:Node):
	if body == player: touching_player = true
func _on_Area_body_exited(body:Node):
	if body == player: touching_player = false
