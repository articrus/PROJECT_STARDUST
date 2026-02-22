extends Node2D
# Written By: Gianni Coladonato
# Date Created/Modificed: 08-11-2025 | 08-11-025
var amplitude: float = 1.5
var frequency: float = 5
var time = 0
@export var fixed_position: Vector2 = Vector2(0,0)

func _process(delta: float) -> void:
	time += delta * frequency
	self.set_position(fixed_position + Vector2(0, sin(time) * amplitude))
