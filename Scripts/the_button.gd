extends Area2D

@export var spine_sprite: SpineSprite
@onready var anime_state: SpineAnimationState = spine_sprite.get_animation_state()

var is_hovering = false
var is_pressed_down = false
var can_click = true 

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	anime_state.set_animation("IDLE Up", true, 0)

func _process(delta):
	if is_hovering and can_click:
		var mouse_pos = get_local_mouse_position()
		var tilt_amount = clamp(mouse_pos.x / 100.0, -1.0, 1.0) 
		spine_sprite.rotation = lerp(spine_sprite.rotation, tilt_amount * deg_to_rad(2.5), 10 * delta)
	else:
		spine_sprite.rotation = lerp(spine_sprite.rotation, 0.0, 10 * delta)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and can_click:
			is_pressed_down = true
			can_click = false # Se bloquea
			
			
			var entry = anime_state.set_animation("Touch Down", false, 0)
			entry.set_time_scale(2.5) 

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_pressed_down:
			is_pressed_down = false
			_release_button()

func _release_button():
	var entry_up = anime_state.set_animation("Touch Up", false, 0)
	entry_up.set_time_scale(2.5)
	
	
	var entry_idle = anime_state.add_animation("IDLE Up", 0.0, true, 0)
	entry_idle.set_time_scale(1.0)
	
	var main_node = get_tree().current_scene
	if main_node.has_method("button_clicked"):
		main_node.button_clicked()


func unlock_button():
	can_click = true
	
func _on_mouse_entered():
	is_hovering = true

func _on_mouse_exited():
	is_hovering = false
