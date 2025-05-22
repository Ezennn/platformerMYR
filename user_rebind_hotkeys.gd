extends Control
@onready var label = $HBoxContainer/Label 
@onready var button = $HBoxContainer/Button

@export var action_name : String = "move_left"

func _ready() :
	set_process_unhandled_key_input(false)
	set_action_name()
	
func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"move_left":
			label.text = "Move Left"
		"move_right":
			label.text = "Move Right"
		"jump":
			label.text = "Jump/ Double Jump"
		"dash":
			label.text = "Dash"
	
