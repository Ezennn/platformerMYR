#red_slime
extends Node2D

const SPEED = 30
var direction = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_hitbox: Area2D = $HeadHitbox
@onready var timer: Timer = $Timer
@export var projectile_scene: PackedScene
	
func _on_head_hit(body):
	if body.has_method("enemy_bounce"):
		body.enemy_bounce()
		queue_free()  # destroy enemy

var vel_y : float = 0.0
func _physics_process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
	if ray_cast_down.is_colliding():
		vel_y = 0
	else: 
		vel_y += delta * (ProjectSettings.get_setting("physics/2d/default_gravity") as float)
		position.y += vel_y * delta
		
func _on_timer_timeout() :
	shoot_projectile()
	
func shoot_projectile():
	print("firing")
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	get_parent().add_child(projectile)
	projectile.direction = Vector2(direction, 0)
