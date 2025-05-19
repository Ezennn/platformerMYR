extends CharacterBody2D

class_name Player

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var isAlive = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func setIsAlive(alive: bool) -> void:
	self.isAlive = alive
	
func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and isAlive:
		velocity.y = JUMP_VELOCITY

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
		animated_sprite.play("jump")
		
	move_and_slide()
