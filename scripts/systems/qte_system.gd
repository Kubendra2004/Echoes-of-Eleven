## QTE (Quick Time Event) System
## Used for action/thriller sequences — chase scenes, combat, tense moments
extends CanvasLayer

signal qte_completed(success: bool, score: float)
signal qte_hit
signal qte_miss

@onready var prompt_label: Label = %PromptLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var result_label: Label = %ResultLabel
@onready var qte_panel: PanelContainer = %QTEPanel

## QTE configuration
var _events: Array[Dictionary] = []
var _current_event_index: int = 0
var _is_active: bool = false
var _time_remaining: float = 0.0
var _successes: int = 0
var _total_events: int = 0

## QTE Event Structure:
## {
##   "key": "qte_action",        # Input action name
##   "prompt": "PRESS SPACE!",    # Text to display
##   "time": 1.5,                 # Seconds to react
##   "success_text": "Dodged!",   # Shown on success
##   "fail_text": "Hit!",         # Shown on failure
## }

func _ready() -> void:
	qte_panel.visible = false
	result_label.visible = false

func _process(delta: float) -> void:
	if not _is_active:
		return
	
	_time_remaining -= delta
	timer_bar.value = (_time_remaining / _events[_current_event_index]["time"]) * 100.0
	
	if _time_remaining <= 0.0:
		_on_event_failed()

func _input(event: InputEvent) -> void:
	if not _is_active:
		return
	
	var current_event = _events[_current_event_index]
	var required_action = current_event.get("key", "qte_action")
	
	if event.is_action_pressed(required_action):
		_on_event_success()

## Start a QTE sequence with an array of events
func start_qte(events: Array[Dictionary]) -> void:
	_events = events
	_current_event_index = 0
	_successes = 0
	_total_events = events.size()
	_is_active = false
	
	qte_panel.visible = true
	result_label.visible = false
	
	# Brief delay before first event
	await get_tree().create_timer(0.5).timeout
	_start_current_event()

## Start a single quick QTE (convenience method)
func start_single_qte(prompt: String, time_limit: float = 1.5) -> void:
	var events: Array[Dictionary] = [{
		"key": "qte_action",
		"prompt": prompt,
		"time": time_limit,
		"success_text": "Success!",
		"fail_text": "Failed!"
	}]
	start_qte(events)

func _start_current_event() -> void:
	if _current_event_index >= _events.size():
		_finish_qte()
		return
	
	var ev = _events[_current_event_index]
	prompt_label.text = ev.get("prompt", "PRESS SPACE!")
	_time_remaining = ev.get("time", 1.5)
	timer_bar.value = 100.0
	result_label.visible = false
	_is_active = true
	
	# Dramatic flash effect
	var tween = create_tween()
	tween.tween_property(prompt_label, "modulate", Color.WHITE, 0.1).from(Color.RED)

func _on_event_success() -> void:
	_is_active = false
	_successes += 1
	
	var ev = _events[_current_event_index]
	result_label.text = ev.get("success_text", "Success!")
	result_label.add_theme_color_override("font_color", Color.GREEN)
	result_label.visible = true
	
	qte_hit.emit()
	
	# Brief pause then next event
	await get_tree().create_timer(0.8).timeout
	_current_event_index += 1
	_start_current_event()

func _on_event_failed() -> void:
	_is_active = false
	
	var ev = _events[_current_event_index]
	result_label.text = ev.get("fail_text", "Failed!")
	result_label.add_theme_color_override("font_color", Color.RED)
	result_label.visible = true
	
	qte_miss.emit()
	GameState.modify_stress(10)
	
	# Brief pause then next event
	await get_tree().create_timer(0.8).timeout
	_current_event_index += 1
	_start_current_event()

func _finish_qte() -> void:
	_is_active = false
	var score = float(_successes) / float(_total_events) if _total_events > 0 else 0.0
	var success = score >= 0.5
	
	# Show final result
	if success:
		result_label.text = "SEQUENCE PASSED! (%d/%d)" % [_successes, _total_events]
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "SEQUENCE FAILED! (%d/%d)" % [_successes, _total_events]
		result_label.add_theme_color_override("font_color", Color.RED)
	result_label.visible = true
	
	await get_tree().create_timer(2.0).timeout
	qte_panel.visible = false
	qte_completed.emit(success, score)
