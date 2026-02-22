extends Enemy_AI
class_name Support_AI
# Written By: Gianni Coladonato
# Date Created / Modified: 27-01-2026 / 28-01-2026
# 1: Always pick ideal target, 0.5: 50/50, 0.0: Random
@export var ranking: int = 0 # Higher ranking enemies more likely to be buffed
@export var intelligence: float = 0.0
@export var attack: Skill
@export var signature_skill: Skill
@export var skill_list: Array[Skill]
@export var cooldown:= Vector2i(0, 2) # Current/Duration
@export var can_buff_self: bool = false # Can target self with buff skills

func _make_decision(_party_node: Node2D, enemies_node: Node2D) -> enums.ENEMY_CHOICE:
	#Check if this enemy is the last one
	if enemies_node.get_child_count() == 1:
		return enums.ENEMY_CHOICE.ATTACK # Attack if the last enemy
	elif cooldown.x == 0:
		cooldown.x = cooldown.y # Initiate cooldown
		return enums.ENEMY_CHOICE.SIG_SKILL # Signature skill
	else:
		return enums.ENEMY_CHOICE.SKILL # Any other skill from the skill list

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
