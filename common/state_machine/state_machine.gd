extends Node
class_name StateMachine

@export var default_state : State

var states := get_children()
var current_state : State

func _ready() -> void:
	_change_state(default_state)

func _change_state(new_state : State) -> void:
	if current_state:
		current_state.exit()
	new_state.enter(current_state)
	current_state = new_state
