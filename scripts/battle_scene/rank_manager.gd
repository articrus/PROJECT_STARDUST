extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 20-10-2025 / 25-04-2026
@onready var player_container = $Players
@onready var enemy_container = $Enemies
var player_ranks = []
var enemy_ranks = []

func _ready() -> void:
	_init_ranks()

func _init_ranks() -> void:
	for rank in player_container.get_children():
		player_ranks.append(rank)
	for rank in enemy_container.get_children():
		enemy_ranks.append(rank)

func _init_positions(chara, new_position, is_player: bool):
	if is_player:
		chara.char_stats.rank = new_position
		chara.global_position = player_ranks[new_position].global_position
	else:
		chara.char_stats.rank = new_position
		chara.global_position = enemy_ranks[new_position].global_position
