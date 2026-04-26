## Main menu with reliable mouse + keyboard navigation.
extends Control

@onready var new_game_btn: Button = %NewGameButton
@onready var continue_btn: Button = %ContinueButton
@onready var quit_btn: Button = %QuitButton

var _buttons: Array[Button] = []
var _current_focus_index: int = 0
var _menu_open: bool = true
var _is_transitioning: bool = false

func _ready() -> void:
	_buttons = [new_game_btn, continue_btn, quit_btn]
	modulate.a = 0.0
	var intro_tween = create_tween()
	intro_tween.tween_property(self, "modulate:a", 1.0, 0.35)

	# Explicitly connect scene buttons so mouse click always works.
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	quit_btn.pressed.connect(_on_quit)

	# Keep Continue hidden when no save exists.
	continue_btn.visible = SaveManager.has_save(1)

	# Focus first visible button.
	_current_focus_index = _first_visible_button_index()
	_highlight_current_button()

	# Sync keyboard selection when hovering with mouse.
	for i in range(_buttons.size()):
		var idx := i
		_buttons[i].mouse_entered.connect(func() -> void:
			if _menu_open and _buttons[idx].visible:
				_current_focus_index = idx
				_highlight_current_button()
		)
		_buttons[i].focus_entered.connect(func() -> void:
			if _menu_open and _buttons[idx].visible:
				_current_focus_index = idx
				_highlight_current_button()
		)

func _unhandled_input(event: InputEvent) -> void:
	if not _menu_open or _buttons.is_empty():
		return

	if event.is_action_pressed("ui_up"):
		_move_selection(-1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_down"):
		_move_selection(1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept"):
		var button := _buttons[_current_focus_index]
		if is_instance_valid(button) and button.visible and not button.disabled:
			button.pressed.emit()
		get_viewport().set_input_as_handled()

func _move_selection(step: int) -> void:
	if _buttons.is_empty():
		return

	var idx := _current_focus_index
	for _i in range(_buttons.size()):
		idx = (idx + step + _buttons.size()) % _buttons.size()
		if _buttons[idx].visible and not _buttons[idx].disabled:
			_current_focus_index = idx
			break

	_highlight_current_button()

func _first_visible_button_index() -> int:
	for i in range(_buttons.size()):
		if _buttons[i].visible and not _buttons[i].disabled:
			return i
	return 0

func _highlight_current_button() -> void:
	for i in range(_buttons.size()):
		var btn := _buttons[i]
		if not is_instance_valid(btn):
			continue
		if i == _current_focus_index and btn.visible:
			btn.grab_focus()
			btn.modulate = Color(0.92, 0.97, 1.0, 1.0)
			btn.scale = Vector2(1.06, 1.06)
		else:
			btn.modulate = Color(0.86, 0.9, 0.96, 1.0)
			btn.scale = Vector2.ONE

func _on_new_game() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_menu_open = false
	_set_buttons_disabled(true)
	GameState.reset_state()
	ClueManager.reset()

	var target_scene := "res://scenes/prologue/prologue.tscn"
	var probe := ResourceLoader.load(target_scene)
	if probe == null:
		target_scene = "res://scenes/chapter1/crime_scene.tscn"

	SceneManager.change_scene(target_scene)

func _on_continue() -> void:
	if _is_transitioning:
		return
	if not SaveManager.has_save(1):
		return
	_is_transitioning = true
	_menu_open = false
	_set_buttons_disabled(true)
	SaveManager.load_game(1)

func _on_quit() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_set_buttons_disabled(true)
	get_tree().quit()

func _set_buttons_disabled(value: bool) -> void:
	for button in _buttons:
		if is_instance_valid(button):
			button.disabled = value
