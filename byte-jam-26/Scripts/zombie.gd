
extends CharacterBody2D

# Zombie settings
@export var gravity: float = 980.0
@export var speed: float = 100.0

var player: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Follow player
	if is_instance_valid(player):
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed
	else:
		velocity.x = 0

	# Apply movement and collisions
	move_and_slide()

	# Play animations
	if abs(velocity.x) > 0.1:
		animated_sprite.play("zombieWalking")

		# Face the direction of movement
		animated_sprite.flip_h = velocity.x > 0
	else:
		animated_sprite.play("zombieIdle")


# Player enters attention range
func _on_zombie_attention_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


# Player leaves attention range
func _on_zombie_attention_range_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
