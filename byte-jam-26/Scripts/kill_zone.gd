
extends Area2D

@onready var timer: Timer = $Timer

var player: Node2D = null


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player fell out of the map!")

		player = body
		timer.start()


func _on_timer_timeout() -> void:
	if is_instance_valid(player):
		player.die()
