extends Node2D
@onready var area_2d: Area2D = $Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	
	#debug 
	#print(body)
	if not body.has_method("bounce"):
		return
	# Get the top of the mushroom (this node)
	var mushroom_top = global_position.y -  $CollisionShape2D.shape.extents.y

	# Get the player's bottom position
	var player_shape = body.get_node("CollisionShape2D").shape
	var player_bottom = body.global_position.y + player_shape.extents.y

	# Add a small leeway
	var leeway = 1
	
	# debug 
	#print("Player bottom: " + str(player_bottom) + "\n" + "Mushroom Top : " + str(mushroom_top))
	
	# leeway used for physics engine
	if player_bottom < (mushroom_top + leeway) and player_bottom > (mushroom_top - leeway):
		body.bounce()
		$AudioStreamPlayer2D.play()
