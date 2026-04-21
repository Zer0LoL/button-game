extends Camera2D

var shake_strength = 0.0
var shake_decay = 5.0 

func _process(delta):
	if shake_strength > 0:
		offset = Vector2(randf_range(-1, 1) * shake_strength, randf_range(-1, 1) * shake_strength)
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func apply_shake(strength: float):
	shake_strength = strength
