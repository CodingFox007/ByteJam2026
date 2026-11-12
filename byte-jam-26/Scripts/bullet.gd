
extends Area2D

@export var speed: float = 800.0
@export var lifetime: float = 2.0

var direction: int = 1
var damage: int = 10

func _ready() -> void:
	# Detect collisions
	body_entered.connect(_on_body_entered)

	# Automatically delete bullet after 2 seconds
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	# Move bullet horizontally
	position.x += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	# Damage zombies
	if body.is_in_group("zombie"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

	# Destroy bullet after hitting something
	queue_free()
