## Pause Overlay — Shift+Enter to open, ESC to close
## Built entirely in GDScript — no .tscn dependency
extends CanvasLayer

var _is_open: bool = false

var _backdrop: ColorRect
var _panel: PanelContainer
var _title: Label
var _objective_label: Label
var _clue_label: Label
var _resume_btn: Button
var _save_btn: Button
var _board_btn: Button
var _menu_btn: Button
var _exit_btn: Button
var _all_buttons: Array[Button] = []

func _ready() -> void:
	layer = 30
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var k: InputEventKey = event as InputEventKey
	if (k.keycode == KEY_ENTER or k.keycode == KEY_KP_ENTER) and k.shift_pressed:
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif k.keycode == KEY_ESCAPE and _is_open:
		_close_pause()
		get_viewport().set_input_as_handled()

func toggle_pause_menu() -> void:
	_toggle_pause()

# ──────────────────────────────────────────────
func _build_ui() -> void:
	# Full-screen dark overlay
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.04, 0.06, 0.10, 0.72)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_backdrop)

	# Central panel
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(420, 380)
	_panel.offset_left   = -210
	_panel.offset_top    = -190
	_panel.offset_right  = 210
	_panel.offset_bottom = 190
	add_child(_panel)

	var margin = MarginContainer.new()
	for side in ["margin_left","margin_right","margin_top","margin_bottom"]:
		margin.add_theme_constant_override(side, 28)
	_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Title
	_title = Label.new()
	_title.text = "⏸  PAUSED"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95, 1.0))
	vbox.add_child(_title)

	# Context info strip
	var info_box = VBoxContainer.new()
	info_box.add_theme_constant_override("separation", 4)
	vbox.add_child(info_box)

	_objective_label = Label.new()
	_objective_label.text = ""
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_objective_label.add_theme_color_override("font_color", Color(0.65, 0.75, 0.9, 1.0))
	_objective_label.add_theme_font_size_override("font_size", 13)
	info_box.add_child(_objective_label)

	_clue_label = Label.new()
	_clue_label.text = ""
	_clue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clue_label.add_theme_color_override("font_color", Color(0.55, 0.65, 0.8, 1.0))
	_clue_label.add_theme_font_size_override("font_size", 12)
	info_box.add_child(_clue_label)

	vbox.add_child(HSeparator.new())

	# Buttons
	_resume_btn = _make_btn("▶  Resume")
	_resume_btn.pressed.connect(_on_resume)
	vbox.add_child(_resume_btn)

	_save_btn = _make_btn("💾  Save Game")
	_save_btn.pressed.connect(_on_save)
	vbox.add_child(_save_btn)

	_board_btn = _make_btn("🗂️  Evidence Board")
	_board_btn.pressed.connect(_on_open_board)
	vbox.add_child(_board_btn)

	_menu_btn = _make_btn("🏠  Main Menu")
	_menu_btn.pressed.connect(_on_main_menu)
	vbox.add_child(_menu_btn)

	_exit_btn = _make_btn("✕  Exit Game")
	_exit_btn.pressed.connect(_on_exit)
	vbox.add_child(_exit_btn)

	_all_buttons = [_resume_btn, _save_btn, _board_btn, _menu_btn, _exit_btn]
	for btn in _all_buttons:
		btn.mouse_entered.connect(_on_btn_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_btn_hover.bind(btn, false))
		btn.focus_entered.connect(_on_btn_hover.bind(btn, true))
		btn.focus_exited.connect(_on_btn_hover.bind(btn, false))

func _make_btn(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 44)
	btn.focus_mode = Control.FOCUS_ALL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return btn

func _on_btn_hover(btn: Button, hovered: bool) -> void:
	btn.self_modulate = Color(0.78, 0.88, 1.0, 1.0) if hovered else Color.WHITE

# ──────────────────────────────────────────────
func _toggle_pause() -> void:
	if _is_open: _close_pause()
	else:        _open_pause()

func _open_pause() -> void:
	_is_open = true
	visible  = true

	# Refresh live context info
	_objective_label.text = "📋 " + GameState.current_objective
	_clue_label.text      = "🔍 Evidence collected: %d" % ClueManager.get_clue_count()

	_backdrop.modulate.a = 0.0
	_panel.modulate.a    = 0.0
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(_backdrop, "modulate:a", 1.0, 0.2)
	t.tween_property(_panel,    "modulate:a", 1.0, 0.2)
	_resume_btn.grab_focus()

func _close_pause() -> void:
	_is_open = false
	visible  = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ──────────────────────────────────────────────
func _on_resume() -> void:
	_close_pause()

func _on_save() -> void:
	SaveManager.save_game(1)
	_save_btn.text = "✅  Saved!"
	await get_tree().create_timer(1.5).timeout
	_save_btn.text = "💾  Save Game"

func _on_open_board() -> void:
	_close_pause()
	# Find the DeductionBoard in scene and open it
	var board = get_tree().get_first_node_in_group("deduction_board")
	if board and board.has_method("_open_board"):
		board._open_board()

func _on_main_menu() -> void:
	get_tree().paused = false
	_is_open = false
	visible  = false
	SceneManager.go_to_main_menu()

func _on_exit() -> void:
	get_tree().paused = false
	get_tree().quit()
