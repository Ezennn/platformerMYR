extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var game_manager
func _ready() -> void:
	var managers = get_tree().get_nodes_in_group("GameManager")
	if managers.size() > 0:
		game_manager = managers[0]
	else:
		print("GameManager not found in group.")
		
func _on_body_entered(_body: Node2D) -> void:
	# waiting for the animation is too laggy
	remove_child($AnimatedSprite2D)
	game_manager.add_point()
	animation_player.play("pickupAnimation")
