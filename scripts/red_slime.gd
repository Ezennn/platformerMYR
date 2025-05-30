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
		on_death()  

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
	var projectile = projectile_scene.instantiate()
	projectile.configure_and_add_to_child(self, global_position, direction, get_parent())

func on_death() -> void:
	animated_sprite.play("Death")
	await animated_sprite.animation_finished
	queue_free()

func _on_ready() -> void:
	var num_frames := animated_sprite.sprite_frames.get_frame_count("Aggressive Idle")
	var shoot_frame := 2 #when the slime has a wide open mouth
	var fps := animated_sprite.sprite_frames.get_animation_speed("Aggressive Idle")
	var anim_time := num_frames / fps
	
	# First shot is out of cycle 
	var wait_time := anim_time * shoot_frame / num_frames # +1 due to zero indexing
	$Timer.wait_time = wait_time
	await get_tree().create_timer(wait_time).timeout
	
	# Future shots are after every full animation
	$Timer.wait_time = anim_time
