class_name hot_key_bind
extends Control

@onready var label = $HBoxContainer/Label as Label 
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = "move_left"

var waiting_for_key: bool = false
var ignore_first_key: bool = true

func _ready() -> void:
	add_to_group("hotkey_button")
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP

func set_action_name() -> void:
	label.text = "Unassigned"
	match action_name:
		"move_left": label.text = "Left"
		"move_right": label.text = "Right"
		"jump": label.text = "Jump"
		"dash": label.text = "Dash"
		"pause": label.text = "Pause"
		"down": label.text = "Down"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.is_empty():
		button.text = "Unassigned"
		return

	var action_event = action_events[0]
	
	if action_event is InputEventKey:
		button.text = OS.get_keycode_string(action_event.physical_keycode)

	elif action_event is InputEventMouseButton:
		match action_event.button_index:
			MOUSE_BUTTON_LEFT: button.text = "Mouse Left"
			MOUSE_BUTTON_RIGHT: button.text = "Mouse Right"
			MOUSE_BUTTON_MIDDLE: button.text = "Mouse Middle"
			_: button.text = "Mouse Button %d" % action_event.button_index
	else:
		button.text = "Unknown"

func _on_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		button.text = "Press any key ..."
		button.focus_mode = Control.FOCUS_NONE  # Temporarily disable focus nav
		button.grab_focus()  # Still grabs key input though

		button.mouse_filter = Control.MOUSE_FILTER_IGNORE  #  IMPORTANT
		set_process_unhandled_key_input(true)

		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i != self and i is hot_key_bind:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
	else:
		button.mouse_filter = Control.MOUSE_FILTER_STOP  #  Reset to default
		set_text_for_key()
		set_process_unhandled_key_input(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if not button.pressed:
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		rebind_action_key(event)
		button.button_pressed = false
		button.focus_mode = Control.FOCUS_ALL
		return

	if event is InputEventMouseButton and event.is_pressed():
		rebind_action_key(event)
		button.button_pressed = false
		button.focus_mode = Control.FOCUS_ALL
		return

func rebind_action_key(event: InputEvent) -> void:
	# Optionally remove from other actions to avoid conflicts
	for action in InputMap.get_actions():
		if action == action_name:
			continue
		for ev in InputMap.action_get_events(action):
			if ev.as_text() == event.as_text():
				InputMap.action_erase_event(action, ev)

	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	set_process_unhandled_key_input(false)
	button.mouse_filter = Control.MOUSE_FILTER_STOP  #  Reset here too
	set_text_for_key()
	set_action_name()
	button.focus_mode = Control.FOCUS_NONE
