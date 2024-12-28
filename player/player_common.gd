extends CharacterBody3D
class_name Player

@export_range(0.1, 2.0) var sensitivity : float = 0.5
## movement variable exports
@export_group("Movement variables")
@export var jump_height : float
@export var peak_time_sec : float
@export var fall_time_sec : float
@export var hang_time : float
@export var hang_vel_mult : float
@export var hang_grav_mult : float
@export var coyote_time : float
@export var terminal_velocity : float
@export var move_speed : float
@export var running_speed : float
@export var run_delay : float
@export var accel_time_sec : float
@export var decel_time_sec : float

## math
@onready var accel : float = move_speed / accel_time_sec
@onready var decel : float = move_speed / decel_time_sec

## nodes
@onready var camera: Camera3D = %Camera
@onready var run_timer: Timer = %RunTimer
@onready var stop_run_timer: Timer = %StopRunTimer

var camera_input_dir := Vector2.ZERO
var jump_buffered : bool
var running : bool = false

func _input(event: InputEvent) -> void:
	## lets you focus in and out of the window
	if event.is_action_pressed("focus_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	## gets the camera input direction
	var is_camera_moving : bool = (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_moving:
		camera_input_dir = event.screen_relative * sensitivity

func _physics_process(delta: float) -> void:
	## camera rotation
	camera.rotation.x -= camera_input_dir.y * delta
	camera.rotation.x = clampf(camera.rotation.x, 
			deg_to_rad(-80), deg_to_rad(80)
	)
	camera.rotation.y -= camera_input_dir.x * delta
	camera_input_dir = Vector2.ZERO

	var move_dir = _get_move_dir()

	## accelerates the velocity towards the move direction
	if move_dir:
		velocity.x = move_toward(
				velocity.x, move_dir.x * _get_final_speed(), accel * delta
			)
		velocity.z = move_toward(
				velocity.z, move_dir.y * _get_final_speed(), accel * delta
			)
		if run_timer.is_stopped() and not running and not _is_slowed_down():
			run_timer.start()
		if stop_run_timer.is_stopped() and _is_slowed_down():
			stop_run_timer.start()
		if not _is_slowed_down():
			stop_run_timer.stop()

	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)
		velocity.z = move_toward(velocity.z, 0, decel * delta)
		if stop_run_timer.is_stopped():
			stop_run_timer.start()

	get_tree().create_tween().tween_property(camera, "fov", 90.0 if running else 75.0, 0.25)

	move_and_slide()


func _get_move_dir() -> Vector2:
	## gets the raw input and forward and right vectors based on camera rotation
	var raw_input := Input.get_vector("left", "right", "forw", "back")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x

	## calculates the movement direction from the raw input and camera rotation
	var move_dir := (forward * raw_input.y) + (right * raw_input.x)
	move_dir.y = 0.0
	move_dir = move_dir.normalized()

	return Vector2(move_dir.x, move_dir.z)


func _get_final_speed() -> float:
	return (running_speed if running else move_speed)\
	 * (0.5 if Input.get_axis("back", "forw") < 0 else 1.0)

func _is_slowed_down() -> bool:
	return Input.get_axis("back", "forw") <= 0


func recalculate_movement() -> void:
	accel = move_speed / accel_time_sec
	decel = move_speed / decel_time_sec
	$StateMachine/Jumping.recalculate_movement()
	$StateMachine/Falling.recalculate_movement()
	%HangTimer.wait_time = hang_time
	%CoyoteTimer.wait_time = coyote_time
	%RunTimer.wait_time = run_delay


func _on_run_timer_timeout() -> void:
	running = true


func _on_stop_run_timer_timeout() -> void:
	running = false
