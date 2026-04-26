## Deduction Board UI
## Lets the player review collected clues and make connections
extends CanvasLayer

@onready var board_panel: PanelContainer = %BoardPanel
@onready var clue_list: VBoxContainer = %ClueList
@onready var detail_label: RichTextLabel = %DetailLabel
@onready var connections_label: Label = %ConnectionsLabel
@onready var close_btn: Button = %CloseButton

var _is_open: bool = false
var _selected_clue_ids: Array[String] = []

func _ready() -> void:
	board_panel.visible = false
	close_btn.pressed.connect(_close_board)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if _is_open:
			_close_board()
		else:
			_open_board()

func _open_board() -> void:
	_is_open = true
	board_panel.visible = true
	_refresh_clue_list()
	get_tree().paused = true

func _close_board() -> void:
	_is_open = false
	board_panel.visible = false
	_selected_clue_ids.clear()
	get_tree().paused = false

func _refresh_clue_list() -> void:
	# Clear existing entries
	for child in clue_list.get_children():
		child.queue_free()
	
	var clues = ClueManager.get_collected_clues()
	
	if clues.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No clues collected yet."
		clue_list.add_child(empty_label)
		return
	
	# Group by category
	var categories = {"physical": [], "testimony": [], "document": [], "digital": []}
	for clue_id in clues:
		var cat = clues[clue_id].get("category", "physical")
		if cat in categories:
			categories[cat].append({"id": clue_id, "data": clues[clue_id]})
	
	var category_names = {
		"physical": "🔍 Physical Evidence",
		"testimony": "🗣 Testimonies",
		"document": "📄 Documents",
		"digital": "💻 Digital Evidence"
	}
	
	for cat in categories:
		if categories[cat].is_empty():
			continue
		
		# Category header
		var header = Label.new()
		header.text = category_names.get(cat, cat)
		clue_list.add_child(header)
		
		# Clue buttons
		for entry in categories[cat]:
			var btn = Button.new()
			btn.text = "  " + entry["data"].get("name", entry["id"])
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			var cid = entry["id"]
			btn.pressed.connect(func(): _select_clue(cid))
			clue_list.add_child(btn)

func _select_clue(clue_id: String) -> void:
	var clue = ClueManager.get_clue(clue_id)
	
	# Show details
	var text = "[b]%s[/b]\n\n" % clue.get("name", clue_id)
	text += "%s\n\n" % clue.get("description", "No description.")
	text += "[i]Found at: %s[/i]\n" % clue.get("location_found", "Unknown")
	
	if "collected_time" in clue:
		text += "[i]Collected: Day %d, %02d:00[/i]" % [
			clue["collected_time"].get("day", 0),
			clue["collected_time"].get("hour", 0)
		]
	
	detail_label.text = text
	
	# Handle connecting clues
	if clue_id in _selected_clue_ids:
		_selected_clue_ids.erase(clue_id)
	else:
		_selected_clue_ids.append(clue_id)
	
	# If two clues selected, try to connect them
	if _selected_clue_ids.size() == 2:
		var success = ClueManager.connect_clues(_selected_clue_ids[0], _selected_clue_ids[1])
		if success:
			connections_label.text = "✓ Connection made!"
		else:
			connections_label.text = "These clues don't connect."
		_selected_clue_ids.clear()
		
		# Clear message after delay
		await get_tree().create_timer(2.0).timeout
		connections_label.text = ""
