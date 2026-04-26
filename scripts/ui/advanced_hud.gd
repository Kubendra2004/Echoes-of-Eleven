## Advanced HUD with Arrow Key Navigation for Dialogue Choices
extends CanvasLayer

var _clue_count: Label
var _objective_label: Label
var _stress_meter: ProgressBar
var _time_label: Label
var _dialogue_choices: Array[Button] = []
var _selected_choice: int = 0
var _dialogue_active: bool = false

func _ready() -> void:
	setup_hud_elements()
	GameState.objective_changed.connect(_on_objective_changed)
	GameState.stress_changed.connect(_on_stress_changed)

func setup_hud_elements() -> void:
	"""Create HUD elements if not found in scene"""
	
	# Clue counter
	_clue_count = Label.new()
	_clue_count.text = "🔍 Evidence: 0/11"
	_clue_count.add_theme_font_size_override("font_size", 18)
	_clue_count.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_clue_count.position = Vector2(20, 20)
	add_child(_clue_count)
	
	# Objective
	_objective_label = Label.new()
	_objective_label.text = "Search for clues..."
	_objective_label.add_theme_font_size_override("font_size", 14)
	_objective_label.word_wrap_mode = TextServer.AUTOWRAP_WORD
	_objective_label.custom_minimum_size = Vector2(400, 60)
	_objective_label.position = Vector2(20, 60)
	add_child(_objective_label)
	
	# Stress meter
	_stress_meter = ProgressBar.new()
	_stress_meter.value = 50
	_stress_meter.custom_minimum_size = Vector2(200, 20)
	_stress_meter.position = Vector2(20, 140)
	_stress_meter.modulate = Color(1.0, 0.2, 0.2)  # Red
	add_child(_stress_meter)
	
	# Time display
	_time_label = Label.new()
	_time_label.text = "Day 1 — 08:00"
	_time_label.add_theme_font_size_override("font_size", 16)
	_time_label.position = Vector2(get_viewport().size.x - 200, 20)
	add_child(_time_label)

func update_clue_count(count: int) -> void:
	"""Update the clue counter display"""
	_clue_count.text = "🔍 Evidence: %d/11" % count
	
	# Pulse effect on new clue
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	var original_scale = _clue_count.scale
	tween.tween_property(_clue_count, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(_clue_count, "scale", original_scale, 0.2)

func _on_objective_changed(new_objective: String) -> void:
	"""Update objective display"""
	_objective_label.text = "📋 " + new_objective

func _on_stress_changed(stress_level: int) -> void:
	"""Update stress meter"""
	_stress_meter.value = stress_level
	
	# Color coding
	if stress_level < 30:
		_stress_meter.modulate = Color(0.2, 1.0, 0.2)  # Green
	elif stress_level < 70:
		_stress_meter.modulate = Color(1.0, 1.0, 0.2)  # Yellow
	else:
		_stress_meter.modulate = Color(1.0, 0.2, 0.2)  # Red

func show_dialogue_choices(choices: Array[String], callback: Callable) -> void:
	"""Show dialogue choices with arrow key navigation"""
	_dialogue_active = true
	_selected_choice = 0
	_dialogue_choices.clear()
	
	# Create choice buttons
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i]
		btn.custom_minimum_size = Vector2(500, 40)
		btn.position = Vector2(
			(get_viewport().size.x - 500) / 2,
			get_viewport().size.y - 150 - (i * 50)
		)
		btn.pressed.connect(func(): 
			_dialogue_active = false
			callback.call(i)
		)
		add_child(btn)
		_dialogue_choices.append(btn)
	
	highlight_choice()

func highlight_choice() -> void:
	"""Highlight the currently selected dialogue choice"""
	for i in range(_dialogue_choices.size()):
		if i == _selected_choice:
			_dialogue_choices[i].modulate = Color(1.0, 0.84, 0.0)  # Gold
			_dialogue_choices[i].scale = Vector2(1.05, 1.05)
		else:
			_dialogue_choices[i].modulate = Color.WHITE
			_dialogue_choices[i].scale = Vector2(1.0, 1.0)

func _input(event: InputEvent) -> void:
	"""Handle arrow key navigation for dialogue choices"""
	if not _dialogue_active or _dialogue_choices.is_empty():
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP, KEY_W:
				_selected_choice = (_selected_choice - 1) % _dialogue_choices.size()
				highlight_choice()
				get_tree().root.set_input_as_handled()
			
			KEY_DOWN, KEY_S:
				_selected_choice = (_selected_choice + 1) % _dialogue_choices.size()
				highlight_choice()
				get_tree().root.set_input_as_handled()
			
			KEY_ENTER, KEY_SPACE:
				_dialogue_choices[_selected_choice].emit_signal("pressed")
				get_tree().root.set_input_as_handled()

func _process(_delta: float) -> void:
	"""Update time display"""
	var time_str = GameState.get_time_display()
	_time_label.text = time_str
