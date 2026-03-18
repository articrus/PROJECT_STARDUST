extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 20-10-2025 / 18-11-2025
# Positions saved here
@onready var rank_one = $"Rank 1"
@onready var rank_two = $"Rank 2"
@onready var rank_three = $"Rank 3"
@onready var rank_four = $"Rank 4"
var ranks
@onready var is_occupied = [false, false, false, false]

func _ready() -> void:
	ranks = [rank_one, rank_two, rank_three, rank_four]

func _change_target_position(chara, new_position, players_node):
	var signals := []
	if !is_occupied[new_position]:
		is_occupied[chara.char_stats.rank] = false
		chara.char_stats.rank = new_position
		var sig = _tween_move(chara, ranks[new_position].global_position)
		signals.append(sig)
		is_occupied[new_position] = true
	else:
		var has_switched = false
		for player in players_node.get_children():
			if(player.char_stats.rank == new_position && !has_switched):
				var old_rank = chara.char_stats.rank 
				is_occupied[old_rank] = false
				is_occupied[new_position] = false
				player.char_stats.rank = old_rank
				chara.char_stats.rank = new_position
				is_occupied[old_rank] = true
				is_occupied[new_position] = true
				var sig1 = _tween_move(player, ranks[old_rank].global_position)
				var sig2 = _tween_move(chara, ranks[new_position].global_position)
				signals.append(sig1)
				signals.append(sig2)
				has_switched = true
				break
	return signals

func _tween_move(node: Node2D, target_pos: Vector2, duration:= 0.3):
	var tween := get_tree().create_tween()
	tween.tween_property(node, "global_position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween.finished

func _init_positions(chara, new_position):
	chara.char_stats.rank = new_position
	chara.global_position = ranks[new_position].global_position
	is_occupied[new_position] = true
