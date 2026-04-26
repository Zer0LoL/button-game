extends Area2D

signal atrapado

@onready var spine_sprite = $SpineSprite # Referencia a tu SpineSprite

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	
	if spine_sprite and spine_sprite.get_skeleton():
		spine_sprite.get_animation_state().set_animation("IDLE Body", true, 0)
		spine_sprite.get_animation_state().set_animation("IDLE Eye", true, 1)

	# Desfasamos un poco el inicio para que no todos floten sincronizados
	var tiempo_flote = randf_range(0.8, 1.2) 
	
	# Creamos un Tween que se repite infinitamente
	var tween = create_tween().set_loops()
	
	# Sube 20 píxeles usando una curva suave
	tween.tween_property(spine_sprite, "position:y", -20.0, tiempo_flote).as_relative().set_trans(Tween.TRANS_SINE)
	# Baja 20 píxeles
	tween.tween_property(spine_sprite, "position:y", 20.0, tiempo_flote).as_relative().set_trans(Tween.TRANS_SINE)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "LineaJugador":
		atrapado.emit() 
		queue_free() 

func _on_screen_exited() -> void:
	# Obtenemos la cámara actual de la escena
	var camara = get_viewport().get_camera_2d()
	
	if camara:
		# Solo nos destruimos si nuestra posición X está MÁS ATRÁS (izquierda) que la cámara
		if global_position.x < camara.global_position.x:
			queue_free()
