extends State

@export var jumping_state : State
@export var grounded_state : State

@onready var coyote_timer: Timer = %CoyoteTimer
@onready var hang_timer: Timer = %HangTimer
@onready var grav : float = (-2.0 * owner.jump_height) / (owner.fall_time_sec ** 2)

var jump_cut : bool = false

func enter(previous_state) -> void:
	super(previous_state)
	if previous_state == grounded_state:
		coyote_timer.start()
	if previous_state == jumping_state and not jump_cut:
		hang_timer.start()
		var tween = get_tree().create_tween()
		tween.tween_property(owner, "velocity:x", owner.velocity.x * owner.hang_vel_mult, owner.hang_time / 1.5)
		tween.tween_property(owner, "velocity:z", owner.velocity.z * owner.hang_vel_mult, owner.hang_time / 1.5)
	jump_cut = false

func _physics_process(delta: float) -> void:
	owner.velocity.y += grav * delta * (owner.hang_grav_mult if not hang_timer.is_stopped() else 1.0)
	if Input.is_action_just_pressed("jump"):
		if not coyote_timer.is_stopped():
			emit_signal("state_changed", jumping_state)
	if owner.is_on_floor():
		emit_signal("state_changed", grounded_state)	

func recalculate_movement() -> void:
	grav = (-2.0 * owner.jump_height) / (owner.fall_time_sec ** 2)


func _on_jump_cut() -> void:
	jump_cut = true
