extends Node2D

enum State { PROLOGUE, ALIGNMENT, TRANSITION, MINIGAME }
var current_state = State.PROLOGUE

@onready var game_world = $GameWorld
@onready var main_camera = $MainCamera
@onready var animated_title = $UI_Layer/AnimatedTitle
@onready var the_button = $GameWorld/TheButton 
@onready var hud = $UI_Layer/UiInterface

var worker_scene = preload("res://Scenes/Worker.tscn")
var work_zone_scene = preload("res://Scenes/WorkZone.tscn")

var workers_count = 0
var spawn_delay_time = 1.0 
var cooldown_time = 1.0    

func _ready():
	hud.hide() 
	setup_title_animations()
	
func setup_title_animations():
	var letter_k = animated_title.get_child(0)
	var letter_r = animated_title.get_child(1)
	var gear_o = animated_title.get_child(2)
	var letter_w = animated_title.get_child(3)
	var letter_inc = animated_title.get_child(4)
	
	_force_skin(letter_k, "K")
	_force_skin(letter_r, "R")
	_force_skin(letter_w, "W")
	_force_skin(letter_inc, "inc")
	
	var normal_letters = [letter_k, letter_r, letter_w, letter_inc]
	for letter in normal_letters:
		var state = letter.get_animation_state()
		state.set_animation("Appear", false, 0)
		state.add_animation("IDLE", 0.0, true, 0) 
		
	var gear_state = gear_o.get_animation_state()
	gear_state.set_animation("IDLE Body", true, 0) 
	gear_state.set_animation("IDLE Eye", true, 1)  

func _force_skin(spine_node, skin_name):
	var skeleton = spine_node.get_skeleton()
	var skin_object = skeleton.get_data().find_skin(skin_name)
	if skin_object:
		skeleton.set_skin(skin_object)

func button_clicked():
	if current_state != State.PROLOGUE: return
	
	if workers_count == 0:
		animated_title.hide()
		await get_tree().create_timer(2.0).timeout
		spawn_worker()
		await get_tree().create_timer(cooldown_time).timeout
		the_button.unlock_button()
		
	elif workers_count < 4:
		await get_tree().create_timer(spawn_delay_time).timeout
		spawn_worker()
		
		if workers_count == 4:
			print("¡Llegamos a 4! Iniciando fase de alineación.")
			start_alignment_phase()
		else:
			await get_tree().create_timer(cooldown_time).timeout
			the_button.unlock_button()

func start_alignment_phase():
	current_state = State.ALIGNMENT
	print("El jugador debe arrastrar a los trabajadores a las zonas.")
	

	for i in range(4):
		var new_zone = work_zone_scene.instantiate()
		# Ajustar la altura (950) y espaciado (384) según se vea mejor
		new_zone.position = Vector2(384 + (i * 384), 950) 
		game_world.add_child(new_zone)
		new_zone.show_zone()

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
	new_worker.add_to_group("workers")
	game_world.add_child(new_worker)
	workers_count += 1
	
	var tween = create_tween()
	var target_y = randf_range(750, 950) 
	tween.tween_property(new_worker, "position:y", target_y, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_on_worker_landed.bind(new_worker))
	
	if new_worker.get_node("WorkerVisual").material:
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


func check_all_zones():
	var total_occupied = 0
	for zone in get_tree().get_nodes_in_group("work_zones"):
		if zone.is_occupied:
			total_occupied += 1
			
	if total_occupied == workers_count:
		start_cinematic_transition()

func start_cinematic_transition():
	current_state = State.TRANSITION
	var cam_tween = create_tween().set_parallel(true)
	cam_tween.tween_property(main_camera, "zoom", Vector2(1.5, 1.5), 1.2).set_trans(Tween.TRANS_SINE)
	cam_tween.tween_property(main_camera, "offset", Vector2(0, 500), 1.2).set_trans(Tween.TRANS_SINE) 
	
	await cam_tween.finished
	await get_tree().create_timer(0.5).timeout
	
	play_ok_and_exit()

func play_ok_and_exit():

	for worker in get_tree().get_nodes_in_group("workers"):
		var ok_anim = SpineSprite.new() 
		ok_anim.skeleton_data_res = load("res://Assets/Animations/Raw/OK_Data.tres")
		worker.add_child(ok_anim)
		ok_anim.position = Vector2(0, -200) 
		ok_anim.get_animation_state().set_animation("IDLE", false, 0)
	
	await get_tree().create_timer(1.0).timeout
	
	var exit_dir = 1 if randf() > 0.5 else -1
	for worker in get_tree().get_nodes_in_group("workers"):
		var speed = randf_range(600, 900)
		var tween = create_tween()
		
		worker.get_node("WorkerVisual").get_animation_state().set_animation("Run/Run", true, 0)
		worker.get_node("WorkerVisual").scale.x = exit_dir 
		
		var target_x = 2500 if exit_dir == 1 else -500
		tween.tween_property(worker, "global_position:x", target_x, 1.5).set_trans(Tween.TRANS_QUAD)
	
	await get_tree().create_timer(1.0).timeout
	play_tv_transition()

func play_tv_transition():
	var tv = $UI_Layer/TV_Effect
	tv.stream = load("res://Assets/Animations/Raw/TV Effect.ogv")
	tv.show()
	tv.play()
	
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://Scenes/MinijuegoTyping.tscn")
	
func _process(delta: float) -> void:
	if animated_title.visible:
		var gear_o = animated_title.get_child(2)
		gear_o.rotation += (TAU / 30.0) * delta
