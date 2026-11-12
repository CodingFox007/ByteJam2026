extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	print("Zombie gonna get you")
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
