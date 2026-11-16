extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var walk: AnimatedSprite2D = $AnimationHolder/Walk
@onready var jump: AnimatedSprite2D = $AnimationHolder/Jump
@onready var idle: AnimatedSprite2D = $AnimationHolder/Idle

# Functions for animation
func jumpAnimation():
	walk.hide()
	idle.hide()
	jump.show()
	
	if not jump.is_playing():
		jump.play()
		
func walkAnimation():
	jump.hide()
	idle.hide()
	walk.show()
	walk.animation = "walkAnimation"
	
func idleAnimation():
	jump.hide()
	walk.hide()
	idle.show()
	idle.animation = "idleAnimation"
			
func _physics_process(delta: float) -> void:
	
	# Add animations
	if velocity.x > 1 or velocity.x < -1 and is_on_floor():
		walkAnimation()
		walk.play("walkAnimation")
		
	if velocity.x == 0 and is_on_floor():
		idleAnimation()
			
	# Add the gravity and play jump.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jumpAnimation()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var get_direction := Input.get_axis("left", "right")
	if get_direction:
		velocity.x = get_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	# Flip Sprite
	if velocity.x < 0:
		walk.flip_h = true
		idle.flip_h = true
		jump.flip_h = true
	elif velocity.x > 0:
		walk.flip_h = false
		idle.flip_h = false
		jump.flip_h = false

		
		

	
