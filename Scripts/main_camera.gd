extends Camera2D

var time: float = 0.0
var breathe_speed: float = 1.2
var breathe_amplitude: float = 8.0 

var mouse_follow_strength: float = 0.05 

var shake_strength = 0.0
var shake_decay = 5.0 

var smoothed_base_offset = Vector2.ZERO

func _process(delta):
	time += delta * breathe_speed
	var breathe_offset = Vector2(
		cos(time * 0.7) * (breathe_amplitude * 0.5),
		sin(time) * breathe_amplitude
	)

	var viewport_center = get_viewport().get_visible_rect().size / 2
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_direction = (mouse_pos - viewport_center) * mouse_follow_strength
	
	var target_offset = breathe_offset + mouse_direction
	
	smoothed_base_offset = lerp(smoothed_base_offset, target_offset, 5 * delta)
	
	var current_shake = Vector2.ZERO
	if shake_strength > 0:
		current_shake = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	
	offset = smoothed_base_offset + current_shake

func apply_shake(strength: float):
	shake_strength = strength
