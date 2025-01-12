extends Node
class_name State

@warning_ignore("unused_signal")
signal state_changed

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)

func exit() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)

func enter(_previous_state : State = null) -> void:
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
