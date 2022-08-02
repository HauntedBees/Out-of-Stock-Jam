extends Control

onready var counter:Label = $Label
var time_left := 10.0
var next_time := 10

func start_timer():
	visible = true
	time_left = 9.8
	next_time = 9
	counter.text = "10"

func _process(delta:float):
	time_left -= delta
	if time_left <= next_time:
		counter.text = String(next_time)
		next_time -= 1
		if next_time < 0:
			visible = false
