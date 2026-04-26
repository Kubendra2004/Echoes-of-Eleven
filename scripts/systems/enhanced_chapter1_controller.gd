## Enhanced Crime Scene Controller with Improved Visuals & Gameplay
extends Node3D

@onready var _hud = $HUD
@onready var _dialogue_ui = $DialogueUI
@onready var _lighting = $Lighting

var _clues_collected: int = 0
var _max_clues: int = 11
var _investigation_phase: int = 0  # 0=start, 1=initial investigation, 2=clues found, 3=questioning, 4=ready for ending

func _ready() -> void:
	setup_enhanced_visuals()
	setup_interactive_elements()
	
	# Connect signals
	ClueManager.clue_collected.connect(_on_clue_found)
	
	# Start investigation
	await get_tree().create_timer(1.5).timeout
	_play_intro()

func setup_enhanced_visuals() -> void:
	"""Enhance lighting and atmospheric effects"""
	var env = get_node("WorldEnvironment")
	var world_env = WorldEnvironment.new()
	
	# Add volumetric fog for atmosphere
	var fog_volume = FogVolume.new()
	add_child(fog_volume)
	
	# Improve directional light
	var light = get_node("DirectionalLight3D") as DirectionalLight3D
	light.light_energy_db = 1.5
	light.shadow_enabled = true
	light.shadow_blur = 2.0
	
	# Add ambient light for grim mood
	var ambient = get_node("AmbientLight3D") as DirectionalLight3D
	if not ambient:
		ambient = DirectionalLight3D.new()
		add_child(ambient)
	ambient.light_energy_db = 0.5
	
	# Add post-processing effect (cameras detect evidence better)
	print("✓ Enhanced visuals initialized")

func setup_interactive_elements() -> void:
	"""Setup enhanced interactive clues with better feedback"""
	var clues = get_tree().get_nodes_in_group("clues")
	for clue in clues:
		if clue.has_method("set_highlight_effect"):
			clue.set_highlight_effect(true)
		
		# Add pulse effect when near clue
		if clue is Node3D:
			_add_clue_glow(clue)

func _add_clue_glow(clue: Node3D) -> void:
	"""Add glowing effect to clues"""
	var mat = StandardMaterial3D.new()
	mat.metallic = 0.3
	mat.roughness = 0.4
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.84, 0.0, 0.3)  # Subtle gold glow
	
	if clue.has_node("MeshInstance3D"):
		var mesh_inst = clue.get_node("MeshInstance3D")
		mesh_inst.material_override = mat

func _play_intro() -> void:
	"""Play enhanced intro with atmospheric setup"""
	_investigation_phase = 1
	
	# Show crime scene with dramatic lighting
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Fade in from dark
	var hud_node = get_node("HUD")
	if hud_node:
		hud_node.modulate.a = 0.0
		tween.tween_property(hud_node, "modulate:a", 1.0, 1.5)
	
	await tween.finished
	
	# Unlock objectives
	GameState.set_objective("Search the apartment thoroughly for evidence")
	
	# Play ambient crime scene music
	AudioManager.play_music("crime_scene_investigation")
	
	# Show initial dialogue
	await get_tree().create_timer(1.0).timeout
	DialogueManager.start_dialogue("chapter1_intro", func(ending):
		_investigation_phase = 2
		print("Begin investigation phase")
	)

func _on_clue_found(clue_id: String, clue_data: Dictionary) -> void:
	"""Enhanced clue collection with achievements and feedback"""
	_clues_collected += 1
	
	# Play collection sound
	AudioManager.play_sfx("clue_collected")
	
	# Update HUD
	if _hud:
		_hud.update_clue_count(_clues_collected)
	
	# Visual feedback
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	# Log to detective notebook
	DetectiveNotebook.add_page(
		"burari_deaths",
		clue_data.get("title", "Unknown Evidence"),
		clue_data.get("description", "No description"),
		"clue"
	)
	
	# Check achievements
	Achievements.check_and_unlock()
	
	# Update objective based on clue count
	if _clues_collected == 3:
		GameState.set_objective("You've found several clues. Question the neighbor in 4A")
	elif _clues_collected == 7:
		GameState.set_objective("Examine the deduction board to connect the evidence")
	elif _clues_collected >= _max_clues:
		GameState.set_objective("You have all the evidence. Time to make your final deduction")
		_investigation_phase = 4

func _input(event: InputEvent) -> void:
	"""Enhanced control handling"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_N:
				# Open notebook with arrow key navigation
				if _hud and _hud.has_method("toggle_notebook"):
					_hud.toggle_notebook()
				get_tree().root.set_input_as_handled()
			
			KEY_TAB:
				# Highlight all interactable clues
				_highlight_all_clues()
				get_tree().root.set_input_as_handled()

func _highlight_all_clues() -> void:
	"""Highlight all nearby clues for 3 seconds"""
	var clues = get_tree().get_nodes_in_group("clues")
	for clue in clues:
		if clue is Node3D:
			# Add temporary highlight
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			
			if clue.has_node("MeshInstance3D"):
				var mesh = clue.get_node("MeshInstance3D")
				var original_color = mesh.material_override.emission
				tween.tween_property(mesh.material_override, "emission", Color.YELLOW, 0.3)
				tween.tween_property(mesh.material_override, "emission", original_color, 0.3)

func get_investigation_progress() -> float:
	"""Return progress as percentage"""
	return float(_clues_collected) / float(_max_clues) * 100.0

func is_investigation_complete() -> bool:
	"""Check if investigation is ready for conclusion"""
	return _investigation_phase == 4
