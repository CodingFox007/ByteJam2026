
extends CharacterBody2D

# Zombie settings
@export var gravity: float = 980.0
@export var speed: float = 100.0
@export var max_health: int = 100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var zombie_hitbox: Area2D = $zombieHitbox

# Zombie variables
var health: int
var player: Node2D = null
var player_in_killzone: bool = false
var is_attacking: bool = false
var is_dead: bool = false


func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Stop and attack when player is in the killzone
	if player_in_killzone:
		velocity.x = 0

		if not is_attacking:
			attack()

		move_and_slide()
		return

	# Finish the current attack before chasing again
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# Follow player
	if is_instance_valid(player):
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed
	else:
		velocity.x = 0

	move_and_slide()

	# Play walking or idle animation
	if abs(velocity.x) > 0.1:
		animated_sprite.play("zombieWalking")

		# Face direction of movement
		animated_sprite.flip_h = velocity.x > 0
	else:
		animated_sprite.play("zombieIdle")


func attack() -> void:
	if is_dead or is_attacking:
		return

	is_attacking = true
	velocity.x = 0

	animated_sprite.play("zombieHit")

	# Wait for the attack animation to finish
	await animated_sprite.animation_finished

	if is_dead:
		return

	is_attacking = false


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health = max(health - amount, 0)
	health_bar.value = health

	if health <= 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	is_attacking = false
	player_in_killzone = false
	velocity = Vector2.ZERO

	# Disable killzone and stop its timer
	zombie_hitbox.set_deferred("monitoring", false)
	zombie_hitbox.get_node("Timer").stop()

	# Stop collisions with player
	$CollisionShape2D.set_deferred("disabled", true)

	# Hide health bar
	health_bar.hide()

	# Play death animation
	animated_sprite.play("zombieDeath")

	await animated_sprite.animation_finished

	queue_free()


# Player enters attention range
func _on_zombie_attention_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


# Player leaves attention range
func _on_zombie_attention_range_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
