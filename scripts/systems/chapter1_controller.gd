## Chapter 1: The Silent Witness — Crime Scene Controller
## Handles chapter-specific logic, triggers, and story progression
extends Node3D

@onready var hud = $HUD
@onready var dialogue_ui = $DialogueUI
@onready var qte_system = $QTESystem
@onready var pause_overlay = $PauseOverlay

var _intro_played: bool = false
var _chase_triggered: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and event.shift_pressed:
			if pause_overlay and pause_overlay.has_method("toggle_pause_menu"):
				pause_overlay.toggle_pause_menu()
				get_viewport().set_input_as_handled()

func _ready() -> void:
	# Set chapter info
	GameState.start_chapter("chapter_1")
	
	# Wait for scene to settle, then play intro
	await get_tree().create_timer(1.5).timeout
	_play_intro()

func _play_intro() -> void:
	if _intro_played:
		return
	_intro_played = true
	
	# Start the complete Act 1 dialogue tree
	DialogueManager.start_dialogue("res://dialogue_data/chapter1_complete.json")
	
	# After intro dialogue ends, set objective
	await DialogueManager.dialogue_ended
	
	if hud:
		hud.set_objective("Search the apartment for clues")
	
	# Monitor clue collection for story progression
	ClueManager.clue_collected.connect(_on_clue_found)
	ClueManager.deduction_unlocked.connect(_on_deduction_made)
	
	# Connect to achievement system
	Achievements.check_and_unlock()

func _on_clue_found(clue: Dictionary) -> void:
	var count = ClueManager.get_clue_count()
	
	# Log to detective notebook
	DetectiveNotebook.record_clue_examination(
		clue.get("id", "unknown"),
		clue.get("name", "Unknown Evidence"),
		clue.get("description", "Evidence discovered at the crime scene")
	)
	
	# Check for achievements
	if count == 1:
		Achievements.unlock_achievement("first_clue")
	elif count == 5:
		Achievements.unlock_achievement("clue_hoarder")
	Achievements.check_and_unlock()
	
	# Update objectives based on progress
	if count == 3 and hud:
		hud.set_objective("Talk to the neighbor in 4A")
	elif count == 5 and hud:
		hud.set_objective("Review your evidence at the deduction board")
	
	# Trigger chase sequence after finding enough evidence
	if count >= 6 and not _chase_triggered:
		_trigger_chase_sequence()

func _on_deduction_made(deduction_id: String) -> void:
	if hud:
		hud.show_notification("New deduction unlocked!", 4.0)

## ACTION SEQUENCE: A suspect is spotted fleeing the building!
func _trigger_chase_sequence() -> void:
	_chase_triggered = true
	
	# Dramatic dialogue before chase
	var chase_intro = {
		"start": {
			"speaker": "Officer Chen",
			"text": "(radio crackles) Detective! We've got a man running from the back exit! Dark coat, heading toward the alley!",
			"next": "react"
		},
		"react": {
			"speaker": "{detective}",
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
	
	# Start QTE chase sequence!
	GameState.modify_stress(15)
	
	var chase_events: Array[Dictionary] = [
		{
			"key": "qte_action",
			"prompt": "⬆ JUMP OVER FENCE!",
			"time": 2.0,
			"success_text": "You vault the fence!",
			"fail_text": "You stumble but keep going!"
		},
		{
			"key": "qte_action",
			"prompt": "⬅ DODGE LEFT!",
			"time": 1.5,
			"success_text": "Narrowly avoided the dumpster!",
			"fail_text": "You clip the dumpster — lost ground!"
		},
		{
			"key": "qte_action",
			"prompt": "GRAB HIM!",
			"time": 1.2,
			"success_text": "Got him!",
			"fail_text": "He slips away!"
		}
	]
	
	qte_system.start_qte(chase_events)
	
	var result = await qte_system.qte_completed
	var success: bool = result[0]
	
	if success:
		_chase_success()
	else:
		_chase_failed()

func _chase_success() -> void:
	var dialogue = {
		"start": {
			"speaker": "Narrator",
			"text": "You tackle the man to the ground. He struggles, but you pin him against the wet pavement.",
			"next": "confrontation"
		},
		"confrontation": {
			"speaker": "{detective}",
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
	
	# Log to detective notebook
	DetectiveNotebook.record_theory(
		"Suspect's Warning",
		["Suspect claims he was warning the victim", "Suspect was at the apartment during time of death"],
		["Motive unclear", "Suspect fled the scene"]
	)
	
	await DialogueManager.dialogue_ended
	SaveManager.save_game(1)

func _chase_failed() -> void:
	var dialogue = {
		"start": {
			"speaker": "Narrator",
			"text": "The figure disappears into the darkness of the city. You're left standing in the empty alley, catching your breath.",
			"next": "aftermath"
		},
		"aftermath": {
			"speaker": "{detective}",
			"text": "Damn. I lost him. But I got a good look — this isn't over. I'll find out who you are.",
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
	
	# Log to detective notebook
	DetectiveNotebook.record_theory(
		"Escaped Suspect",
		["Unknown man fled apartment", "Was attempting to warn the victim"],
		["Identity unknown", "Motive still unclear", "Suspect now at large"]
	)
	
	Achievements.check_and_unlock()
	
	await DialogueManager.dialogue_ended
	SaveManager.save_game(1)
