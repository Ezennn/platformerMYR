extends Control

func _ready() :
	$AnimationPlayer.play("RESET")
	hide()

func resume() :
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	
func pause() :
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func pausing():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
		
	if Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()


func _on_resume_pressed() -> void:
	resume()
	hide()
	

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _process(delta):
	pausing();
