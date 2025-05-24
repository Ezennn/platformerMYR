extends Area2D

signal win(level : int)

var game_manager
@export var level : int = 1

func _ready() -> void:
	var managers = get_tree().get_nodes_in_group("GameManager")
	if managers.size() > 0:
		game_manager = managers[0]
	else:
		print("GameManager not found in group.")

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		# currently the win signal isnt used by anyone. Most communication (Except killzones) are done using GameManager as a unique name 
		emit_signal("win", level)
		game_manager.win(level)
