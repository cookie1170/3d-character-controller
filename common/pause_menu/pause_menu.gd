extends Control

@export var settings : Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		owner.set_visible(!owner.is_visible())
		get_tree().set_pause(owner.is_visible())
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if owner.is_visible()\
		 else Input.MOUSE_MODE_CAPTURED)


func _on_back_down() -> void:
	owner.set_visible(false)
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_down() -> void:
	settings.show()
	hide()


func _on_quit_down() -> void:
	get_tree().quit()
