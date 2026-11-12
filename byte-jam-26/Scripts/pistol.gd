
extends Node2D
class_name Weapon

@export var weapon_name: String = "Pistol"
@export var damage: int = 10
@export var fire_rate: float = 0.4
@export var automatic: bool = false
@export var bullet_scene: PackedScene

@onready var bullet_spawn = $BulletSpawn

var can_shoot: bool = true

func shoot(direction: int) -> void:
	if not can_shoot or bullet_scene == null:
		return

	can_shoot = false

	var bullet = bullet_scene.instantiate()

	bullet.direction = direction
	bullet.damage = damage

	get_tree().current_scene.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position

	await get_tree().create_timer(fire_rate).timeout

	if is_inside_tree():
		can_shoot = true
