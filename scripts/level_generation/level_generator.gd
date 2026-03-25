extends Node
class_name Level_Generator
# Written By: Gianni Coladonato
# Date Created / Modified: 25-03-2026 / 25-03-2026
@export var level_nodes: Vector2i # Length / Node Count
var col_index: int
var prev_room: Room
var last_rooms: Array[Room] = []

func _ready() -> void:
	_generate_level()

func _generate_level() -> void:
	# Create Starting Room
	col_index = 0
	var rm_start = _make_room("Start", col_index)
	prev_room = rm_start
	col_index += 1
	last_rooms.clear()
	# Run for total length
	for i in range(level_nodes.x):
		var rand_rooms = randi_range(1,3)
		for j in range(rand_rooms):
			var child_room = _make_room(("Room " + str(j)), col_index)
			prev_room._connect_to_room(child_room)
			if(i == level_nodes.x -1):
				last_rooms.append(child_room)
		col_index += 1
	# Create and Link End Room
	var rm_end = _make_room("End", col_index+1)
	for last_child in last_rooms:
		rm_end._connect_to_room(last_child)
	_print_graph(rm_start)

func _make_room(rm_name: String, col: int) -> Room:
	var room = Room.new()
	room.node_index.x = col
	room.room_name = rm_name
	return room

func _print_graph(start: Room) -> void:
	var visited: Dictionary = {}
	var queue: Array[Room] = [start]
	while queue.size() > 0:
		var room = queue.pop_front()
		if visited.has(room): continue
		visited[room] = true
		var parents = room.prev_rooms.map(func(r): return r.room_name)
		print("col %d | %s  ← [%s]" % [room.node_index.x, room.room_name, ", ".join(parents)])
		for next in room.next_rooms:
			queue.append(next)

# For now, just assign a vector2i to the level nodes
# (Factors such as difficulty and level count will affect generation)
func _init_level_nodes(nodes: Vector2i) -> void:
	level_nodes = nodes
