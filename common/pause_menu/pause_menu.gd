extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_visible(!is_visible())
		get_tree().set_pause(is_visible())
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_visible()\
		 else Input.MOUSE_MODE_CAPTURED)


func _on_back_down() -> void:
	set_visible(false)
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_down() -> void:
	pass # Replace with function body.


func _on_quit_down() -> void:
	get_tree().quit()
