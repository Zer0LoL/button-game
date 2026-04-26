extends Node2D

@export var worker_scene: PackedScene = preload("res://Scenes/Worker.tscn")
@onready var false_button = $FalseButton 

var main_camera: Camera2D
var tv_effect: VideoStreamPlayer
var fade_negro: ColorRect
var fondo_crema: ColorRect

# --- NUEVOS REPRODUCTORES DE AUDIO ---
var music_player: AudioStreamPlayer
var sfx_walk: AudioStreamPlayer

func _ready() -> void:
	# ---------------------------------------------------------
	# CONFIGURACIÓN DE AUDIO
	# ---------------------------------------------------------
	music_player = AudioStreamPlayer.new()
	music_player.stream = load("res://Assets/Audio/Music/krow-end.ogg")
	music_player.bus = "Master" # O el bus que prefieras
	add_child(music_player)
	
	sfx_walk = AudioStreamPlayer.new()
	sfx_walk.stream = load("res://Assets/Audio/sfx walk.wav")
	add_child(sfx_walk)
	
	# ---------------------------------------------------------
	# PREPARACIÓN DEL SET
	# ---------------------------------------------------------
	fondo_crema = ColorRect.new()
	fondo_crema.color = Color("e3d3a9")
	fondo_crema.size = Vector2(20000, 20000)
	fondo_crema.position = Vector2(-10000, -10000)
	fondo_crema.z_index = -100
	add_child(fondo_crema)
	
	main_camera = Camera2D.new()
	add_child(main_camera)
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	
	fade_negro = ColorRect.new()
	fade_negro.size = Vector2(1920, 1080)
	fade_negro.color = Color(0, 0, 0, 1.0) 
	ui_layer.add_child(fade_negro)
	
	tv_effect = VideoStreamPlayer.new()
	tv_effect.expand = true 
	tv_effect.custom_minimum_size = Vector2(1920, 1080)
	tv_effect.size = Vector2(1920, 1080)
	tv_effect.hide()
	ui_layer.add_child(tv_effect)
	
	tv_effect.finished.connect(func():
		if tv_effect.visible:
			tv_effect.play()
	)

	if false_button:
		false_button.hide()
		if false_button.get_skeleton():
			false_button.get_animation_state().set_animation("IDLE Up", true, 0)
			
	play_choreography()

func play_choreography() -> void:
	# =========================================================
	# ACTO 1: TV (5s) + INICIO DE MÚSICA
	# =========================================================
	music_player.play() # Empieza la música en loop
	
	tv_effect.stream = load("res://Assets/Animations/Raw/TV Effect.ogv")
	tv_effect.show()
	tv_effect.play()
	
	await get_tree().create_timer(5.0).timeout
	
	# =========================================================
	# ACTO 2: Pantalla Negra (2s)
	# =========================================================
	tv_effect.hide()
	tv_effect.stop()
	await get_tree().create_timer(2.0).timeout
	
	# =========================================================
	# ACTO 3: Deslizamiento revelando al protagonista
	# =========================================================
	var centro_x = 960
	var centro_y = 540
	main_camera.global_position = Vector2(centro_x, centro_y)
	
	var prota = worker_scene.instantiate()
	prota.global_position = Vector2(centro_x, centro_y)
	add_child(prota)
	prota.set_process(false)
	prota.set_physics_process(false)
	prota.can_be_dragged = false
	
	var spine = prota.get_node("WorkerVisual")
	spine.get_animation_state().set_animation("IDLE", true, 0)
	spine.scale = Vector2(4.0, 4.0)
	spine.modulate = Color(1, 1, 1, 0.0) 
	
	var tween_intro = create_tween().set_parallel(true)
	tween_intro.tween_property(spine, "modulate:a", 0.3, 2.0)
	tween_intro.tween_property(fade_negro, "position:x", 1920.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_intro.finished
	
	# =========================================================
	# ACTO 4: Enfoque (2s)
	# =========================================================
	var tween_focus = create_tween().set_parallel(true)
	tween_focus.tween_property(spine, "scale", Vector2(1.5, 1.5), 1.5).set_trans(Tween.TRANS_SINE)
	tween_focus.tween_property(spine, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	await tween_focus.finished
	await get_tree().create_timer(2.0).timeout
	
	# =========================================================
	# ACTO 5: El trabajador se va + SFX caminar
	# =========================================================
	spine.scale.x = -1.5 
	spine.get_animation_state().set_animation("Run/Run", true, 0)
	
	sfx_walk.play() # Inicia sonido de pasos
	
	var tween_marcha = create_tween()
	tween_marcha.tween_property(prota, "global_position:x", centro_x + 1200.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween_marcha.finished
	
	sfx_walk.stop() # Deja de caminar
	prota.queue_free()
	
	# =========================================================
	# ACTO 6: TV rápida
	# =========================================================
	tv_effect.show()
	tv_effect.play()
	await get_tree().create_timer(0.4).timeout
	
	# =========================================================
	# ACTO 7 y 8: Botón y Zoom Inmediato
	# =========================================================
	tv_effect.hide()
	tv_effect.stop()
	false_button.show()
	main_camera.global_position = false_button.global_position
	main_camera.zoom = Vector2(2.5, 2.5)
	
	var duracion_descenso = 20.0
	var tween_descenso = create_tween().set_parallel(true)
	tween_descenso.tween_property(main_camera, "zoom", Vector2(0.2, 0.2), duracion_descenso).set_trans(Tween.TRANS_SINE)
	tween_descenso.tween_property(main_camera, "global_position:y", false_button.global_position.y + 2500.0, duracion_descenso).set_trans(Tween.TRANS_SINE)
	
	# =========================================================
	# ACTO 9: Horda masiva + SFX caminar continuo
	# =========================================================
	await get_tree().create_timer(5.0).timeout
	
	sfx_walk.play() # Los pasos de la horda se mantienen hasta el fin
	_spawn_horde()
	
	await get_tree().create_timer(15.0).timeout
	
	# =========================================================
	# ACTO 10: Fin + FADE OUT MÚSICA
	# =========================================================
	fade_negro.position = Vector2.ZERO
	fade_negro.color.a = 0.0
	
	var tween_fin = create_tween().set_parallel(true)
	# Fade a negro de la pantalla
	tween_fin.tween_property(fade_negro, "color:a", 1.0, 4.0)
	# Fade out de la música bajando el volumen a -80dB (silencio)
	tween_fin.tween_property(music_player, "volume_db", -80.0, 4.0)
	
	await tween_fin.finished
	
	sfx_walk.stop()
	music_player.stop()
	print("FIN. GRACIAS POR JUGAR.")

func _spawn_horde() -> void:
	if not false_button: return
	var btn_pos = false_button.global_position
	var delay_entre_spawns = 0.5 
	var workers_lanzados = 0
	
	for i in range(500):
		var zombie = worker_scene.instantiate()
		add_child(zombie)
		zombie.set_process(false)
		zombie.set_physics_process(false)
		zombie.can_be_dragged = false
		
		var angulo = randf_range(PI * 0.1, PI * 0.9) if randf() < 0.8 else randf_range(0, TAU)
		var distancia = randf_range(3000, 7000)
		zombie.global_position = btn_pos + Vector2(cos(angulo), sin(angulo)) * distancia
		zombie.z_index = randi_range(-5, 5)
		
		var spine = zombie.get_node("WorkerVisual")
		spine.get_animation_state().set_animation("Run/Run", true, 0)
		if btn_pos.x < zombie.global_position.x:
			spine.scale.x = -1
			
		var tiempo = randf_range(8.0, 15.0) 
		var tween = create_tween()
		tween.tween_property(zombie, "global_position", btn_pos, tiempo)
		tween.finished.connect(func():
			if is_instance_valid(spine):
				spine.get_animation_state().set_animation("IDLE", true, 0)
		)
		
		await get_tree().create_timer(delay_entre_spawns).timeout
		workers_lanzados += 1
		if workers_lanzados % 10 == 0 and delay_entre_spawns > 0.01:
			delay_entre_spawns *= 0.65
