class_name StatsSystem
extends RefCounted

signal stamina_changed(new_current: float, max: float)
signal health_changed(new_current: float, max: float)
signal exhausted # Emitted when stamina hits 0

var max_stamina: float = 100.0
var current_stamina: float = 100.0:
	set(value):
		var old_value = current_stamina
		current_stamina = clampf(value, 0, max_stamina)
		
		if old_value != current_stamina:
			stamina_changed.emit(current_stamina, max_stamina)
			
		if current_stamina <= 0 and old_value > 0:
			exhausted.emit()

var max_health: float = 100.0
var current_health: float = 100.0

func _init(start_max_stamina: float = 100.0):
	max_stamina = start_max_stamina
	current_stamina = max_stamina

func consume_stamina(amount: float) -> bool:
	if current_stamina <= 0:
		return false # Operation failed due to lack of stamina
	
	self.current_stamina -= amount
	return true

func restore_stamina(amount: float):
	self.current_stamina += amount
