extends CharacterBody2D
class_name Player

const SPEED = 130.0
const DASHSPEED = 200.0
const DASHTIME = 0.3
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -450.0
const MAX_FALL_SPEED_WHILE_ON_WALL= 20
const WALLJUMP_HOR_SPEED = 150.0
const FALL_THROUGH_TIMER = 0.2  # Duration to disable collision in seconds

# Constants for double tap timing (assumed in GameConstants)
const DOUBLE_TAP_MAX_DELAY = GameConstants.DOUBLE_TAP_MAX_DELAY
const DEATH_TIME = GameConstants.DEATH_TIME * GameConstants.DEATH_ENGINE_SLOWDOWN

# triggered when win game by gamemanager
var player_control := true:
	set(_player_control):
		blocking_animation_playing = _player_control
		player_control = _player_control
		
var parry_active =false 
var parry_timer = Timer.new()
		
var last_tap_time_left: float = -1.0
var last_tap_time_right: float = -1.0
var refreshable_actions_on_contact: Array[String] = []
# please rename the blocking_animation_playing variable later so its blocking other keyboard actions not blocking the animations. 
var blocking_animation_playing: bool = false
var bounce_pending: bool = false
var is_on_wall_left: bool = false
var is_on_wall_right: bool = false
var jump_x_velocity_override = null
var walljump_leftright_suppression_timer
# please look through and check whether some of the code is no longer needed due to the animation priority
var current_animation_priority = 0
var animation_priority = {
	"dead": 5,
	"dash": 4,
	"jump": 3,
	"run": 1,
	"idle": 1
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	add_child(parry_timer)
	parry_timer.wait_time = DASHTIME
	parry_timer.one_shot = true
	parry_timer.connect("timeout", Callable(self,"_on_parry_timeout"))
	# the below code is no longer required, since killzones communicate directly to players
	#for zone in get_tree().get_nodes_in_group("KillZones"):
		#zone.player_death.connect(on_player_death)

func update_wall_contact() -> void:
	is_on_wall_left = $RayCastLeft.get_collider() is TileMapLayer
	is_on_wall_right = $RayCastRight.get_collider() is TileMapLayer

func play_animation_with_priority(anim_name: String, duration: float = 0.0, sprite : AnimatedSprite2D = animated_sprite) -> void:
	var priority = animation_priority.get(anim_name)
	if priority < current_animation_priority:
		# Current animation is higher priority, ignore
		return
	
	current_animation_priority = priority
	
	if duration > 0:
		play_animation_for_duration(anim_name, duration, sprite)
	else:
		if animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name)
		else:
			print("Animation not found:", anim_name)

func bounce() -> void:
	bounce_pending = true
	
func enemy_bounce():
	velocity.y = JUMP_VELOCITY * 1.2
	velocity.x = 0
	audio_player.stream = preload("res://assets/sounds/jump.mp3")
	audio_player.play()

func on_player_death() -> void:
	blocking_animation_playing = true
	play_animation_for_duration("dead", DEATH_TIME)
	audio_player.stream = preload("res://assets/sounds/hurt.wav")
	audio_player.play()

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

func _on_animation_finished() -> void:
	current_animation_priority = 0
	blocking_animation_playing = false
	if is_on_floor() and velocity.x == 0:
		play_animation_with_priority("idle")

func dash() -> void:
	refreshable_actions_on_contact.erase("dash")
	velocity.y = 0
	play_animation_for_duration("dash", DASHTIME)
	audio_player.stream = preload("res://assets/sounds/dash.mp3")
	audio_player.play()
	if Input.is_action_pressed("move_left"):
		velocity.x = -1 *DASHSPEED
	elif Input.is_action_pressed("move_right"):
		velocity.x = 1 *DASHSPEED
	else :
		velocity.x = 0 * DASHSPEED #frontflip
		parry_active = true #parry
		parry_timer.start()

func _on_parry_timeout() :
	parry_active = false
	
func _physics_process(delta: float) -> void:
	if (player_control):
		physics_when_playing(delta)
	else:
		physics_player_control_detached(delta)

func physics_when_playing(delta: float) -> void: 
	move_and_slide()
	update_wall_contact()
	if blocking_animation_playing:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var double_tap_dash_key_pressed = false

	if Input.is_action_just_pressed("move_left"):
		if current_time - last_tap_time_left < DOUBLE_TAP_MAX_DELAY:
			double_tap_dash_key_pressed = true
			animated_sprite.flip_h = true
		last_tap_time_left = current_time

	if Input.is_action_just_pressed("move_right"):
		if current_time - last_tap_time_right < DOUBLE_TAP_MAX_DELAY:
			double_tap_dash_key_pressed = true
			animated_sprite.flip_h = false
		last_tap_time_right = current_time

	if (Input.is_action_just_pressed("dash") or double_tap_dash_key_pressed) and "dash" in refreshable_actions_on_contact:
		dash()
		blocking_animation_playing = true
		return

	if Input.is_action_just_pressed("jump"):
		if try_jump():
			audio_player.stream = preload("res://assets/sounds/jump.mp3")
			audio_player.play()
	
	if Input.is_action_just_pressed("down"):
		if is_on_floor():
			set_collision_mask_value(3, false)
			await get_tree().create_timer(FALL_THROUGH_TIMER).timeout
			set_collision_mask_value(3, true)
		else:
			velocity.y = 150
			
	if bounce_pending:
		velocity.y = min(velocity.y, BOUNCE_VELOCITY)
		bounce_pending = false

	handle_gravity_and_animation(delta)
	handle_movement()
	
	if is_on_floor() or is_on_wall_left or is_on_wall_right:
		refreshable_actions_on_contact = ["double_jump", "dash"]

func try_jump() -> bool:
	if not is_on_floor():
		if is_on_wall_left:
			jump_x_velocity_override = WALLJUMP_HOR_SPEED
		elif is_on_wall_right: 
			jump_x_velocity_override = - WALLJUMP_HOR_SPEED
	if is_on_floor() or is_on_wall_left or is_on_wall_right:
		velocity.y = JUMP_VELOCITY
		return true
	elif "double_jump" in refreshable_actions_on_contact:
		velocity.y = JUMP_VELOCITY
		refreshable_actions_on_contact.erase("double_jump")
		return true
	return false

func handle_movement() -> void:
	var direction = Input.get_axis("move_left", "move_right")
	if jump_x_velocity_override != null:
		velocity.x = jump_x_velocity_override
		jump_x_velocity_override = null
	elif direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

func handle_gravity_and_animation(delta: float) -> void:
	if not is_on_floor() :
		velocity += get_gravity() * delta
		play_animation_with_priority("jump")
	if is_on_wall_left or is_on_wall_right:
		# upper clamped using jump velocity to deal with wall jumps
		velocity.y = clamp(velocity.y, JUMP_VELOCITY, MAX_FALL_SPEED_WHILE_ON_WALL)

# triggered when win game by gamemanager
func physics_player_control_detached(delta: float) -> void:
	move_and_slide()
	if bounce_pending:
		velocity.y = min(velocity.y, BOUNCE_VELOCITY)
		bounce_pending = false
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
	handle_gravity_and_animation(delta)
