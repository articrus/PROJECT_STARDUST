extends Resource
class_name Enemy_Brain
# Written By: Gianni Coladonato
# Date Created / Modified: 09-11-2025 / 27-01-2026
@export var skill_weight: int = 0
@export var attack_weight: int = 0
# 1: Always pick ideal target, 0.5: 50/50, 0.0: Random
@export var intelligence: float = 0.0
var chosen_action: enums.ENEMY_CHOICE

func _make_decision() -> enums.ENEMY_CHOICE:
	var total_weight = attack_weight + skill_weight
	if total_weight == 0:
		return enums.ENEMY_CHOICE.NONE
	# Choose between attack and skill
	var roll = randi_range(1, total_weight)
	if roll <= attack_weight:
		return enums.ENEMY_CHOICE.ATTACK
	elif roll <= attack_weight + skill_weight:
		return enums.ENEMY_CHOICE.SKILL
	else:
		return enums.ENEMY_CHOICE.NONE

func _get_enemy_skill(actor) -> Skill:
	var skill_int = randi_range(0, actor.char_stats.skill_list.size()-1)
	return actor.char_stats.skill_list[skill_int]

# For selecting enemies to attack
func _select_attack_target(party_node, _enemies_node) -> Node2D:
	return Enemy_AI_Utils._select_attack_target(party_node, intelligence)

# For selecting allies to buff/heal
func _select_ally_target(_party_node, enemies_node, can_self: bool) -> Node2D:
	return Enemy_AI_Utils._select_ally_target(enemies_node, intelligence, can_self, self)
