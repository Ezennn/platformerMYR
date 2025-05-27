extends Node2D

func _GameManager_get_game_state() :
	return GameManager.GS.LEVEL
#Let worldboundary = 470 be a easter egg for a later level 
#@export var world_bottom_bound : float = 470.0


@export var world_bottom_bound : float = 133.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WorldBoundary/CollisionShape2D.position.y = world_bottom_bound
	$Player/Camera2D.limit_bottom = world_bottom_bound + get_viewport().get_visible_rect().size.y / 2
