## GameState Autoload
## Tracks global game state: current chapter, player choices, game flags
extends Node

signal chapter_changed(chapter_id: String)
signal choice_made(choice_id: String, option: String)
signal game_flag_set(flag: String, value: bool)
signal objective_changed(new_objective: String)
signal stress_changed(stress_level: int)

## Current chapter/case being played
var current_chapter: String = ""
var current_scene_id: String = ""

## Player's detective name
var detective_name: String = "Detective"

## All choices the player has made — affects story branching
var choices: Dictionary = {}

## Game flags for tracking story progress (e.g., "met_witness_jones": true)
var flags: Dictionary = {}

## Player stats
var reputation: int = 50  # 0-100, affects NPC interactions
var stress: int = 0        # 0-100, affects action sequences

## Time tracking (in-game time)
var current_day: int = 1
var current_hour: int = 8  # 24-hour format

## Play time tracking (in seconds)
var play_time_seconds: int = 0
var _play_time_timer: Timer = null

## Current objective
var current_objective: String = "Begin investigation"

## --- Choice System ---

func make_choice(choice_id: String, option: String) -> void:
	choices[choice_id] = option
	choice_made.emit(choice_id, option)
	print("[GameState] Choice made: %s -> %s" % [choice_id, option])

func get_choice(choice_id: String) -> String:
	return choices.get(choice_id, "")

func has_made_choice(choice_id: String) -> bool:
	return choice_id in choices

## --- Flag System ---

func set_flag(flag: String, value: bool = true) -> void:
	flags[flag] = value
	game_flag_set.emit(flag, value)
	print("[GameState] Flag set: %s = %s" % [flag, str(value)])

func get_flag(flag: String) -> bool:
	return flags.get(flag, false)

## --- Chapter Management ---

func start_chapter(chapter_id: String) -> void:
	current_chapter = chapter_id
	chapter_changed.emit(chapter_id)
	print("[GameState] Chapter started: %s" % chapter_id)

## --- Reputation & Stress ---

func modify_reputation(amount: int) -> void:
	reputation = clampi(reputation + amount, 0, 100)
	print("[GameState] Reputation: %d" % reputation)

func modify_stress(amount: int) -> void:
	stress = clampi(stress + amount, 0, 100)
	stress_changed.emit(stress)
	print("[GameState] Stress: %d" % stress)

func set_objective(new_objective: String) -> void:
	current_objective = new_objective
	objective_changed.emit(new_objective)
	print("[GameState] Objective: %s" % new_objective)

func get_time_display() -> String:
	return "Day %d — %02d:00 | ⏱ %s" % [current_day, current_hour, get_play_time_formatted()]

## --- Time ---

func advance_time(hours: int) -> void:
	current_hour += hours
	while current_hour >= 24:
		current_hour -= 24
		current_day += 1
	print("[GameState] Day %d, %02d:00" % [current_day, current_hour])

## --- Reset ---

func reset_state() -> void:
	current_chapter = ""
	current_scene_id = ""
	choices.clear()
	flags.clear()
	reputation = 50
	stress = 0
	current_day = 1
	current_hour = 8
	play_time_seconds = 0
	start_play_timer()

## --- Play Time Tracking ---

func start_play_timer() -> void:
	if _play_time_timer:
		_play_time_timer.queue_free()
	
	_play_time_timer = Timer.new()
	_play_time_timer.wait_time = 1.0
	_play_time_timer.timeout.connect(func(): play_time_seconds += 1)
	add_child(_play_time_timer)
	_play_time_timer.start()

func stop_play_timer() -> void:
	if _play_time_timer:
		_play_time_timer.stop()

func get_play_time_minutes() -> float:
	return play_time_seconds / 60.0

func get_play_time_formatted() -> String:
	var mins = play_time_seconds / 60
	var secs = play_time_seconds % 60
	return "%02d:%02d" % [mins, secs]
