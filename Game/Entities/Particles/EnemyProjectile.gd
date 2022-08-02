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

func _ready():
	mesh.material_override = material

func _on_body_entered(body:Node):
	if body == launcher: return
	if explode_on_impact:
		var blast = boom.instance()
		blast.force = blast_force
		blast.damage = damage
		get_parent().add_child(blast)
		blast.global_transform.origin = global_transform.origin
	elif !(body is StaticBody):
		if body != player: return
		player.take_damage()
	queue_free()
