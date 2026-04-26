extends Node

var workers_count: int = 0
# workers_max empieza en 4 y ahora lo cambiarán las mejoras
var workers_max: int = 4 

var last_minigame: String = ""
var completed_minigames: int = 0
var total_empleados: int = 0
var money: int = 0

# Mejoras
var upgrade_level: int = 0
var upgrade_costs: Array[int] = [5000, 10000, 20000]
