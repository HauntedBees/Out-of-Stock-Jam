extends Spatial

onready var rng := RandomNumberGenerator.new()
onready var ring_scene:PackedScene = load("res://Entities/Ring.tscn")

var rings := []

func _ready():
	PlayerInfo.rings = 100
	rng.randomize()
func _physics_process(delta: float):
	for idx in range(rings.size() - 1, 0, -1):
		var c:Dictionary = rings[idx]
		var ring:Spatial = c["ring"]
		if ring == null || !is_instance_valid(ring):
			rings.remove(idx)
			continue
		ring.transform.origin.y += c["speed"] * delta
		if ring.transform.origin.y >= 80:
			ring.queue_free()
			rings.remove(idx)
	if rings.size() < 500:
		var amount := rng.randi_range(2, 20)
		var x := rng.randf_range(-40.0, 40.0)
		var z := rng.randf_range(-40.0, 40.0)
		for i in amount:
			var ring:Spatial = ring_scene.instance()
			add_child(ring)
			ring.transform.origin = Vector3(x, i * -0.02, z)
			rings.append({
				"ring": ring,
				"speed": rng.randf_range(1.0, 10.0)
			})
