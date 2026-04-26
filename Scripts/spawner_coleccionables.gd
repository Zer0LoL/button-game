extends Node2D

@export var escena_coleccionable: PackedScene
@export var barra_progreso: Control
@export var linea_jugador: Area2D

@export var progreso_por_item: float = 5.0 

var limite_superior: float = 100.0 
var limite_inferior: float = 650.0 

@export var escena_obstaculo: PackedScene
@onready var timer_obstaculos: Timer = Timer.new() 
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start(randf_range(0.4, 1.0)) 
	
	add_child(timer_obstaculos)
	timer_obstaculos.timeout.connect(_spawn_obstaculo)
	timer_obstaculos.start(randf_range(0.8, 1.6))

func _on_timer_timeout() -> void:
	if not escena_coleccionable or not linea_jugador: return
	
	var nuevo_item = escena_coleccionable.instantiate()
	var spawn_x = linea_jugador.global_position.x + 1800.0 
	
	var spawn_y = randf_range(limite_superior, limite_inferior) 
	
	nuevo_item.global_position = Vector2(spawn_x, spawn_y)
	nuevo_item.atrapado.connect(_on_item_atrapado)
	
	add_child(nuevo_item)
	
	# Nuevo tiempo rápido
	timer.start(randf_range(0.4, 1.0))

func _spawn_obstaculo() -> void:
	if not escena_obstaculo or not linea_jugador: 
		print("¡FALTA ASIGNAR LA ESCENA DEL OBSTÁCULO EN EL INSPECTOR!")
		return
	
	var nuevo_obs = escena_obstaculo.instantiate()
	var spawn_x = linea_jugador.global_position.x + 1800.0 
	
	var viene_de_arriba = randf() > 0.5
	var spawn_y = 0.0
	
	if viene_de_arriba:
		spawn_y = 0.0 
	else:
		spawn_y = 750.0 
		
	nuevo_obs.global_position = Vector2(spawn_x, spawn_y)
	
	if not viene_de_arriba:
		nuevo_obs.scale.y = -1
		
	add_child(nuevo_obs)
	
	timer_obstaculos.start(randf_range(0.6, 1.4))
	
func _on_item_atrapado() -> void:
	SFXManager.play_coin_sound()
	if barra_progreso:
		barra_progreso.add_progress(progreso_por_item)
