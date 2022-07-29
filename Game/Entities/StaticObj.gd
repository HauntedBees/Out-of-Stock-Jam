extends StaticBody

onready var c:CollisionShape = $CollisionShape
onready var m:MeshInstance = $MeshInstance
export(String) var type := ""
export(Vector2) var mesh_scale := Vector2(1.0, 1.0)

func _ready():
	m.material_override = m.get_active_material(0).duplicate()
	(m.material_override as SpatialMaterial).albedo_texture = load("res://Textures/Environment/%s.png" % type)
	(m.mesh as QuadMesh).size *= mesh_scale
	(c.shape as BoxShape).extents *= Vector3(mesh_scale.x, mesh_scale.y, mesh_scale.x)
