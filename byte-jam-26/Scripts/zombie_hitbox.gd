
extends Area2D

@onready var timer: Timer = $Timer
@onready var zombie = get_parent()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not zombie.is_dead:
		print("Zombie gonna get you!")

		# Tell zombie to start attacking
		zombie.player_in_killzone = true

		# Start the kill timer
		timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Tell zombie to stop attacking
		zombie.player_in_killzone = false

		# Stop the kill timer
		timer.stop()


func _on_timer_timeout() -> void:
	if not zombie.is_dead and zombie.player_in_killzone:
		get_tree().reload_current_scene()
