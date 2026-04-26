## Main Menu Script
extends Control

@onready var new_game_btn: Button = %NewGameButton
@onready var continue_btn: Button = %ContinueButton
@onready var quit_btn: Button = %QuitButton
@onready var title_label: Label = %TitleLabel

func _ready() -> void:
	# Check if there's a save to continue from
	continue_btn.visible = SaveManager.has_save(1)
	
	# Animate title
	title_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 2.0)
	
	# Connect buttons
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	quit_btn.pressed.connect(_on_quit)

func _on_new_game() -> void:
	GameState.reset_state()
	ClueManager.reset()
	GameState.start_chapter("chapter_1")
	SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")

func _on_continue() -> void:
	SaveManager.load_game(1)

func _on_quit() -> void:
	get_tree().quit()
