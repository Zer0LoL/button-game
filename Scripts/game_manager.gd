extends Node2D

@onready var game_world = $GameWorld
@onready var main_camera = $MainCamera
@onready var title_label = $UI_Layer/Title
@onready var the_button = $GameWorld/TheButton 

var worker_scene = preload("res://Scenes/Worker.tscn")

var workers_count = 0
var is_prologue_active = false 


var spawn_delay_time = 1.0 
var cooldown_time = 1.0    

func _ready():
	pass

func button_clicked():
	if workers_count == 0 and not is_prologue_active:
	   
		is_prologue_active = true
		title_label.hide()
		
		await get_tree().create_timer(2.0).timeout
		spawn_worker()
		
		await get_tree().create_timer(cooldown_time).timeout
		the_button.unlock_button()
		
	elif is_prologue_active and workers_count < 4:
		
		await get_tree().create_timer(spawn_delay_time).timeout
		spawn_worker()
		
		
		if workers_count == 4:
			print("¡Llegamos a 4! Bloqueando botón e iniciando fase de alineación.")
			start_alignment_phase()
		  
		else:
			await get_tree().create_timer(cooldown_time).timeout
			the_button.unlock_button()

func start_alignment_phase():
	
	print("El jugador ahora debe arrastrar a los trabajadores en fila.")

func spawn_worker():
	var new_worker = worker_scene.instantiate()
	var spawn_pos = Vector2.ZERO
	
	if workers_count == 0:
		spawn_pos = Vector2(960, -200) 
	else:
		
		var valid_pos = false
		while not valid_pos:
			var random_x = randf_range(200, 1720)
			spawn_pos = Vector2(random_x, -200)
			
			
			if abs(spawn_pos.x - 960) > 150:
				valid_pos = true
				
	new_worker.position = spawn_pos
	game_world.add_child(new_worker)
	workers_count += 1
	
   
	var tween = create_tween()
	var target_y = randf_range(750, 950) # Altura del suelo aleatoria para dar profundidad
	tween.tween_property(new_worker, "position:y", target_y, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_on_worker_landed.bind(new_worker))
	tween.tween_method(func(val): new_worker.get_node("WorkerVisual").material.set_shader_parameter("stretch_amount", val), 0.0, 30.0, 0.1)
	tween.parallel().tween_method(func(val): new_worker.get_node("WorkerVisual").material.set_shader_parameter("stretch_amount", val), 30.0, 0.0, 0.2).set_delay(0.2)

func _on_worker_landed(worker):
	if workers_count == 1:
		main_camera.apply_shake(20.0) 
	else:
		main_camera.apply_shake(2.0)  

	var worker_spine = worker.get_node("WorkerVisual")
	worker_spine.get_animation_state().set_animation("IDLE", true, 0)
	worker.enable_interaction()
