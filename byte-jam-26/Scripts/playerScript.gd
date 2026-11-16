extends CharacterBody2D

@export var knockback_distance: float = 100.0
@export var knockback_duration: float = 0.2
@export var walk_hand_offset: Vector2 = Vector2(12, -2)
@export var idle_hand_offset: Vector2 = Vector2(-5, 10)
@export var jump_hand_offset: Vector2 = Vector2(-10, -5)
@export var starting_weapon: PackedScene
@export var max_health: int = 3
@export var hit_cooldown: float = 1.0

@onready var walk: AnimatedSprite2D = $AnimationHolder/Walk
@onready var jump: AnimatedSprite2D = $AnimationHolder/Jump
@onready var idle: AnimatedSprite2D = $AnimationHolder/Idle
@onready var hurt: AnimatedSprite2D = $AnimationHolder/Hurt
@onready var weapon_holder: Node2D = $WeaponHolder

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var knockback_velocity: float = 0.0
var knockback_time_left: float = 0.0
var is_hurt: bool = false
var current_weapon: Weapon
var health: int = 3
var can_take_damage: bool = true
var is_dead: bool = false

signal health_changed(current_health: int)

# Functions for animation
func jumpAnimation():
	walk.hide()
	idle.hide()
	jump.show()
	
	if not jump.is_playing():
		jump.play()
		

func hurtAnimation() -> void:
	if is_hurt or is_dead:
		return

	is_hurt = true

	# Hide all normal sprites
	walk.hide()
	idle.hide()
	jump.hide()

	# Show hurt animation
	hurt.flip_h = walk.flip_h
	hurt.show()
	hurt.play("hurtAnimation")

	# Wait for animation to finish
	await hurt.animation_finished

	# Hide hurt sprite
	hurt.hide()

	is_hurt = false

	
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
			
func apply_knockback(zombie_position: Vector2) -> void:
	var direction: float = sign(global_position.x - zombie_position.x)

	# Default to right if both characters share the same X position
	if direction == 0:
		direction = 1.0

	knockback_velocity = direction * (knockback_distance / knockback_duration)
	knockback_time_left = knockback_duration

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Only play normal animations when player isn't hurt
	if not is_hurt:
		if not is_on_floor():
			jumpAnimation()

		elif abs(velocity.x) > 1:
			walkAnimation()
			walk.play("walkAnimation")

		else:
			idleAnimation()
			idle.play("idleAnimation")

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle horizontal movement
	if knockback_time_left > 0.0:
		# Temporarily override movement during knockback
		velocity.x = knockback_velocity
		knockback_time_left = maxf(knockback_time_left - delta, 0.0)
	else:
		# Normal player movement
		var get_direction := Input.get_axis("left", "right")
		if get_direction:
			velocity.x = get_direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Flip character sprites
	if velocity.x < 0:
		walk.flip_h = true
		idle.flip_h = true
		jump.flip_h = true
		hurt.flip_h = true

	elif velocity.x > 0:
		walk.flip_h = false
		idle.flip_h = false
		jump.flip_h = false
		hurt.flip_h = false

	# Flip gun with character
	if walk.flip_h:
		weapon_holder.scale.x = -1.0
	else:
		weapon_holder.scale.x = 1.0

	update_weapon_position()


func _ready() -> void:
	health = max_health
	equip_weapon(starting_weapon)
	health_changed.emit(health)


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
	

func take_damage(amount: int = 1) -> void:
	if not can_take_damage or is_dead:
		return

	health = max(health - amount, 0)
	health_changed.emit(health)

	print("Player health: ", health)

	if health <= 0:
		die()
		return

	can_take_damage = false
	await get_tree().create_timer(hit_cooldown, false).timeout

	if not is_dead:
		can_take_damage = true



func die() -> void:
	if is_dead:
		return

	is_dead = true
	print("Player died!")

	var death_screen = get_tree().current_scene.get_node("DeathUI/DeathScreen")

	if death_screen:
		death_screen.show_death_screen()
