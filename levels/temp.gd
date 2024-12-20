extends Label


func _process(_delta: float) -> void:
	if %Player/StateMachine.current_state:
		text = %Player/StateMachine.current_state.name
