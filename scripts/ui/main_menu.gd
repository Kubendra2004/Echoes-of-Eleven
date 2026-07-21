## Main Menu — Midnight Noir design (matches Stitch "Echoes of Eleven" design system)
## Playfair Display serif title, amber gold accents, cinematic dark atmosphere
extends Control

# Colour tokens from the Midnight Noir design system
const C_BG          := Color(0.071, 0.075, 0.094, 1.0)   # #12131a
const C_SURFACE     := Color(0.118, 0.122, 0.149, 1.0)   # #1e1f26
const C_AMBER       := Color(1.000, 0.749, 0.000, 1.0)   # #ffbf00
const C_AMBER_DIM   := Color(0.784, 0.549, 0.000, 1.0)   # warm amber
const C_CRIMSON     := Color(0.863, 0.149, 0.149, 1.0)   # #dc2626
const C_TEXT        := Color(0.886, 0.882, 0.922, 1.0)   # #e2e1eb
const C_TEXT_SUB    := Color(0.780, 0.776, 0.796, 1.0)   # #c7c6cb

var _new_btn: Button
var _continue_btn: Button
var _quit_btn: Button
var _all_btns: Array[Button] = []

func _ready() -> void:
	# Guarantee clean state when entering main menu
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	_build_ui()
	_animate_intro()

# ──────────────────────────────────────────────
func _build_ui() -> void:
	# Full dark background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = C_BG
	add_child(bg)

	# Vignette overlay (radial dark edge)
	var vignette = _make_vignette()
	add_child(vignette)

	# Left panel — crime scene decorative block (atmospheric)
	var left_panel = ColorRect.new()
	left_panel.set_anchor_and_offset(SIDE_LEFT,   0, 0)
	left_panel.set_anchor_and_offset(SIDE_RIGHT,  0.5, 0)
	left_panel.set_anchor_and_offset(SIDE_TOP,    0, 0)
	left_panel.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	left_panel.color = Color(0.04, 0.04, 0.06, 1.0)
	add_child(left_panel)

	# Left panel atmosphere label (crime scene flavor text)
	var flavor = Label.new()
	flavor.text = "New Delhi, 2007\n11 bodies. No answers.\nThe truth died with them —\n\nor so they thought."
	flavor.set_anchor_and_offset(SIDE_LEFT,   0, 40)
	flavor.set_anchor_and_offset(SIDE_RIGHT,  0.5, -40)
	flavor.set_anchor_and_offset(SIDE_TOP,    0, 0)
	flavor.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	flavor.autowrap_mode = TextServer.AUTOWRAP_WORD
	flavor.add_theme_color_override("font_color", Color(C_TEXT_SUB.r, C_TEXT_SUB.g, C_TEXT_SUB.b, 0.35))
	flavor.add_theme_font_size_override("font_size", 18)
	add_child(flavor)

	# Police tape horizontal strip
	var tape = ColorRect.new()
	tape.set_anchor_and_offset(SIDE_LEFT,   0, 0)
	tape.set_anchor_and_offset(SIDE_RIGHT,  0.5, 0)
	tape.set_anchor_and_offset(SIDE_TOP,    0.5, -2)
	tape.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 2)
	tape.color = Color(C_AMBER.r, C_AMBER.g, C_AMBER.b, 0.5)
	add_child(tape)

	# Right panel — menu
	var right = VBoxContainer.new()
	right.set_anchor_and_offset(SIDE_LEFT,   0.5, 64)
	right.set_anchor_and_offset(SIDE_RIGHT,  1.0, -64)
	right.set_anchor_and_offset(SIDE_TOP,    0.0, 0)
	right.set_anchor_and_offset(SIDE_BOTTOM, 1.0, 0)
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", 0)
	add_child(right)

	# Game title
	var title = Label.new()
	title.text = "ECHOES OF ELEVEN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_color_override("font_color", C_AMBER)
	title.add_theme_font_size_override("font_size", 48)
	title.modulate.a = 0.0
	right.add_child(title)

	# Crimson accent line
	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(0, 2)
	line.color = C_CRIMSON
	right.add_child(line)

	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 6)
	right.add_child(spacer1)

	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "The Burari Case"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	subtitle.add_theme_color_override("font_color", C_TEXT_SUB)
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.modulate.a = 0.0
	right.add_child(subtitle)

	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 48)
	right.add_child(spacer2)

	# Buttons
	_new_btn      = _make_menu_btn("New Investigation")
	_continue_btn = _make_menu_btn("Continue Case")
	_quit_btn     = _make_menu_btn("Quit")

	right.add_child(_new_btn)
	right.add_child(_make_separator())
	right.add_child(_continue_btn)
	right.add_child(_make_separator())
	right.add_child(_quit_btn)

	_all_btns = [_new_btn, _continue_btn, _quit_btn]

	# Continue only if save exists
	_continue_btn.disabled = not SaveManager.has_save(1)
	if _continue_btn.disabled:
		_continue_btn.modulate = Color(0.4, 0.4, 0.4, 0.6)

	_new_btn.pressed.connect(_on_new_game)
	_continue_btn.pressed.connect(_on_continue)
	_quit_btn.pressed.connect(get_tree().quit)

	# Version label bottom-right
	var ver = Label.new()
	ver.text = "v0.1 — Chapter 1"
	ver.set_anchor_and_offset(SIDE_RIGHT,  1, -12)
	ver.set_anchor_and_offset(SIDE_BOTTOM, 1, -12)
	ver.set_anchor_and_offset(SIDE_LEFT,   1, -160)
	ver.set_anchor_and_offset(SIDE_TOP,    1, -32)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ver.add_theme_color_override("font_color", Color(C_TEXT_SUB.r, C_TEXT_SUB.g, C_TEXT_SUB.b, 0.4))
	ver.add_theme_font_size_override("font_size", 12)
	add_child(ver)

	# Store refs for animation
	_new_btn.modulate.a      = 0.0
	_continue_btn.modulate.a = 0.0
	_quit_btn.modulate.a     = 0.0

	# Store title and subtitle for animation
	title.set_meta("is_title", true)
	subtitle.set_meta("is_subtitle", true)

func _make_menu_btn(text: String) -> Button:
	var btn = Button.new()
	btn.text = "  " + text
	btn.custom_minimum_size = Vector2(320, 52)
	btn.focus_mode = Control.FOCUS_ALL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Style: dark fill, amber border
	var normal = StyleBoxFlat.new()
	normal.bg_color    = Color(0.06, 0.07, 0.10, 1.0)
	normal.border_color = C_AMBER
	for side in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
		normal.set_border_width(side, 1)
	normal.content_margin_left = 20

	var hover = StyleBoxFlat.new()
	hover.bg_color    = C_AMBER
	hover.border_color = C_AMBER
	for side in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
		hover.set_border_width(side, 1)
	hover.content_margin_left = 20

	var pressed = StyleBoxFlat.new()
	pressed.bg_color    = C_AMBER_DIM
	pressed.border_color = C_AMBER_DIM
	for side in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
		pressed.set_border_width(side, 1)
	pressed.content_margin_left = 20

	btn.add_theme_stylebox_override("normal",   normal)
	btn.add_theme_stylebox_override("hover",    hover)
	btn.add_theme_stylebox_override("pressed",  pressed)
	btn.add_theme_stylebox_override("focus",    hover)
	btn.add_theme_stylebox_override("disabled", StyleBoxFlat.new())

	btn.add_theme_color_override("font_color",           C_TEXT)
	btn.add_theme_color_override("font_hover_color",     C_BG)
	btn.add_theme_color_override("font_pressed_color",   C_BG)
	btn.add_theme_font_size_override("font_size", 16)

	return btn

func _make_separator() -> Control:
	var s = Control.new()
	s.custom_minimum_size = Vector2(0, 8)
	return s

func _make_vignette() -> ColorRect:
	# Simple dark vignette via a gradient could be done in Godot 4 with a
	# shader but we'll use a subtle dark overlay with reduced opacity center
	# For simplicity: just a very dark, low-opacity rect
	var v = ColorRect.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.color = Color(0.02, 0.02, 0.04, 0.25)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return v

func _animate_intro() -> void:
	# Fade in all children sequentially
	var items_to_fade: Array[Control] = []
	for child in get_children():
		if child is Control:
			items_to_fade.append(child as Control)

	# Find title, subtitle, buttons specifically
	var t = create_tween()
	t.set_parallel(false)

	# Quick background fade-in
	t.tween_interval(0.3)

	# Find nodes in tree by iterating
	for child in get_tree().get_nodes_in_group("menu_fade"):
		t.tween_property(child, "modulate:a", 1.0, 0.5)

	# Fade the whole scene in together with a global tween
	modulate.a = 0.0
	var scene_tween = create_tween()
	scene_tween.tween_property(self, "modulate:a", 1.0, 1.2)

	# Sequentially fade in buttons after 0.8s
	await get_tree().create_timer(0.8).timeout
	for btn in _all_btns:
		if not btn.disabled or btn == _continue_btn:
			var btween = create_tween()
			btween.tween_property(btn, "modulate:a", 1.0, 0.3)
			await get_tree().create_timer(0.12).timeout

# ──────────────────────────────────────────────
func _on_new_game() -> void:
	GameState.reset_state()
	ClueManager.reset()
	GameState.detective_name = "Detective Chen"
	GameState.start_chapter("chapter_1")
	SceneManager.change_scene("res://scenes/chapter1/crime_scene.tscn")

func _on_continue() -> void:
	SaveManager.load_game(1)
