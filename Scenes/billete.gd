extends Area2D

# Definimos nuestras dos señales
signal caught
signal missed

@export var fall_speed: float = 400.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	
	if position.y > 1200.0:
		missed.emit() # Avisamos que falló
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("basket"):
		caught.emit() # Avisamos que lo atrapó
		queue_free()
