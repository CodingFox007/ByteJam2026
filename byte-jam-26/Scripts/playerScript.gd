
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Weapon settings
@export var starting_weapon: PackedScene

@onready var animation = $AnimatedSprite2D
@onready var weapon_holder = $WeaponHolder

var current_weapon: Weapon
var facing_direction: int = 1


func _ready() -> void:
	# Start with the pistol
	if starting_weapon != null:
		equip_weapon(starting_weapon)


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED

		# Remember which direction player faces
		if direction > 0:
			facing_direction = 1
		else:
			facing_direction = -1

		# Flip player sprite
		animation.flip_h = facing_direction == -1

		# Flip weapon holder
		weapon_holder.scale.x = facing_direction

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animation logic
	if abs(velocity.x) > 0.1:
		animation.play("walkAnimation")
	else:
		animation.play("idleAnimation")

	# Handle shooting
	if current_weapon != null:
		if current_weapon.automatic:
			if Input.is_action_pressed("shoot"):
				shoot_weapon()
		else:
			if Input.is_action_just_pressed("shoot"):
				shoot_weapon()


# Equip a weapon
func equip_weapon(weapon_scene: PackedScene) -> void:
	if weapon_scene == null:
		return

	# Remove old weapon
	if is_instance_valid(current_weapon):
		current_weapon.queue_free()
		current_weapon = null

	# Add new weapon
	current_weapon = weapon_scene.instantiate()
	weapon_holder.add_child(current_weapon)


# Shoot current weapon
func shoot_weapon() -> void:
	if is_instance_valid(current_weapon):
		current_weapon.shoot(facing_direction)
