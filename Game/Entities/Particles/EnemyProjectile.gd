class_name EnemyProjectile
extends RigidBody

var boom:PackedScene = load("res://Weapons/Explosion.tscn")

var material:SpatialMaterial
var explode_on_impact := false
var blast_force := 0.0
var damage := 0.0
onready var collider:CollisionShape = $CollisionShape
onready var mesh:MeshInstance = $MeshInstance
onready var player = get_tree().get_nodes_in_group("player")[0]
var launcher:Node
var saved_velocity := Vector3.ZERO

func _ready(): mesh.material_override = material

func _physics_process(_delta:float):
	if PlayerInfo.time_frozen && gravity_scale > 0.0:
		print("FREEZIN")
		print(linear_velocity)
		sleeping = true
		saved_velocity = linear_velocity
		gravity_scale = 0.0
	elif !PlayerInfo.time_frozen && gravity_scale == 0.0:
		sleeping = false
		linear_velocity = saved_velocity
		gravity_scale = 1.0

func _on_body_entered(body:Node):
	if body == launcher: return
	if explode_on_impact:
		var blast = boom.instance()
		blast.force = blast_force
		blast.damage = damage
		get_parent().add_child(blast)
		blast.global_transform.origin = global_transform.origin
		get_tree().call_group("SoundAwaiter", "noise_made", 2.0, global_transform.origin)
	elif !(body is StaticBody):
		if body != player: return
		player.take_damage()
	queue_free()
