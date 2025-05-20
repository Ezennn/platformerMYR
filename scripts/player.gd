extends CharacterBody2D

class_name Player

const SPEED = 130.0
const DASHSPEED = 200.0
const JUMP_VELOCITY = -300.0
const DASHTIME = 0.3

var isAlive = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var doublejump = true
var airdash = true
var is_dashing = false
var dash_timer = 0.0

func setIsAlive(alive: bool) -> void:
	self.isAlive = alive
	
func _physics_process(delta: float) -> void:
		
	
	if Input.is_action_just_pressed("Dash") and airdash == true:
		is_dashing =true
		dash_timer = DASHTIME
		velocity.y = 0
		if not is_on_floor():
			airdash = false
		return
	
	if is_dashing == true :
		if animated_sprite.animation != "Dash" :
			animated_sprite.play("Dash")
		var direction := Input.get_axis("move_left", "move_right")
		if direction :
			velocity.x = direction * DASHSPEED
			animated_sprite.flip_h = direction < 0
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return 
		
	
	if Input.is_action_just_pressed("jump")  and isAlive:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		if not is_on_floor() and doublejump:
			velocity.y = JUMP_VELOCITY
			doublejump = false
			
	var direction := Input.get_axis("move_left", "move_right")
	if direction and isAlive:
		velocity.x = direction * SPEED
		# flips Animated Sprite
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if animated_sprite.animation != "Dash" :
			animated_sprite.play("jump")
			
	
	
	#Add doublejump everytime on floor
	if is_on_floor():
		doublejump = true
		airdash = true
	
	move_and_slide()
