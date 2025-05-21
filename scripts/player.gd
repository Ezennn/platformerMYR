extends CharacterBody2D

class_name Player

const SPEED = 130.0
const DASHSPEED = 200.0
const DASHTIME = 0.3
const JUMP_VELOCITY = -300.0

var refreshable_actions_when_touch_ground : Array[String] = []
var blocking_animation_playing = false
var isAlive : bool = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var bounce_pending := false


func _ready() -> void:
	var killzones = get_tree().get_nodes_in_group("KillZones")

	for zone in killzones:
		zone.player_death.connect(_on_player_death)

func bounce() -> void:
	bounce_pending = true

func _on_player_death() -> void:
	isAlive = false
	$AudioStreamPlayer2D.stream = preload("res://assets/sounds/hurt.wav")
	$AudioStreamPlayer2D.play()
	
func play_animation_for_duration(anim_name: String, desired_duration: float) -> void:
	var sprite_frames = animated_sprite.sprite_frames

	if not sprite_frames.has_animation(anim_name):
		print("Animation not found!")
		return

	var frame_count = sprite_frames.get_frame_count(anim_name)

	if desired_duration <= 0:
		print("Duration must be positive!")
		return

	# Compute the FPS so the animation fits the desired time
	var new_fps = frame_count / desired_duration
	sprite_frames.set_animation_speed(anim_name, new_fps)

	animated_sprite.play(anim_name)
	
# decouple the idle animation 
func _on_animation_finished() -> void:
	blocking_animation_playing = false
	if is_on_floor() and velocity.x == 0:
		animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	move_and_slide()
	if blocking_animation_playing:
		return;
		
	if Input.is_action_just_pressed("dash") and "dash" in refreshable_actions_when_touch_ground:
		refreshable_actions_when_touch_ground.erase("dash")
		velocity.y = 0;
		play_animation_for_duration("dash", DASHTIME)
		$AudioStreamPlayer2D.stream = preload("res://assets/sounds/dash.mp3")
		$AudioStreamPlayer2D.play()
		var direction : int = -1 if animated_sprite.flip_h else 1
		velocity.x = direction * DASHSPEED
		blocking_animation_playing = true
		# must stop other code from running, since blocking animation just started
		return
	
	
	if Input.is_action_just_pressed("jump")  and isAlive:
		var successful_jump : bool = false;
		if is_on_floor():
			successful_jump = true
			velocity.y = JUMP_VELOCITY
		if not is_on_floor() and "double_jump" in refreshable_actions_when_touch_ground:
			successful_jump = true
			velocity.y = JUMP_VELOCITY
			refreshable_actions_when_touch_ground.erase("double_jump")
		if (successful_jump):
			$AudioStreamPlayer2D.stream = preload("res://assets/sounds/jump.mp3")
			$AudioStreamPlayer2D.play()
	
	# Apply bounce if pending
	if bounce_pending:
		velocity.y = min(velocity.y, JUMP_VELOCITY * 1.5)
		bounce_pending = false
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction and isAlive:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if animated_sprite.animation != "dash" :
			animated_sprite.play("jump")
			
	#Add doublejump everytime on floor
	if is_on_floor():
		refreshable_actions_when_touch_ground = ["double_jump", "dash"]
