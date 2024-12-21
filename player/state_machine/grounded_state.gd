extends State

var jump_buffered : bool = false

@export var jumping_state : State
@export var falling_state : State

func enter(previous_state) -> void:
	super(previous_state)
	if jump_buffered:
		emit_signal("state_changed", jumping_state)
		jump_buffered = false

func _physics_process(_delta: float) -> void:
	if not owner.is_on_floor():
		emit_signal("state_changed", falling_state)

	if Input.is_action_just_pressed("jump"):
		emit_signal("state_changed", jumping_state)
