## Dialogue UI — Shows dialogue text, speaker name, and choices
extends CanvasLayer

signal choice_selected(index: int)

@onready var panel: PanelContainer = %DialoguePanel
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var continue_indicator: Label = %ContinueIndicator

var _is_typing: bool = false
var _full_text: String = ""
var _char_index: int = 0
var _type_speed: float = 0.03  # seconds per character
var _choice_buttons: Array[Button] = []
var _selected_choice_index: int = 0

func _ready() -> void:
	panel.visible = false
	continue_indicator.visible = false
	choices_container.visible = false
	
	# Connect to DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_displayed.connect(_on_line_displayed)
	DialogueManager.dialogue_choices_presented.connect(_on_choices_presented)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _input(event: InputEvent) -> void:
	if not panel.visible:
		return

	# If text is typing, accept/click should skip typewriter effect.
	if _is_typing and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_click")):
		_finish_typing()
		get_viewport().set_input_as_handled()
		return

	# Choice navigation and confirmation.
	if _choice_buttons.size() > 0:
		if event.is_action_pressed("ui_up"):
			_selected_choice_index = (_selected_choice_index - 1 + _choice_buttons.size()) % _choice_buttons.size()
			_focus_selected_choice()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("ui_down"):
			_selected_choice_index = (_selected_choice_index + 1) % _choice_buttons.size()
			_focus_selected_choice()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("ui_accept"):
			_on_choice_pressed(_selected_choice_index)
			get_viewport().set_input_as_handled()
			return

	# Linear dialogue advance when there are no choices.
	if _choice_buttons.is_empty() and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_click")):
		DialogueManager.advance()
		get_viewport().set_input_as_handled()

func _on_dialogue_started(_npc_name: String) -> void:
	panel.visible = true
	choices_container.visible = false
	continue_indicator.visible = false

func _on_line_displayed(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	_clear_choices()
	continue_indicator.visible = false
	
	# Start typewriter effect
	_full_text = text
	_char_index = 0
	_is_typing = true
	%TextLabel.text = ""
	_type_next_char()

func _type_next_char() -> void:
	if _char_index >= _full_text.length():
		_finish_typing()
		return
	
	%TextLabel.text += _full_text[_char_index]
	_char_index += 1
	
	# Schedule next character
	get_tree().create_timer(_type_speed).timeout.connect(_type_next_char)

func _finish_typing() -> void:
	_is_typing = false
	%TextLabel.text = _full_text
	continue_indicator.visible = true

func _on_choices_presented(choices: Array) -> void:
	_clear_choices()
	continue_indicator.visible = false
	choices_container.visible = true
	_selected_choice_index = 0
	
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i].get("text", "...")
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 40)
		btn.focus_mode = Control.FOCUS_ALL
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx = i  # Capture index for lambda
		btn.pressed.connect(func(): _on_choice_pressed(idx))
		btn.mouse_entered.connect(func(): _on_choice_hovered(idx))
		choices_container.add_child(btn)
		_choice_buttons.append(btn)

	_focus_selected_choice()

func _on_choice_hovered(index: int) -> void:
	if index < 0 or index >= _choice_buttons.size():
		return
	_selected_choice_index = index
	_focus_selected_choice()

func _focus_selected_choice() -> void:
	if _choice_buttons.is_empty():
		return
	for i in range(_choice_buttons.size()):
		var button = _choice_buttons[i]
		if not is_instance_valid(button):
			continue
		button.modulate = Color.WHITE
	
	var selected = _choice_buttons[_selected_choice_index]
	if is_instance_valid(selected):
		selected.grab_focus()
		selected.modulate = Color(1.0, 0.9, 0.6, 1.0)

func _on_choice_pressed(index: int) -> void:
	_clear_choices()
	choices_container.visible = false
	choice_selected.emit(index)
	DialogueManager.select_choice(index)

func _clear_choices() -> void:
	_choice_buttons.clear()
	for child in choices_container.get_children():
		child.queue_free()

func _on_dialogue_ended() -> void:
	panel.visible = false
	choices_container.visible = false
	continue_indicator.visible = false
