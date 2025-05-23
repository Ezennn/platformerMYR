extends Node2D

const SPEED = 30
var direction = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_hitbox: Area2D = $HeadHitbox

func _on_killzone_body_entered(body: Node2D) -> void:
	$HeadHitbox.disconnect("body_entered", Callable(self, "_on_head_hit"))
	
func _on_head_hit(body):
	$Killzone.disconnect("body_entered", Callable(self, "_on_killzone_body_entered"))
	remove_child($Killzone)
	if body.has_method("enemy_bounce"):
		body.enemy_bounce()
		queue_free()  # destroy enemy

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
	if not ray_cast_down.is_colliding():
		position.y += 0.5
