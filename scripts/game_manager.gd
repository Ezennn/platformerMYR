extends Node

const DEATH_TIME = GameConstants.DEATH_TIME * GameConstants.DEATH_ENGINE_SLOWDOWN

var max_score: int = 0
var previous_scene : Node = null
var score = 0
var player : Player
@onready var score_label: Label = $ScoreRect/ScoreLabel
@onready var animated_sprite: AnimatedSprite2D = $ColorRect/AnimatedSprite2D
# minimum unlocked level 
@export var unlocked_up_to_level = 1

enum GAME_SCREEN_STATE {LEVEL, LOSE, WIN, LEVEL_SELECT, NA}
const GS = GAME_SCREEN_STATE
@export var game_screen : GAME_SCREEN_STATE = GAME_SCREEN_STATE.LEVEL

func _hide_contents() -> void:
	for node in get_children():
		node.visible = false
		
func refresh_labels(new_state : GAME_SCREEN_STATE = GS.NA) -> void:
	_refresh_positions()
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

func _refresh_positions():
	animated_sprite.position = Vector2(593.0,427.0)
	
func add_point():
	score += 1
	score_label.text = "Coins: " + str(score) + "/" +str(max_score)

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

func on_player_death() -> void:
	refresh_labels(GS.LOSE)
	play_animation_for_duration("dead", DEATH_TIME)
	await $ColorRect/AnimatedSprite2D.animation_finished
	refresh_labels(GS.LEVEL)

func win(level : int) -> void:
	refresh_labels(GS.WIN)
	player.player_control = false
	animated_sprite.position.x -= 122
	animated_sprite.position.y -= 150
	$WinLabel.text = "Level " + str(level) + " Won!"
	unlocked_up_to_level = min(5, max(unlocked_up_to_level, level + 1))
	animated_sprite.play("idle")
	$VictorySound.play()

func inc_max_score() -> void:
	max_score += 1
	score_label.text = "Coins: " + str(score) + "/" +str(max_score)
	
func _ready():
	previous_scene = get_tree().current_scene
	set_process(true)
	_on_scene_changed(previous_scene)

func _process(_delta):
	var current_scene = get_tree().current_scene
	if current_scene != previous_scene and current_scene != null:
		previous_scene = current_scene
		_on_scene_changed(current_scene)
		
func _on_scene_changed(current_scene) -> void:
	self.visible = true
	var player_list = get_tree().get_nodes_in_group("Player")
	if len(player_list) != 0:
		player = player_list [0] as Player
	if current_scene.has_method("_GameManager_get_game_state"):
		refresh_labels(current_scene._GameManager_get_game_state())
	else:
		refresh_labels(GS.NA)
