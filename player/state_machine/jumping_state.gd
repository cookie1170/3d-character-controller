extends State

@export var grounded_state : State
@export var falling_state : State

@onready var jump_velocity : float = (2.0 * owner.jump_height) / owner.peak_time_sec
@onready var grav : float = (-2.0 * owner.jump_height) / (owner.peak_time_sec ** 2)

func enter(previous_state : State) -> void:
	super(previous_state)
	owner.velocity.y = jump_velocity

func _physics_process(delta: float) -> void:
	owner.velocity.y += grav * delta
	if owner.is_on_floor():
		emit_signal("state_changed", grounded_state)
	if owner.velocity.y <= 0:
		emit_signal("state_changed", falling_state)
	if Input.is_action_just_released("jump"):
		owner.velocity.y -= 2.5
		emit_signal("state_changed", falling_state)

func recalculate_movement() -> void:
	jump_velocity = (2.0 * owner.jump_height) / owner.peak_time_sec
	grav = (-2.0 * owner.jump_height) / (owner.peak_time_sec ** 2)
