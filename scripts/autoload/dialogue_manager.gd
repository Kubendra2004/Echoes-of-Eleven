## DialogueManager Autoload
## Manages dialogue trees, branching conversations, and NPC interactions
extends Node

signal dialogue_started(npc_name: String)
signal dialogue_line_displayed(speaker: String, text: String)
signal dialogue_choices_presented(choices: Array)
signal dialogue_ended

## Currently loaded dialogue data
var _current_dialogue: Dictionary = {}
var _current_node_id: String = ""
var _is_active: bool = false

## Dialogue history for the current conversation
var _history: Array[Dictionary] = []

func is_dialogue_active() -> bool:
	return _is_active

## Load dialogue from a JSON file
## Dialogue format:
## {
##   "start": {
##     "speaker": "Witness",
##     "text": "I saw everything that night...",
##     "next": "question_1"
##   },
##   "question_1": {
##     "speaker": "Detective",
##     "text": "What did you see?",
##     "choices": [
##       {"text": "Be aggressive", "next": "aggressive_path", "flag": "aggressive_interrogation"},
##       {"text": "Be empathetic", "next": "empathetic_path", "reputation": 5},
##       {"text": "Show evidence", "next": "evidence_path", "requires_clue": "bloody_knife"}
##     ]
##   }
## }
func start_dialogue(dialogue_file: String) -> void:
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	if not file:
		push_error("[DialogueManager] Could not open: %s" % dialogue_file)
		return
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	if parse_result != OK:
		push_error("[DialogueManager] JSON parse error in: %s" % dialogue_file)
		return
	
	_current_dialogue = json.data
	_current_node_id = "start"
	_is_active = true
	_history.clear()
	
	var speaker = _current_dialogue.get("start", {}).get("speaker", "")
	dialogue_started.emit(speaker)
	display_current_node()

## Start dialogue from a dictionary directly (useful for dynamic dialogue)
func start_dialogue_from_data(data: Dictionary) -> void:
	_current_dialogue = data
	_current_node_id = "start"
	_is_active = true
	_history.clear()
	
	var speaker = _current_dialogue.get("start", {}).get("speaker", "")
	dialogue_started.emit(speaker)
	display_current_node()

## Display the current dialogue node
func display_current_node() -> void:
	if not _is_active or _current_node_id not in _current_dialogue:
		end_dialogue()
		return
	
	var node = _current_dialogue[_current_node_id]
	var speaker: String = node.get("speaker", "")
	var text: String = node.get("text", "")
	
	# Replace variables in text
	text = text.replace("{detective}", GameState.detective_name)
	text = text.replace("{day}", str(GameState.current_day))
	
	# Record in history
	_history.append({"speaker": speaker, "text": text})
	
	# Emit the line
	dialogue_line_displayed.emit(speaker, text)
	
	# Check if this node has choices
	if "choices" in node:
		var available_choices: Array = []
		for choice in node["choices"]:
			# Check if choice requires a clue
			if "requires_clue" in choice:
				if not ClueManager.has_clue(choice["requires_clue"]):
					continue
			# Check if choice requires a flag
			if "requires_flag" in choice:
				if not GameState.get_flag(choice["requires_flag"]):
					continue
			available_choices.append(choice)
		
		dialogue_choices_presented.emit(available_choices)

## Advance to next node (for linear dialogue without choices)
func advance() -> void:
	if not _is_active:
		return
	
	var node = _current_dialogue.get(_current_node_id, {})
	
	if "next" in node:
		_current_node_id = node["next"]
		display_current_node()
	elif "choices" not in node:
		end_dialogue()

## Select a choice by index
func select_choice(choice_index: int) -> void:
	if not _is_active:
		return
	
	var node = _current_dialogue.get(_current_node_id, {})
	if "choices" not in node:
		return
	
	var choices = node["choices"]
	if choice_index < 0 or choice_index >= choices.size():
		return
	
	var choice = choices[choice_index]
	
	# Apply choice effects
	if "flag" in choice:
		GameState.set_flag(choice["flag"])
	if "reputation" in choice:
		GameState.modify_reputation(choice["reputation"])
	if "stress" in choice:
		GameState.modify_stress(choice["stress"])
	if "choice_id" in choice:
		GameState.make_choice(choice["choice_id"], choice["text"])
	
	# Move to next node
	if "next" in choice:
		_current_node_id = choice["next"]
		display_current_node()
	else:
		end_dialogue()

## End the current dialogue
func end_dialogue() -> void:
	_is_active = false
	_current_dialogue.clear()
	_current_node_id = ""
	dialogue_ended.emit()

## Get conversation history
func get_history() -> Array[Dictionary]:
	return _history
