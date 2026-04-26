## First-person detective camera — look around and walk through the crime scene
extends Camera3D

@export var move_speed: float = 3.0
@export var mouse_sensitivity: float = 0.003
@export var sprint_multiplier: float = 2.0
@export var room_min_x: float = -5.7
@export var room_max_x: float = 5.7
@export var room_min_z: float = -4.7
@export var room_max_z: float = 4.7

# Smooth Look
@export var look_smoothness: float = 15.0
var _target_rotation_x: float = 0.0
var _target_rotation_y: float = 0.0
var _current_rotation_x: float = 0.0
var _current_rotation_y: float = 0.0

# Smooth Movement
@export var move_smoothness: float = 10.0
var _current_velocity: Vector3 = Vector3.ZERO

# Head Bobbing
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.05
var _bob_timer: float = 0.0
var _base_y: float = 1.7

var _mouse_captured: bool = false

func _ready() -> void:
	current = true
	# Capture mouse for FPS-style look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true
	
	# Set initial rotation from current transform
	_current_rotation_y = rotation.y
	_current_rotation_x = rotation.x
	_target_rotation_y = rotation.y
	_target_rotation_x = rotation.x
	_base_y = global_position.y

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
			
	if _mouse_captured and event is InputEventMouseMotion:
		_target_rotation_y -= event.relative.x * mouse_sensitivity
		_target_rotation_x -= event.relative.y * mouse_sensitivity
		_target_rotation_x = clampf(_target_rotation_x, -PI / 2.2, PI / 2.2)

func _physics_process(delta: float) -> void:
	_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

	if get_tree().paused:
		return

	# Don't move during dialogue.
	if DialogueManager.is_dialogue_active():
		_current_velocity = _current_velocity.lerp(Vector3.ZERO, move_smoothness * delta)
		return

	# Smooth Look Application
	_current_rotation_x = lerpf(_current_rotation_x, _target_rotation_x, look_smoothness * delta)
	_current_rotation_y = lerpf(_current_rotation_y, _target_rotation_y, look_smoothness * delta)
	rotation = Vector3(_current_rotation_x, _current_rotation_y, 0)

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
	
	var target_velocity = Vector3.ZERO
	var is_moving = false
	var is_sprinting = false
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		is_moving = true
		
		# Move relative to camera direction (but keep Y level)
		var forward = -global_transform.basis.z
		forward.y = 0
		if forward.length_squared() > 0:
			forward = forward.normalized()
			
		var right = global_transform.basis.x
		right.y = 0
		if right.length_squared() > 0:
			right = right.normalized()
		
		target_velocity = (forward * -input_dir.z + right * input_dir.x)
		
		var speed = move_speed
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL):
			speed *= sprint_multiplier
			is_sprinting = true
			
		target_velocity *= speed
		
	# Smooth Movement Application
	_current_velocity = _current_velocity.lerp(target_velocity, move_smoothness * delta)
	
	var pos = global_position
	pos += _current_velocity * delta
	
	# Head Bobbing
	if is_moving:
		var speed_factor = sprint_multiplier if is_sprinting else 1.0
		_bob_timer += delta * bob_frequency * speed_factor
		var bob_offset = sin(_bob_timer * PI * 2) * bob_amplitude
		pos.y = _base_y + bob_offset
		
		# FOV dynamic effect
		fov = lerpf(fov, 75.0 if is_sprinting else 70.0, 5.0 * delta)
	else:
		_bob_timer = 0.0
		pos.y = lerpf(pos.y, _base_y, move_smoothness * delta)
		fov = lerpf(fov, 70.0, 5.0 * delta)
		
	# Clamping
	pos.y = clampf(pos.y, 1.5, 2.5)
	pos.x = clampf(pos.x, room_min_x, room_max_x)
	pos.z = clampf(pos.z, room_min_z, room_max_z)
	
	global_position = pos
