extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameManager.inc_max_score()
		
func _on_body_entered(_body: Node2D) -> void:
	# waiting for the animation is too laggy
	remove_child($AnimatedSprite2D)
	GameManager.add_point()
	animation_player.play("pickupAnimation")
