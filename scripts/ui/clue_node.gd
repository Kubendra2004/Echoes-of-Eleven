extends PanelContainer

signal clue_clicked(clue_id: String)
signal clue_dragged(clue_id: String, new_pos: Vector2)

var clue_id: String = ""
var clue_name: String = ""

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

@onready var name_label: Label = $MarginContainer/NameLabel

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if name_label:
		name_label.text = clue_name

func setup(id: String, data: Dictionary) -> void:
	clue_id = id
	clue_name = data.get("name", id)
	
	# Try to restore saved position
	var pos_data = data.get("board_position", null)
	if pos_data and typeof(pos_data) == TYPE_DICTIONARY:
		position = Vector2(pos_data.get("x", 100), pos_data.get("y", 100))
	else:
		# Random spawn position if none saved
		position = Vector2(randf_range(100, 600), randf_range(100, 400))
		
	# Random messy rotation
	rotation_degrees = randf_range(-4.0, 4.0)

func set_selected(selected: bool) -> void:
	if selected:
		modulate = Color(1.2, 1.2, 0.8, 1.0) # Highlight yellow
		z_index = 10 # Bring to front
	else:
		modulate = Color.WHITE
		z_index = 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_offset = get_global_mouse_position() - global_position
				clue_clicked.emit(clue_id)
				z_index = 10
			else:
				_dragging = false
				z_index = 0
				clue_dragged.emit(clue_id, position)
	
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
		clue_dragged.emit(clue_id, position) # Emit while dragging to update lines dynamically
