## HUD Script — Shows clue count, current objective, day/time, stress meter
extends CanvasLayer

@onready var clue_count_label: Label = %ClueCountLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var time_label: Label = %TimeLabel
@onready var stress_bar: ProgressBar = %StressBar
@onready var notification_label: Label = %NotificationLabel

var _current_objective: String = ""
var _notification_tween: Tween
var _objective_tween: Tween

func _ready() -> void:
	# Connect signals
	ClueManager.clue_collected.connect(_on_clue_collected)
	GameState.game_flag_set.connect(_on_flag_set)

	# Lighter modern HUD palette.
	clue_count_label.add_theme_color_override("font_color", Color(0.16, 0.25, 0.38, 1.0))
	time_label.add_theme_color_override("font_color", Color(0.16, 0.25, 0.38, 1.0))
	objective_label.add_theme_color_override("font_color", Color(0.08, 0.18, 0.28, 1.0))
	notification_label.add_theme_color_override("font_color", Color(0.08, 0.2, 0.3, 1.0))
	notification_label.add_theme_font_size_override("font_size", 18)
	
	_update_hud()
	notification_label.modulate.a = 0.0

func _process(_delta: float) -> void:
	_update_time_display()

func _update_hud() -> void:
	clue_count_label.text = "Evidence: %d | Interact: E / Enter / Left Click | Pause: Shift+Enter" % ClueManager.get_clue_count()
	stress_bar.value = GameState.stress
	if GameState.stress < 30:
		stress_bar.modulate = Color(0.4, 0.9, 0.6, 1.0)
	elif GameState.stress < 70:
		stress_bar.modulate = Color(0.95, 0.84, 0.45, 1.0)
	else:
		stress_bar.modulate = Color(0.95, 0.45, 0.45, 1.0)
	_update_time_display()

func _update_time_display() -> void:
	var play_time = GameState.get_play_time_formatted()
	time_label.text = "Day %d — %02d:00 | ⏱ %s" % [GameState.current_day, GameState.current_hour, play_time]

## Set the current objective text
func set_objective(text: String) -> void:
	_current_objective = text
	objective_label.text = "📋 " + text

	if _objective_tween:
		_objective_tween.kill()
	objective_label.scale = Vector2(0.98, 0.98)
	_objective_tween = create_tween()
	_objective_tween.tween_property(objective_label, "scale", Vector2(1.0, 1.0), 0.25)

## Show a notification popup (e.g., "New clue found!")
func show_notification(text: String, duration: float = 3.0) -> void:
	notification_label.text = text
	
	if _notification_tween:
		_notification_tween.kill()
	
	_notification_tween = create_tween()
	_notification_tween.tween_property(notification_label, "modulate:a", 1.0, 0.3)
	_notification_tween.tween_interval(duration)
	_notification_tween.tween_property(notification_label, "modulate:a", 0.0, 0.5)

func _on_clue_collected(clue: Dictionary) -> void:
	_update_hud()
	show_notification("🔍 Clue found: %s" % clue.get("name", "Unknown"))

func _on_flag_set(_flag: String, _value: bool) -> void:
	_update_hud()
