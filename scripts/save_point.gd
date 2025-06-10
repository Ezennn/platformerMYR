extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.visible = false
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(_body) -> void:
	if GameManager.save_enabled:
		$ColorRect.visible = true
		GameManager.save_point = position
		await get_tree().create_timer(1.5).timeout
		$ColorRect.visible = false

func _on_body_exited(_body) -> void:
	if not GameManager.save_enabled:
		GameManager.save_enabled = true
