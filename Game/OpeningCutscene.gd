extends Spatial

onready var spartacus:MeshInstance = $Spartacus
onready var shooter:MeshInstance = $Shooter
onready var hands:Control = $Hands
onready var anim:AnimationPlayer = $Hands/AnimationPlayer
onready var grab_hand:TextureRect = $Hands/GrabHand
onready var hurt_face:Texture = preload("res://Textures/OpeningCutscene/SpartacusHurt.png")

var messages := [
	"???: Good morning, sleepyhead... Welcome to Space Station M0BI.",
	"???: I hate to disturb you so soon after waking up, but I've got very specific orders from Dr. Roboton.",
	"???: Roboticize. Everyone.",
	"???: So, no hard feelings, yeah?",
	"???: URK...",
	"*thud*",
	"???: That was close. I'm glad I caught you in time. We're the last two left.",
	"???: I'm Princess Oaknut, and I used to lead this space station. Until Roboton happened.",
	"Oaknut: He and his minions invaded the station and began killing and roboticizing everyone.",
	"Oaknut: Your cryogenic chamber must have glitched, so you got lucky and missed everything.",
	"Oaknut: But now you're the only one who can stop Roboton, he's not stopping with just this station.",
	"Oaknut: Once he's finished taking control of the captain's chamber... our species is doomed.",
	"Oaknut: Please, stop him. I'm glad I was able to catch you before it was too late for you.",
	"Oaknut: But now, it's too late for me..."
]
var message_idx := 0

var already_cutscened := false

func _ready():
	if already_cutscened: return
	PlayerInfo.in_cutscene = true
	start()

func start():
	get_tree().call_group("Dialog", "post_message", messages[0])

func done_message():
	message_idx += 1
	if message_idx == 5:
		shooter.visible = true
		anim.play("Drop")
	elif message_idx == 4:
		hands.visible = true
		anim.play("Grab", -1, 2.0)
		yield(anim, "animation_finished")
		anim.play("Transform", -1, 0.25)
		yield(anim, "animation_finished")
		# TODO: play bang sound
		grab_hand.visible = false
		spartacus.get_active_material(0).albedo_texture = hurt_face
	elif message_idx == 2:
		anim.play("WalkForward")
	elif message_idx >= messages.size():
		PlayerInfo.in_cutscene = false
		queue_free()
		return
	get_tree().call_group("Dialog", "post_message", messages[message_idx])
	
