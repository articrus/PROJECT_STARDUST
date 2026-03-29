extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 29-03-2026 / 29-03-2026
@export var x_offset: int = 50
@export var y_offset: Array[int] = [-50, 0, 50]
@onready var test_tile = load("res://areas/test_tile.tscn")
var row_column: int = 1

func _ready() -> void:
	Signalbus.temp_pass_level.connect(_layout_level)

func _layout_level(starting_room: Room) -> void:
	var rooms_queue: Array[Room] = [starting_room]
	var rooms_visited: Dictionary = {}
	while rooms_queue.size() > 0:
		var current_room = rooms_queue.pop_front()
		# Making sure we haven't visited this room before
		if rooms_visited.has(current_room): continue
		rooms_visited[current_room] = true
		# Creating the room tile
		var room_tile = test_tile.instantiate()
		room_tile.global_position = Vector2i(x_offset * current_room.node_index.x, y_offset[row_column])
		add_child(room_tile)
		_increment_row_tile()
		# Add next room to rooms_queue
		for room in current_room.next_rooms:
			rooms_queue.append(room)

func _increment_row_tile() -> void:
	row_column += 1
	if row_column >= 3:
		row_column = 0
