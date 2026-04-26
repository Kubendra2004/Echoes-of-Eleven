## Achievement System - Unlocks for player engagement
extends Node

signal achievement_unlocked(achievement_id: String, title: String, description: String)

var _achievements: Dictionary = {
	"first_clue": {
		"title": "Detective's Eye",
		"description": "Collected your first clue",
		"unlocked": false,
		"icon": "🔍"
	},
	"clue_hoarder": {
		"title": "Clue Hoarder",
		"description": "Collected 5 clues",
		"unlocked": false,
		"condition": {"type": "clue_count", "value": 5},
		"icon": "📋"
	},
	"evidence_master": {
		"title": "Evidence Master",
		"description": "Connected 3 clues together",
		"unlocked": false,
		"condition": {"type": "connections", "value": 3},
		"icon": "🔗"
	},
	"truth_seeker": {
		"title": "Truth Seeker",
		"description": "Chose to hunt the handler",
		"unlocked": false,
		"condition": {"type": "choice", "value": "hunt_handler"},
		"icon": "⚖️"
	},
	"hasty_detective": {
		"title": "Hasty Detective",
		"description": "Closed the case without collecting all evidence",
		"unlocked": false,
		"condition": {"type": "choice", "value": "close_case"},
		"icon": "⏱️"
	},
	"curious_mind": {
		"title": "Curious Mind",
		"description": "Chose to dig deeper into the mystery",
		"unlocked": false,
		"condition": {"type": "choice", "value": "dig_deeper"},
		"icon": "🧠"
	},
	"stress_test": {
		"title": "Under Pressure",
		"description": "Reached 80+ stress level",
		"unlocked": false,
		"condition": {"type": "stat", "stat_name": "stress", "value": 80},
		"icon": "😰"
	},
	"reputation_gain": {
		"title": "Admired",
		"description": "Earned 80+ reputation",
		"unlocked": false,
		"condition": {"type": "stat", "stat_name": "reputation", "value": 80},
		"icon": "⭐"
	},
	"perfect_game": {
		"title": "Perfect Investigation",
		"description": "Beat Act 1 with 90+ reputation and <30 stress",
		"unlocked": false,
		"condition": {"type": "combined", "stats": {"reputation": 90, "stress": 30}},
		"icon": "👑"
	},
	"speedrunner": {
		"title": "Speedrunner",
		"description": "Complete Act 1 in under 15 minutes",
		"unlocked": false,
		"condition": {"type": "time_limit", "value": 900},
		"icon": "🏃"
	}
}

var _save_path = "user://achievements.json"

func _ready() -> void:
	load_achievements()

func unlock_achievement(achievement_id: String) -> bool:
	if achievement_id in _achievements and not _achievements[achievement_id]["unlocked"]:
		_achievements[achievement_id]["unlocked"] = true
		var ach = _achievements[achievement_id]
		print("🏆 ACHIEVEMENT UNLOCKED: %s - %s" % [ach["title"], ach["description"]])
		achievement_unlocked.emit(achievement_id, ach["title"], ach["description"])
		save_achievements()
		return true
	return false

## Check and unlock based on game state
func check_and_unlock() -> void:
	for ach_id in _achievements:
		if _achievements[ach_id]["unlocked"]:
			continue
		
		var ach = _achievements[ach_id]
		if "condition" not in ach:
			continue
		
		var condition = ach["condition"]
		var should_unlock = false
		
		match condition.get("type"):
			"clue_count":
				if ClueManager.collected_clues.size() >= condition["value"]:
					should_unlock = true
			
			"connections":
				if ClueManager.connections.size() >= condition["value"]:
					should_unlock = true
			
			"choice":
				if GameState.choices.get("final_choice") == condition["value"]:
					should_unlock = true
			
			"stat":
				var stat_name = condition["stat_name"]
				var stat_value = GameState.get(stat_name) if stat_name in ["reputation", "stress"] else 0
				if stat_value >= condition["value"]:
					should_unlock = true
			
			"combined":
				var stats = condition["stats"]
				var all_match = true
				for stat_name in stats:
					var stat_value = GameState.get(stat_name) if stat_name in ["reputation", "stress"] else 0
					if stat_name == "stress":
						if stat_value > stats[stat_name]:
							all_match = false
					else:
						if stat_value < stats[stat_name]:
							all_match = false
				should_unlock = all_match
			
			"time_limit":
				# Check play time
				var play_time = GameState.get("play_time_seconds")
				if play_time <= condition["value"]:
					should_unlock = true

		if should_unlock:
			unlock_achievement(ach_id)

func get_achievements() -> Dictionary:
	return _achievements.duplicate()

func get_unlocked_count() -> int:
	var count = 0
	for ach in _achievements.values():
		if ach.get("unlocked", false):
			count += 1
	return count

func save_achievements() -> void:
	var data = {}
	for ach_id in _achievements:
		data[ach_id] = _achievements[ach_id].get("unlocked", false)
	
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	if file:
		file.store_var(data)

func load_achievements() -> void:
	var file = FileAccess.open(_save_path, FileAccess.READ)
	if file:
		var data = file.get_var()
		for ach_id in data:
			if ach_id in _achievements:
				_achievements[ach_id]["unlocked"] = data[ach_id]
