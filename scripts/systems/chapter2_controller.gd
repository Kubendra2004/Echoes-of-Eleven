## Chapter 2: The Warning — Sullivan's Office Investigation
## Player investigates Marcus Sullivan's office and conducts the interrogation
extends Node3D

@onready var hud           = $HUD
@onready var dialogue_ui   = $DialogueUI
@onready var pause_overlay = $PauseOverlay
@onready var deduction_board = $DeductionBoard

var _intro_played: bool = false
var _interrogation_started: bool = false
var _chapter_ended: bool = false

# Tracks which chapter 1 outcome we're continuing from
var _ch1_caught_suspect: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and event.shift_pressed:
			if pause_overlay and pause_overlay.has_method("toggle_pause_menu"):
				pause_overlay.toggle_pause_menu()
				get_viewport().set_input_as_handled()

func _ready() -> void:
	if deduction_board:
		deduction_board.add_to_group("deduction_board")

	GameState.start_chapter("chapter_2")
	GameState.set_objective("Search Sullivan's office for evidence")

	# Read Chapter 1 outcome
	_ch1_caught_suspect = GameState.get_flag("caught_suspect_ch1")

	# Load Chapter 2 clues into ClueManager
	ClueManager.load_chapter_clues("res://dialogue_data/chapter2_clues.json")

	# Connect signals
	ClueManager.clue_collected.connect(_on_clue_found)
	ClueManager.deduction_unlocked.connect(_on_deduction_made)

	await get_tree().create_timer(1.5).timeout
	_play_intro()

func _play_intro() -> void:
	if _intro_played:
		return
	_intro_played = true

	# Tailor intro based on chapter 1 outcome
	var intro_text: String
	if _ch1_caught_suspect:
		intro_text = "The man you caught — he refused to give his name. But he said one word before the lawyers arrived: 'Sullivan.' Three days later, you're standing outside Marcus Sullivan's office."
	else:
		intro_text = "The suspect vanished. But he left a trail. Three missed calls to the victim from one number: Marcus Sullivan. Business partner. Alibi unverified. Three days later, you have a warrant."

	var intro = {
		"start": {
			"speaker": "Narrator",
			"text": intro_text,
			"next": "chen_resolve"
		},
		"chen_resolve": {
			"speaker": "Detective Chen",
			"text": "Marcus Sullivan. Let's see what you're hiding."
		}
	}

	DialogueManager.start_dialogue_from_data(intro)

	var timeout = get_tree().create_timer(30.0)
	await _race([DialogueManager.dialogue_ended, timeout.timeout])

	if hud: hud.set_objective("Search Sullivan's office for evidence")
	if hud: hud.show_notification("🔍 Search the room for clues", 3.0)

func _on_clue_found(clue: Dictionary) -> void:
	var count = ClueManager.get_clues_for_chapter("chapter_2").size()

	DetectiveNotebook.record_clue_examination(
		clue.get("id", "unknown"),
		clue.get("name", "Unknown"),
		clue.get("description", "")
	)

	# Progressive objectives
	match count:
		2:
			if hud: hud.set_objective("Keep searching — look for anything that breaks his alibi")
		4:
			if hud: hud.set_objective("Enough to question him. Confront Sullivan at his desk")
		6:
			if hud: hud.set_objective("Check the desk for the key you saw him pocket")

	# Unlock interrogation after 4 clues
	if count >= 4 and not _interrogation_started:
		_start_interrogation()

	# Check achievements
	if ClueManager.get_clue_count() >= 10:
		Achievements.unlock_achievement("clue_hoarder")
	Achievements.check_and_unlock()

func _on_deduction_made(_id: String) -> void:
	if hud: hud.show_notification("💡 New deduction unlocked!", 4.0)

# ──────────────────────────────────────────────
func _start_interrogation() -> void:
	if _interrogation_started: return
	_interrogation_started = true

	if hud: hud.show_notification("⚡ Time to confront Sullivan", 3.0)
	await get_tree().create_timer(2.0).timeout

	DialogueManager.start_dialogue("res://dialogue_data/chapter2_interrogation.json")

	var timeout = get_tree().create_timer(120.0)
	await _race([DialogueManager.dialogue_ended, timeout.timeout])

	# After interrogation, collect the mystery key
	ClueManager.collect_clue("mystery_key")
	if hud: hud.show_notification("🗝️ You pocketed the key before Sullivan noticed.", 4.0)

	await get_tree().create_timer(3.0).timeout
	_end_chapter()

func _end_chapter() -> void:
	if _chapter_ended: return
	_chapter_ended = true

	SaveManager.save_game(1)
	GameState.set_flag("chapter_2_complete")
	Achievements.check_and_unlock()
	_show_chapter_complete()

func _show_chapter_complete() -> void:
	var overlay = CanvasLayer.new()
	overlay.layer = 50
	add_child(overlay)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.08, 0.0)
	overlay.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(520, 0)
	vbox.offset_left = -260; vbox.offset_right = 260
	vbox.offset_top  = -130; vbox.offset_bottom = 130
	vbox.add_theme_constant_override("separation", 18)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay.add_child(vbox)

	var _add_label = func(text: String, size: int, color: Color, italic: bool = false) -> Label:
		var lbl = Label.new()
		lbl.text = text
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", size)
		lbl.add_theme_color_override("font_color", color)
		lbl.modulate.a = 0.0
		vbox.add_child(lbl)
		return lbl

	var ch_lbl   = _add_label.call("CHAPTER 2 COMPLETE",          34, Color(0.9, 0.85, 0.6, 1.0))
	var sub_lbl  = _add_label.call("The Warning",                 20, Color(0.78, 0.78, 0.82, 1.0))
	var gap      = Control.new(); gap.custom_minimum_size = Vector2(0,8); vbox.add_child(gap)
	var info_lbl = _add_label.call("The key to New Delhi Railway Station — Locker 47.\nWhat did Sullivan hide there?", 15, Color(0.65, 0.72, 0.85, 1.0))
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	var stats    = _add_label.call("Evidence: %d  |  Reputation: %d  |  Stress: %d" % [
		ClueManager.get_clue_count(), GameState.reputation, GameState.stress], 13, Color(0.55, 0.65, 0.8, 1.0))
	var saved    = _add_label.call("✅  Progress saved",          13, Color(0.4, 0.85, 0.5, 1.0))

	var btn = Button.new()
	btn.text = "Return to Main Menu"
	btn.custom_minimum_size = Vector2(240, 48)
	btn.modulate.a = 0.0
	vbox.add_child(btn)

	# Animate in
	var nodes_to_fade = [ch_lbl, sub_lbl, info_lbl, stats, saved, btn]
	var t = create_tween().set_parallel(true)
	t.tween_property(bg, "color:a", 0.90, 1.0)
	for i in nodes_to_fade.size():
		t.tween_property(nodes_to_fade[i], "modulate:a", 1.0, 0.8).set_delay(0.4 + i * 0.25)

	await t.finished
	btn.pressed.connect(func():
		get_tree().paused = false
		SceneManager.go_to_main_menu()
	)

## Wait for either signal, return index of winner (0 or 1)
func _race(signals: Array) -> int:
	var done = false; var result = 0
	var cbs = []
	for i in signals.size():
		var cb = func():
			if not done: done = true; result = i
		cbs.append(cb)
		signals[i].connect(cb, CONNECT_ONE_SHOT)
	while not done:
		await get_tree().process_frame
	for i in signals.size():
		if signals[i].is_connected(cbs[i]):
			signals[i].disconnect(cbs[i])
	return result
