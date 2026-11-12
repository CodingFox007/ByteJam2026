
extends CharacterBody2D

# Gravity strength
@export var gravity: float = 980.0

func _physics_process(delta: float) -> void:
	# Apply gravity when the zombie is in the air
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Apply movement and collisions
	move_and_slide()
