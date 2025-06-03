extends Area2D

# Always shows label; Off by default
@export var ALWAYS_SHOW : bool = false
@export var textToShow : String = ""
@onready var label: Label = $MarginContainer/MarginContainer/Label
@onready var color_rect: ColorRect = $MarginContainer/ColorRect
@onready var margin_container: MarginContainer = $MarginContainer

func _on_body_entered(_body: Node2D) -> void:
	margin_container.visible = true
	if textToShow != "":
		label.text = textToShow


func _on_body_exited(_body: Node2D) -> void:
	if not ALWAYS_SHOW:
		margin_container.visible = false


func _on_ready() -> void:
	margin_container.visible = ALWAYS_SHOW
	
