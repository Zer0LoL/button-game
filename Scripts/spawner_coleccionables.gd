extends Node2D

@export var escena_coleccionable: PackedScene
@export var barra_progreso: Control
@export var linea_jugador: Area2D

# Cuánto progreso da cada coleccionable
@export var progreso_por_item: float = 5.0 

# Límites donde pueden aparecer
@export var limite_superior: float = 50.0
@export var limite_inferior: float = 700.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if not escena_coleccionable or not linea_jugador: return
	
	var nuevo_item = escena_coleccionable.instantiate()
	
	# Posición X: Que aparezca bastante más adelante de donde está el jugador actualmente
	var spawn_x = linea_jugador.global_position.x + 1800.0 
	
	# Posición Y: Aleatoria entre el techo y el piso
	var spawn_y = randf_range(limite_superior, limite_inferior)
	
	nuevo_item.global_position = Vector2(spawn_x, spawn_y)
	
	# Escuchamos la señal del coleccionable
	nuevo_item.atrapado.connect(_on_item_atrapado)
	
	add_child(nuevo_item)
	
	# Hacemos que el tiempo para el próximo coleccionable varíe un poco
	timer.start(randf_range(1.0, 2.5))

func _on_item_atrapado() -> void:
	# SFXManager.play_random_type_sound() ola pon un efecto de sonido
	
	# Aumentamos la barra de progreso
	if barra_progreso:
		barra_progreso.add_progress(progreso_por_item)
