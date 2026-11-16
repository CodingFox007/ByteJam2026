
extends Area2D

@onready var timer: Timer = $Timer
@onready var zombie = get_parent()

var player_in_range: Node2D = null


func _ready() -> void:
	timer.wait_time = 1.0
	timer.one_shot = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not zombie.is_dead:

		player_in_range = body
		zombie.player_in_killzone = true

		hit_player()
		timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:

		stop_attacking()


func _on_timer_timeout() -> void:
	if zombie.is_dead:
		stop_attacking()
		return

	# Check whether the player is STILL inside the hitbox
	if not is_instance_valid(player_in_range):
		stop_attacking()
		return

	if not overlaps_body(player_in_range):
		stop_attacking()
		return

	hit_player()


func hit_player() -> void:
	if zombie.is_dead:
		return

	if not is_instance_valid(player_in_range):
		return

	if not overlaps_body(player_in_range):
		return

	if player_in_range.has_method("take_damage"):
		if player_in_range.can_take_damage:
			player_in_range.take_damage(1)

			if player_in_range.has_method("hurtAnimation"):
				player_in_range.hurtAnimation()


func stop_attacking() -> void:
	player_in_range = null
	zombie.player_in_killzone = false
	timer.stop()
