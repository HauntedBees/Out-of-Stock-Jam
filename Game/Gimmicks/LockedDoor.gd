class_name LockedDoor
extends StaticBody

onready var t:Tween = $Tween
var is_open := false

func open(immediate := false):
	if is_open: return
	is_open = true
	if immediate:
		transform.origin.y = -3.0
	else:
		t.interpolate_property(self, "translation:y", 0.0, -3.0, 1.0)
		t.start()

func close():
	if !is_open: return
	is_open = false
	t.interpolate_property(self, "translation:y", -3.0, 0.0, 1.0)
	t.start()
