# Platformer Game

## Features
- A simple platformer game (closed task)
- Deployed in straight .exe into itch.io
- Login
- Completed within next week


## Tech stack

GoDOt - application
itch.io - deployment

## Level Deets
- Level 1 - Ruins (inner temple)
- Level 2 - Ruins (outer temple)
- Level 3 - Forest with slime
- Level 4 - Town (name to be decided)
- Level 5 - Inside Castle (Boss Level)

### Story Progression ###
- You are an incel. You clicked on the link "Single Horses Around my area". The Horse God did not like it. He sent a thunder and blow you into smithereens. You wake up to see yourself as a knight stuck at a temple. Somehow you horses don't exist in this world and that it is your duty to invent them. The first move of your story would obvs be to travel to the closest town to acquire about what the world is like.
- Little do u know that because horses weren't invented yet, the world is falling apart. The ruined temples and existence of slimes proves this. Once you have invented horses, the Horse Gods promise to forgive you and send you back with the working link.


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

