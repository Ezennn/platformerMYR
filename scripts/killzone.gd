extends Area2D
		
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if GameManager.game_screen != GameManager.GS.LOSE:
			var player := body as Player
			player.on_player_death()
			GameManager.on_player_death()
			GameManager._handle_death_timescale()
	elif body.has_method("on_death") and not body.is_ancestor_of(self):
		body.on_death()
	elif body is TileMapLayer:
		pass
	else:
		print("Something unexpected happened: Body entered: " + str(body))
