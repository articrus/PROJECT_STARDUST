extends Enemy_AI
class_name Boss_AI
# Written By: Gianni Coladonato
# Date Created / Modified: 28-01-2026 / 30-01-2026
@export var ranking: int = 5 # Higher ranking enemies more likely to be buffed
@export var skill_weight: int = 0
@export var attack_weight: int = 0
# 1: Always pick ideal target, 0.5: 50/50, 0.0: Random
@export var intelligence: float = 0.0
@export var attack: Skill
@export var signature_skill: Skill
@export var skill_list: Array[Skill]
@export var special_end_skill: Skill # A special skill/legendary action that procs at the end of every turn
@export var cooldown:= Vector2i(0, 3) # Current/Duration
@export var can_buff_self: bool = false # Can target self with buff skills

func _make_decision(_party_node: Node2D, _enemies_node: Node2D) -> enums.ENEMY_CHOICE:
	if cooldown.x == 0: # Use signature skill if able
		cooldown.x = cooldown.y # Initiate cooldown
		return enums.ENEMY_CHOICE.SIG_SKILL # Signature skill
	
	var total_weight = attack_weight + skill_weight
	if total_weight == 0:
		return enums.ENEMY_CHOICE.NONE # Shouldn't occur
	# Choose between attack and skill
	var roll = randi_range(1, total_weight)
	if roll <= attack_weight:
		return enums.ENEMY_CHOICE.ATTACK
	elif roll <= attack_weight + skill_weight:
		return enums.ENEMY_CHOICE.SKILL
	else:
		return enums.ENEMY_CHOICE.NONE

func _end_of_turn_check() -> void:
	if cooldown.x > 0:
		cooldown.x -= 1

# For selecting enemies to attack
func _select_attack_target(party_node, _enemies_node) -> Node2D:
	return Enemy_AI_Utils._select_attack_target(party_node, intelligence)

# For selecting allies to buff
func _select_ally_target(enemies_node) -> Node2D:
	return Enemy_AI_Utils._select_ally_target(enemies_node, intelligence, can_buff_self, self)

func _get_enemy_skill() -> Skill:
	var skill_int = randi_range(0, skill_list.size()-1)
	return skill_list[skill_int]
