extends Control 
var workers: int = 0 # ¡Cambiamos esto a 0!
var money: int = 0

@onready var workers_counter: RichTextLabel = $WorkersCounter
@onready var money_counter: RichTextLabel = $MoneyCounter

var time_passed: float = 0.0

func _ready() -> void:
	hide() 
	update_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= 1.0:
		money += workers # Añade 1$ por cada trabajador
		time_passed -= 1.0
		update_ui()
		
func update_ui() -> void:
	workers_counter.text = str(workers) + "/10" 
	money_counter.text = "$" + str(money)
		
		
		
		
		
		
