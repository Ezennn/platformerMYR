extends Control

@export var game_state : GameManager.GS = GameManager.GS.NA

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_quit_pressed() -> void:
	GameManager.quit()
