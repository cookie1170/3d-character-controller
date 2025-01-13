extends CharacterBody3D
class_name Player

@export_group("Camera")
@export_range(0.1, 5.0) var sensitivity : float = 0.5
@export_range(60, 130) var walking_fov : int = 75
@export_range(60, 130) var running_fov : int = 90
@export var invert_y : bool = false
## movement variable exports
@export_group("Movement variables")
@export_range(2, 10, 0.5) var jump_height : float
@export_range(0.1, 1, 0.05) var peak_time_sec : float
@export_range(0.1, 1, 0.05) var fall_time_sec : float
@export_range(0.1, 1, 0.05) var hang_time : float
@export_range(1, 3, 0.05) var hang_vel_mult : float
@export_range(0.1, 1, 0.05) var hang_grav_mult : float
@export_range(0.1, 1, 0.05) var coyote_time : float
@export_range(4, 32) var terminal_velocity : float
@export_range(1, 16, 0.5) var move_speed : float
@export_range(1, 24, 0.5) var running_speed : float
@export_range(0.1, 1, 0.05) var run_delay : float
@export_range(0.05, 1, 0.05) var accel_time_sec : float
@export_range(0.05, 1, 0.05) var decel_time_sec : float

## math
@onready var accel : float = running_speed / accel_time_sec
@onready var decel : float = running_speed / decel_time_sec

## nodes
@onready var camera: Camera3D = %Camera
@onready var run_timer: Timer = %RunTimer
@onready var stop_run_timer: Timer = %StopRunTimer

var camera_input_dir := Vector2.ZERO
var jump_buffered : bool
var running : bool = false
var lose_speed_on_ground : bool = true
var horizontal_vel := Vector2.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = walking_fov


func _unhandled_input(event: InputEvent) -> void:
	## gets the camera input direction
	var is_camera_moving : bool = (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_moving:
		camera_input_dir = event.screen_relative * sensitivity


func _physics_process(delta: float) -> void:
	var move_dir = _get_move_dir()

	if move_dir:
		if horizontal_vel.length_squared() < _get_final_speed() ** 2\
		 or (is_on_floor() and lose_speed_on_ground):
			horizontal_vel = horizontal_vel.move_toward(move_dir * _get_final_speed(),\
		 	accel * delta)
		if run_timer.is_stopped() and not running and not _is_slowed_down():
			run_timer.start()
		if stop_run_timer.is_stopped() and _is_slowed_down():
			stop_run_timer.start()
		if not _is_slowed_down():
			stop_run_timer.stop()

	else:
		horizontal_vel = horizontal_vel.move_toward(Vector2.ZERO, decel * delta)
		run_timer.stop()
		if stop_run_timer.is_stopped():
			stop_run_timer.start()
		

	if horizontal_vel.length_squared() >= _get_final_speed() ** 2: # squared because more performant
		if not horizontal_vel.normalized() == move_dir:
			horizontal_vel = horizontal_vel.length() * move_dir

	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.y
	camera.rotation.x -= camera_input_dir.y * delta\
	 * (-1.0 if invert_y else 1.0)
	camera.rotation.x = clampf(camera.rotation.x, 
			deg_to_rad(-80.0), deg_to_rad(80.0)
	)
	camera.rotation.y -= camera_input_dir.x * delta
	camera_input_dir = Vector2.ZERO
	if Input.is_action_just_pressed("focus_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("boost_temp"):
		horizontal_vel += Vector2(40, 40) * Vector2(move_dir.x, move_dir.y)
		velocity.y = 40
	print(snappedf(horizontal_vel.length(), 0.05))
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


func _on_run_timer_timeout() -> void:
	running = true
	get_tree().create_tween().tween_property(camera, "fov", running_fov, 0.25)


func _on_stop_run_timer_timeout() -> void:
	running = false
	get_tree().create_tween().tween_property(camera, "fov", walking_fov, 0.25)


func _on_land_speed_loss() -> void:
	lose_speed_on_ground = true
