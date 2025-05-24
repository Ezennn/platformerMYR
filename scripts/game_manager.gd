extends Node

const DEATH_TIME = GameConstants.DEATH_TIME * GameConstants.DEATH_ENGINE_SLOWDOWN

var score = 0
@onready var score_label: Label = $ScoreLabel
@onready var animated_sprite: AnimatedSprite2D = $ColorRect/TextureRect/AnimatedSprite2D
# minimum unlocked level 
@export var unlocked_up_to_level = 1

enum GAME_SCREEN_STATE {LEVEL, LOSE, WIN, LEVEL_SELECT, NA}
const GS = GAME_SCREEN_STATE
@export var game_screen : GAME_SCREEN_STATE = GAME_SCREEN_STATE.LEVEL

func _hide_contents() -> void:
	for node in get_children():
		node.visible = false
		
func refresh_labels(new_state : GAME_SCREEN_STATE = GS.NA) -> void:
	_hide_contents()
	match (new_state):
		GS.LEVEL:
			for node in get_children():
				if node.is_in_group("LevelGroup"):
					node.visible = true
		GS.LOSE:
			for node in get_children():
				if node.is_in_group("DeadGroup"):
					node.visible = true
		GS.WIN:
			for node in get_children():
				if node.is_in_group("WinGroup"):
					node.visible = true
		_: 
			pass

func add_point():
	score += 1
	score_label.text = "Coins: " + str(score)

func play_animation_for_duration(anim_name: String, duration: float, sprite : AnimatedSprite2D = animated_sprite) -> void:
	var frames = sprite.sprite_frames
	if not frames.has_animation(anim_name):
		print("Animation not found:", anim_name)
		return
	if duration <= 0:
		print("Duration must be positive!")
		return
	var frame_count = frames.get_frame_count(anim_name)
	var new_fps = frame_count / duration
	frames.set_animation_speed(anim_name, new_fps)
	sprite.play(anim_name)

func _on_ready() -> void:
	self.visible = true
	refresh_labels(GS.LEVEL)
	# no longer required as killzones directly communicate with players and game manager 
	#for zone in get_tree().get_nodes_in_group("KillZones"):
		#zone.player_death.connect(_on_player_death)

func on_player_death() -> void:
	refresh_labels(GS.LOSE)
	play_animation_for_duration("dead", DEATH_TIME)

func win(level : int) -> void:
	animated_sprite.position.y -= 200
	animated_sprite.position.x -= 100
	$WinLabel.text = "Level " + str(level) + " Won!"
	unlocked_up_to_level = min(5, max(unlocked_up_to_level, level + 1))
	animated_sprite.play("idle")
	$VictorySound.play()
	refresh_labels(GS.WIN)
