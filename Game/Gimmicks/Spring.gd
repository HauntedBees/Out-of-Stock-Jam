extends Gimmick

func _on_player(player:Player):
	player.velocity.y += 18.0
	get_tree().call_group("PlayerSound", "play_sound", "Bounce")
