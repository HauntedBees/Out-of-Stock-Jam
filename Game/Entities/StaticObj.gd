extends StaticBody

onready var c:CollisionShape = $CollisionShape
onready var m:MeshInstance = $MeshInstance
export(String) var type := ""
export(Vector2) var mesh_scale := Vector2(1.0, 1.0)

func _ready():
	m.material_override = m.get_active_material(0).duplicate()
	(m.material_override as SpatialMaterial).albedo_texture = load("res://Textures/Environment/%s.png" % type)
	m.mesh = MeshCache.get_mesh_with_dimensions(m.mesh, mesh_scale)
	c.shape = MeshCache.get_collider_with_dimensions(c.shape, mesh_scale * 0.25)
