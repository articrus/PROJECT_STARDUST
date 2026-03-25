extends Node
class_name Level_Generator
# Written By: Gianni Coladonato
# Date Created / Modified: 25-03-2026 / 25-03-2026
@export var level_nodes: Vector2i # Length / Node Count

func _generate_level() -> void:
	# Create Starting Room
	for i in range(level_nodes.x):
		print("#")
	# Create End Room

# For now, just assign a vector2i to the level nodes
# (Factors such as difficulty and level count will affect generation)
func _init_level_nodes(nodes: Vector2i) -> void:
	level_nodes = nodes
