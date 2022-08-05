extends Timer

func _ready():
	match PlayerInfo.difficulty:
		0: wait_time = 2.0
		1: wait_time = 1.0
		2: wait_time = 0.75
