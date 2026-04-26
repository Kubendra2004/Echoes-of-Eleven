## Optimized FPS Interaction for Low-End PCs
## Reduced raycast frequency, simplified calculations
extends Node3D

class_name FPSInteractionOptimized

@export var raycast_distance: float = 10.0
@export var raycast_layer: int = 2

@onready var raycast: RayCast3D = $RayCast3D
var _last_hovered_object: Node3D = null

# Performance optimization
var _raycast_frame_skip: int = 0
var _raycast_frame_limit: int = 3  # Only raycast every 3rd frame on low-end
var _is_low_end: bool = true

func _ready() -> void:
    raycast = RayCast3D.new()
    raycast.target_position = Vector3(0, 0, -raycast_distance)
    add_child(raycast)
    
    _is_low_end = _detect_low_end_system()
    
    # Adjust raycast frequency based on system
    if _is_low_end:
        _raycast_frame_limit = 4  # Every 4th frame
    
    print("[FPSInteraction] Initialized (Low-End: %s)" % _is_low_end)

func _process(_delta: float) -> void:
    # Frame skipping for raycasts (expensive operation)
    if _is_low_end:
        _raycast_frame_skip += 1
        if _raycast_frame_skip < _raycast_frame_limit:
            _raycast_frame_skip = 0
            return
    
    _update_raycast()
    _check_input()

func _update_raycast() -> void:
    # Simplified raycast without complex tracking
    if not raycast.is_colliding():
        if _last_hovered_object:
            _remove_highlight(_last_hovered_object)
            _last_hovered_object = null
        return
    
    var collider = raycast.get_collider()
    if not collider:
        return
    
    # Update highlight
    if collider != _last_hovered_object:
        if _last_hovered_object:
            _remove_highlight(_last_hovered_object)
        _add_highlight(collider)
        _last_hovered_object = collider

func _add_highlight(object: Node3D) -> void:
    # Minimal highlight effect (no emission on low-end)
    if object.has_method("set_highlighted"):
        object.set_highlighted(true)

func _remove_highlight(object: Node3D) -> void:
    if object.has_method("set_highlighted"):
        object.set_highlighted(false)

func _check_input() -> void:
    if Input.is_action_just_pressed("interact"):
        if _last_hovered_object and _last_hovered_object.has_method("interact"):
            _last_hovered_object.interact()

func _detect_low_end_system() -> bool:
    # Simple low-end detection based on available RAM
    var ram_available = OS.get_static_memory_usage()
    
    # Low-end if <4GB RAM
    return ram_available < 4_000_000_000
