extends Node2D 

func _ready() -> void:
	MusicManager.play_basket_music()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
