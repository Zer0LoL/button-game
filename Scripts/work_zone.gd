extends Area2D

@onready var sprite = $Sprite2D
@onready var pointer = $Pointer

var is_occupied = false

func _ready():
	modulate.a = 0 
	

	var random_index = randi() % 5 
	sprite.texture = load("res://Assets/Art/zones/work zone " + str(random_index) + ".png")

func show_zone():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func toggle_pointer(show: bool):
	if not is_occupied:
		if show and not pointer.visible:
			pointer.visible = true
			pointer.get_animation_state().set_animation("IDLE", true, 0)
		elif not show and pointer.visible:
			pointer.visible = false
