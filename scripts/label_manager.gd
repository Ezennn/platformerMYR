extends Node

@onready var score_label: Label = $ScoreLabel

var score = 0

func add_point():
	score += 1
	score_label.text = "Coins: " + str(score)


func _on_ready() -> void:
	$ScoreLabel.visible = true
	$DeadLabel.visible = false
	$ColorRect.visible = false
	for zone in get_tree().get_nodes_in_group("KillZones"):
		zone.player_death.connect(_on_player_death)
		
func _on_player_death() -> void:
	$DeadLabel.visible = true
	$ColorRect.visible = true
	$ColorRect/TextureRect/AnimatedSprite2D.play("dead")
