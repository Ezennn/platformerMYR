class_name hot_key_bind
extends Control
@onready var label = $HBoxContainer/Label as Label 
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = "move_left"

var waiting_for_key: bool = false
var ignore_first_key: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("hotkey_button")
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name :
		"move_left" :
			label.text = "Left"
		"move_right" :
			label.text = "Right"
		"jump" :
			label.text = "Jump"
		"dash" :
			label.text = "Dash"
		"pause" :
			label.text = "Pause"
			
func set_text_for_key() -> void :
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	
	button.text = "%s" % action_keycode


func _on_button_toggled(button_pressed) -> void:
	if button.pressed :
		button.text = "Press any key ..."
		button.grab_focus()
		set_process_unhandled_key_input(true)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i != self and i is hot_key_bind:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		
	else :
		set_text_for_key()
		set_process_unhandled_key_input(false)
	
	
func _unhandled_key_input(event) :
	if event is InputEventKey and event.pressed:
		rebind_action_key(event)
		button.button_pressed = false
	
	
func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
	
