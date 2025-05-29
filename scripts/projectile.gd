#projectile.gd

extends Area2D

@export var speed := 200
@export var direction := Vector2.RIGHT

func  _process(delta : float) -> void:
	position += direction * speed * delta
	
func _on_body_entered(_body : Node2D) -> void:
	$Killzone.dequeue()
	$AnimatedSprite2D.play("onhit")
	#speed = 0
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
