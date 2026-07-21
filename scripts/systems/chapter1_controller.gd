## Chapter 1: The Silent Witness — Crime Scene Controller
extends Node3D

@onready var hud = $HUD
@onready var dialogue_ui = $DialogueUI
@onready var qte_system = $QTESystem
@onready var pause_overlay = $PauseOverlay
@onready var deduction_board = $DeductionBoard

var _intro_played: bool = false
var _chase_triggered: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and event.shift_pressed:
			if pause_overlay and pause_overlay.has_method("toggle_pause_menu"):
				pause_overlay.toggle_pause_menu()
				get_viewport().set_input_as_handled()

func _ready() -> void:
	# Register deduction board in group so pause overlay can find it
	if deduction_board:
		deduction_board.add_to_group("deduction_board")

	GameState.start_chapter("chapter_1")
	GameState.set_objective("Investigate the crime scene")

	# Wait for scene to fully settle before starting intro dialogue
	await get_tree().create_timer(1.5).timeout
	_play_intro()

func _play_intro() -> void:
	if _intro_played:
		return
	_intro_played = true

	DialogueManager.start_dialogue("res://dialogue_data/chapter1_complete.json")

	# Guard: if dialogue never ends in 60s, continue anyway (prevents infinite hang)
	var timeout_timer = get_tree().create_timer(60.0)
	var finished = await _race_signals([DialogueManager.dialogue_ended, timeout_timer.timeout])
	if finished == 1:
		push_warning("[Chapter1] Dialogue timed out after 60s — continuing to investigation.")

	_begin_investigation()

## Wait for whichever signal fires first. Returns 0 for first signal, 1 for second.
func _race_signals(signals: Array) -> int:
	var done = false
	var result = -1

	var callbacks = []
	for i in signals.size():
		var cb = func():
			if not done:
				done = true
				result = i
		callbacks.append(cb)
		signals[i].connect(cb, CONNECT_ONE_SHOT)

	while not done:
		await get_tree().process_frame

	# Disconnect any remaining
	for i in signals.size():
		if signals[i].is_connected(callbacks[i]):
			signals[i].disconnect(callbacks[i])

	return result

func _begin_investigation() -> void:
	if hud:
		hud.set_objective("Search the apartment for clues")

	ClueManager.clue_collected.connect(_on_clue_found)
	ClueManager.deduction_unlocked.connect(_on_deduction_made)
	Achievements.check_and_unlock()

func _on_clue_found(clue: Dictionary) -> void:
	var count = ClueManager.get_clue_count()

	DetectiveNotebook.record_clue_examination(
		clue.get("id", "unknown"),
		clue.get("name", "Unknown Evidence"),
		clue.get("description", "Evidence discovered at the crime scene")
	)

	if count == 1:
		Achievements.unlock_achievement("first_clue")
	elif count == 5:
		Achievements.unlock_achievement("clue_hoarder")
	Achievements.check_and_unlock()

	match count:
		3:
			if hud: hud.set_objective("Talk to the neighbor in apartment 4A")
			_enable_neighbor_door()
		5:
			if hud: hud.set_objective("Review your evidence on the deduction board (press I)")
		_:
			pass

	if clue.get("id") == "neighbor_testimony":
		DialogueManager.start_dialogue("res://dialogue_data/chapter1_neighbor.json")

	if count >= 6 and not _chase_triggered:
		_trigger_chase_sequence()

func _on_deduction_made(_deduction_id: String) -> void:
	if hud:
		hud.show_notification("💡 New deduction unlocked!", 4.0)

# ──────────────────────────────────────────────
func _enable_neighbor_door() -> void:
	# Check if it already exists
	if get_node_or_null("/root/CrimeScene/Clues/NeighborDoor"): return
	
	# Try to find the Clues container
	var clues_node = get_node_or_null("/root/CrimeScene/Clues")
	if not clues_node: return
	
	# Spawn a new InteractableClue for the door
	var door_clue = load("res://scripts/entities/interactable_clue.gd").new()
	door_clue.name = "NeighborDoor"
	door_clue.clue_id = "neighbor_testimony"
	door_clue.clue_display_name = "Apartment 4A Door"
	door_clue.examine_text = "Mrs. Park lives here. She might have heard something."
	door_clue.position = Vector3(-6.5, 1.0, 2.0)
	
	# Add a collision shape
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.5, 2.0, 1.5)
	collision.shape = shape
	door_clue.add_child(collision)
	
	# Add the floating label
	var label = Label3D.new()
	label.text = "[E] Knock"
	label.pixel_size = 0.005
	label.position = Vector3(0.3, 0.2, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	door_clue.add_child(label)
	
	clues_node.add_child(door_clue)
	
	# Setup logic when examining this clue to trigger dialogue
	# We rely on the ClueManager emitting clue_collected for this ID
	
func _trigger_chase_sequence() -> void:
	_chase_triggered = true

	var chase_intro = {
		"start": {
			"speaker": "Officer Chen",
			"text": "(radio crackles) Detective! We've got a man running from the back exit! Dark coat, heading toward the alley!",
			"next": "react"
		},
		"react": {
			"speaker": GameState.detective_name,
			"text": "That matches Park's description. I'm going after him!",
			"next": "chase_begin"
		},
		"chase_begin": {
			"speaker": "Narrator",
			"text": "You sprint toward the back exit. The cold night air hits your face as you burst through the door into the dark alley..."
		}
	}

	DialogueManager.start_dialogue_from_data(chase_intro)
	await DialogueManager.dialogue_ended

	GameState.modify_stress(15)
	if hud: hud.show_notification("⚡ CHASE SEQUENCE", 2.0)

	var chase_events: Array[Dictionary] = [
		{"key": "qte_action", "prompt": "⬆  JUMP OVER FENCE!", "time": 2.0,
		 "success_text": "You vault the fence!", "fail_text": "You stumble but keep going!"},
		{"key": "qte_action", "prompt": "⬅  DODGE LEFT!", "time": 1.5,
		 "success_text": "Narrowly avoided the dumpster!", "fail_text": "You clip the dumpster — lost ground!"},
		{"key": "qte_action", "prompt": "⚡  GRAB HIM!", "time": 1.2,
		 "success_text": "Got him!", "fail_text": "He slips away!"},
	]

	qte_system.start_qte(chase_events)
	var result = await qte_system.qte_completed
	var success: bool = result[0]

	if success: _chase_success()
	else:        _chase_failed()

func _chase_success() -> void:
	var dialogue = {
		"start": {
			"speaker": "Narrator",
			"text": "You tackle the man to the ground. He struggles, but you pin him against the wet pavement.",
			"next": "confrontation"
		},
		"confrontation": {
			"speaker": GameState.detective_name,
			"text": "Going somewhere? Let's have a chat about what you were doing at Apartment 4B tonight.",
			"next": "suspect_response"
		},
		"suspect_response": {
			"speaker": "???",
			"text": "(breathing heavily) You don't understand... I didn't kill him! I was trying to WARN him! But I was too late...",
			"next": "chapter_end"
		},
		"chapter_end": {
			"speaker": "Narrator",
			"text": "To be continued in Chapter 2: The Warning..."
		}
	}

	DialogueManager.start_dialogue_from_data(dialogue)
	GameState.set_flag("caught_suspect_ch1")
	GameState.make_choice("chase_outcome", "success")
	GameState.modify_reputation(10)

	DetectiveNotebook.record_theory(
		"Suspect's Warning",
		["Suspect claims he was warning the victim", "Suspect was at the apartment during time of death"],
		["Motive unclear", "Suspect fled the scene"]
	)

	await DialogueManager.dialogue_ended
	_end_chapter("success")

func _chase_failed() -> void:
	var dialogue = {
		"start": {
			"speaker": "Narrator",
			"text": "The figure disappears into the darkness of the city. You're left standing in the empty alley, catching your breath.",
			"next": "aftermath"
		},
		"aftermath": {
			"speaker": GameState.detective_name,
			"text": "Damn. I lost him. But I got a good look — this isn't over.",
			"next": "chapter_end"
		},
		"chapter_end": {
			"speaker": "Narrator",
			"text": "The suspect escaped. But every clue tells a story. To be continued in Chapter 2: The Ghost..."
		}
	}

	DialogueManager.start_dialogue_from_data(dialogue)
	GameState.set_flag("suspect_escaped_ch1")
	GameState.make_choice("chase_outcome", "failed")
	GameState.modify_stress(20)

	DetectiveNotebook.record_theory(
		"Escaped Suspect",
		["Unknown man fled apartment", "Was attempting to warn the victim"],
		["Identity unknown", "Motive still unclear", "Suspect now at large"]
	)

	await DialogueManager.dialogue_ended
	_end_chapter("failed")

func _end_chapter(outcome: String) -> void:
	SaveManager.save_game(1)
	Achievements.check_and_unlock()

	# Show Chapter Complete overlay
	_show_chapter_complete_screen(outcome)

func _show_chapter_complete_screen(outcome: String) -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var overlay = CanvasLayer.new()
	overlay.layer = 50
	add_child(overlay)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.08, 0.0)
	overlay.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(500, 0)
	vbox.offset_left   = -250
	vbox.offset_right  = 250
	vbox.offset_top    = -120
	vbox.offset_bottom = 120
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay.add_child(vbox)

	var ch_label = Label.new()
	ch_label.text = "CHAPTER 1 COMPLETE"
	ch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ch_label.add_theme_font_size_override("font_size", 36)
	ch_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6, 1.0))
	ch_label.modulate.a = 0.0
	vbox.add_child(ch_label)

	var sub_text = "The suspect escaped into the night." if outcome == "failed" else "You caught the fleeing suspect."
	var sub = Label.new()
	sub.text = sub_text
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1.0))
	sub.modulate.a = 0.0
	vbox.add_child(sub)

	var stats = Label.new()
	stats.text = "Evidence collected: %d / 6   |   Reputation: %d" % [ClueManager.get_clue_count(), GameState.reputation]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_color_override("font_color", Color(0.55, 0.65, 0.8, 1.0))
	stats.modulate.a = 0.0
	vbox.add_child(stats)

	var saved_lbl = Label.new()
	saved_lbl.text = "✅  Progress saved"
	saved_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	saved_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5, 1.0))
	saved_lbl.modulate.a = 0.0
	vbox.add_child(saved_lbl)

	var btn = Button.new()
	btn.text = "Continue to Chapter 2 →"
	btn.custom_minimum_size = Vector2(280, 48)
	btn.modulate.a = 0.0
	vbox.add_child(btn)

	var menu_btn = Button.new()
	menu_btn.text = "Return to Main Menu"
	menu_btn.custom_minimum_size = Vector2(280, 48)
	menu_btn.modulate.a = 0.0
	vbox.add_child(menu_btn)

	# Animate everything in
	var t = create_tween().set_parallel(true)
	t.tween_property(bg, "color:a", 0.88, 1.0)
	t.tween_property(ch_label, "modulate:a", 1.0, 1.2).set_delay(0.3)
	t.tween_property(sub, "modulate:a", 1.0, 1.0).set_delay(0.8)
	t.tween_property(stats, "modulate:a", 1.0, 1.0).set_delay(1.1)
	t.tween_property(saved_lbl, "modulate:a", 1.0, 1.0).set_delay(1.4)
	t.tween_property(btn, "modulate:a", 1.0, 1.0).set_delay(1.8)
	t.tween_property(menu_btn, "modulate:a", 1.0, 1.0).set_delay(2.0)

	await t.finished

	btn.pressed.connect(func():
		get_tree().paused = false
		SceneManager.change_scene("res://scenes/chapter2/sullivan_office.tscn")
	)
	menu_btn.pressed.connect(func():
		get_tree().paused = false
		SceneManager.go_to_main_menu()
	)
