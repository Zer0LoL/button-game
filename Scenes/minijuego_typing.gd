extends Node2D

@onready var type_text: RichTextLabel = $TypeText

var sentences: Array[String] = [
	"TYPE WITH ME.",
	"WORK IS GOOD.",
	"I LOVE WORKING.",
	"MONEY, MONEY, MONEY.",
	"MAXIMIZE GROWTH."
]

var current_sentence: String = ""
var current_char_index: int = 0
# In case of failure
var is_waiting: bool = false

#colors
var color_typed: String = "#39ff14" #verde brillante
var color_untyped: String = "#1b5e20" #verde oscuro


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_text.bbcode_enabled = true
	pick_new_sentence()

func pick_new_sentence() -> void:
	current_sentence = sentences.pick_random()
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
	
	# Verde oscuro
	type_text.text = "[color=" + color_untyped + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.1).timeout
	
	# Verde claro
	type_text.text = "[color=" + color_typed + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.05).timeout
	
	# Verde oscuro
	type_text.text = "[color=" + color_untyped + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.05).timeout
	
	# Verde claro (más tiempo)
	type_text.text = "[color=" + color_typed + "]" + current_sentence + "[/color]"
	await get_tree().create_timer(0.3).timeout
	
	pick_new_sentence()
	
func handle_mistake() -> void:
	is_waiting = true
	type_text.text = "[color=#ff0000]" + current_sentence + "[/color]"
	
	# 0.5s to update to new sentence
	await get_tree().create_timer(0.5).timeout 
	
	# New sentence
	pick_new_sentence()
