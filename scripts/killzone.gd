extends Area2D

@onready var timer: Timer = $Timer

signal player_death

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_death.emit()
		print("You died!") 
		Engine.time_scale = GameConstants.DEATH_ENGINE_SLOWDOWN
		timer.wait_time = GameConstants.DEATH_TIME
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
