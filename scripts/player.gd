extends CharacterBody2D
class_name Player

@export var god_mode : bool = false
const SPEED = 100.0
const DASHSPEED = 200.0
const DASHTIME = 0.3
const DASH_INVULNERABILITY_TIME = DASHTIME * 2
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -450.0
const MAX_FALL_SPEED_WHILE_ON_WALL= 20
const WALLJUMP_HOR_SPEED = 150.0
const LADDER_VELOCITY = -80

# Constants for double tap timing (assumed in GameConstants)
const DOUBLE_TAP_MAX_DELAY = GameConstants.DOUBLE_TAP_MAX_DELAY
const DEATH_TIME = GameConstants.DEATH_TIME * GameConstants.DEATH_ENGINE_SLOWDOWN

# triggered when win game by gamemanager
var player_control := true:
	set(_player_control):
		blocking_animation_playing = _player_control
		player_control = _player_control

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
	velocity.y = max(velocity.y, 0)
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
	if (is_on_floor() or is_on_ladder()) and velocity.x == 0:
		play_animation_with_priority("idle")

func parry() -> void:
	var overlapping_areas = $ParryArea2D.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("Projectile"):
			var projectile = area
			if (projectile.position.x > self.global_position.x && projectile.direction.x == -1) or (projectile.position.x < self.global_position.x && projectile.direction.x == 1):
				projectile.parent = self
				projectile.direction *= -1

func dash() -> void:
	# invulnerable to Killzones
	death_disable()
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
		parry()
	
	# Disable invulnerability
	if not god_mode:
		await get_tree().create_timer(DASH_INVULNERABILITY_TIME).timeout
		set_collision_layer_value(4, true)
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	update_wall_contact()
	if blocking_animation_playing:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var double_tap_dash_key_pressed = false

	if player_control and Input.is_action_just_pressed("move_left"):
		if current_time - last_tap_time_left < DOUBLE_TAP_MAX_DELAY:
			double_tap_dash_key_pressed = true
			animated_sprite.flip_h = true
		last_tap_time_left = current_time

	if player_control and Input.is_action_just_pressed("move_right"):
		if current_time - last_tap_time_right < DOUBLE_TAP_MAX_DELAY:
			double_tap_dash_key_pressed = true
			animated_sprite.flip_h = false
		last_tap_time_right = current_time

	if (player_control and Input.is_action_just_pressed("dash") or double_tap_dash_key_pressed) and "dash" in refreshable_actions_on_contact:
		dash()
		blocking_animation_playing = true
		return

	if player_control and Input.is_action_just_pressed("jump"):
		if is_on_ladder():
			velocity.y = LADDER_VELOCITY
		elif try_jump():
			audio_player.stream = preload("res://assets/sounds/jump.mp3")
			audio_player.play()
	
	if player_control and Input.is_action_just_pressed("down"):
		set_collision_mask_value(3, false)
		var bottom_tile_ladder : bool = $RayCastDown.get_collider() != null and $RayCastDown.get_collider().is_in_group("Ladder")
		if is_on_floor() and not bottom_tile_ladder:
			pass
		elif is_on_ladder() or bottom_tile_ladder:
			velocity.y = - LADDER_VELOCITY
		else:
			velocity.y = 150
	if !player_control or Input.is_action_just_released("down"):
		set_collision_mask_value(3, true)
	if bounce_pending:
		velocity.y = min(velocity.y, BOUNCE_VELOCITY)
		bounce_pending = false

	handle_gravity_and_animation(delta)
	handle_movement()
	
	if is_on_floor() or is_on_wall_left or is_on_wall_right or is_on_ladder():
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

#func small_ledge_detected(direction : float) -> bool:
	#for ray_cast in [ray_cast_down, ray_cast_down_short, ray_cast_up]:
		#ray_cast.target_position.x = 4 * direction
	#if ray_cast_down.is_colliding() and not ray_cast_up.is_colliding() and not ray_cast_down_short.is_colliding():
		#print("Collision detected")
		#print(ray_cast_down.get_collider())
		#return true
	#else:
		#print("Collision not detected")
		#return false
	
func handle_movement() -> void:
	var direction = Input.get_axis("move_left", "move_right") if player_control else 0.0
	if jump_x_velocity_override != null:
		velocity.x = jump_x_velocity_override
		jump_x_velocity_override = null
	elif direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		if not((direction>0 && is_on_wall_right) || (direction <0 && is_on_wall_left)):
			animated_sprite.play("run")
		#if small_ledge_detected(direction):
			#position.y -= 4
		
	elif is_on_floor() or is_on_ladder():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
		

func is_on_ladder() -> bool:
	var overlapping_areas = $LadderArea2D.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("Ladder"):
			return true
	return false

	
func handle_gravity_and_animation(delta: float) -> void:
	#gravity disabled while on ladder
	if is_on_ladder():
		if player_control and (Input.is_action_pressed("down") or Input.is_action_pressed("jump")):
			return
		else:
			velocity.y = 0
			return
	if not is_on_floor():
		velocity += get_gravity() * delta
		play_animation_with_priority("jump")
	if is_on_wall_left or is_on_wall_right:
		# upper clamped using jump velocity to deal with wall jumps
		velocity.y = clamp(velocity.y, JUMP_VELOCITY, MAX_FALL_SPEED_WHILE_ON_WALL)

func set_camera_position_smoothing(smoothening_value : bool) -> void:
	$Camera2D.position_smoothing_enabled = smoothening_value

func death_disable() -> void:
	set_collision_layer_value(4, false)

func death_enable() -> void:
	set_collision_layer_value(4, true)
	
func _on_ready() -> void:
	if god_mode:
		print("God mode is ON in the level %i screen. Disable God Mode in the scene Player Inspector to enable deaths".format(GameManager.level))
		death_disable()
	else:
		death_enable()
