extends Control

@onready var workers_counter = $WorkersCounter
@onready var money_counter = $MoneyCounter
@onready var empleados_label = $Empleados
@onready var upgrade_button = $UpgradeButton

var time_passed: float = 0.0

func _ready() -> void:
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)
	update_ui()

func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= 1.0:
		# El ingreso pasivo vuelve a ser 1 a 1 normal
		GlobalData.money += GlobalData.total_empleados
		time_passed -= 1.0
		update_ui()
		
func update_ui() -> void:
	workers_counter.text = str(GlobalData.workers_count) + "/" + str(GlobalData.workers_max) 
	money_counter.text = "$" + str(GlobalData.money)
	empleados_label.text = "EMPLEADOS: " + str(GlobalData.total_empleados)
	
	if GlobalData.upgrade_level < GlobalData.upgrade_costs.size():
		var next_cost = GlobalData.upgrade_costs[GlobalData.upgrade_level]
		upgrade_button.text = "MEJORA: $" + str(next_cost / 1000) + "k"
		
		if GlobalData.money >= next_cost:
			upgrade_button.disabled = false
		else:
			upgrade_button.disabled = true
	else:
		upgrade_button.text = "¡CONQUISTA TOTAL!"
		upgrade_button.disabled = true

func _on_upgrade_pressed() -> void:
	if GlobalData.upgrade_level < GlobalData.upgrade_costs.size():
		var cost = GlobalData.upgrade_costs[GlobalData.upgrade_level]
		
		if GlobalData.money >= cost:
			GlobalData.money -= cost
			GlobalData.upgrade_level += 1
			
			# Niveles de mejora
			if GlobalData.upgrade_level == 1:
				# Primera compra (50k)
				GlobalData.workers_max = 6
				
			elif GlobalData.upgrade_level == 2:
				# Segunda compra (170k)
				GlobalData.workers_max = 10
				
			elif GlobalData.upgrade_level == 3:
				# Tercera compra (360k) -> Final del juego
				get_tree().change_scene_to_file("res://Scenes/Ending.tscn")
				return
			
			update_ui()
		
		
		
