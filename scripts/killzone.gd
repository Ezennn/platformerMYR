extends Area2D

@onready var timer: Timer = $Timer

#signal player_death

var game_manager
func _ready() -> void:
	var managers = get_tree().get_nodes_in_group("GameManager")
	if managers.size() > 0:
		game_manager = managers[0]
	else:
		print("GameManager not found in group.")
		
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player := body as Player
		#player_death.emit()
		player.on_player_death()
		game_manager.on_player_death()
		Engine.time_scale = GameConstants.DEATH_ENGINE_SLOWDOWN
		timer.wait_time = GameConstants.DEATH_TIME
		timer.start()
	elif body.is_in_group("Enemy") or body.is_in_group("Projectile"):
		body.queue_free()
	elif body is TileMapLayer:
		pass
	else:
		print("Something unexpected happened: Body entered: " + str(body))


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().paused = false
	get_tree().reload_current_scene()
