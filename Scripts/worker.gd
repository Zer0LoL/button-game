extends Area2D

@onready var spine_sprite = $WorkerVisual
@onready var timer = Timer.new()

var target_position = Vector2.ZERO
var is_moving = false
var speed = 100.0

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	_start_idle()

func _process(delta):
	if is_moving:
		position = position.move_toward(target_position, speed * delta)
		
		
		if position.distance_to(target_position) < 5:
			is_moving = false
			spine_sprite.get_animation_state().set_animation("IDLE", true, 0)
			_start_idle()

func _start_idle():
	timer.start(randf_range(2.0, 5.0)) 

func _on_timer_timeout():
	
	var new_x = randf_range(100, 1820)
	var new_y = randf_range(700, 1000) 
	
	
	if Rect2(800, 650, 320, 400).has_point(Vector2(new_x, new_y)):
		_start_idle() # Si el punto es inválido, reintentamos después de otro idle
		return

	target_position = Vector2(new_x, new_y)
	is_moving = true
	
	
	var state = spine_sprite.get_animation_state()
	state.set_animation("Run/Run", true, 0) # Piernas
	state.set_animation("Run/Body", true, 1) # Cuerpo
	
	
	spine_sprite.scale.x = -1 if target_position.x < position.x else 1
