extends Area2D

# Always shows label; Off by default
@export var ALWAYS_SHOW : bool = false

func _on_body_entered(body: Node2D) -> void:
	$ColorRect.visible = true


func _on_body_exited(body: Node2D) -> void:
	if not ALWAYS_SHOW:
		$ColorRect.visible = false


func _on_ready() -> void:
	$ColorRect.visible = ALWAYS_SHOW
	
