# Platformer Game

## Features
- A simple platformer game (closed task)
- Deployed in straight .exe into itch.io
- Login
- Completed within next week


## Tech stack
- GoDot - FrontEnd
- PostGres - Database
- Django - BackEnd Supplementary

  # TO DO
  save method after make level 2
player automatically go up and down small ledgees

Sign done 
pretty lava block 
added everything into tileset
finished level 1

// Slime need to make it into rigidbody2d for it to bounce
//background make infinite extending in levels

level 1: default + tutorial
Level 2: the whole world running paste: Level node just put a script going to the right
func _process(delta: float) -> void:
	position.x -= direction * SPEED * delta

Level 3: walls become elevators
func handle_gravity_and_animation(delta: float) -> void:
	if not is_on_floor() :
		velocity += get_gravity() * delta
		if animated_sprite.animation != "dash":
			play_animation_with_priority("jump")
	if (is_on_wall_left or is_on_wall_right) and jump_x_velocity_override == null:
		# upper clamped using jump velocity to deal with wall jumps
		velocity.y = clamp(velocity.y, -MAX_FALL_SPEED_WHILE_ON_WALL, MAX_FALL_SPEED_WHILE_ON_WALL)
Level 4: start with a bunch of slimes immediately running towards the player flying, need to jump up immediately
Level 5: user dash just stops all movement, consecutive dash and hold down dash enabled

last line become 
velocity.y = clamp(velocity.y, -MAX_FALL_SPEED_WHILE_ON_WALL, JUMP_VELOCITY)
jump velocity is negative

maybe this will become a feature of the game; uncontrollable walls 

