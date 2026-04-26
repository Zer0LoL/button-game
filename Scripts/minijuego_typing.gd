extends Node2D

@onready var type_text: RichTextLabel = $TypeText
@onready var progress_bar = $BackgroundLayer/UiProgressBarInterface

var intro_text: String = "TYPE WITH ME."

var sentences: Array[String] = [
	"WORK IS GOOD.",
	"I LOVE WORKING.",
	"WORK LIKE MACHINES.",
	"MAXIMIZE GROWTH.",
	"BOSS IS THE BEST.",
	"LOVING THE WORK.",
	"ONLY THE BEST."
]

var current_sentence: String = ""
var current_char_index: int = 0
# In case of failure
var is_waiting: bool = true # start with true for prep text

#colors
var color_typed: String = "#39ff14" #verde brillante
var color_untyped: String = "#1b5e20" #verde oscuro


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_text.bbcode_enabled = true
	play_intro()
	
func play_intro() -> void:
	# clean TypeText
	type_text.text = ""
	type_text.modulate.a = 1.0 
	
	# Typewriter effect for intro
	for i in range(intro_text.length()):
		type_text.text += intro_text[i]
		
		if intro_text[i] != " ":
			SFXManager.play_random_type_sound()
			
		# Pause between characters
		await get_tree().create_timer(0.1).timeout 
		
	# Pause to read
	await get_tree().create_timer(1.2).timeout
	
	# Fadeout
	var tween = create_tween()
	# animate opacity
	tween.tween_property(type_text, "modulate:a", 0.0, 0.5)
	
	# wait opacity 0
	await tween.finished
	
	# restore opacity
	type_text.modulate.a = 1.0 
	pick_new_sentence()

func pick_new_sentence() -> void:
	var next_sentence: String = current_sentence
	
	# El bucle se repite hasta que la nueva oración sea distinta a la actual
	while next_sentence == current_sentence:
		next_sentence = sentences.pick_random()
		
	# Una vez que tenemos una oración diferente, la asignamos
	current_sentence = next_sentence
	current_char_index = 0
	is_waiting = false
	update_text_display()

func update_text_display() -> void:
	# Cut sentence to type and untyped
	var typed_part: String = current_sentence.substr(0, current_char_index)
	var untyped_part: String = current_sentence.substr(current_char_index)
	
	# Se unen de nuevo
	type_text.text = "[color=" + color_typed + "]" + typed_part + "[/color]" + \
					 "[color=" + color_untyped + "]" + untyped_part + "[/color]"

func _unhandled_input(event: InputEvent) -> void:
	# check failure pause
	if is_waiting:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		# Obtains character
		var typed_char: String = String.chr(event.unicode)
		
		# No special characters
		if typed_char == "":
			return
			
		var expected_char: String = current_sentence[current_char_index]
		SFXManager.play_random_type_sound()
		# mayus & minus check
		if typed_char.to_lower() == expected_char.to_lower():
			current_char_index += 1
			update_text_display() # Se actualizan los colores letra por letra
			
			if current_char_index >= current_sentence.length():
				handle_success() # ¡Escribió toda la oración!
		else:
			handle_mistake()

func handle_success() -> void:
	is_waiting = true
	if progress_bar:
		progress_bar.add_progress(6.0)
	type_text.text = "[color=" + color_untyped + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.1).timeout
	
	type_text.text = "[color=" + color_typed + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.05).timeout
	
	type_text.text = "[color=" + color_untyped + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.05).timeout
	
	# Verde claro (más tiempo)
	type_text.text = "[color=" + color_typed + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.3).timeout
	
	pick_new_sentence()
	
func handle_mistake() -> void:
	is_waiting = true
	
	if progress_bar:
		progress_bar.lose_progress(8.0) 
		
	type_text.text = "[color=#ff0000]" + current_sentence + "[/color]"
	
	await get_tree().create_timer(0.5).timeout 
	pick_new_sentence()
