## Deduction Board UI
## Interactive corkboard — drag clues, click two to connect with red string.
## Works automatically for all current and future clues.
extends CanvasLayer

# --- Scene refs (built from actual .tscn node tree) ---
@onready var corkboard_bg: TextureRect = $CorkboardBG
@onready var lines_layer: Control  = $LinesLayer
@onready var nodes_layer: Control  = $NodesLayer
@onready var close_btn: Button     = $Overlay/TopBar/CloseButton
@onready var detail_label: RichTextLabel = $Overlay/DetailPanel/Margin/DetailLabel
@onready var connections_label: Label    = $Overlay/TopBar/ConnectionsLabel

# --- State ---
var _is_open: bool = false
var _clue_nodes: Dictionary = {}          # clue_id  → Control node
var _selected: Array[String] = []         # up to 2 selected clue IDs
var _connecting_mode: bool = false        # true while waiting for 2nd clue

# ─────────────────────────────────────────────
func _ready() -> void:
	visible = false
	close_btn.pressed.connect(_close_board)
	
	# Apply Midnight Noir skin
	corkboard_bg.texture = null
	# Deep charcoal background #080A10
	corkboard_bg.modulate = Color(0.03, 0.04, 0.06, 1.0)
	
	# Style the DetailPanel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.08, 0.1, 0.88)
	panel_style.border_color = Color(1.0, 0.75, 0.0, 0.5)
	panel_style.set_border_width_all(1)
	var panel = $Overlay/DetailPanel
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style Close Button
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.07, 0.08, 0.1, 1.0)
	btn_normal.border_color = Color(1.0, 0.75, 0.0, 1.0)
	btn_normal.set_border_width_all(1)
	
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(1.0, 0.75, 0.0, 1.0)
	
	close_btn.add_theme_stylebox_override("normal", btn_normal)
	close_btn.add_theme_stylebox_override("hover", btn_hover)
	close_btn.add_theme_color_override("font_color", Color(0.88, 0.88, 0.92, 1.0))
	close_btn.add_theme_color_override("font_hover_color", Color(0.07, 0.08, 0.1, 1.0))

	# Title color (Amber)
	var title = $Overlay/TopBar/Title
	title.add_theme_color_override("font_color", Color(1.0, 0.75, 0.0, 1.0))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if _is_open: _close_board()
		else:        _open_board()

# ─────────────────────────────────────────────
func _open_board() -> void:
	_is_open = true
	visible  = true
	_refresh_board()
	await get_tree().process_frame   # let layout pass finish
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_board() -> void:
	_is_open = false
	visible  = false
	_selected.clear()
	_update_selections()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ─────────────────────────────────────────────
## Spawns any newly-collected clues, draws all connections.
## Safe to call repeatedly — only spawns clues not yet on board.
func _refresh_board() -> void:
	var clues = ClueManager.get_collected_clues()
	for clue_id in clues:
		if not _clue_nodes.has(clue_id):
			_spawn_clue_node(clue_id, clues[clue_id])
	_draw_connections()

# ─────────────────────────────────────────────
## Builds a sticky-note Control node entirely in code.
## No .tscn file needed — works for all future clues automatically.
func _spawn_clue_node(id: String, data: Dictionary) -> void:
	var node = Control.new()
	node.custom_minimum_size = Vector2(150, 160)
	node.size = Vector2(150, 160)

	# Position: restore saved or scatter randomly across board
	var pos_data = data.get("board_position", null)
	if pos_data and typeof(pos_data) == TYPE_DICTIONARY:
		node.position = Vector2(pos_data.get("x", 100.0), pos_data.get("y", 100.0))
	else:
		# Scatter in a grid-like pattern to avoid overlap
		var idx = _clue_nodes.size()
		var col = idx % 5
		var row = idx / 5
		node.position = Vector2(80.0 + col * 170.0, 80.0 + row * 180.0)

	node.rotation_degrees = randf_range(-5.0, 5.0)
	node.z_index = 1
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Yellow paper background
	var bg = ColorRect.new()
	bg.color = Color(0.96, 0.93, 0.72, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(bg)

	# Shadow strip at top (like a pinned note)
	var pin_strip = ColorRect.new()
	pin_strip.color = Color(0.85, 0.82, 0.60, 1.0)
	pin_strip.set_anchor_and_offset(SIDE_LEFT,   0, 0)
	pin_strip.set_anchor_and_offset(SIDE_RIGHT,  1, 0)
	pin_strip.set_anchor_and_offset(SIDE_TOP,    0, 0)
	pin_strip.set_anchor_and_offset(SIDE_BOTTOM, 0, 18)
	pin_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(pin_strip)

	# Category coloured dot
	var category_colors = {
		"physical":  Color(0.8, 0.3, 0.3, 1.0),
		"document":  Color(0.3, 0.5, 0.8, 1.0),
		"testimony": Color(0.3, 0.7, 0.4, 1.0),
		"digital":   Color(0.6, 0.3, 0.8, 1.0),
	}
	var cat = data.get("category", "physical")
	var dot = ColorRect.new()
	dot.color = category_colors.get(cat, Color(0.5, 0.5, 0.5, 1.0))
	dot.set_anchor_and_offset(SIDE_LEFT,   0,  6)
	dot.set_anchor_and_offset(SIDE_RIGHT,  0, 16)
	dot.set_anchor_and_offset(SIDE_TOP,    0,  5)
	dot.set_anchor_and_offset(SIDE_BOTTOM, 0, 15)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(dot)

	# Clue name label
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   10)
	margin.add_theme_constant_override("margin_right",  10)
	margin.add_theme_constant_override("margin_top",    22)
	margin.add_theme_constant_override("margin_bottom",  8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(margin)

	var label = Label.new()
	label.text = data.get("name", id)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04, 1.0))
	label.add_theme_font_size_override("font_size", 13)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(label)

	# Selection ring (hidden by default)
	var ring = ColorRect.new()
	ring.name = "SelectionRing"
	ring.color = Color(1.0, 0.85, 0.1, 0.0)   # transparent initially
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.z_index = -1  # behind content
	node.add_child(ring)

	# Attach the interaction script
	var script = GDScript.new()
	script.source_code = """
extends Control

var clue_id: String = ""
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

signal clue_clicked(id: String)
signal clue_dragged(id: String, pos: Vector2)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			z_index = 100
		else:
			_dragging = false
			z_index = 1
			clue_dragged.emit(clue_id, position)
			clue_clicked.emit(clue_id)
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
		clue_dragged.emit(clue_id, position)

func set_selected(selected: bool) -> void:
	var ring = get_node_or_null("SelectionRing")
	if selected:
		modulate = Color(1.0, 1.0, 0.7, 1.0)
		z_index = 50
		if ring: ring.color = Color(1.0, 0.85, 0.1, 0.4)
	else:
		modulate = Color(1, 1, 1, 1)
		z_index = 1
		if ring: ring.color = Color(1.0, 0.85, 0.1, 0.0)
"""
	script.reload()
	node.set_script(script)
	node.clue_id = id
	node.clue_clicked.connect(_on_clue_clicked)
	node.clue_dragged.connect(_on_clue_dragged)

	add_child(node)
	_clue_nodes[id] = node

# ─────────────────────────────────────────────
func _on_clue_clicked(clue_id: String) -> void:
	# Show detail panel
	var clue = ClueManager.get_clue(clue_id)
	var cat_icon = {"physical": "🔍", "document": "📄", "testimony": "💬", "digital": "📱"}
	var cat = clue.get("category", "physical")
	var txt = "[b]%s %s[/b]\n\n" % [cat_icon.get(cat, "🔍"), clue.get("name", clue_id)]
	txt += "%s\n\n" % clue.get("description", "No description available.")
	txt += "[i]📍 Found at: %s[/i]" % clue.get("location_found", "Unknown location")
	if detail_label:
		detail_label.text = txt

	# Selection toggle
	if clue_id in _selected:
		_selected.erase(clue_id)
		_update_selections()
		_connecting_mode = false
		if connections_label:
			connections_label.text = ""
		return

	_selected.append(clue_id)
	_update_selections()

	if _selected.size() == 1:
		# First clue selected — prompt for second
		_connecting_mode = true
		if connections_label:
			connections_label.text = "🔗 Select a second clue to connect..."

	elif _selected.size() == 2:
		# Attempt connection
		_connecting_mode = false
		var id1 = _selected[0]
		var id2 = _selected[1]
		_selected.clear()

		var success = ClueManager.connect_clues(id1, id2)
		_update_selections()
		_draw_connections()

		if success:
			if connections_label:
				connections_label.text = "✅ Connection made!"
		else:
			# Already connected — still draw (may have been loaded from save)
			if connections_label:
				connections_label.text = "↩ Already connected (or no logical link)."

		await get_tree().create_timer(2.5).timeout
		if connections_label and not _connecting_mode:
			connections_label.text = ""

func _on_clue_dragged(clue_id: String, new_pos: Vector2) -> void:
	# Persist the updated board position
	var clues = ClueManager.get_collected_clues()
	if clues.has(clue_id):
		clues[clue_id]["board_position"] = {"x": new_pos.x, "y": new_pos.y}
	# Redraw strings live so they follow the note
	_draw_connections()

# ─────────────────────────────────────────────
func _update_selections() -> void:
	for id in _clue_nodes:
		_clue_nodes[id].set_selected(id in _selected)

## Redraws ALL red strings from ClueManager.connections.
## Called after every drag, click, and board open.
func _draw_connections() -> void:
	for child in lines_layer.get_children():
		child.queue_free()

	for conn in ClueManager.connections:
		var id_a: String = conn.get("a", "")
		var id_b: String = conn.get("b", "")
		if id_a.is_empty() or id_b.is_empty():
			continue
		if not (_clue_nodes.has(id_a) and _clue_nodes.has(id_b)):
			continue

		var node_a: Control = _clue_nodes[id_a]
		var node_b: Control = _clue_nodes[id_b]
		var center_a = node_a.position + node_a.size * 0.5
		var center_b = node_b.position + node_b.size * 0.5

		# Shadow line for depth effect
		var shadow = Line2D.new()
		shadow.add_point(center_a + Vector2(2, 2))
		shadow.add_point(center_b + Vector2(2, 2))
		shadow.width = 5.0
		shadow.default_color = Color(0.0, 0.0, 0.0, 0.25)
		shadow.antialiased = true
		lines_layer.add_child(shadow)

		# Main red string
		var line = Line2D.new()
		line.add_point(center_a)
		line.add_point(center_b)
		line.width = 3.0
		line.default_color = Color(0.85, 0.18, 0.18, 0.9)
		line.antialiased = true
		lines_layer.add_child(line)
