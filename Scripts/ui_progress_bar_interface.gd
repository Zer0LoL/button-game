extends Control

@onready var progress_bar: ColorRect = $UIRect/ProgressBar
@onready var word1: Label = $UIRect/WordCenter/Word1
@onready var word2: Label = $UIRect/WordCenter/Word2
@onready var word3: Label = $UIRect/WordCenter/Word3

var current_progress: float = 0.0 
var max_width: float = 0.0 


var passive_fill_rate: float = 3.33 

var current_words: Array = []
var phase: int = 0 

func _ready() -> void:
	word1.modulate.a = 0
	word2.modulate.a = 0
	word3.modulate.a = 0
	
	max_width = $UIRect.size.x
	progress_bar.size.x = 0
	
	load_words_from_json()

func load_words_from_json() -> void:
	var file = FileAccess.open("res://Assets/Meta/ensourage words.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.parse_string(json_string)
		if json and json.has("words"):
			var random_group = json["words"].pick_random()
			word1.text = random_group[0].to_upper()
			word2.text = random_group[1].to_upper()
			word3.text = random_group[2].to_upper()
	else:
		print("Error: No se encontró el JSON de palabras")

func _process(delta: float) -> void:
	if current_progress < 100.0:
		current_progress += passive_fill_rate * delta
		_update_bar_visuals()

func add_progress(amount: float) -> void:
	current_progress = clamp(current_progress + amount, 0.0, 100.0)
	_update_bar_visuals()

func lose_progress(amount: float) -> void:
	current_progress = clamp(current_progress - amount, 0.0, 100.0)
	_update_bar_visuals()

func _update_bar_visuals() -> void:
	var target_width = (current_progress / 100.0) * max_width
	
	progress_bar.size.x = lerp(progress_bar.size.x, target_width, 0.3)
	
	check_phases()

func check_phases() -> void:
	if current_progress >= 25.0 and phase == 0:
		phase = 1
		show_word_1()
	elif current_progress >= 50.0 and phase == 1:
		phase = 2
		show_word_2()
	elif current_progress >= 75.0 and phase == 2:
		phase = 3
		show_word_3()
	elif current_progress >= 100.0 and phase == 3:
		phase = 4
		print("¡Minijuego Completado! Barra llena.")

func show_word_1() -> void:
	var tween = create_tween()
	
	word1.scale = Vector2(1.2, 1.2)
	tween.tween_property(word1, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(word1, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)

func show_word_2() -> void:
	var tween = create_tween()
	
	tween.tween_property(word1, "position:y", word1.position.y - 85, 0.4)
	tween.parallel().tween_property(word1, "scale", Vector2(0.7, 0.7), 0.4)
	tween.parallel().tween_property(word1, "modulate:a", 0.6, 0.4)
	
	word2.scale = Vector2(1.2, 1.2)
	tween.parallel().tween_property(word2, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(word2, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)

func show_word_3() -> void:
	var tween = create_tween()
	
	tween.tween_property(word1, "position:x", word1.position.x - 150, 0.4)
	tween.parallel().tween_property(word1, "scale", Vector2(0.45, 0.45), 0.4)
	tween.parallel().tween_property(word1, "modulate:a", 0.3, 0.4)
	
	tween.parallel().tween_property(word2, "position:y", word2.position.y - 85, 0.4)
	tween.parallel().tween_property(word2, "scale", Vector2(0.7, 0.7), 0.4)
	tween.parallel().tween_property(word2, "modulate:a", 0.6, 0.4)
	
	word3.scale = Vector2(1.2, 1.2)
	tween.parallel().tween_property(word3, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(word3, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
