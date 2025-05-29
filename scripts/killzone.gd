extends Area2D

signal player_death
var death_scene_playing: bool = false
		
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if !death_scene_playing:
			death_scene_playing = true
			var player := body as Player
			player_death.emit()
			player.on_player_death()
			GameManager.on_player_death()
			_handle_death_timescale()
	elif body is TileMapLayer:
		pass
	else:
		print("Something unexpected happened: Body entered: " + str(body))

func _handle_death_timescale() -> void:
	Engine.time_scale = GameConstants.DEATH_ENGINE_SLOWDOWN
	await get_tree().create_timer(GameManager.DEATH_TIME).timeout
	Engine.time_scale = 1
	get_tree().paused = false
	get_tree().reload_current_scene()
