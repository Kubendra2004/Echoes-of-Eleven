## ClueManager Autoload
## Manages collected clues, evidence, and the deduction board
extends Node

signal clue_collected(clue: Dictionary)
signal clue_connection_made(clue_a: String, clue_b: String)
signal deduction_unlocked(deduction_id: String)

## All available clues in the game (loaded from data)
var _all_clues: Dictionary = {}

## Clues the player has collected
var collected_clues: Dictionary = {}

## Connections the player has made between clues
var connections: Array[Dictionary] = []

## Deductions unlocked by connecting clues
var deductions: Dictionary = {}

## --- Clue Data Structure ---
## {
##   "clue_id": {
##     "name": "Bloody Knife",
##     "description": "A kitchen knife with dried blood on the handle.",
##     "category": "physical",  # physical, testimony, document, digital
##     "location_found": "Kitchen",
##     "chapter": "chapter_1",
##     "icon": "res://assets/sprites/clues/bloody_knife.png",
##     "connects_to": ["victim_wound", "suspect_fingerprint"]
##   }
## }

func _ready() -> void:
	_load_clue_database()

func _load_clue_database() -> void:
	var file_path = "res://dialogue_data/clue_database.json"
	if not FileAccess.file_exists(file_path):
		print("[ClueManager] No clue database found, starting empty.")
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_all_clues = json.data
		print("[ClueManager] Loaded %d clues from database." % _all_clues.size())

## Collect a clue by ID
func collect_clue(clue_id: String) -> bool:
	if clue_id in collected_clues:
		print("[ClueManager] Clue already collected: %s" % clue_id)
		return false
	
	if clue_id not in _all_clues:
		push_warning("[ClueManager] Unknown clue ID: %s" % clue_id)
		# Allow collecting unknown clues with minimal data
		collected_clues[clue_id] = {"name": clue_id, "description": "Unknown clue"}
		clue_collected.emit(collected_clues[clue_id])
		return true
	
	collected_clues[clue_id] = _all_clues[clue_id].duplicate(true)
	collected_clues[clue_id]["collected_time"] = {
		"day": GameState.current_day,
		"hour": GameState.current_hour
	}
	
	clue_collected.emit(collected_clues[clue_id])
	GameState.set_flag("clue_" + clue_id)
	print("[ClueManager] Clue collected: %s" % _all_clues[clue_id].get("name", clue_id))
	
	# Check for auto-deductions
	_check_deductions()
	return true

## Check if player has a specific clue
func has_clue(clue_id: String) -> bool:
	return clue_id in collected_clues

## Get clue data
func get_clue(clue_id: String) -> Dictionary:
	return collected_clues.get(clue_id, {})

## Get all collected clues
func get_collected_clues() -> Dictionary:
	return collected_clues

## Get clues by category
func get_clues_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for clue_id in collected_clues:
		if collected_clues[clue_id].get("category", "") == category:
			result.append(collected_clues[clue_id])
	return result

## Connect two clues on the deduction board.
## Always succeeds if both clues are collected and not already connected.
## Returns true if the connection was newly made, false if it already existed.
func connect_clues(clue_a: String, clue_b: String) -> bool:
	if not has_clue(clue_a) or not has_clue(clue_b):
		return false
	if clue_a == clue_b:
		return false
	
	# Check if connection already exists
	for conn in connections:
		if (conn["a"] == clue_a and conn["b"] == clue_b) or \
		   (conn["a"] == clue_b and conn["b"] == clue_a):
			return false
	
	connections.append({"a": clue_a, "b": clue_b})
	clue_connection_made.emit(clue_a, clue_b)
	
	# Check if this connection unlocks a canonical deduction
	_check_deductions()
	return true

## Check if any deductions should be unlocked
func _check_deductions() -> void:
	# Check connects_to relationships
	for clue_id in collected_clues:
		var clue_data = _all_clues.get(clue_id, {})
		if "connects_to" in clue_data:
			for target_id in clue_data["connects_to"]:
				if has_clue(target_id):
					var deduction_id = clue_id + "_" + target_id
					if deduction_id not in deductions:
						deductions[deduction_id] = {
							"clues": [clue_id, target_id],
							"unlocked": true
						}
						deduction_unlocked.emit(deduction_id)

## Get number of collected clues
func get_clue_count() -> int:
	return collected_clues.size()

## Reset all clues (new game)
func reset() -> void:
	collected_clues.clear()
	connections.clear()
	deductions.clear()
