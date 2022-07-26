class_name SpecialStages
extends Node

#-1 = right, 1 = left
var stages := [
#	[SpecialStageLevelInfo.new(0, ["C0:0,-20"])],
	[
		SpecialStageLevelInfo.new(20, ["R0:0,0", "R0:1,10", "R0:-1,20", "R1:1,30", "R1:-1,40", "R1:0,50", "C0:0,70"]),
		SpecialStageLevelInfo.new(50, [
			"R1:0,0", 
			"R0:-1,10", "R0:1,20", "R0:0,25", 
			"R1:0,35", "s1:-1,35", "s1:1,35", 
			"R1:1,45", "R2:1,50", "R2:-1,60",
			"C0:0,85"]),
		SpecialStageLevelInfo.new(100, [
			"R0:-1,0", "R0:1,0", "R0:0,10", 
			"R0:0,20", "S0:-1,20", "S0:1,20",
			"R0:-1,35", "R0:1,35", "S0:0,35",
			"R5:-1,60", "H0:0,60", "R1:1,60",
			"R5:0,70", "H0:0,70", "R1:0,70",
			"R5:-1,80", "H0:0,80", "R1:1,80",
			"R1:-1,90", "R2:1,100", "S2:0,100",
			"R2:0,110", "S2:1,116", "R2:-1,120",
			"C0:0,135"
		])
	]
]

func get_stage(num:int, part:int) -> SpecialStageLevelInfo:
	var parts:Array = stages[num]
	var stage:SpecialStageLevelInfo = parts[part]
	if part == (parts.size() - 1): stage.is_last = true
	return stage
