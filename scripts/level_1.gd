extends Node2D

@export var game_state : GameManager.GS = GameManager.GS.LEVEL
@export var level : int = 1
@export var world_bottom_bound : float = 133.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WorldBoundary/CollisionShape2D.position.y = world_bottom_bound
	$Player/Camera2D.limit_bottom = world_bottom_bound + get_viewport().get_visible_rect().size.y / 2
