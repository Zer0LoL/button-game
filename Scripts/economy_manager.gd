extends Control 

var money: int = 0
var milestones: Array[int] = [
	50, # k
	170 # k
]

@onready var workers_counter: RichTextLabel = $WorkersCounter
@onready var money_counter: RichTextLabel = $MoneyCounter
@onready var promotion_counter: RichTextLabel = $Promotion

var time_passed: float = 0.0

func _ready() -> void:
	hide() 
	update_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= 1.0:
		money += GameManager.workers_count 
		time_passed -= 1.0
		update_ui()
		
func update_ui() -> void:
	workers_counter.text = str(GameManager.workers_count) + "/" + str(GameManager.workers_max) 
	money_counter.text = "$" + str(money)
		
		
		
		
		
		
