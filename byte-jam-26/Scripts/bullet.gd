extends Area2D

@export var speed: float = 800.0
@export var lifetime: float = 2.0

var direction: int = 1
var travel_direction: Vector2 = Vector2.ZERO
var damage: int = 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if travel_direction == Vector2.ZERO:
		travel_direction = Vector2(direction, 0)

	global_position += travel_direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Damage zombies
	if body.is_in_group("zombie") and body.has_method("take_damage"):
		body.take_damage(damage)

	# Destroy bullet when hitting anything solid
	queue_free()
