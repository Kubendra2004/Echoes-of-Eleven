extends OmniLight3D

var _timer = 0.0

func _process(delta: float) -> void:
	_timer += delta * 4.0 # Speed of flashing
	var cycle = fmod(_timer, 2.0)
	
	if cycle < 1.0:
		light_color = Color(1.0, 0.1, 0.1) # Red
		light_energy = 8.0 * max(0.0, sin(cycle * PI * 4.0)) # Rapid pulsing
	else:
		light_color = Color(0.1, 0.2, 1.0) # Blue
		light_energy = 8.0 * max(0.0, sin((cycle - 1.0) * PI * 4.0))
