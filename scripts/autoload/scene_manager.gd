## SceneManager Autoload
## Handles scene transitions with fade effects
extends Node

signal scene_changed(new_scene: String)
signal transition_started
signal transition_finished

@onready var tree: SceneTree = get_tree()

var _transition_overlay: ColorRect
var _tween: Tween

func _ready() -> void:
	# Ensure transitions play even if the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create a full-screen overlay for fade transitions
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.modulate.a = 0.0
	_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_overlay.z_index = 100
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	canvas_layer.add_child(_transition_overlay)
	add_child(canvas_layer)

## Change scene with a fade transition
func change_scene(scene_path: String, fade_duration: float = 0.5) -> void:
	transition_started.emit()
	
	# Fade to black
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_transition_overlay, "modulate:a", 1.0, fade_duration)
	await _tween.finished
	
	# Change the scene
	tree.change_scene_to_file(scene_path)
	GameState.current_scene_id = scene_path
	scene_changed.emit(scene_path)
	
	# Wait a frame for the new scene to load
	await tree.process_frame
	
	# Fade from black
	_tween = create_tween()
	_tween.tween_property(_transition_overlay, "modulate:a", 0.0, fade_duration)
	await _tween.finished
	
	# Guarantee the game is unpaused when a new scene begins
	get_tree().paused = false
	transition_finished.emit()

## Quick scene change without fade
func change_scene_instant(scene_path: String) -> void:
	tree.change_scene_to_file(scene_path)
	GameState.current_scene_id = scene_path
	scene_changed.emit(scene_path)

## Reload current scene
func reload_current_scene() -> void:
	tree.reload_current_scene()

## Go to main menu
func go_to_main_menu() -> void:
	change_scene("res://scenes/main_menu/main_menu.tscn")
