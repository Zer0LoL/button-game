extends Node2D

@onready var linea_jugador = $LineaJugador
@onready var barra_progreso = $BackgroundLayer/UiProgressBarInterface

func _ready() -> void:
	MusicManager.play_linea_music()
	if linea_jugador:
		linea_jugador.choco_obstaculo.connect(_on_jugador_dano)

func _on_jugador_dano() -> void:
	if barra_progreso:
		barra_progreso.lose_progress(5.0)
		
