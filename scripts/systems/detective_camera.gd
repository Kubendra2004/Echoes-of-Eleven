## First-person detective camera — look around and walk through the crime scene
extends Camera3D

@export var move_speed: float = 3.0
@export var mouse_sensitivity: float = 0.003
@export var sprint_multiplier: float = 2.0
@export var room_min_x: float = -5.7
@export var room_max_x: float = 5.7
@export var room_min_z: float = -4.7
@export var room_max_z: float = 4.7

var _rotation_x: float = 0.0
var _rotation_y: float = 0.0
var _mouse_captured: bool = false

func _ready() -> void:
	current = true
	# Capture mouse for FPS-style look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true
	
	# Set initial rotation from current transform
	_rotation_y = rotation.y
	_rotation_x = rotation.x

func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	# Left or right click re-captures mouse for FPS look when released.
	if event is InputEventMouseButton and event.pressed and not _mouse_captured and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_mouse_captured = true
	
	# Escape toggles mouse capture.
	if event.is_action_pressed("pause_menu"):
		if _mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_mouse_captured = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_mouse_captured = true

func _physics_process(delta: float) -> void:
	_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

	if get_tree().paused:
		return

	# Don't move during dialogue.
	if DialogueManager.is_dialogue_active():
		return

	# Mouse look is processed every frame to avoid key-hold input conflicts.
	if _mouse_captured:
		var mouse_velocity = Input.get_last_mouse_velocity()
		if mouse_velocity.length_squared() > 0.0001:
			_rotation_y -= mouse_velocity.x * mouse_sensitivity * delta
			_rotation_x -= mouse_velocity.y * mouse_sensitivity * delta
			_rotation_x = clampf(_rotation_x, -PI / 2.2, PI / 2.2)
			rotation = Vector3(_rotation_x, _rotation_y, 0)

	var input_dir = Vector3.ZERO

	# Use physical keys for WASD so movement works across keyboard layouts.
	if Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.z -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.z += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		
		# Move relative to camera direction (but keep Y level)
		var forward = -global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		var right = global_transform.basis.x
		right.y = 0
		right = right.normalized()
		
		var velocity = (forward * -input_dir.z + right * input_dir.x)
		
		var speed = move_speed
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL):
			speed *= sprint_multiplier
		
		global_position += velocity * speed * delta
		
		# Keep camera at eye height
		global_position.y = clampf(global_position.y, 1.5, 2.5)
		global_position.x = clampf(global_position.x, room_min_x, room_max_x)
		global_position.z = clampf(global_position.z, room_min_z, room_max_z)
