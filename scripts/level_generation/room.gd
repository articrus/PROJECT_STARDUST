extends Node
# Written By: Gianni Coladonato
# Date Created / Modified: 25-03-2026 / 25-03-2026
@export var node_index: Vector2i # Column, Row
@export var node_paths: Array[enums.PATHS] = []

func _init_values(col: int, row: int, paths: Array[enums.PATHS]) -> void:
	node_index = Vector2i(col, row)
	node_paths = paths
