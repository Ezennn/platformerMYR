extends RigidBody2D

const SPEED = 100
var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_hitbox: Area2D = $HeadHitbox

func _ready():
	# Connect signals
	head_hitbox.body_entered.connect(_on_head_hit)
	$Killzone.body_entered.connect(_on_killzone_body_entered)

func _physics_process(delta: float) -> void:
	# Check for wall collisions and change direction
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	# speed = 30
	if (abs(linear_velocity.y) < 0.01):
		var impulse = Vector2(direction * SPEED, 0)
		apply_central_impulse(impulse * delta)

	# Apply gravity force
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") as float
	var gravity_vector = Vector2.DOWN * gravity
	apply_central_force(gravity_vector * mass)

func _on_killzone_body_entered(body: Node2D) -> void:
	head_hitbox.body_entered.disconnect(_on_head_hit)

func _on_head_hit(body):
	$Killzone.body_entered.disconnect(_on_killzone_body_entered)
	remove_child($Killzone)
	if body.has_method("enemy_bounce"):
		body.enemy_bounce()
	queue_free()  # Destroy enemy
