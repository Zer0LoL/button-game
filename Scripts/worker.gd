extends Area2D

@onready var spine_sprite = $WorkerVisual
@onready var timer = Timer.new()
@onready var cigar_smoke = $WorkerVisual/SpineBoneNode/CigarSmoke

var is_dragging = false
var drag_speed = 15.0 
var target_position = Vector2.ZERO
var is_moving = false
var speed = 100.0
var can_be_dragged = false 

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	randomize_skin()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and can_be_dragged:
		if event.pressed: # Clic presionado
			is_dragging = true
			is_moving = false
			timer.stop()
			
			spine_sprite.get_animation_state().set_animation("Drag", true, 0)


func _input(event):
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		
		
		target_position = global_position 
		
		spine_sprite.get_animation_state().set_animation("IDLE", true, 0)
		_start_idle()
func _process(delta):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		global_position = global_position.lerp(mouse_pos, drag_speed * delta)
		
		
		var velocity = (mouse_pos - global_position).x
		spine_sprite.rotation = lerp(spine_sprite.rotation, deg_to_rad(velocity * 0.2), 5 * delta)
		
	elif is_moving:
		
		spine_sprite.rotation = lerp(spine_sprite.rotation, 0.0, 5 * delta)
		
		position = position.move_toward(target_position, speed * delta)
		if position.distance_to(target_position) < 5:
			is_moving = false
			spine_sprite.get_animation_state().set_animation("IDLE", true, 0)
			_start_idle()
	else:
		spine_sprite.rotation = lerp(spine_sprite.rotation, 0.0, 5 * delta)

func randomize_skin():
	var available_skins = ["Bald", "Worker", "Boss"] 
	var chosen_skin = available_skins.pick_random()
	
	var skeleton = spine_sprite.get_skeleton()
	var skin_object = skeleton.get_data().find_skin(chosen_skin)
	skeleton.set_skin(skin_object)
	
	if chosen_skin == "Boss":
		cigar_smoke.emitting = true
	else:
		cigar_smoke.emitting = false

func enable_interaction():
	can_be_dragged = true
	_start_idle()

func _start_idle():
	timer.start(randf_range(2.0, 5.0))

func _on_timer_timeout():
	var new_x = randf_range(100, 1820)
	var new_y = randf_range(700, 1000) 
	
	
	if Rect2(800, 650, 320, 400).has_point(Vector2(new_x, new_y)):
		_start_idle() 
		return

	target_position = Vector2(new_x, new_y)
	is_moving = true
	
	var state = spine_sprite.get_animation_state()
	state.set_animation("Run/Run", true, 0) 
	state.set_animation("Run/Body", true, 1) 
	
	spine_sprite.scale.x = -1 if target_position.x < position.x else 1
