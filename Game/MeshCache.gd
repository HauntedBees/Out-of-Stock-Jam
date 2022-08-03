extends Node

var meshes := {}
var colliders := {}

func get_mesh_with_dimensions(mesh:Mesh, v:Vector2) -> Mesh:
	var id := "%s-%s,%s" % [mesh.get_rid(), v.x, v.y]
	if meshes.has(id):
		return meshes[id]
	var new_mesh:Mesh = mesh.duplicate()
	new_mesh.size = v
	meshes[id] = new_mesh
	return new_mesh

func get_collider_with_dimensions(shape:BoxShape, v:Vector2) -> BoxShape:
	var id := "%s-%s,%s" % [shape.get_rid(), v.x, v.y]
	if colliders.has(id):
		return colliders[id]
	var new_shape:BoxShape = shape.duplicate()
	new_shape.extents = Vector3(v.x, v.y, v.x)
	colliders[id] = new_shape
	return new_shape
