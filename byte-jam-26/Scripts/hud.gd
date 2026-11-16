
extends CanvasLayer

@export var full_heart: Texture2D
@export var damaged_heart: Texture2D

@onready var hearts = [
	$HeartContainer/Heart1,
	$HeartContainer/Heart2,
	$HeartContainer/Heart3
]


func update_hearts(current_health: int) -> void:
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = damaged_heart

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("HUD could not find the player!")
		return

	player.health_changed.connect(update_hearts)
	update_hearts(player.health)
