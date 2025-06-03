extends Control

@export var game_state : GameManager.GS = GameManager.GS.NA

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	set_process(false)
