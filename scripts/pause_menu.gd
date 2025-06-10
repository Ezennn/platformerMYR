extends Control

func hide_menu() :
	$ColorRect.hide()
	$PanelContainer.hide()

func show_menu() :
	$ColorRect.show()
	$PanelContainer.show()
	
func _ready() :
	show()
	$PauseButton.show()
	$AnimationPlayer.play("RESET")
	hide_menu()
	set_process_input(true)  # Make sure input is processed
	
func _input(event):
	if event.is_action_pressed("pause"):
		if $ColorRect.visible :
			resume()
		else :
			pause()

func resume() :
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	hide_menu()
	
func pause() :
	show_menu()
	get_tree().paused = true
	$AnimationPlayer.play("blur")



func _on_resume_pressed() -> void:
	resume()
	hide_menu()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	# reset save point 
	GameManager.save_point = Vector2(0.0,0.0)
	Engine.time_scale = 1
	resume()
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	hide_menu()
	GameManager.apply_game_state(GameManager.GS.LEVEL_SELECT)
	get_tree().paused = false
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	


func _on_pause_button_pressed() -> void:
	if $ColorRect.visible :
		resume()
	else :
		pause()
		
	
