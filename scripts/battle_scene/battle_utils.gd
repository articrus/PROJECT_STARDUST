extends Node
class_name Battle_Utils
# Written By: Gianni Coladonato
# Date Created/Modificed: 09-11-2025 | 12-02-2026
# This class is used to store some simple functions to reduce the complexity of the battle_manager script

# Return a valid target for skills and attacks
static func _get_valid_target(skill, choice_data):
	var target = choice_data.Target
	if skill.skill_target == enums.TARGET.ENEMY: # Check if targeting a single enemy
		if not Battle_Utils._check_if_is_alive(target):
			return null
	if is_instance_valid(target):
		return target
	else:
		return null

# Is valid still applies when waiting for death, let's see if is_alive is a good marker
static func _check_if_is_alive(target) -> bool:
	if !is_instance_valid(target):
		return false
	return target.char_stats.is_alive

# Return the target(s) of an enemy skill
static func _get_skill_target(targeting, enemy, party_node, enemies_node) -> Node2D:
	var target = null
	match targeting:
		enums.TARGET.ALLY:
			target = enemy.enemy_brain._select_ally_target(enemies_node)
		enums.TARGET.ENEMY:
			target = enemy.enemy_brain._select_attack_target(party_node, enemies_node)
		enums.TARGET.ALL_ENEMIES:
			target = party_node
		enums.TARGET.ALL_ALLIES:
			target = enemies_node
		enums.TARGET.SELF:
			target = enemy
		enums.TARGET.ALLY_NOT_SELF:
			target = enemy.enemy_brain._select_ally_target(enemies_node)
	return target

# For use with selection functions
static func _handle_section_input(on_up : Callable, on_down: Callable, on_confirm: Callable, on_cancel: Callable ):
	if(Input.is_action_just_pressed("move_up") || Input.is_action_just_pressed("move_right")):
		on_up.call()
	elif(Input.is_action_just_pressed("move_down") || Input.is_action_just_pressed("move_left")):
		on_down.call()
	elif Input.is_action_just_pressed("interact"):
		on_confirm.call()
	elif Input.is_action_just_pressed("cancel"):
		on_cancel.call()

static func _check_if_no_enemies_remain(enemies_node) -> bool:
	return enemies_node.get_child_count() == 0

static func _check_if_all_players_downed(party_node) -> bool:
	var checker = 0
	for player in party_node.get_children():
		if !player.char_stats.is_alive:
			checker += 1
	return checker == party_node.get_child_count()

static func _sort_turn_order_values(a,b):
	return a.Value < b.Value

static func _get_skill_cost(skill: Skill) -> int:
	return skill.cost

static func _position_players(rank_manager: Node2D, enemy_rank_manager: Node2D, party_node: Node2D, enemies_node: Node2D):
	var index = 0
	for player in party_node.get_children():
		rank_manager._init_positions(player, index)
		player._enter_battle()
		index += 1
	index = 0
	for enemy in enemies_node.get_children():
		enemy_rank_manager._init_positions(enemy, index)
		index += 1

static func _save_player_data(party_node):
	for player in party_node.get_children():
		if !player.char_stats.is_alive:
			player.char_stats._heal(1)
		GameManager._save_player_data_from_node(player)
