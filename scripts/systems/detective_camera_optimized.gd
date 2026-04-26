## Optimized Detective Camera for Low-End PCs
## Reduced update frequency, simplified calculations
extends Camera3D

class_name DetectiveCamera

# Movement
var _velocity: Vector3 = Vector3.ZERO
var _speed: float = 3.0
var _sprint_speed: float = 6.0
var _is_sprinting: bool = false

# Camera look
var _yaw: float = 0.0
var _pitch: float = 0.0
var _mouse_sensitivity: float = 0.003
var _pitch_limit: float = PI / 2.5
var _frame_skip_limit: int = 2  # Update every 2nd/3rd frame on low-end

# Footstep system (disabled on low-end by default)
var _footstep_distance: float = 0.0
var _last_footstep_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    position = Vector3(0, 1.7, 4)
    
    # Disable auto processing on low-end
    set_process(not _is_low_end_system())
    
    print("[DetectiveCamera] Camera initialized (Low-End: %s)" % _is_low_end_system())

func _process(delta: float) -> void:
    # Frame skipping for low-end systems
    if _is_low_end_system():
        _frame_skip += 1
        if _frame_skip < _frame_skip_limit:
            return
        _frame_skip = 0
    
    _handle_input(delta)
    _handle_movement(delta)
    _update_rotation()

func _handle_input(delta: float) -> void:
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    _velocity = global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
    
    # Sprint
    _is_sprinting = Input.is_action_pressed("ui_select")
    var current_speed = _sprint_speed if _is_sprinting else _speed
    _velocity *= current_speed

func _handle_movement(delta: float) -> void:
    # Simple movement without complex physics
    global_position += _velocity * delta

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_event = event as InputEventMouseMotion
        _yaw -= mouse_event.relative.x * _mouse_sensitivity
        _pitch -= mouse_event.relative.y * _mouse_sensitivity
        _pitch = clamp(_pitch, -_pitch_limit, _pitch_limit)

func _update_rotation() -> void:
    # Optimized rotation calculation
    var target_rotation = Vector3(_pitch, _yaw, 0)
    rotation = target_rotation

## Check if running on low-end system
func _is_low_end_system() -> bool:
    # Check GPU name for integrated graphics
    # Fallback to static low-end assumption in optimized profile
    return true

func stop_movement() -> void:
    _velocity = Vector3.ZERO

func resume_movement() -> void:
    _velocity = Vector3.ZERO  # Reset on resume

func disable_camera() -> void:
    set_process(false)

func enable_camera() -> void:
    set_process(true)
