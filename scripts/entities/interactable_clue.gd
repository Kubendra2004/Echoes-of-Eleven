## Interactable Clue Entity
## Place this in investigation scenes — player clicks/raycasts to examine & collect
extends Area3D

signal examined(clue_id: String)

@export var clue_id: String = ""
@export var clue_display_name: String = "Unknown Object"
@export var examine_text: String = "You examine the object closely..."
@export var highlight_color: Color = Color(1.0, 1.0, 0.5, 0.3)

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var interaction_label: Label3D = $Label3D

var _is_collected: bool = false
var _mouse_hovering: bool = false
var _base_position: Vector3
var _anim_offset: float = 0.0

func _ready() -> void:
	_base_position = position
	_anim_offset = randf() * TAU
	set_process(true)

	# Check if already collected in a previous visit
	if ClueManager.has_clue(clue_id):
		_mark_collected()
		return
	
	interaction_label.visible = false
	interaction_label.text = "[E / Enter / Click] Examine"
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	if _is_collected:
		return

	_anim_offset += delta
	position.y = _base_position.y + sin(_anim_offset * 1.6) * 0.015
	rotation.y += delta * 0.25

func _on_mouse_entered() -> void:
	if _is_collected:
		return
	_mouse_hovering = true
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.emission_enabled = true
			mat.emission = highlight_color
			mat.emission_energy_multiplier = 2.0
	interaction_label.visible = true

func _on_mouse_exited() -> void:
	_mouse_hovering = false
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.emission_enabled = false
	interaction_label.visible = false

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _is_collected:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_examine()
	elif event.is_action_pressed("interact"):
		_examine()
	elif event.is_action_pressed("ui_accept"):
		_examine()

func _examine() -> void:
	# Collect the clue
	ClueManager.collect_clue(clue_id)
	examined.emit(clue_id)
	
	# Show examine dialogue
	var dialogue_data = {
		"start": {
			"speaker": GameState.detective_name,
			"text": examine_text
		}
	}
	DialogueManager.start_dialogue_from_data(dialogue_data)
	
	_mark_collected()

func _mark_collected() -> void:
	_is_collected = true
	interaction_label.visible = false
	# Dim the mesh to show it's been collected
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.albedo_color = Color(0.3, 0.3, 0.3, 0.7)
			mat.emission_enabled = false
