extends Node
# Written By: Gianni Coladonato
# Date Created/Modificed: 17-03-2026 | 17-03-2026
@onready var turn_change = $TurnChange
@onready var battle_end = $EndTimer
var battle_manager

func _connect_to_battle_manager(manager) -> void:
	battle_manager = manager

func _on_turn_change_timeout() -> void:
	battle_manager._end_turn()

func _on_end_timer_timeout() -> void:
	Signalbus.end_encounter.emit()
