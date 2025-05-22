extends Control

func _ready() :
	$AnimationPlayer.play("RESET")
	hide()
	set_process_input(true)  # Make sure input is processed
	
func _input(event):
	if event.is_action_pressed("pause"):
		if visible :
			resume()
		else :
			pause()

func resume() :
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	hide()
	
func pause() :
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")



func _on_resume_pressed() -> void:
	resume()
	hide()
	

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
