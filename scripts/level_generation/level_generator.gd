extends Node
class_name Level_Generator
# Written By: Gianni Coladonato
# Date Created / Modified: 25-03-2026 / 29-03-2026
@export var level_nodes: Vector2i = Vector2i(3, 5)# Length / Node Count
var col_index: int
var prev_rooms: Array[Room] = []
var curr_rooms: Array[Room] = []

func _ready() -> void:
	_generate_level()

func _generate_level() -> void:
	# Create Starting Room
	col_index = 0
	var rm_start = _make_room("Start", col_index, 0)
	prev_rooms.append(rm_start)
	col_index += 1
	# Run for total length
	for i in range(level_nodes.x):
		var rand_rooms = randi_range(1,3)
		curr_rooms.clear()
		for j in range(rand_rooms):
			var child_room = _make_room(("Room " + str(j)), col_index, j)
			curr_rooms.append(child_room)
		for prev in prev_rooms:
			for curr in curr_rooms:
				prev._connect_to_room(curr)
		prev_rooms = curr_rooms.duplicate()
		col_index += 1
	# Create and Link End Room
	var rm_end = _make_room("End", col_index, 0)
	for prev in prev_rooms:
		prev._connect_to_room(rm_end)
	_print_graph(rm_start)
	Signalbus.temp_pass_level.emit(rm_start)

func _connect_rooms_array(current: Room, last_array: Array[Room]):
	for last_child in last_array:
		current._connect_to_room(last_child)

func _make_room(rm_name: String, col: int, row: int) -> Room:
	var room = Room.new()
	room.node_index = Vector2i(col, row)
	room.room_name = rm_name
	return room

func _print_graph(start: Room) -> void:
	var visited: Dictionary = {}
	var queue: Array[Room] = [start]
	var cols: Dictionary = {}
	while queue.size() > 0:
		var room = queue.pop_front()
		if visited.has(room): continue
		visited[room] = true
		var col = room.node_index.x
		if not cols.has(col):
			cols[col] = []
		cols[col].append(room.room_name)
		for next in room.next_rooms:
			queue.append(next)
	
	var col_width = 12
	var sorted_keys = cols.keys()
	sorted_keys.sort()
	var header = ""
	for col in sorted_keys:
		var label = "Col %d" % col
		header += lfit(label, col_width)
	print(header)
	print("-".repeat(col_width * sorted_keys.size()))
	var max_rows = 0
	for col in sorted_keys:
		max_rows = max(max_rows, cols[col].size())
	for row in range(max_rows):
		var line = ""
		for col in sorted_keys:
			if row < cols[col].size():
				line += lfit(cols[col][row], col_width)
			else:
				line += " ".repeat(col_width)
		print(line)

func lfit(s: String, width: int) -> String:
	if s.length() >= width:
		return s.substr(0, width)
	return s + " ".repeat(width - s.length())

# For now, just assign a vector2i to the level nodes
# (Factors such as difficulty and level count will affect generation)
func _init_level_nodes(nodes: Vector2i) -> void:
	level_nodes = nodes
