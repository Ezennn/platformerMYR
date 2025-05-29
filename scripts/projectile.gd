#projectile.gd

extends Area2D

@export var speed := 200
@export var direction := Vector2.RIGHT

func  _process(delta : float) -> void:
	position += direction * speed * delta
	
func _on_body_entered(body : Node2D) -> void:
	if body.is_in_group("Enemy"):
		return
	self.collision_mask = 0
	$Killzone.collision_mask = 0
	$Timer.queue_free()
	speed = 0
	GameManager.play_animation_for_duration("onhit", GameManager.DEATH_TIME, $AnimatedSprite2D)
	await $AnimatedSprite2D.animation_finished
	queue_free()
		
func _ready() :
	$AnimatedSprite2D.play("start")
	$Timer.start()
	
func _on_timer_timeout() :
	$AnimatedSprite2D.play("onhit")
	speed = 0
	await $AnimatedSprite2D.animation_finished
	queue_free()
