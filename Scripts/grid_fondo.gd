extends Node2D

@export var grid_size: int = 100
@export var grid_color: Color = Color(0.75, 0.65, 0.5, 0.4) 

@onready var camara = $"../../LineaJugador/Camera2D"

func _process(_delta):
	queue_redraw()

func _draw():
	if not camara: return
	
	var offset_x = -fmod(camara.global_position.x, grid_size)

	for x in range(offset_x, 1920 + grid_size, grid_size):
		draw_line(Vector2(x, 0), Vector2(x, 756), grid_color, 2.0)
		
	for y in range(0, 756 + grid_size, grid_size):
		draw_line(Vector2(0, y), Vector2(1920, y), grid_color, 2.0)
