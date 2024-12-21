extends Node
class_name State

signal state_changed

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)

func exit() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)

func enter(_previous_state) -> void:
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
