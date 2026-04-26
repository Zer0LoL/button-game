extends Node

var type_sounds: Array[AudioStream] = [
	preload("res://Assets/Audio/TypingSound1.mp3"),
	preload("res://Assets/Audio/TypingSound2.mp3"),
	preload("res://Assets/Audio/TypingSound3.mp3")
]

var grab_sounds: Array[AudioStream] = [
	preload("res://Assets/Audio/sfx uhg 1.wav"),
	preload("res://Assets/Audio/sfx uhg 2.wav")
]

var drop_sound: AudioStream = preload("res://Assets/Audio/sfx-soltar.ogg")
var button_sound: AudioStream = preload("res://Assets/Audio/sfx-boton-presionandose.ogg")
var coin_sound: AudioStream = preload("res://Assets/Audio/sfx-coin.ogg")
var walk_sound: AudioStream = preload("res://Assets/Audio/sfx walk.wav")
var bam_sound: AudioStream = preload("res://Assets/Audio/bam-suelo.ogg")
var like_sound: AudioStream = preload("res://Assets/Audio/like sound.ogg")

func play_bam_sound() -> void:
	play_sound(bam_sound)

func play_like_sound() -> void:
	play_sound(like_sound)

# --- MODIFICADO: Ahora recibe el volumen en decibelios (0.0 por defecto) ---
func play_sound(stream: AudioStream, pitch_variance: float = 0.0, volume: float = 0.0) -> void:
	if stream == null:
		return
		
	var player := AudioStreamPlayer.new()
	player.stream = stream
	
	if pitch_variance > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
		
	# Aplicamos el ajuste de volumen
	player.volume_db = volume
		
	add_child(player)
	player.play()
	
	# Eliminamos el nodo automáticamente cuando el sonido termina
	player.finished.connect(player.queue_free)

#grab sound
func play_random_grab_sound() -> void:
	var random_sound: AudioStream = grab_sounds.pick_random()
	play_sound(random_sound, 0.1)

func play_drop_sound() -> void:
	play_sound(drop_sound, 0.1)

# Llamamos a la función con 0.0 de pitch y -12.0 de volumen
func play_button_sound() -> void:
	play_sound(button_sound, 0.0, -8.0)

func play_coin_sound() -> void:
	# Le damos una variación de pitch chiquita para que si agarras muchos billetes seguidos, no suene robótico
	play_sound(coin_sound, 0.05) 

func play_walk_sound() -> void:
	play_sound(walk_sound, 0.1)

# Específico para minijuego typing
func play_random_type_sound() -> void:
	# Elegimos uno de los 3 sonidos al azar
	var random_sound: AudioStream = type_sounds.pick_random()
	
	# pequeña variación de pitch
	play_sound(random_sound, 0.1)
