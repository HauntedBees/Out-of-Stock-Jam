extends Spatial

var is_open := false
onready var children := get_children()

func open(immediate := false):
	if is_open: return
	is_open = true
	for c in children:
		c.open(immediate)

func close():
	if !is_open: return
	is_open = false
	for c in children:
		c.close()
