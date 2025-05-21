extends Node2D

const SPEED = 60
var direction = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_hitbox: Area2D = $HeadHitbox
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	head_hitbox.body_entered.connect(_on_head_hit)

func _on_head_hit(body):
	if body.has_method("enemybounce") and body.velocity.y > 0:
		body.enemybounce()
		queue_free()  # destroy enemy
	

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
