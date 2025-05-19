extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("You died!") 
		Engine.time_scale = 0.2
		var player = body as Player
		player.setIsAlive(false)
		#player.get_node("CollisionShape2D").queue_free()
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
