extends Resource
class_name Passive
# Written By: Gianni Coladonato
# Date Created / Modified : 22-04-2026 / 22-04-2026
@export var pass_name: String = "Passive Name"
@export var pass_description: String = "Passive Description"
@export var category: enums.PASSIVE_CATEGORIES
@export var passive_boosts: Array[Passive_Effect]

# Mainly for hp/ability increase
func _set_passive_boost(actor: Character) -> void:
	for boost in passive_boosts:
		boost._apply_boost(actor) #Check to see if this affects the actor

# For returning active boosts for damage/healing
func _return_boost(actor: Character) -> int:
	var total = 1;
	for boost in passive_boosts:
		total += boost._apply_boost(actor)
	return total
