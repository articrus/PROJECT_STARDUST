extends Passive_Effect
class_name Ability_Increase

@export var M_ATK: int
@export var R_ATK: int
@export var SKLL: int

func _apply_boost(actor: Character):
	actor.abilities.x += M_ATK
	actor.abilities.y += R_ATK
	actor.abilities.y += SKLL
