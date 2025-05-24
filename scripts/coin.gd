extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(_body: Node2D) -> void:
	# waiting for the animation is too laggy
	remove_child($AnimatedSprite2D)
	game_manager.add_point()
	animation_player.play("pickupAnimation")
