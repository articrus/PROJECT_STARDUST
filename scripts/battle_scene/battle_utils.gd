extends Node
class_name Battle_Utils
# Written By: Gianni Coladonato
# Date Created/Modificed: 09-11-2025 | 17-04-2026
# This class is used to store some simple functions to reduce the complexity of the battle_manager script

# Return a valid target for skills and attacks (FIXXXX)
static func _get_valid_target(skill, choice_data):
	var target = choice_data.Target
	var single_target_types = [enums.TARGET.ENEMY, enums.TARGET.ALLY, enums.TARGET.SELF]
	if skill.skill_target in single_target_types:
		if not _check_if_is_alive(target):
			return null
	if is_instance_valid(target):
		return target
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
	return party_node.get_children().all(func(p): return !p.char_stats.is_alive)

static func _sort_turn_order_values(a,b):
	return a.Value < b.Value

static func _position_players(rank_manager: Node2D, enemy_rank_manager: Node2D, party_node: Node2D, enemies_node: Node2D):
	for i in party_node.get_child_count():
		var player = party_node.get_child(i)
		rank_manager._init_positions(player, i)
		player._enter_battle()
	for i in enemies_node.get_child_count():
		var enemy = enemies_node.get_child(i)
		enemy_rank_manager._init_positions(enemy, i)

static func _save_player_data(party_node):
	for player in party_node.get_children():
		if !player.char_stats.is_alive:
			player.char_stats._heal(1)
	GameManager._save_and_pass_data(party_node)
