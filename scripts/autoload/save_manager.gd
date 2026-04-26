## SaveManager Autoload
## Handles saving and loading game progress
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE = "save_slot_%d.json"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

## Save game to slot (1-3)
func save_game(slot: int = 1) -> bool:
	var save_data: Dictionary = {
		"version": "1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"game_state": {
			"current_chapter": GameState.current_chapter,
			"current_scene_id": GameState.current_scene_id,
			"detective_name": GameState.detective_name,
			"choices": GameState.choices,
			"flags": GameState.flags,
			"reputation": GameState.reputation,
			"stress": GameState.stress,
			"current_day": GameState.current_day,
			"current_hour": GameState.current_hour,
		},
		"clues": {
			"collected": ClueManager.collected_clues,
			"connections": ClueManager.connections,
			"deductions": ClueManager.deductions,
		}
	}
	
	var file_path = SAVE_DIR + SAVE_FILE % slot
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[SaveManager] Could not save to: %s" % file_path)
		return false
	
	file.store_string(JSON.stringify(save_data, "\t"))
	print("[SaveManager] Game saved to slot %d" % slot)
	return true

## Load game from slot
func load_game(slot: int = 1) -> bool:
	var file_path = SAVE_DIR + SAVE_FILE % slot
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[SaveManager] No save file in slot %d" % slot)
		return false
	
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("[SaveManager] Corrupt save file in slot %d" % slot)
		return false
	
	var data: Dictionary = json.data
	
	# Restore GameState
	var gs = data.get("game_state", {})
	GameState.current_chapter = gs.get("current_chapter", "")
	GameState.current_scene_id = gs.get("current_scene_id", "")
	GameState.detective_name = gs.get("detective_name", "Detective")
	GameState.choices = gs.get("choices", {})
	GameState.flags = gs.get("flags", {})
	GameState.reputation = gs.get("reputation", 50)
	GameState.stress = gs.get("stress", 0)
	GameState.current_day = gs.get("current_day", 1)
	GameState.current_hour = gs.get("current_hour", 8)
	
	# Restore ClueManager
	var clues = data.get("clues", {})
	ClueManager.collected_clues = clues.get("collected", {})
	ClueManager.connections = clues.get("connections", [])
	ClueManager.deductions = clues.get("deductions", {})
	
	# Load the saved scene
	if GameState.current_scene_id != "":
		SceneManager.change_scene(GameState.current_scene_id)
	
	print("[SaveManager] Game loaded from slot %d" % slot)
	return true

## Check if a save slot exists
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + SAVE_FILE % slot)

## Get save slot info (for UI display)
func get_save_info(slot: int) -> Dictionary:
	var file_path = SAVE_DIR + SAVE_FILE % slot
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	
	var data: Dictionary = json.data
	return {
		"timestamp": data.get("timestamp", "Unknown"),
		"chapter": data.get("game_state", {}).get("current_chapter", "Unknown"),
		"day": data.get("game_state", {}).get("current_day", 0),
	}

## Delete a save slot
func delete_save(slot: int) -> void:
	var file_path = SAVE_DIR + SAVE_FILE % slot
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("[SaveManager] Deleted save slot %d" % slot)
