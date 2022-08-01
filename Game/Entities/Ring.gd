extends Area

onready var flicker:AnimationPlayer = $FlickerPlayer

var delay_timeout := 0.0
var launch_on_start := false
var forced_velocity := Vector3.ZERO
var bounce_count := 5
var life_span := 15.0
var is_flickering := false

func _ready():
	if launch_on_start:
		forced_velocity = 50.0 * Vector3(
			-1.0 + 2.0 * randf(),
			-1.0 + 2.0 * randf(),
			-1.0 + 2.0 * randf()
		)

func _process(delta:float):
	if delay_timeout > 0.0:
		delay_timeout -= delta
	if launch_on_start:
		life_span -= delta
		if !is_flickering && life_span < 4.0:
			flicker.play("Flicker")
			is_flickering = true
		if life_span <= 0:
			queue_free()

func _physics_process(delta:float):
	if forced_velocity.length() == 0: return
	forced_velocity.y -= 0.5
	transform.origin += forced_velocity * delta
	if transform.origin.y < 0.0:
		bounce_count -= 1
		transform.origin.y = 0.5
		if bounce_count == 0:
			forced_velocity = Vector3.ZERO
	forced_velocity *= 1.0 - delta
	if forced_velocity.length() < 0.05:
		forced_velocity = Vector3.ZERO

func _on_body_entered(body:Node):
	if delay_timeout > 0.0: return
	if !(body is Player):
		if forced_velocity.length() > 0.05:
			forced_velocity *= -0.9
		return
	get_tree().call_group("player", "add_rings", 1)
	if name[0] != "@":
		get_tree().call_group("destroy_monitor", "on_destroy", name)
	queue_free()
