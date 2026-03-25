extends Node
class_name Room
# Written By: Gianni Coladonato
# Date Created / Modified: 25-03-2026 / 25-03-2026
@export var room_name: String
@export var node_index: Vector2i # Column, Row
@export var next_rooms: Array[Room]
@export var prev_rooms: Array[Room]

func _connect_to_room(other: Room) -> void:
	next_rooms.append(other)
	other.prev_rooms.append(self)
