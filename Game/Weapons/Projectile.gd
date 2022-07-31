class_name Projectile
extends RigidBody

var boom:PackedScene = load("res://Weapons/Explosion.tscn")

export(bool) var explode_on_impact := false
export(float) var blast_force := 0.0
export(float) var launch_force := 0.0
export(float) var damage := 0.0
onready var collider:CollisionShape = $CollisionShape
onready var mesh:MeshInstance = $MeshInstance
var launcher:Node

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body:Node):
	if body == launcher: return
	var blast = boom.instance()
	blast.force = blast_force
	blast.damage = damage
	get_parent().add_child(blast)
	blast.global_transform.origin = global_transform.origin
	queue_free()
