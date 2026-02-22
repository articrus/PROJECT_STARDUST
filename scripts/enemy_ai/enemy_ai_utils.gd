extends Node
class_name Enemy_AI_Utils
# Written By: Gianni Coladonato
# Date Created/Modificed: 27-01-2026 | 27-01-2026
# This class is used to store some simple functions to reduce the complexity of enemy ai scripts

static func _get_target_priority(actor) -> float: # Return a target's priority
	if !actor.char_stats.is_alive: # Down players are ignored
		return -10
	var score = 0.0
	# Marked targets take extra priority
	if actor.char_stats.is_marked:
		score += 2.0
	# Lower HP grants higher priority
	var ratio = actor.char_stats.hp.x / actor.char_stats.hp.y
	score += (1.0 - ratio) * 2
	return score

# Return attack target
static func _select_attack_target(party_node, intelligence) -> Node2D:
	var priorities = []
	var max_priority = 0
	for player in party_node.get_children():
		var weight = Enemy_AI_Utils._get_target_priority(player)
		priorities.append(weight)
		if weight > max_priority:
			max_priority = weight
	
	if max_priority <= 0:
		return party_node.get_child(randi() % party_node.get_child_count())
	
	# Normalize and blend randomness with intelligence
	for w in range(priorities.size()):
		var normalized = priorities[w] / max_priority
		priorities[w] = lerp(1.0, normalized, intelligence)
	
	return party_node.get_child(_choose_weighted(priorities))

# For selecting allies to buff/heal
static func _select_ally_target(enemies_node, intelligence, can_self: bool, self_ref) -> Node2D:
	var priorities = []
	var max_priority = 0
	for enemy in enemies_node.get_children():
		var weight = _get_ally_priority(enemy, can_self, self_ref)
		priorities.append(weight)
		if weight > max_priority:
			max_priority = weight
	if max_priority <= 0:
		return enemies_node.get_child(randi() % enemies_node.get_child_count())
	# Normalize and blend randomness with intelligence
	for w in range(priorities.size()):
		var normalized = priorities[w] / max_priority
		priorities[w] = lerp(1.0, normalized, intelligence)
	return enemies_node.get_child(_choose_weighted(priorities))
	
# Returns an ally's priority to recieve a buff
static func _get_ally_priority(actor, can_self: bool, self_ref) -> float:
	if actor == self_ref and !can_self: 
		return -10 # Target cannot be self
	var score = 0.0
	score += actor.char_stats.rank * 2 # Higher ranking enemies have more priority
	var ratio = actor.char_stats.hp.x / actor.char_stats.hp.y
	score += ratio # Higher HP targets have more priority
	# Add a heirarchy rank so more important targets get priority (bosses and such)
	return score

# Return the chosen target from the weights (Write a better explanation for clarity)
static func _choose_weighted(weights) -> int:
	var total = 0.0
	for weight in weights:
		total += weight
	var roll = randf() * total
	var accum = 0.0
	for i in range(weights.size()):
		accum += weights[i]
		if roll <= accum:
			return i
	return weights.size() - 1
