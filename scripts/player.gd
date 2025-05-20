extends CharacterBody2D

class_name Player

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
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
	
func _physics_process(delta: float) -> void:
	# Apply bounce if pending
	if bounce_pending:
		velocity.y = min(velocity.y, JUMP_VELOCITY * 1.5)
		bounce_pending = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and isAlive:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction and isAlive:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite.play("jump")

	move_and_slide()
