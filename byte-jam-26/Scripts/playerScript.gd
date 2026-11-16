extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var walk: AnimatedSprite2D = $AnimationHolder/Walk
@onready var jump: AnimatedSprite2D = $AnimationHolder/Jump
@onready var idle: AnimatedSprite2D = $AnimationHolder/Idle
@export var walk_hand_offset: Vector2 = Vector2(12, -2)
@export var idle_hand_offset: Vector2 = Vector2(-5, 10)
@export var jump_hand_offset: Vector2 = Vector2(-10, -5)

@export var starting_weapon: PackedScene

@onready var weapon_holder: Node2D = $WeaponHolder

var current_weapon: Weapon

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
		
	# Flip gun with character
	if walk.flip_h:
		weapon_holder.scale.x = -1.0
	else:
		weapon_holder.scale.x = 1.0

	update_weapon_position()
	
	update_weapon_position()

func _ready() -> void:
	equip_weapon(starting_weapon)


func equip_weapon(weapon_scene: PackedScene) -> void:
	if weapon_scene == null:
		return

	var new_weapon = weapon_scene.instantiate() as Weapon

	if new_weapon == null:
		push_error("Invalid weapon scene!")
		return

	if current_weapon != null:
		current_weapon.queue_free()

	weapon_holder.add_child(new_weapon)
	new_weapon.position = Vector2.ZERO
	current_weapon = new_weapon
		
func update_weapon_position() -> void:
	var active_sprite: AnimatedSprite2D
	var hand_offset: Vector2

	if jump.visible:
		active_sprite = jump
		hand_offset = jump_hand_offset
	elif walk.visible:
		active_sprite = walk
		hand_offset = walk_hand_offset
	else:
		active_sprite = idle
		hand_offset = idle_hand_offset

	var facing_left = active_sprite.flip_h

	var offset_x = hand_offset.x
	if facing_left:
		offset_x = -offset_x

	weapon_holder.position = active_sprite.position + Vector2(offset_x, hand_offset.y)


func _process(_delta: float) -> void:
	if current_weapon == null:
		return

	if Input.is_action_pressed("shoot"):
		var direction = -1 if walk.flip_h else 1
		current_weapon.shoot(direction)
	
