## Crosshair + Raycast interaction for first-person detective mode
## Attach to the Camera3D node as a child
extends RayCast3D

@onready var crosshair_label: Label = $"../CrosshairUI/Crosshair"
@onready var interact_hint: Label = $"../CrosshairUI/InteractHint"

var _current_target: Node = null
var _pulse_time: float = 0.0

var _hint_alpha_target: float = 0.0
var _hint_alpha_current: float = 0.0
var _crosshair_color_target: Color = Color(0.2, 0.3, 0.45, 1.0)
var _crosshair_color_current: Color = Color(0.2, 0.3, 0.45, 1.0)

func _ready() -> void:
	target_position = Vector3(0, 0, -10)  # 10 meters forward
	enabled = true
	collide_with_areas = true
	collide_with_bodies = true
	interact_hint.modulate = Color(0.1, 0.18, 0.28, 0.0)
	interact_hint.visible = true # Always visible but alpha controlled
	crosshair_label.modulate = _crosshair_color_current

func _process(delta: float) -> void:
	_pulse_time += delta

	if is_colliding():
		var collider = get_collider()
		if collider != _current_target:
			_current_target = collider
			_update_hint()
	else:
		if _current_target != null:
			_current_target = null
			_update_hint()

	# Smooth alpha fade
	_hint_alpha_current = lerpf(_hint_alpha_current, _hint_alpha_target, 10.0 * delta)
	interact_hint.modulate.a = _hint_alpha_current
	
	# Smooth crosshair color transition
	_crosshair_color_current = _crosshair_color_current.lerp(_crosshair_color_target, 10.0 * delta)
	crosshair_label.modulate = _crosshair_color_current

	if _hint_alpha_current > 0.01:
		var pulse = 0.95 + sin(_pulse_time * 4.0) * 0.05
		interact_hint.scale = Vector2(pulse, pulse)
	else:
		interact_hint.scale = Vector2.ONE

func _update_hint() -> void:
	if _current_target == null:
		_hint_alpha_target = 0.0
		_crosshair_color_target = Color(0.2, 0.3, 0.45, 1.0)
		return
	
	# Check if target is interactable
	if _current_target is Area3D:
		var parent = _current_target
		if parent.has_method("_examine") or parent.has_method("_talk"):
			_hint_alpha_target = 1.0
			_crosshair_color_target = Color(0.95, 0.82, 0.35, 1.0)
			
			if parent.has_method("_examine"):
				interact_hint.text = "[E / Enter / Left Click] Examine"
			elif parent.has_method("_talk"):
				interact_hint.text = "[E / Enter / Left Click] Talk"
			return
	
	_hint_alpha_target = 0.0
	_crosshair_color_target = Color(0.2, 0.3, 0.45, 1.0)

func _input(event: InputEvent) -> void:
	if _current_target == null:
		return
	
	if DialogueManager.is_dialogue_active():
		return
	
	var should_interact = false
	if event.is_action_pressed("interact"):
		should_interact = true
	elif event.is_action_pressed("ui_accept"):
		should_interact = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		should_interact = true
	
	if should_interact and _current_target is Area3D:
		if _current_target.has_method("_examine"):
			_current_target._examine()
		elif _current_target.has_method("_talk"):
			_current_target._talk()
