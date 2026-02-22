extends Enemy_AI
class_name Normal_AI
# Written By: Gianni Coladonato
# Date Created / Modified: 27-01-2026 / 28-01-2026
@export var ranking: int = 0 # Higher ranking enemies more likely to be buffed
@export var skill_weight: int = 0
@export var attack_weight: int = 0
# 1: Always pick ideal target, 0.5: 50/50, 0.0: Random
@export var intelligence: float = 0.0
@export var attack: Skill # Default Attack
@export var skill_list: Array[Skill] # Other Skills that can be used
@export var can_buff_self: bool = false # Can target self with buff skills

func _make_decision(_party_node: Node2D, _enemies_node: Node2D) -> enums.ENEMY_CHOICE:
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

func _end_of_turn_check() -> void:
	pass

# For selecting enemies to attack
func _select_attack_target(party_node, _enemies_node) -> Node2D:
	return Enemy_AI_Utils._select_attack_target(party_node, intelligence)

# For selecting allies to buff
func _select_ally_target(enemies_node) -> Node2D:
	return Enemy_AI_Utils._select_ally_target(enemies_node, intelligence, can_buff_self, self)

func _get_enemy_skill() -> Skill:
	var skill_int = randi_range(0, skill_list.size()-1)
	return skill_list[skill_int]
