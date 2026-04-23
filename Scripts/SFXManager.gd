extends Node

var type_sounds: Array[AudioStream] = [
	preload("res://Assets/Audio/TypingSound1.mp3"),
	preload("res://Assets/Audio/TypingSound2.mp3"),
	preload("res://Assets/Audio/TypingSound3.mp3")
]

# Recibe un audio y un nivel opcional de variación de tono
func play_sound(stream: AudioStream, pitch_variance: float = 0.0) -> void:
	if stream == null:
		return
		
	var player := AudioStreamPlayer.new()
	player.stream = stream
	
	if pitch_variance > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
		
	add_child(player)
	player.play()
	
	# Eliminamos el nodo automáticamente cuando el sonido termina
	player.finished.connect(player.queue_free)

# Específico para minijuego typing
func play_random_type_sound() -> void:
	# Elegimos uno de los 3 sonidos al azar
	var random_sound: AudioStream = type_sounds.pick_random()
	
	# pequeña variación de pitch
	play_sound(random_sound, 0.1)
