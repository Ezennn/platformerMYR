#projectile.gd

extends Area2D

var parent : Node2D
@export var speed := 200
@export var direction := Vector2.RIGHT

func  _process(delta : float) -> void:
	position += direction * speed * delta


func _on_body_entered(body : Node2D) -> void:
	if (body == null): 
		return
	if parent.is_inside_tree() and (parent.is_ancestor_of(body) or parent == body):
		return
	
	# killzone does not play well with moving StaticBody2D. Manually implement slime death here
	if body.is_in_group("Enemy") && body.has_method("on_death"):
		body.on_death()
	self.collision_mask = 0
	$Killzone.collision_mask = 0
	$Timer.queue_free()
	speed = 0
	GameManager.play_animation_for_duration("onhit", GameManager.DEATH_TIME, $AnimatedSprite2D)
	await $AnimatedSprite2D.animation_finished
	queue_free()

func configure_and_add_to_child(projectile_caster : Node2D, _position : Vector2, _direction : int, node_parent : Node2D) -> void:
	parent = projectile_caster
	self.position = _position 
	self.direction = Vector2(_direction, 0)
	node_parent.add_child(self)
	
func _ready() :
	# remove the following line if you want projectiles to interact with the world and not just the player
	collision_mask = 4
	$AnimatedSprite2D.play("start")
	$Timer.start()
	body_entered.connect(_on_body_entered)
	
func _on_timer_timeout() :
	$AnimatedSprite2D.play("onhit")
	speed = 0
	await $AnimatedSprite2D.animation_finished
	queue_free()
