extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
		
func _on_body_entered(_body: Node2D) -> void:
	# waiting for the animation is too laggy
	remove_child($AnimatedSprite2D)
	GameManager.add_point()
	animation_player.play("pickupAnimation")

# Programmed connections rather than editor connections to avoid being in a tilemaplayer to regenerate connections with different IDs
func _on_ready() -> void:
	connect("body_entered", _on_body_entered)
