extends AudioStreamPlayer

# Pre-cargamos todas las pistas de música en la memoria
const MAIN_MUSIC = preload("res://Assets/Audio/Music/MainMusicLoop.ogg")
const BASKET_MUSIC = preload("res://Assets/Audio/Music/minijuegoBasket.ogg")
const LINEA_MUSIC = preload("res://Assets/Audio/Music/minijuegoLinea.ogg")
const TYPING_MUSIC = preload("res://Assets/Audio/Music/minijuegoTyping.ogg")
const ENDING_MUSIC = preload("res://Assets/Audio/Music/krow-end.ogg")

func _ready() -> void:
	# Nos aseguramos de que el volumen sea adecuado
	volume_db = -4.0 

func play_track(new_stream: AudioStream) -> void:
	if stream == new_stream and playing:
		return
		
	# Cambiamos la pista y le damos play
	stream = new_stream
	play()

# Funciones rápidas para llamar desde tus escenas 

func play_main_music() -> void:
	play_track(MAIN_MUSIC)

func play_basket_music() -> void:
	play_track(BASKET_MUSIC)

func play_linea_music() -> void:
	play_track(LINEA_MUSIC)

func play_typing_music() -> void:
	play_track(TYPING_MUSIC)

func play_ending_music() -> void:
	play_track(ENDING_MUSIC)
