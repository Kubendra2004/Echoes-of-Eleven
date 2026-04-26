## Enhanced Main Menu with Professional Theming
extends Control

var _buttons: Array[Button] = []
var _current_focus_index: int = 0

func _ready() -> void:
	# Check if there's a save to continue from
	setup_ui()
	check_save_status()
	
	# Animate in
	modulate.a = 0.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func setup_ui() -> void:
	# Background effect
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.04, 0.03, 1.0)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)
	move_child(bg, 0)
	
	# Main container
	var container = VBoxContainer.new()
	container.anchor_left = 0.25
	container.anchor_top = 0.15
	container.anchor_right = 0.75
	container.anchor_bottom = 0.85
	add_child(container)
	
	# Title
	var title = Label.new()
	title.text = "🔍 DETECTIVE CHRONICLES"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	title.alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(0, 100)
	container.add_child(title)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "The Burari Deaths"
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.7, 0.6))
	subtitle.alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(subtitle)
	
	# Spacer
	container.add_child(Control.new())
	
	# Quote/Description
	var description = Label.new()
	description.text = '"Eleven bodies. One question.\nWhat really happened that night?"'
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	description.alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.word_wrap_mode = TextServer.AUTOWRAP_WORD
	description.custom_minimum_size = Vector2(400, 0)
	container.add_child(description)
	
	# Spacer
	container.add_child(Control.new())
	
	# Buttons container
	var buttons_container = VBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 15)
	buttons_container.custom_minimum_size = Vector2(300, 0)
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# New Game Button
	var btn_new = create_menu_button("▶ NEW INVESTIGATION", _on_new_game)
	buttons_container.add_child(btn_new)
	_buttons.append(btn_new)
	
	# Continue Button
	var btn_continue = create_menu_button("⏸ CONTINUE CASE", _on_continue)
	buttons_container.add_child(btn_continue)
	_buttons.append(btn_continue)
	
	# Settings Button
	var btn_settings = create_menu_button("⚙ SETTINGS", _on_settings)
	buttons_container.add_child(btn_settings)
	_buttons.append(btn_settings)
	
	# Credits Button
	var btn_credits = create_menu_button("ℹ CREDITS", _on_credits)
	buttons_container.add_child(btn_credits)
	_buttons.append(btn_credits)
	
	# Quit Button
	var btn_quit = create_menu_button("✕ EXIT GAME", _on_quit)
	buttons_container.add_child(btn_quit)
	_buttons.append(btn_quit)
	
	container.add_child(buttons_container)
	
	# Footer
	var footer = Label.new()
	footer.text = "Echoes of Eleven v1.0 | Story-Driven Psychological Thriller | Based on Real Events"
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	footer.alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(footer)

func create_menu_button(text: String, callback: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 50)
	btn.add_theme_font_size_override("font_size", 16)
	
	# Style
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.15, 0.1, 0.8)
	style_normal.border_color = Color(0.8, 0.6, 0.3, 0.6)
	style_normal.set_border_enabled_all(true)
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.3, 0.2, 0.12, 0.9)
	style_hover.border_color = Color(1.0, 0.84, 0.0, 0.9)
	style_hover.set_border_enabled_all(true)
	style_hover.set_border_width_all(2)
	style_hover.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("hover", style_hover)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.15, 0.1, 0.05, 0.9)
	style_pressed.border_color = Color(1.0, 0.84, 0.0, 1.0)
	style_pressed.set_border_enabled_all(true)
	style_pressed.set_border_width_all(3)
	style_pressed.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	
	btn.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	btn.pressed.connect(callback)
	
	return btn

func check_save_status() -> void:
	# Disable continue button if no save exists
	if _buttons.size() > 1:
		_buttons[1].disabled = not SaveManager.has_save(1)

func _on_new_game() -> void:
	_show_confirmation("Start a new investigation?\nYour current progress will be lost.", func():
		GameState.reset_state()
		ClueManager.reset()
		Achievements.load_achievements()
		GameState.start_chapter("chapter_1")
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		await tween.finished
		SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")
	)

func _on_continue() -> void:
	# Load and transition
	SaveManager.load_game(1)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")

func _on_settings() -> void:
	print("⚙ Settings menu (to be implemented)")

func _on_credits() -> void:
	var credits_text = """
Echoes of Eleven: The Burari Deaths

DEVELOPMENT
Design, Programming: [Your Name]
Writing & Narrative: [Your Name]
Audio Design: [Contributors]

TECHNOLOGY
Engine: Godot Engine 4.3 (MIT License)
Made with ❤️ by the indie game community

SPECIAL THANKS
- Godot community and contributors
- Testers and feedback providers
- The real investigation team (Burari Deaths, 2007)

INSPIRED BY REAL EVENTS
This game is a fictional interpretation inspired by true events.
The Burari Deaths case remains partially unsolved.
This game is not affiliated with any official investigation.

© 2024 Echoes of Eleven
All rights reserved.
"""
	_show_info_dialog("CREDITS", credits_text)

func _on_quit() -> void:
	get_tree().quit()

func _show_confirmation(message: String, callback: Callable) -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Confirmation"
	dialog.dialog_text = message
	dialog.canceled.connect(dialog.queue_free)
	dialog.confirmed.connect(func():
		callback.call()
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered_ratio()

func _show_info_dialog(title: String, content: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = content
	dialog.ok_button.text = "Back"
	add_child(dialog)
	dialog.popup_centered_ratio(0.7)
