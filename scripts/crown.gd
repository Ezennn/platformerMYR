extends Area2D

@onready var game_manager: Node = %GameManager

signal win(level : int)

@export var level : int = 1

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		# currently the win signal isnt used by anyone. Most communication (Except killzones) are done using GameManager as a unique name 
		emit_signal("win", level)
		game_manager.win(level)
