## Detective Notebook UI - Open with N key
extends CanvasLayer

@onready var panel = PanelContainer.new()
var _is_open: bool = false

func _ready() -> void:
	# Create the notebook UI
	setup_notebook_ui()
	
	# Initially hidden
	panel.visible = false

func setup_notebook_ui() -> void:
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.08, 0.98)
	style.border_color = Color(0.8, 0.6, 0.4, 0.8)
	style.set_border_enabled_all(true)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Title bar
	var title_hbox = HBoxContainer.new()
	var title = Label.new()
	title.text = "📓 DETECTIVE'S NOTEBOOK"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
	title_hbox.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "[X] Close (N)"
	close_btn.pressed.connect(_toggle_notebook)
	title_hbox.add_child(close_btn)
	vbox.add_child(title_hbox)
	
	# Tab system
	var tab_hbox = HBoxContainer.new()
	var categories = ["All", "Clues", "Theories", "Witnesses", "Events"]
	var buttons: Array[Button] = []
	
	for category in categories:
		var btn = Button.new()
		btn.text = category
		btn.custom_minimum_size = Vector2(100, 30)
		btn.pressed.connect(_on_category_selected.bindv([category]))
		btn.toggle_mode = true
		if category == "All":
			btn.button_pressed = true
		tab_hbox.add_child(btn)
		buttons.append(btn)
	
	vbox.add_child(tab_hbox)
	
	# Notebook entries scroll
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 400)
	
	var entries_vbox = VBoxContainer.new()
	entries_vbox.name = "EntriesBox"
	entries_vbox.add_theme_constant_override("separation", 5)
	
	# Populate entries
	_populate_entries(entries_vbox, "All")
	
	scroll.add_child(entries_vbox)
	vbox.add_child(scroll)
	
	# Stats footer
	var stats_hbox = HBoxContainer.new()
	
	var stats_text = Label.new()
	var achievements = Achievements.get_unlocked_count()
	var total_achievements = Achievements.get_achievements().size()
	var pages = DetectiveNotebook.get_case_pages().size()
	stats_text.text = "📝 Pages: %d | 🏆 Achievements: %d/%d | ⭐ Reputation: %d | 😰 Stress: %d" % [
		pages,
		achievements,
		total_achievements,
		GameState.reputation,
		GameState.stress
	]
	stats_hbox.add_child(stats_text)
	
	vbox.add_child(stats_hbox)
	panel.add_child(vbox)
	add_child(panel)

func _populate_entries(container: VBoxContainer, category: String) -> void:
	# Clear existing
	for child in container.get_children():
		child.queue_free()
	
	var pages: Array
	if category == "All":
		pages = DetectiveNotebook.get_case_pages()
	else:
		var cat_map = {
			"Clues": "clue",
			"Theories": "theory",
			"Witnesses": "witness",
			"Events": "event"
		}
		if category in cat_map:
			pages = DetectiveNotebook.get_pages_by_category(cat_map[category])
	
	for page in pages:
		var entry = PanelContainer.new()
		var entry_style = StyleBoxFlat.new()
		entry_style.bg_color = Color(0.2, 0.18, 0.15, 0.6)
		entry_style.border_color = Color(0.6, 0.5, 0.4, 0.4)
		entry_style.set_border_enabled_all(true)
		entry_style.set_border_width_all(1)
		entry.add_theme_stylebox_override("panel", entry_style)
		
		var entry_vbox = VBoxContainer.new()
		
		var entry_title = Label.new()
		entry_title.text = page["title"]
		entry_title.add_theme_font_size_override("font_size", 13)
		entry_title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
		entry_vbox.add_child(entry_title)
		
		var entry_content = Label.new()
		entry_content.text = page["content"]
		entry_content.word_wrap_mode = TextServer.AUTOWRAP_WORD
		entry_content.custom_minimum_size = Vector2(500, 0)
		entry_content.add_theme_font_size_override("font_size", 11)
		entry_vbox.add_child(entry_content)
		
		entry.add_child(entry_vbox)
		container.add_child(entry)

func _on_category_selected(category: String) -> void:
	var entries_box = panel.get_child(0).find_child("EntriesBox")
	if entries_box:
		_populate_entries(entries_box, category)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_N:
		_toggle_notebook()
		get_tree().root.set_input_as_handled()

func _toggle_notebook() -> void:
	_is_open = not _is_open
	panel.visible = _is_open
	
	# Pause game when notebook open
	if _is_open:
		get_tree().paused = true
	else:
		get_tree().paused = false
