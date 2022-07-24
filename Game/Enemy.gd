class_name Enemy
extends Entity

var forced_velocity := Vector3.ZERO
var forced_velocity_timer := 0.0

func _ready():
	main_mesh = $EnemyModel
	name_mesh = $Name

func _process(delta:float):
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = global_transform.origin.y
	look_at(camera_pos, Vector3(0, 1, 0))

func take_hit(direction:Vector3, force:float, _damage:float):
	forced_velocity = direction * force
	forced_velocity.y = 0.0
	forced_velocity_timer = 0.2
	# TODO: take damage

func _physics_process(delta:float):
	if forced_velocity_timer >= 0.0:
		move_and_slide(forced_velocity * delta, Vector3.UP)
		forced_velocity_timer -= delta
