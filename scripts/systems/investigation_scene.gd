## Investigation Scene — Base script for crime scene / location exploration
extends Node3D

@export var scene_name: String = "Crime Scene"
@export var scene_description: String = ""
@export var ambient_music_path: String = ""

@onready var hud = $HUD
@onready var dialogue_ui = $DialogueUI

func _ready() -> void:
	# Set objective
	if hud:
		hud.set_objective("Investigate the %s" % scene_name)
	
	# Intro text
	await get_tree().create_timer(1.0).timeout
	_show_scene_intro()

func _show_scene_intro() -> void:
	if scene_description != "":
		var intro_dialogue = {
			"start": {
				"speaker": "Narrator",
				"text": scene_description
			}
		}
		DialogueManager.start_dialogue_from_data(intro_dialogue)

func _input(event: InputEvent) -> void:
	# Quick save
	if event.is_action_pressed("pause_menu"):
		_open_pause_menu()

func _open_pause_menu() -> void:
	# Simple pause — can be expanded later
	get_tree().paused = !get_tree().paused
