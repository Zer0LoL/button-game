extends Area2D

@export var speed_x: float = 350.0 
@export var speed_y: float = 300.0 
@export var limite_superior: float = 0.0
@export var limite_inferior: float = 780.0

var is_pressing: bool = false

@onready var rastro_linea: Line2D = $Line2D
# Obtenemos la referencia a la cámara
@onready var camara: Camera2D = $Camera2D 

func _ready() -> void:
	rastro_linea.top_level = true 
	rastro_linea.clear_points()
	
	camara.top_level = true 
	
	# Colocamos al jugador empezando a la izquierda (X=100) y a media altura (Y=540)
	global_position = Vector2(100.0, 540.0)
	
	# Fijamos la cámara en el centro vertical de la pantalla (540) para siempre
	camara.global_position = Vector2(global_position.x + 600.0, 540.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_pressing = event.pressed

func _process(delta: float) -> void:
	# Movimiento
	position.x += speed_x * delta
	
	if is_pressing:
		position.y += speed_y * delta # Va hacia abajo
	else:
		position.y -= speed_y * delta # Va hacia arriba
		
	# Limites
	position.y = clamp(position.y, limite_superior, limite_inferior)
		
	# Rastro
	rastro_linea.add_point(global_position)
	if rastro_linea.get_point_count() > 150:
		rastro_linea.remove_point(0)
		
	# La cámara sigue al jugador en X, pero su Y se queda quieto en 540
	camara.global_position.x = global_position.x + 600.0
