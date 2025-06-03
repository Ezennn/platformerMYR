extends Node

# ---------------------------------------
# CONSTANTS & ENUMS
# ---------------------------------------

const DEATH_TIME := GameConstants.DEATH_TIME * GameConstants.DEATH_ENGINE_SLOWDOWN

enum COLLECTIBLE { SWORD, SHIELD, CROWN }
enum GAME_SCREEN_STATE { LEVEL, LOSE, WIN, LEVEL_SELECT, NA }
const GS := GAME_SCREEN_STATE

# ---------------------------------------
# EXPORTED PROPERTIES
# ---------------------------------------

@export var reset_saves: bool = false
@export var unlocked_up_to_level: int = 1
@export var game_screen: GAME_SCREEN_STATE = GS.LEVEL

# ---------------------------------------
# MEMBER VARIABLES
# ---------------------------------------

# To‐collect vs. already‐collected sets (typed Arrays of enum)
var _items_to_collect: Array[COLLECTIBLE] = []
var _collected_items: Array[COLLECTIBLE] = []

# Score tracking
var max_score: int = 0
var score: int = 0

# Current level number
var level: int

# Reference to previous scene, to detect scene changes
var _previous_scene: Node = null

# Reference to the Player node (set at runtime when the scene changes)
var player: Player

# Default requirements label prefix
const _DEFAULT_REQ_PREFIX := "Requirements:\n"

# ---------------------------------------
# ONREADY REFERENCES
# ---------------------------------------

@onready var _collectible_pickup_sound: AudioStreamPlayer2D = $CollectiblePickupSound
@onready var _score_label: Label = $ScoreRect/ScoreLabel
@onready var _animated_sprite: AnimatedSprite2D = $ColorRect/AnimatedSprite2D
@onready var _win_requirements_label: Label = $WinRequirementsTextBox/WinRequirementsTextBox/MarginContainer/Label

# ---------------------------------------
# LIFECYCLE CALLBACKS
# ---------------------------------------

func _ready() -> void:
	self.visible = true
	set_process(true)
	load_progress()
	_on_scene_changed(get_tree().current_scene)

func _process(_delta: float) -> void:
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene != _previous_scene:
		_previous_scene = current_scene
		_on_scene_changed(current_scene)

# ---------------------------------------
# SCENE CHANGE HANDLING
# ---------------------------------------

func _on_scene_changed(current_scene: Node) -> void:
	_reset_score_counts()
	self.visible = true

	# Locate Player in the new scene, if any
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] as Player

	if "game_state" in current_scene:
		apply_game_state(current_scene.game_state)
	else:
		push_warning("Scene %s has no 'game_state'; defaulting to LEVEL." % current_scene.name)
		apply_game_state(GS.LEVEL)

# ---------------------------------------
# GAME STATE & UI REFRESH
# ---------------------------------------

func apply_game_state(state: GAME_SCREEN_STATE= GS.NA) -> void:
	game_screen = state
	_hide_all_groups()
	match state:
		GS.LEVEL:
			_show_group("LevelGroup")
			if "level" in get_tree().current_scene:
				level = get_tree().current_scene.level
			else:
				push_error("Current scene's 'level' property missing; defaulting to level = 1.")
				level = 1
		GS.LOSE:
			_show_group("DeadGroup")
		GS.WIN:
			player.death_disable()
			_show_group("WinGroup")
		_: 
			pass  # For LEVEL_SELECT, NA, etc. no immediate UI changes

# Hide every child node before selectively showing those in a specific group
func _hide_all_groups() -> void:
	for child in get_children():
		child.visible = false

func _show_group(group_name: String) -> void:
	for child in get_children():
		if child.is_in_group(group_name):
			child.visible = true

# ---------------------------------------
# SCORE HANDLING
# ---------------------------------------

func _reset_score_counts() -> void:
	score = 0
	max_score = 0
	for coin in get_tree().get_nodes_in_group("Coin"):
		max_score += 1
	_update_score_label()

func add_point() -> void:
	score += 1
	_update_score_label()

func _update_score_label() -> void:
	_score_label.text = "Coins: %d/%d" % [score, max_score]

# ---------------------------------------
# COLLECTIBLE HANDLING
# ---------------------------------------

# Register a collectible that must be gathered in this level
func register_collectible(item: COLLECTIBLE) -> void:
	if item in _items_to_collect:
		return
	_items_to_collect.append(item)
	_update_requirements()

# Called when the player actually collects a given item
func collect_item(item: COLLECTIBLE) -> void:
	if item in _collected_items:
		return
	_collected_items.append(item)
	_play_collect_sound()
	_update_requirements()
	_check_win_condition()

func _play_collect_sound() -> void:
	if _collectible_pickup_sound:
		_collectible_pickup_sound.play()

# Update the on‐screen “Requirements” label to show which collectibles are done/pending
func _update_requirements() -> void:
	var text := _DEFAULT_REQ_PREFIX
	for item in _items_to_collect:
		var name : String = COLLECTIBLE.keys()[item].capitalize()
		if item in _collected_items:
			text += "%s: Done\n" % name
		else:
			text += "%s: Pending\n" % name
	_win_requirements_label.text = text

# Check if all registered items have been collected
func _check_win_condition() -> void:
	if _items_match(_items_to_collect, _collected_items):
		# If the pickup sound is still playing, wait for it to finish
		if _collectible_pickup_sound.playing:
			var duration := _collectible_pickup_sound.stream.get_length()
			await get_tree().create_timer(duration).timeout
		_on_level_win(level)

# Compare two Arrays of COLLECTIBLE to see if they contain the same multiset of entries
func _items_match(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	# Count occurrences in each array; return false on any mismatch
	for entry in a:
		if a.count(entry) != b.count(entry):
			return false
	return true

# ---------------------------------------
# WIN / LOSE LOGIC
# ---------------------------------------

func on_player_death() -> void:
	apply_game_state(GS.LOSE)
	_play_death_animation()
	await _animated_sprite.animation_finished
	score = 0
	_clear_collectibles()
	apply_game_state(GS.LEVEL)

func _play_death_animation() -> void:
	play_animation_for_duration("dead", DEATH_TIME)

func play_animation_for_duration(anim_name: String, duration: float, sprite: AnimatedSprite2D = _animated_sprite) -> void:
	var frames := sprite.sprite_frames
	if not frames.has_animation(anim_name):
		push_error("Animation '%s' not found!" % anim_name)
		return
	if duration <= 0:
		push_error("Animation duration must be positive!")
		return
	var frame_count := frames.get_frame_count(anim_name)
	var new_fps := frame_count / duration
	frames.set_animation_speed(anim_name, new_fps)
	sprite.play(anim_name)

func _on_level_win(current_level: int) -> void:
	apply_game_state(GS.WIN)
	if player:
		player.player_control = false
	# Shift the sprite upwards/leftwards for a “victory stance”
	_animated_sprite.position += Vector2(-122, -150)
	$WinLabel.text = "Level %d Won!" % current_level
	unlocked_up_to_level = min(5, max(unlocked_up_to_level, current_level + 1))
	_animated_sprite.play("idle")
	$VictorySound.play()
	_clear_collectibles()

# ---------------------------------------
# RESET / CLEAR HELPERS
# ---------------------------------------

func _clear_collectibles() -> void:
	_items_to_collect.clear()
	_collected_items.clear()

# ---------------------------------------
# TIMESCALE & LEVEL RELOAD (if needed)
# ---------------------------------------

func _handle_death_timescale() -> void:
	Engine.time_scale = GameConstants.DEATH_ENGINE_SLOWDOWN
	await get_tree().create_timer(DEATH_TIME).timeout
	Engine.time_scale = 1
	get_tree().paused = false
	get_tree().reload_current_scene()


# ---------------------------------------
# SAVES
# ---------------------------------------
const SAVE_PATH := "user://save_data.save"

func save_progress():
	if reset_saves:
		unlocked_up_to_level = 1
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return
	var data := {
		"unlocked_up_to_level": unlocked_up_to_level
	}
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_progress():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content := file.get_as_text()
		var result = JSON.parse_string(content)
		if typeof(result) == TYPE_DICTIONARY and result.has("unlocked_up_to_level"):
			unlocked_up_to_level = result["unlocked_up_to_level"]
		if reset_saves:
			unlocked_up_to_level = 1
		file.close()

func quit():
	save_progress()
	get_tree().quit()
