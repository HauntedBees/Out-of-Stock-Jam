extends StaticBody

onready var t:Tween = $Tween
var is_open := false

func open():
	if is_open: return
	is_open = true
	t.interpolate_property(self, "translation:y", 0.0, -3.0, 1.0)
	t.start()

func close():
	if !is_open: return
	is_open = false
	t.interpolate_property(self, "translation:y", -3.0, 0.0, 1.0)
	t.start()
