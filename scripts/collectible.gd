extends Area2D

class_name Collectible

@export var collectible_type: GameManager.COLLECTIBLE

func _ready():
	# only interacts with player, works even if player dashing 
	collision_mask = 2
	# Connect the body_entered signal to the handler function
	self.body_entered.connect(_on_body_entered)
	GameManager.register_collectible(collectible_type)
	if collectible_type in GameManager._collected_items:
		collision_mask = 0
		visible = false

func _on_body_entered(_body):
	GameManager.collect_item(collectible_type)
	collision_mask = 0
	visible = false
