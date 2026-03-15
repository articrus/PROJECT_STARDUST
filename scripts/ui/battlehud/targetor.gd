extends Node2D
# Written By: Gianni Coladonato
# Date Created/Modificed: 08-11-2025 | 14-03-2026
var amplitude: float = 1.5
var frequency: float = 5
var time = 0
var targetor_offset: = Vector2(0, -10)
@export var fixed_position: Vector2 = Vector2(0,0)

func _process(delta: float) -> void:
	time += delta * frequency
	self.set_position(fixed_position + Vector2(0, sin(time) * amplitude))

func _cycle_targets(node : Node, delta: int, index: int) -> int:
	var targeting_index = index
	var child_count = node.get_child_count()
	targeting_index = (targeting_index + delta) % child_count
	if targeting_index < 0:
		targeting_index += child_count
	_adjust_targeting(node.get_child(targeting_index))
	return targeting_index

func _adjust_targeting(target: Node2D) -> void:
	fixed_position = target.global_position + targetor_offset
