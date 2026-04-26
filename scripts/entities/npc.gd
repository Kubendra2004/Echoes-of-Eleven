## NPC Entity — Clickable character that starts dialogue
extends Area3D

@export var npc_name: String = "Witness"
@export var dialogue_file: String = ""
@export var portrait_texture: Texture2D

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var name_label: Label3D = $NameLabel3D
@onready var interaction_label: Label3D = $InteractionLabel3D

var _mouse_hovering: bool = false
var _talked_to: bool = false

func _ready() -> void:
	name_label.text = npc_name
	name_label.visible = false
	interaction_label.text = "[E] Talk"
	interaction_label.visible = false
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_mouse_entered() -> void:
	_mouse_hovering = true
	name_label.visible = true
	interaction_label.visible = true
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.emission_enabled = true
			mat.emission = Color.WHITE
			mat.emission_energy_multiplier = 0.5

func _on_mouse_exited() -> void:
	_mouse_hovering = false
	name_label.visible = false
	interaction_label.visible = false
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.emission_enabled = false

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_talk()
	elif event.is_action_pressed("interact"):
		_talk()

func _talk() -> void:
	if DialogueManager.is_dialogue_active():
		return
	
	if dialogue_file != "":
		DialogueManager.start_dialogue(dialogue_file)
		_talked_to = true
		GameState.set_flag("talked_to_" + npc_name.to_lower().replace(" ", "_"))
