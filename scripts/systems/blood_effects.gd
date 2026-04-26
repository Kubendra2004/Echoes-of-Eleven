## Blood & Gore Effects System
## Particles, decals, and disturbing details for maximum impact
extends Node3D

class_name BloodEffectSystem

@export var blood_particle_scene: PackedScene
@export var gore_decal_material: Material
@export var decomposition_stage: int = 0  # 0-3 (fresh to advanced)

var _blood_pools: Array[Node3D] = []
var _gore_decals: Array[Node3D] = []

## Blood splatter at a location
func create_blood_splatter(position: Vector3, intensity: float = 1.0, direction: Vector3 = Vector3.UP) -> void:
	# Create particle effect
	if blood_particle_scene:
		var particles = blood_particle_scene.instantiate()
		particles.global_position = position
		particles.emitting = true
		add_child(particles)
	
	# Add blood decal
	var decal = MeshInstance3D.new()
	decal.global_position = position + direction * 0.01
	var blood_mat = gore_decal_material.duplicate()
	blood_mat.albedo_color = Color(0.8, 0.1, 0.1, 0.8 * intensity)
	decal.set_surface_override_material(0, blood_mat)
	add_child(decal)
	_gore_decals.append(decal)

## Pool of blood under a hanging body
func create_blood_pool(position: Vector3) -> void:
	var pool = MeshInstance3D.new()
	pool.mesh = PlaneMesh.new()
	pool.scale = Vector3(0.5, 1, 0.8)
	pool.global_position = position + Vector3(0, 0.01, 0)
	
	var blood_mat = StandardMaterial3D.new()
	blood_mat.albedo_color = Color(0.6, 0.05, 0.05, 0.9)
	blood_mat.roughness = 0.8
	pool.set_surface_override_material(0, blood_mat)
	
	add_child(pool)
	_blood_pools.append(pool)

## Disturbing detail: flies buzzing, body fluids
func add_decomposition_details(body_position: Vector3) -> void:
	# Add fly particle system
	var environment = get_parent()
	if environment:
		# Emit disgusting sounds
		var sound_player = AudioStreamPlayer3D.new()
		sound_player.global_position = body_position
		sound_player.bus = "SFX"
		add_child(sound_player)
		
		# Flies buzzing (add audio later)
		# Fluid dripping sound

## Set body decomposition visual stage
func set_decomposition_stage(stage: int) -> void:
	decomposition_stage = clamp(stage, 0, 3)
	var color_tint = Color.WHITE
	match decomposition_stage:
		0:  # Fresh
			color_tint = Color.WHITE
		1:  # 4-6 hours
			color_tint = Color(0.95, 0.93, 0.92)
		2:  # 12+ hours
			color_tint = Color(0.85, 0.80, 0.78)
		3:  # Advanced
			color_tint = Color(0.7, 0.6, 0.55)

## Forensic detail: body waste visible in clothing
func highlight_bodily_fluids(mesh: MeshInstance3D) -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.3, 0.2, 0.9)
	mesh.set_surface_override_material(0, mat)
