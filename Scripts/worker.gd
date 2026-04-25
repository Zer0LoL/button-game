extends Area2D

# Interruptor para el minijuego
@export var is_basket_mode: bool = false 
@onready var basket_area = $Basket/Area2D
@onready var basket = $Basket
@onready var spine_sprite = $WorkerVisual
@onready var timer = Timer.new()
@onready var cigar_smoke = $WorkerVisual/SpineBoneNode/CigarSmoke
@onready var name_tag = $NameTag
@onready var name_label = $NameTag/NameLabel

var worker_name: String = "???"
var is_dragging = false
var drag_speed = 15.0 
var target_position = Vector2.ZERO
var is_moving = false
var speed = 100.0
var can_be_dragged = false 

# Variable auxiliar para no reiniciar la animación de Spine cada frame
var current_anim: String = "" 

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	randomize_skin()
	load_random_name()
	
	# Si estamos en el minijuego, no conectamos las señales del mouse 
	if is_basket_mode:
		basket.show()
		if basket_area:
			basket_area.area_entered.connect(_on_basket_area_entered)
		_play_spine_anim("IDLE")
		return
		
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func load_random_name():
	var file = FileAccess.open("res://Assets/Meta/names.json", FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if json and json.has("names"):
			worker_name = json["names"].pick_random()
			name_label.text = worker_name

func _on_mouse_entered():
	name_tag.show()

func _on_mouse_exited():
	name_tag.hide()

func _input_event(viewport, event, shape_idx):
	if is_basket_mode: return # Bloqueamos el clic en el minijuego
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and can_be_dragged:
		if event.pressed:
			is_dragging = true
			is_moving = false
			timer.stop()
			_play_spine_anim("Drag")

func _input(event):
	if is_basket_mode: return # Bloqueamos el soltar clic en el minijuego
	
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		
		var areas = get_overlapping_areas()
		var snapped = false
		
		for area in areas:
			if area.is_in_group("work_zones") and not area.is_occupied:
				global_position = area.global_position 
				area.is_occupied = true
				snapped = true
				can_be_dragged = false 
				
				area.toggle_pointer(false)
				
				get_tree().current_scene.check_all_zones()
				break
		
		if not snapped:
			target_position = global_position 
		
		_play_spine_anim("IDLE")
		_start_idle()

func _process(delta):
	# Lógica del minijuego de la canasta
	if is_basket_mode:
		var mouse_x: float = get_global_mouse_position().x
		
		# Agregamos .0 a los límites para mantener el tipo float
		mouse_x = clamp(mouse_x, 100.0, 1820.0) 
		
		# Ahora lerp recibirá floats en todos sus argumentos sin quejarse
		global_position.x = lerp(global_position.x, mouse_x, drag_speed * delta)
		
		var distance: float = mouse_x - global_position.x
		
		if abs(distance) > 5.0:
			_play_spine_anim("Run/Run")
			spine_sprite.scale.x = -1 if distance < 0 else 1
		else:
			_play_spine_anim("IDLE")
			
		return # Salimos de _process para ignorar la lógica original

	# Lógica original
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		global_position = global_position.lerp(mouse_pos, drag_speed * delta)
		
		var velocity = (mouse_pos - global_position).x
		# Cambiamos 5 por 5.0
		spine_sprite.rotation = lerp(spine_sprite.rotation, deg_to_rad(velocity * 0.2), 5.0 * delta)
		
	elif is_moving:
		# Cambiamos 5 por 5.0
		spine_sprite.rotation = lerp(spine_sprite.rotation, 0.0, 5.0 * delta)
		position = position.move_toward(target_position, speed * delta)
		
		# Cambiamos 5 por 5.0
		if position.distance_to(target_position) < 5.0:
			is_moving = false
			_play_spine_anim("IDLE")
			_start_idle()
	else:
		# Cambiamos 5 por 5.0
		spine_sprite.rotation = lerp(spine_sprite.rotation, 0.0, 5.0 * delta)
	# Lógica del minijuego de la canasta
	if is_basket_mode:
		var mouse_x = get_global_mouse_position().x
		
		# Limita movimiento del mouse
		mouse_x = clamp(mouse_x, 100, 1820) 
		
		# Movimiento suave hacia el mouse usando interpolación
		global_position.x = lerp(global_position.x, mouse_x, drag_speed * delta)
		
		var distance = mouse_x - global_position.x
		
		# Si se está moviendo, corre. Si está quieto, se queda en IDLE.
		if abs(distance) > 5.0:
			_play_spine_anim("Run/Run")
			# Voltear el sprite según la dirección
			spine_sprite.scale.x = -1 if distance < 0 else 1
		else:
			_play_spine_anim("IDLE")
			
		return # Salimos de _process para ignorar la lógica original

	# Lógica original
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
			_play_spine_anim("IDLE")
			_start_idle()
	else:
		spine_sprite.rotation = lerp(spine_sprite.rotation, 0.0, 5 * delta)

# Función auxiliar para no reiniciar la animación en bucle cada frame
func _play_spine_anim(anim_name: String):
	if current_anim != anim_name:
		spine_sprite.get_animation_state().set_animation(anim_name, true, 0)
		current_anim = anim_name

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
	
	_play_spine_anim("Run/Run")
	spine_sprite.get_animation_state().set_animation("Run/Body", true, 1) 
	
	spine_sprite.scale.x = -1 if target_position.x < position.x else 1

func _on_basket_area_entered(area: Area2D) -> void:
	# Verificamos que lo que entró fue un billete (usando el grupo que creamos antes)
	if area.is_in_group("billetes"):
		_bounce_basket()

func _bounce_basket() -> void:
	# Creamos la animación de rebote
	var tween = create_tween()
	
	# Se aplasta un poco al recibir el impacto
	tween.tween_property(basket, "scale", Vector2(0.51, 0.11), 0.05)
	# Rebota hacia arriba
	tween.tween_property(basket, "scale", Vector2(0.21, 0.41), 0.1)
	# Vuelve a su tamaño original
	tween.tween_property(basket, "scale", Vector2(0.31, 0.31), 0.1)
