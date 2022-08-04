extends Node

var meshes := {}
var colliders := {}
var materials := {}

func get_mesh_with_dimensions(mesh:QuadMesh, v:Vector2) -> QuadMesh:
	var id := "%s-%s,%s" % [mesh.get_rid().get_id(), v.x, v.y]
	if meshes.has(id):
		return meshes[id]
	var new_mesh:QuadMesh = mesh.duplicate()
	new_mesh.size = v
	meshes[id] = new_mesh
	return new_mesh

func get_collider_with_dimensions(shape:BoxShape, v:Vector2) -> BoxShape:
	var id := "%s-%s,%s" % [shape.get_rid().get_id(), v.x, v.y]
	if colliders.has(id):
		return colliders[id]
	var new_shape:BoxShape = shape.duplicate()
	new_shape.extents = Vector3(v.x, v.y, v.x)
	colliders[id] = new_shape
	return new_shape

func get_material_with_texture(material:SpatialMaterial, texture:Texture) -> SpatialMaterial:
	var id := "%s-%s" % [material.get_rid().get_id(), texture.get_rid().get_id()]
	if materials.has(id):
		return materials[id]
	var new_material:SpatialMaterial = material.duplicate()
	new_material.albedo_texture = texture
	materials[id] = new_material
	return new_material
