## Pause overlay opened with Shift+Enter.
extends CanvasLayer

var _panel: PanelContainer
var _title: Label
var _hint: Label
var _resume_btn: Button
var _main_menu_btn: Button
var _exit_btn: Button
var _backdrop: ColorRect
var _is_open: bool = false

func _ready() -> void:
	layer = 30
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	set_process_unhandled_input(true)
	_build_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and event.shift_pressed:
			_toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and _is_open:
			_close_pause()
			get_viewport().set_input_as_handled()

func toggle_pause_menu() -> void:
	_toggle_pause()

func _build_ui() -> void:
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.03, 0.06, 0.1, 0.52)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_backdrop)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(440, 320)
	_panel.offset_left = -220
	_panel.offset_top = -160
	_panel.offset_right = 220
	_panel.offset_bottom = 160
	_panel.self_modulate = Color(0.96, 0.98, 1.0, 0.98)
	add_child(_panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	_title = Label.new()
	_title.text = "Pause Menu"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color(0.14, 0.2, 0.3, 1.0))
	vbox.add_child(_title)

	_hint = Label.new()
	_hint.text = "Controls: WASD/Arrows move, Mouse look, E/Enter/Click interact"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	_hint.add_theme_color_override("font_color", Color(0.25, 0.33, 0.45, 1.0))
	vbox.add_child(_hint)

	vbox.add_child(HSeparator.new())

	_resume_btn = _make_button("Resume")
	_resume_btn.pressed.connect(_on_resume)
	vbox.add_child(_resume_btn)

	_main_menu_btn = _make_button("Main Menu")
	_main_menu_btn.pressed.connect(_on_main_menu)
	vbox.add_child(_main_menu_btn)

	_exit_btn = _make_button("Exit Game")
	_exit_btn.pressed.connect(_on_exit)
	vbox.add_child(_exit_btn)

	for button in [_resume_btn, _main_menu_btn, _exit_btn]:
		button.mouse_entered.connect(func() -> void:
			button.self_modulate = Color(0.88, 0.94, 1.0, 1.0)
		)
		button.focus_entered.connect(func() -> void:
			button.self_modulate = Color(0.88, 0.94, 1.0, 1.0)
		)
		button.mouse_exited.connect(func() -> void:
			button.self_modulate = Color.WHITE
		)
		button.focus_exited.connect(func() -> void:
			button.self_modulate = Color.WHITE
		)

func _make_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 44)
	btn.focus_mode = Control.FOCUS_ALL
	return btn

func _toggle_pause() -> void:
	if _is_open:
		_close_pause()
	else:
		_open_pause()

func _open_pause() -> void:
	_is_open = true
	visible = true
	_backdrop.modulate.a = 0.0
	_panel.modulate.a = 0.0
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(_backdrop, "modulate:a", 1.0, 0.18)
	t.tween_property(_panel, "modulate:a", 1.0, 0.18)
	_resume_btn.grab_focus()

func _close_pause() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume() -> void:
	_close_pause()

func _on_main_menu() -> void:
	get_tree().paused = false
	_is_open = false
	visible = false
	SceneManager.go_to_main_menu()

func _on_exit() -> void:
	get_tree().paused = false
	get_tree().quit()
