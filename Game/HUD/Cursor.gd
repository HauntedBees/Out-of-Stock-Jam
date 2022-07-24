class_name Cursor
extends Control

onready var tl := $TopLeft
onready var tr := $TopRight
onready var bl := $BottomLeft
onready var br := $BottomRight

func fit_to_object(o:MeshInstance):
	if o == null:
		visible = false
		return
	var camera:Camera = get_viewport().get_camera()
	var mesh := o.mesh.get_aabb()
	var scale := o.scale 
	var top_left := camera.unproject_position(o.global_transform.origin - scale)
	var bottom_right := camera.unproject_position(o.global_transform.origin + scale)
	var size := bottom_right - top_left#mesh.size #Vector3(1, 1, 1)#0.8 * (bottom_right - top_left)#mesh.size
	
	bl.rect_position = top_left
	br.rect_position = Vector2(top_left.x + size.x, top_left.y)
	tl.rect_position = Vector2(top_left.x, top_left.y + size.y)
	tr.rect_position = Vector2(top_left.x + size.x, top_left.y + size.y)#bottom_right
	visible = false
