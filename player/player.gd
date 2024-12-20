extends CharacterBody3D
class_name Player

@export_range(0.1, 2.0) var sensitivity : float = 0.5
@export var jump_velocity : float = 2.0
@export var gravity : float = -9.8
@export var move_speed : float = 8.0
@export var accel_time : float = 0.15

@onready var accel : float = move_speed / accel_time
@onready var camera: Camera3D = %Camera

var camera_input_dir := Vector2.ZERO

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
	velocity.x = move_toward(velocity.x, move_dir.x * move_speed, accel * delta)
	velocity.z = move_toward(velocity.z, move_dir.y * move_speed, accel * delta)
	## handles gravity
	if not is_on_floor():
		_apply_gravity(delta)
	## handles the jump
	if Input.is_action_just_pressed("jump") and _can_jump():
		_jump()

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

func _apply_gravity(delta : float) -> void:
	velocity.y += gravity * delta

func _jump() -> void:
	velocity.y = jump_velocity

func _can_jump() -> bool:
	# temp
	return is_on_floor()
