## Deduction Board UI
## Interactive Corkboard for clues and connections
extends CanvasLayer

@onready var corkboard_bg: ColorRect = %CorkboardBG
@onready var lines_layer: Control = %LinesLayer
@onready var nodes_layer: Control = %NodesLayer
@onready var detail_label: RichTextLabel = %DetailLabel
@onready var connections_label: Label = %ConnectionsLabel
@onready var close_btn: Button = %CloseButton

var _is_open: bool = false
var _selected_clue_ids: Array[String] = []
var _clue_nodes: Dictionary = {}

var clue_node_scene = preload("res://scenes/investigation/clue_node.tscn")

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(_close_board)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if _is_open:
			_close_board()
		else:
			_open_board()

func _open_board() -> void:
	_is_open = true
	visible = true
	_refresh_board()
	
	# Await one frame to ensure Godot UI layout pass completes before pausing
	await get_tree().process_frame
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_board() -> void:
	_is_open = false
	visible = false
	_selected_clue_ids.clear()
	_update_selections()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _refresh_board() -> void:
	
	# DEBUG: FORCE SPAWN A DUMMY CLUE
	if not _clue_nodes.has("debug_dummy"):
		_spawn_clue_node("debug_dummy", {"name": "DEBUG CLUE", "description": "If you see this, rendering works."})

	var clues = ClueManager.get_collected_clues()

	var file = FileAccess.open("user://debug_board.txt", FileAccess.WRITE)
	if file:
		file.store_string("Refresh called!\n")
		file.store_string("Clues found: " + str(clues.size()) + "\n")
		var child_count = nodes_layer.get_child_count()
		file.store_string("NodesLayer children before: " + str(child_count) + "\n")
		file.store_string("Clues: " + str(clues) + "\n")

	
	# Spawn any new clues
	for clue_id in clues:
		if not _clue_nodes.has(clue_id):
			_spawn_clue_node(clue_id, clues[clue_id])
	
	_draw_connections()

func _spawn_clue_node(id: String, data: Dictionary) -> void:
	var node = clue_node_scene.instantiate()
	nodes_layer.add_child(node)
	node.setup(id, data)
	node.clue_clicked.connect(_on_clue_clicked)
	node.clue_dragged.connect(_on_clue_dragged)
	_clue_nodes[id] = node

func _on_clue_dragged(clue_id: String, new_pos: Vector2) -> void:
	# Save position
	
	# DEBUG: FORCE SPAWN A DUMMY CLUE
	if not _clue_nodes.has("debug_dummy"):
		_spawn_clue_node("debug_dummy", {"name": "DEBUG CLUE", "description": "If you see this, rendering works."})

	var clues = ClueManager.get_collected_clues()

	var file = FileAccess.open("user://debug_board.txt", FileAccess.WRITE)
	if file:
		file.store_string("Refresh called!\n")
		file.store_string("Clues found: " + str(clues.size()) + "\n")
		var child_count = nodes_layer.get_child_count()
		file.store_string("NodesLayer children before: " + str(child_count) + "\n")
		file.store_string("Clues: " + str(clues) + "\n")

	if clues.has(clue_id):
		clues[clue_id]["board_position"] = {"x": new_pos.x, "y": new_pos.y}
	
	_draw_connections()

func _on_clue_clicked(clue_id: String) -> void:
	var clue = ClueManager.get_clue(clue_id)
	
	# Show details
	var text = "[b]%s[/b]\n\n" % clue.get("name", clue_id)
	text += "%s\n\n" % clue.get("description", "No description.")
	text += "[i]Found at: %s[/i]\n" % clue.get("location_found", "Unknown")
	detail_label.text = text
	
	# Handle connecting clues
	if clue_id in _selected_clue_ids:
		_selected_clue_ids.erase(clue_id)
	else:
		_selected_clue_ids.append(clue_id)
	
	_update_selections()
	
	# Try to connect if 2 selected
	if _selected_clue_ids.size() == 2:
		var id1 = _selected_clue_ids[0]
		var id2 = _selected_clue_ids[1]
		var success = ClueManager.connect_clues(id1, id2)
		
		if success:
			connections_label.text = "✓ Connection made!"
			_draw_connections()
		else:
			connections_label.text = "These clues don't connect."
			
		_selected_clue_ids.clear()
		_update_selections()
		
		await get_tree().create_timer(2.0).timeout
		connections_label.text = ""

func _update_selections() -> void:
	for id in _clue_nodes:
		_clue_nodes[id].set_selected(id in _selected_clue_ids)

func _draw_connections() -> void:
	# Clear existing lines
	for child in lines_layer.get_children():
		child.queue_free()
	
	var connections = ClueManager.connections
	for conn in connections:
		var id_a = conn["a"]
		var id_b = conn["b"]
		
		if _clue_nodes.has(id_a) and _clue_nodes.has(id_b):
			var node_a = _clue_nodes[id_a]
			var node_b = _clue_nodes[id_b]
			
			var line = Line2D.new()
			line.add_point(node_a.position + node_a.size / 2)
			line.add_point(node_b.position + node_b.size / 2)
			line.width = 4.0
			line.default_color = Color(0.8, 0.2, 0.2, 0.8) # Red string
			line.antialiased = true
			lines_layer.add_child(line)
