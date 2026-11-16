
extends Control

# Change this to the actual path of your main menu scene
@export_file("*.tscn") var main_menu_scene: String = "res://Scenes/title_screen.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _input(event: InputEvent) -> void:
	var death_screen = get_tree().current_scene.get_node_or_null("DeathUI/DeathScreen")

	if death_screen != null and death_screen.visible:
		return

	if event.is_action_pressed("pause") and not event.is_echo():
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

		get_viewport().set_input_as_handled()


func pause_game() -> void:
	show()
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false
	hide()


func _on_resume_button_pressed() -> void:
	resume_game()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
