extends State

signal buffered_jump

@export var jumping_state : State
@export var grounded_state : State

@onready var coyote_timer: Timer = %CoyoteTimer
@onready var grav : float = (-2.0 * owner.jump_height) / (owner.fall_time_sec ** 2)

func enter(previous_state) -> void:
	super(previous_state)
	if previous_state == grounded_state:
		coyote_timer.start()

func _physics_process(delta: float) -> void:
	owner.velocity.y += grav * delta
	if Input.is_action_just_pressed("jump"):
		if not coyote_timer.is_stopped():
			emit_signal("state_changed", jumping_state)
		else:
			emit_signal("buffered_jump")
	if owner.is_on_floor():
		emit_signal("state_changed", grounded_state)	

func recalculate_movement() -> void:
	grav = (-2.0 * owner.jump_height) / (owner.fall_time_sec ** 2)
