class_name SpecialStageLevelInfo
extends Node

var ring_requirement:int
var environment:PoolStringArray
var is_last := false

func _init(requirement:int, items:PoolStringArray):
	ring_requirement = requirement
	environment = items
