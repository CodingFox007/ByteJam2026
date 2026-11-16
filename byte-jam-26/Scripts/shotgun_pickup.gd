extends Node2D

@export var weapon_scene: PackedScene

@onready var interactable = $Interactable

func _ready() -> void:
	interactable.interact_name = "Press E to pick up Shotgun"
	interactable.interact = pick_up_weapon


func pick_up_weapon() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if weapon_scene == null:
		return

	player.equip_weapon(weapon_scene)

	interactable.is_interactable = false
	queue_free()
