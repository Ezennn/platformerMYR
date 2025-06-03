extends Node

@export var game_state : GameManager.GS = GameManager.GS.LEVEL_SELECT

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level 1.tscn")


func _on_level_2_pressed() -> void:
	pass # Replace with function body.


func _on_level_3_pressed() -> void:
	pass # Replace with function body.


func _on_level_4_pressed() -> void:
	pass # Replace with function body.


func _on_level_5_pressed() -> void:
	pass # Replace with function body.
