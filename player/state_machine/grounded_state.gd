extends State

@export var jumping_state : State
@export var falling_state : State

func _physics_process(_delta: float) -> void:
	if not owner.is_on_floor():
		emit_signal("state_changed", falling_state)

	if Input.is_action_just_pressed("jump") or (owner.jump_buffered and Input.is_action_pressed("jump")):
		emit_signal("state_changed", jumping_state)
		owner.jump_buffered = false
