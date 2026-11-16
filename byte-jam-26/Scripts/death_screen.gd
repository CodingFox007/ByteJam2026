
extends Control

@export_file("*.tscn") var main_menu_scene: String = "res://Scenes/title_screen.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func show_death_screen() -> void:
	show()
	get_tree().paused = true


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
