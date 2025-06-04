extends Button

@export var level : int = 1
@export var level_scene : PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.unlocked_up_to_level >= level:
		$ColorRect.visible = false
	else :
		$ColorRect.visible = true



func _on_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)
