extends Passive_Effect
class_name HP_Increase

@export var HP: int

func _apply_boost(actor: Character):
	actor.hp.x += HP
	actor.hp.y += HP
