extends Node2D

@export var billete_scene: PackedScene 

@export var progress_bar: Control 

@export var min_spawn_time: float = 0.1
@export var max_spawn_time: float = 0.8
@export var limite_izquierdo: float = 300.0 
@export var limite_derecho: float = 1600.0 

@export var avance_por_acierto: float = 2 # Cuánto sube la barra
@export var castigo_por_fallo: float = 5 # Cuánto baja la barra

@onready var timer: Timer = $Timer
var billetes_atrapados: int = 0 # Contador

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	start_next_spawn()

func start_next_spawn() -> void:
	var next_time: float = randf_range(min_spawn_time, max_spawn_time)
	timer.start(next_time)

func _on_timer_timeout() -> void:
	spawn_billete()
	start_next_spawn()

func spawn_billete() -> void:
	if billete_scene == null: return
		
	var nuevo_billete = billete_scene.instantiate()
	var random_x: float = randf_range(limite_izquierdo, limite_derecho)
	nuevo_billete.position = Vector2(random_x, 0)
	nuevo_billete.rotation_degrees = randf_range(-45.0, 45.0) 
	
	# Conectamos las señales del billete al spawner
	nuevo_billete.caught.connect(_on_billete_atrapado)
	nuevo_billete.missed.connect(_on_billete_fallado)
	
	add_child(nuevo_billete)

func _on_billete_atrapado() -> void:
	progress_bar.add_progress(avance_por_acierto)

func _on_billete_fallado() -> void:
	if progress_bar:
		progress_bar.lose_progress(castigo_por_fallo)
