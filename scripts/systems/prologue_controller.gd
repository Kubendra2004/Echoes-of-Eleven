## Prologue Controller - Police Briefing Scene
extends Node3D

var _dialogue_index: int = 0
var _speaker_label: Label
var _text_label: Label
var _can_advance: bool = false
var _is_typing: bool = false
var _is_transitioning: bool = false

var _prologue_dialogue = [
	{"speaker": "CAPTAIN SHARMA", "text": "We have a situation. Eleven bodies found hanging in a residence. All from the same family.\n\nNo signs of struggle. No suicide notes. Nothing makes sense."},
	{"speaker": "CAPTAIN SHARMA", "text": "The forensics team is baffled. The media is having a field day. Internal Affairs is breathing down my neck.\n\nWe need answers. Fast."},
	{"speaker": "DETECTIVE (You)", "text": "Tell me what we have, Captain."},
	{"speaker": "CAPTAIN SHARMA", "text": "The Bhatnagar family. 11 members. Found July 16th, 2007 at their home in Burari, Delhi.\n\nTheory: Mass murder-suicide. But the evidence doesn't support it. Every scenario fails the autopsy results."},
	{"speaker": "CAPTAIN SHARMA", "text": "Some bodies had injuries incompatible with hanging. Some had strange substances in their blood. The timeline doesn't add up.\n\nEverything points to a conspiracy. But involving who? How deep does this go?"},
	{"speaker": "DETECTIVE (You)", "text": "I'm on it, Captain. I'll find the truth."},
	{"speaker": "CAPTAIN SHARMA", "text": "The apartment is sealed. Evidence is catalogued. Your job is to piece together what happened that night.\n\nGood luck, Detective. This case will define your career."},
]

func _ready() -> void:
	_speaker_label = get_node_or_null("UILayer/Content/SpeakerLabel") as Label
	_text_label = get_node_or_null("UILayer/Content/DialogueLabel") as Label
	var canv = get_node_or_null("UILayer/Background") as ColorRect

	# Fail-safe: if prologue UI is not valid, jump straight to gameplay.
	if _speaker_label == null or _text_label == null or canv == null:
		push_warning("[Prologue] UI nodes missing. Falling back to crime scene.")
		GameState.start_chapter("chapter_1")
		SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")
		return
	
	# Styling
	_speaker_label.add_theme_font_size_override("font_size", 20)
	_speaker_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	
	_text_label.add_theme_font_size_override("font_size", 16)
	_text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	
	# Fade in from black
	canv.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(canv, "color", Color(0.05, 0.04, 0.03, 1), 2.0)
	await tween.finished
	_show_prologue_line()

func _show_prologue_line() -> void:
	if _speaker_label == null or _text_label == null:
		_end_prologue()
		return

	if _dialogue_index >= _prologue_dialogue.size():
		_end_prologue()
		return
	
	var line = _prologue_dialogue[_dialogue_index]
	_speaker_label.text = line["speaker"]
	_text_label.text = ""
	_is_typing = true
	_can_advance = false
	
	# Typewriter effect
	for char in line["text"]:
		if not _is_typing:
			break
		_text_label.text += char
		await get_tree().create_timer(0.03).timeout

	# Ensure full line is visible after skip.
	_text_label.text = line["text"]
	_is_typing = false
	
	_can_advance = true

func _unhandled_input(event: InputEvent) -> void:
	if _is_transitioning:
		return

	if _is_typing and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_click")):
		_is_typing = false
		get_viewport().set_input_as_handled()
		return

	if not _can_advance:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_click") or event.is_action_pressed("ui_down"):
		_can_advance = false
		_dialogue_index += 1
		_show_prologue_line()
		get_viewport().set_input_as_handled()

func _end_prologue() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_can_advance = false
	_is_typing = false
	# Fade to black
	var canv = get_node_or_null("UILayer/Background") as ColorRect
	if canv == null:
		GameState.start_chapter("chapter_1")
		SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")
		return
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(canv, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	GameState.start_chapter("chapter_1")
	SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")
