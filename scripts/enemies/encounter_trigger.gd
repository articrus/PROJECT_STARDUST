extends Area2D

func _on_area_entered(_area) -> void:
	Signalbus.trigger_encounter.emit()
