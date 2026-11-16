extends Weapon

@export var pellet_count: int = 10
@export var spread_angle: float = 30.0

func shoot(direction: int) -> void:
	if not can_shoot or bullet_scene == null:
		return

	can_shoot = false

	for i in range(pellet_count):
		var bullet = bullet_scene.instantiate()

		# Spread pellets evenly across the angle
		var angle = 0.0

		if pellet_count > 1:
			angle = lerp(
				-spread_angle / 2.0,
				spread_angle / 2.0,
				float(i) / float(pellet_count - 1)
			)

		# Calculate pellet direction
		var base_angle = 0.0 if direction == 1 else PI
		var final_angle = base_angle + deg_to_rad(angle)

		bullet.travel_direction = Vector2.RIGHT.rotated(final_angle)
		bullet.damage = damage

		get_tree().current_scene.add_child(bullet)
		bullet.global_position = bullet_spawn.global_position

	await get_tree().create_timer(fire_rate).timeout

	if is_inside_tree():
		can_shoot = true
