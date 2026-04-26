extends Area2D

signal choco_obstaculo

@export var speed_x: float = 875.0 
@export var speed_y: float = 750.0 

@export var limite_superior: float = 0.0
@export var limite_inferior: float = 700.0

var is_pressing: bool = false
var is_invulnerable: bool = false

@onready var rastro_linea: Line2D = $Line2D
@onready var camara: Camera2D = $Camera2D 
@onready var flecha_visual: Polygon2D = $FlechaVisual 
func _ready() -> void:
	rastro_linea.top_level = true 
	rastro_linea.clear_points()
	camara.top_level = true 
	
	global_position = Vector2(100.0, 540.0)
	camara.global_position = Vector2(global_position.x + 600.0, 540.0)
	
	area_entered.connect(_on_area_entered)
	flecha_visual.polygon = PackedVector2Array([Vector2(-20, -30), Vector2(20, 0), Vector2(-20, 30)])
	flecha_visual.color = Color("#AC3E27")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_pressing = event.pressed

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstaculos") and not is_invulnerable:
		recibir_dano()

func recibir_dano() -> void:
	is_invulnerable = true
	choco_obstaculo.emit()
	
	var blink_tween = create_tween().set_loops(5) 
	blink_tween.tween_property(flecha_visual, "modulate:a", 0.2, 0.1)
	blink_tween.tween_property(flecha_visual, "modulate:a", 1.0, 0.1)
	blink_tween.finished.connect(func(): is_invulnerable = false)

func _process(delta: float) -> void:
	position.x += speed_x * delta
	
	var direccion_y = 0.0
	if is_pressing:
		direccion_y = speed_y
		position.y += speed_y * delta
	else:
		direccion_y = -speed_y
		position.y -= speed_y * delta
		
	position.y = clamp(position.y, limite_superior, limite_inferior)
	
	var velocidad_vector = Vector2(speed_x, direccion_y)
	flecha_visual.rotation = lerp(flecha_visual.rotation, velocidad_vector.angle(), 10 * delta)
		
	rastro_linea.add_point(global_position)
	if rastro_linea.get_point_count() > 150:
		rastro_linea.remove_point(0)
		
	camara.global_position.x = global_position.x + 600.0
